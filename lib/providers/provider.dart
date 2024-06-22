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
  final MapController mapController = MapController();
  final int idKurir;
  final AlgoritmaAStar _algoritmaAStar = AlgoritmaAStar();
  String _prediksiAlamat = '';
  List<dynamic> dataPengantaran = [];
  Map<String, dynamic>? dataPenerima;
  LatLng titikAwal = const LatLng(0.0, 0.0);
  LatLng lokasiAwal = const LatLng(0.0, 0.0);
  List<LatLng> titikTujuan = [];
  Polyline? jalurRute;
  bool _isLoading = true;
  bool _isLoading1 = true;
  bool _isDisposed = false;

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _pollingTimer;
  double _totalJarak = 0.0;
  String _waktuTempuh = '';
  double _lastTotalJarak = 0.0;
  String _lastWaktuTempuh = '0';

  bool get isloading => _isLoading;
  bool get isloading1 => _isLoading1;
  String get prediksiAlamat => _prediksiAlamat;
  double get totalJarak => _lastTotalJarak;
  String get waktuTempuh => _lastWaktuTempuh;

  OSMScreenProvider(this.globalkey, this.context, this.idKurir) {
    _memintaPerizinanLokasi();
    _fetchDataPengantaran();
    _pollingTime();
  }

  Future<void> _fetchDataPengantaran() async {
    try {
      dataPengantaran = await _ambilDataKurir.fetchDataPengantaran(idKurir);
      print('Data pengantaran berhasil diambil: $dataPengantaran');

      if (dataPengantaran.isEmpty) {
        _tampilkanSnackBar("Tidak ada data pengantaran.");
      } else {
        for (var data in dataPengantaran) {
          data['Alamat_Tujuan'] ??= 'Tidak ada alamat yang dikirim';
          data['Nama_Penerima'] ??= '-';
          data['No_HP_Penerima'] ??= '-';
        }
        await _fetchCoordinatesAndBuildRoute();
      }
      safeNotifyListeners();
    } catch (e) {
      _tampilkanSnackBar("Tidak bisa mengambil data: ${e.toString()}");
      print('Error: $e');
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
  }

  Future<void> updateStatus(String status, List<LatLng> titikTujuan) async {
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
            'Nama_Pengiriman': selectedData['Nama_Pengirim'],
            'nama_kurir': selectedData['nama_kurir'],
            'handphone_kurir': selectedData['handphone_kurir'],
            'email': selectedData['email'],
            'password': selectedData['password'],
            'status_pengiriman': status,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          print('Status OK: $status');
          if (status == 'Selesai') {
            final idPengantaran = selectedData['Id_pengantaran_paket'];
            final deleteResponse = await http.delete(
                Uri.parse('${ApiService.url}/dataPengantaran2/$idPengantaran'),
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

  void _memintaPerizinanLokasi() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied || status.isGranted) {
      if (await Permission.location.request().isGranted) {
        await _ambilPosisiTengah();
      } else if (status.isDenied) {
        _tampilkanSnackBar('Izin Lokasi ditolak');
      } else if (status.isPermanentlyDenied) {
        _tampilkanSnackBar('Izinkan Lokasi terlebih dahulu');
      }
    }
  }

  Future<void> _ambilPosisiTengah() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _tampilkanSnackBar("Lokasi dinonaktifkan");
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _tampilkanSnackBar("Akses Lokasi Ditolak");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _tampilkanSnackBar("Akses Lokasi Ditolak secara Permanen");
      return;
    }
    try {
      Position posisiSekarang = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
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
      _tampilkanSnackBar("Map tidak bisa ditampilkan : $e");
    }
  }

  void handlePositionChange(MapCamera latLng, bool hasGesture) {
    lokasiAwal = latLng.center;
    if (!_isDisposed) {
      safeNotifyListeners();
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
        '5b3ce3597851110001cf62480572ee009fe843c78002045ec7ba1e31';
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['features'][0]['geometry']['coordinates'];
        print('Route coordinates: $coordinates');
        return coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();
      } else {
        print('Failed to get route: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _tampilkanSnackBar("Error retrieving route: $e");
      return null;
    }
  }

  void _tampilkanSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
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
