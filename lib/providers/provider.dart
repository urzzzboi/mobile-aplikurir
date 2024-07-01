import 'dart:async';
import 'dart:convert';
import 'package:aplikurir/api/api_service.dart';
import 'package:aplikurir/model/algoritma_astar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class OSMScreenProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> globalkey;
  final BuildContext context;
  final ApiService _ambilDataKurir = ApiService();
  late MapController mapController = MapController();
  final int idKurir;
  final AlgoritmaAStar _algoritmaAStar = AlgoritmaAStar();
  String _prediksiAlamat = '';
  List<dynamic> dataPengantaran = [];
  Map<String, dynamic>? dataPenerima;
  LatLng titikAwal = const LatLng(0.0, 0.0);
  LatLng lokasiAwal = const LatLng(0.0, 0.0);

  List<LatLng> titikTujuan = [];
  List<LatLng> listTitikTujuan2 = [];
  List<LatLng> listTitikTujuan3 = [];

  Polyline? jalurRute;
  bool _isLoading = true;
  bool _isLoading1 = true;
  bool _isDisposed = false;

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _pollingTimer;
  double _totalJarak = 0.0;
  String _waktuTempuh = '0';
  double _lastTotalJarak = 0.0;
  String _lastWaktuTempuh = '0';

  double _totalJarak2 = 0.0;
  String _waktuTempuh2 = '0';
  double _lastTotalJarak2 = 0.0;
  String _lastWaktuTempuh2 = '0';

  double _totalJarak3 = 0.0;
  String _waktuTempuh3 = '0';
  double _lastTotalJarak3 = 0.0;
  String _lastWaktuTempuh3 = '0';

  bool get isloading => _isLoading;
  bool get isloading1 => _isLoading1;
  String get prediksiAlamat => _prediksiAlamat;
  double get totalJarak => _lastTotalJarak;
  String get waktuTempuh => _lastWaktuTempuh;
  bool get cekDataPengantaran => dataPengantaran.isEmpty;

  double get totalJarak2 => _lastTotalJarak2;
  String get waktuTempuh2 => _lastWaktuTempuh2;

  double get totalJarak3 => _lastTotalJarak3;
  String get waktuTempuh3 => _lastWaktuTempuh3;

  OSMScreenProvider(this.globalkey, this.context, this.idKurir) {
    mapController = MapController();
    _memintaPerizinanLokasi().then((_) {
      _fetchDataPengantaran();
      _pollingTime();
    });
  }

  Future<void> _fetchDataPengantaran() async {
    try {
      dataPengantaran = await _ambilDataKurir.fetchDataPengantaran(idKurir);
      print('Data pengantaran berhasil diambil: $dataPengantaran');
      print(cekDataPengantaran);
      if (dataPengantaran.isEmpty) {
        print('Data tidak bisa diambil');
      }
    } catch (e) {
      print("Tidak bisa mengambil data: ${e.toString()}");
      print('Error: $e');
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> _fetchCoordinatesAndBuildRoute() async {
    List<LatLng> fetchedCoordinates =
        await _ambilDataKurir.fetchCoordinates(idKurir);
    fetchedCoordinates =
        _algoritmaAStar.urutkanDenganAStar(titikAwal, fetchedCoordinates);
    titikTujuan = [titikAwal, fetchedCoordinates[0]];

    _buatPolyline();
    _hitungTotalJarak();
    _lokasiAlamat(titikAwal);

    listTitikTujuan2 = [fetchedCoordinates[0], fetchedCoordinates[1]];
    _hitungTotalJarak2();

    listTitikTujuan3 = [fetchedCoordinates[1], fetchedCoordinates[2]];
    _hitungTotalJarak3();
  }

  Future<void> updateStatus(String status, String waktu, String tanggal,
      List<LatLng> titikTujuan, BuildContext context) async {
    try {
      final selectedData = dataPengantaran.firstWhere(
        (item) {
          double itemLatitude = item['latitude'];
          double itemLongitude = item['longitude'];
          return titikTujuan.any((latLng) =>
              latLng.latitude == itemLatitude &&
              latLng.longitude == itemLongitude);
        },
        orElse: () => null,
      );

      if (selectedData != null) {
        final response = await http.post(
          Uri.parse('${ApiService.url}/riwayat'),
          body: jsonEncode({
            'id_kurir': idKurir,
            'nomor_resi': selectedData['nomor_resi'],
            'Alamat_Tujuan': selectedData['Alamat_Tujuan'],
            'Nama_Penerima': selectedData['Nama_Penerima'],
            'nama_kurir': selectedData['nama_kurir'],
            'handphone_kurir': selectedData['handphone_kurir'],
            'email': selectedData['email'],
            'password': selectedData['password'],
            'status_pengiriman': status,
            'waktu_pengiriman': waktu,
            'tanggal_pengiriman': tanggal,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 201) {
          print('Status OK: $status');
          if (status == 'Selesai') {
            final id = selectedData['Id_pengantaran_paket'];
            final deleteResponse = await http.delete(
                Uri.parse('${ApiService.url}/dataPengantaran2/$id'),
                headers: {'Content-Type': 'application/json'});
            if (deleteResponse.statusCode == 200) {
              print('Data pengantaran paket berhasil dihapus.');
            } else {
              print(
                  'Gagal menghapus data pengantaran paket: ${deleteResponse.statusCode}');
            }
          }
          if (status == 'Gagal') {
            final id = selectedData['Id_pengantaran_paket'];
            final deleteResponse = await http.delete(
                Uri.parse('${ApiService.url}/dataPengantaran2/$id'),
                headers: {'Content-Type': 'application/json'});
            if (deleteResponse.statusCode == 200) {
              print('Data pengantaran paket berhasil dihapus.');
            } else {
              print(
                  'Gagal menghapus data pengantaran paket: ${deleteResponse.statusCode}');
            }
          }
        } else {
          print('Data tidak masuk karena: ${response.statusCode}');
        }
      } else {
        print('Data tidak ditemukan');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _hitungTotalJarak() async {
    _totalJarak = 0.0;
    for (int i = 0; i < titikTujuan.length - 1; i++) {
      final route = await _getRoute(titikTujuan[i], titikTujuan[i + 1]);
      if (route != null) {
        for (int j = 0; j < route.length - 1; j++) {
          _totalJarak += Geolocator.distanceBetween(
            route[j].latitude,
            route[j].longitude,
            route[j + 1].latitude,
            route[j + 1].longitude,
          );
        }
      }
    }
    _totalJarak /= 1000;

    _waktuTempuh = calculateTravelTime(_totalJarak, 30.0);

    if (_totalJarak != _lastTotalJarak || _waktuTempuh != _lastWaktuTempuh) {
      _lastTotalJarak = _totalJarak;
      _lastWaktuTempuh = _waktuTempuh;
      _isLoading1 = false;
      safeNotifyListeners();
    }
  }

  void _hitungTotalJarak2() async {
    _totalJarak2 = 0.0;
    for (int i = 0; i < listTitikTujuan2.length - 1; i++) {
      final route =
          await _getRoute(listTitikTujuan2[i], listTitikTujuan2[i + 1]);
      if (route != null) {
        for (int j = 0; j < route.length - 1; j++) {
          _totalJarak2 += Geolocator.distanceBetween(
            route[j].latitude,
            route[j].longitude,
            route[j + 1].latitude,
            route[j + 1].longitude,
          );
        }
      }
    }
    _totalJarak2 /= 1000;

    _waktuTempuh2 = calculateTravelTime(_totalJarak2, 30.0);

    if (_totalJarak2 != _lastTotalJarak2 ||
        _waktuTempuh2 != _lastWaktuTempuh2) {
      _lastTotalJarak2 = _totalJarak2;
      _lastWaktuTempuh2 = _waktuTempuh2;
      _isLoading1 = false;
      safeNotifyListeners();
    }
  }

  void _hitungTotalJarak3() async {
    _totalJarak3 = 0.0;
    for (int i = 0; i < listTitikTujuan3.length - 1; i++) {
      final route =
          await _getRoute(listTitikTujuan3[i], listTitikTujuan3[i + 1]);
      if (route != null) {
        for (int j = 0; j < route.length - 1; j++) {
          _totalJarak3 += Geolocator.distanceBetween(
            route[j].latitude,
            route[j].longitude,
            route[j + 1].latitude,
            route[j + 1].longitude,
          );
        }
      }
    }
    _totalJarak3 /= 1000;

    _waktuTempuh3 = calculateTravelTime(_totalJarak3, 30.0);

    if (_totalJarak3 != _lastTotalJarak3 ||
        _waktuTempuh3 != _lastWaktuTempuh3) {
      _lastTotalJarak3 = _totalJarak3;
      _lastWaktuTempuh3 = _waktuTempuh3;
      _isLoading1 = false;
      safeNotifyListeners();
    }
  }

  String calculateTravelTime(double jarak, double kecepatan) {
    double waktu = (jarak / kecepatan) * 60;
    return waktu.toStringAsFixed(0);
  }

  void _pollingTime() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isDisposed) {
        _fetchDataPengantaran();
      }
    });
  }

  Future<void> _memintaPerizinanLokasi() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied || status.isGranted) {
      if (await Permission.location.request().isGranted) {
        await _ambilPosisiTengah();
      } else if (status.isDenied) {
        print('Izin Lokasi ditolak');
      } else if (status.isPermanentlyDenied) {
        print('Izinkan Lokasi terlebih dahulu');
      }
    }
  }

  Future<void> _ambilPosisiTengah() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Lokasi dinonaktifkan");
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Akses Lokasi Ditolak");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("Akses Lokasi Ditolak secara Permanen");
      return;
    }
    try {
      Position posisiSekarang = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      titikAwal = LatLng(posisiSekarang.latitude, posisiSekarang.longitude);
      print('Posisi sekarang: $titikAwal');
      await _fetchCoordinatesAndBuildRoute();
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen((Position posisiSekarang) {
        _updateCurrentLocation(posisiSekarang);
      });
      safeNotifyListeners();
    } catch (e) {
      print("Tidak bisa ambil tengah karena $e");
    }
  }

  void handlePositionChange(MapCamera latLng, bool hasGesture) {
    print('Current Location: $lokasiAwal, New Location: ${latLng.center}');
    if (lokasiAwal != latLng.center) {
      lokasiAwal = latLng.center;
      print('Location updated to: $lokasiAwal');
      if (!_isDisposed) {
        safeNotifyListeners();
      }
    }
  }

  void _updateCurrentLocation(Position position) {
    lokasiAwal = LatLng(position.latitude, position.longitude);
    if (!_isDisposed) {
      safeNotifyListeners();
    }
  }

  void _lokasiAlamat(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _prediksiAlamat =
            "${place.street}, ${place.locality}, ${place.subLocality}, ${place.administrativeArea}, ${place.country}";
        _isLoading1 = false;
      } else {
        _prediksiAlamat = "Alamat tidak ditemukan";
      }
    } catch (e) {
      print('$e');
      _prediksiAlamat = "";
    }
    print('Alamat yang diprediksi: $_prediksiAlamat');
    if (!_isDisposed) {
      safeNotifyListeners();
    }
  }

  void _buatPolyline() async {
    if (titikTujuan.isNotEmpty && titikTujuan.length > 1) {
      final List<LatLng> polylinePoints = [];
      for (int i = 0; i < titikTujuan.length - 1; i++) {
        final LatLng start = titikTujuan[i];
        final LatLng end = titikTujuan[i + 1];
        final route = await _getRoute(start, end);
        if (route != null) {
          polylinePoints.addAll(route);
        }
      }

      jalurRute = Polyline(
        gradientColors: [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.blue,
        ],
        points: polylinePoints,
        color: Colors.blue,
        borderColor: Colors.black,
        borderStrokeWidth: 2,
        strokeWidth: 5,
      );
      print('Polyline dibuat dengan poin: $polylinePoints');
    } else {
      jalurRute = null;
      _totalJarak = 0.0;
    }
    _isLoading = false;
    safeNotifyListeners();
  }

  Future<List<LatLng>?> _getRoute(LatLng start, LatLng end) async {
    const String apiKey =
        '5b3ce3597851110001cf6248167166d78c714b14831ad77a268357ba';
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['features'][0]['geometry']['coordinates'];
        print('Koodinat Posisi Awal: $coordinates');
        return coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();
      } else {
        print('Gagal mengambil koordinat posisi Awal: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Error pengambilan posisi awal karena $e");
      return null;
    }
  }

  void startDelivery() {
    _buatPolyline();
    _isLoading = false;
  }

  void cancelDelivery() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    dataPengantaran = [];
    titikTujuan = [];
    _totalJarak = 0.0;
    _isLoading = true;
    _isLoading1 = true;
    jalurRute = null;
    _prediksiAlamat = '';
    safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionStreamSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
