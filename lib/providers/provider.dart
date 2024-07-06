import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:aplikurir/api/api_service.dart';
import 'package:aplikurir/model/algoritma_astar.dart';
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

  List<LatLng> polylinePoints = [];

  List<LatLng> titikTujuan = [];

  List<LatLng> listTitikTujuan1 = [];

  List<LatLng> listTitikTujuan2 = [];

  List<LatLng> listTitikTujuan3 = [];

  List<LatLng> listTitikTujuan4 = [];

  List<LatLng> listTitikTujuan5 = [];

  List<LatLng> listTitikTujuan6 = [];

  Polyline? jalurRute;

  bool _isLoading = true;

  bool _isLoading1 = true;

  bool _isLoading2 = true;

  bool _isDisposed = false;

  StreamSubscription<Position>? _positionStreamSubscription;

  Timer? _pollingTimer;

  double _totalJarak = 0.0;

  String _waktuTempuh = '0';

  double _lastTotalJarak = 0.0;

  String _lastWaktuTempuh = '0';

  double _totalJarak1 = 0.0;

  String _waktuTempuh1 = '0';

  double _lastTotalJarak1 = 0.0;

  String _lastWaktuTempuh1 = '0';

  double _totalJarak2 = 0.0;

  String _waktuTempuh2 = '0';

  double _lastTotalJarak2 = 0.0;

  String _lastWaktuTempuh2 = '0';

  double _totalJarak3 = 0.0;

  String _waktuTempuh3 = '0';

  double _lastTotalJarak3 = 0.0;

  String _lastWaktuTempuh3 = '0';

  double _totalJarak4 = 0.0;

  String _waktuTempuh4 = '0';

  double _lastTotalJarak4 = 0.0;

  String _lastWaktuTempuh4 = '0';

  double _totalJarak5 = 0.0;

  String _waktuTempuh5 = '0';

  double _lastTotalJarak5 = 0.0;

  String _lastWaktuTempuh5 = '0';

  double _totalJarak6 = 0.0;

  String _waktuTempuh6 = '0';

  double _lastTotalJarak6 = 0.0;

  String _lastWaktuTempuh6 = '0';

  bool get isloading => _isLoading;

  bool get isloading1 => _isLoading1;

  bool get isloading2 => _isLoading2;

  String get prediksiAlamat => _prediksiAlamat;

  bool get cekDataPengantaran => dataPengantaran.isEmpty;

  double get totalJarak => _lastTotalJarak;

  String get waktuTempuh => _lastWaktuTempuh;
  double get totalJarak1 => _lastTotalJarak1;
  String get waktuTempuh1 => _lastWaktuTempuh1;
  double get totalJarak2 => _lastTotalJarak2;
  String get waktuTempuh2 => _lastWaktuTempuh2;
  double get totalJarak3 => _lastTotalJarak3;
  String get waktuTempuh3 => _lastWaktuTempuh3;
  double get totalJarak4 => _lastTotalJarak4;
  String get waktuTempuh4 => _lastWaktuTempuh4;
  double get totalJarak5 => _lastTotalJarak5;
  String get waktuTempuh5 => _lastWaktuTempuh5;
  double get totalJarak6 => _lastTotalJarak6;
  String get waktuTempuh6 => _lastWaktuTempuh6;
  String get textPerhitungan => _algoritmaAStar.text;

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

      // print('Data pengantaran berhasil diambil: $dataPengantaran');

      // print(cekDataPengantaran);

      if (dataPengantaran.isEmpty) {
        // print('Data tidak bisa diambil');
      }
    } catch (e) {
      // print("Tidak bisa mengambil data: ${e.toString()}");

      // print('Error: $e');
    } finally {
      safeNotifyListeners();
    }
  }

  Future<void> _fetchCoordinatesAndBuildRoute() async {
    List<LatLng> fetchedCoordinates =
        await _ambilDataKurir.fetchCoordinates(idKurir);

    fetchedCoordinates =
        await _algoritmaAStar.urutkanDenganAStar(titikAwal, fetchedCoordinates);

    // await _algoritmaAStar.urutkanDenganAStar(
    //     fetchedCoordinates[0], fetchedCoordinates);

    // titikTujuan = [fetchedCoordinates[0], ...fetchedCoordinates];

    // titikTujuan = [titikAwal, fetchedCoordinates[0]];

    titikTujuan = [titikAwal, ...fetchedCoordinates];
    _ambilTotalJarak(fetchedCoordinates);

    print(titikAwal);
    _buatPolyline();
    _lokasiAlamat(titikAwal);

    safeNotifyListeners();
  }

  Future<void> _ambilTotalJarak(List<LatLng> fetchedCoordinates) async {
    if (fetchedCoordinates.length >= 1) {
      listTitikTujuan1 = [titikAwal, fetchedCoordinates[0]];
      _hitungTotalJarak1();
    }

    if (fetchedCoordinates.length >= 2) {
      listTitikTujuan2 = [fetchedCoordinates[0], fetchedCoordinates[1]];
      _hitungTotalJarak2();
    }

    if (fetchedCoordinates.length >= 3) {
      listTitikTujuan3 = [fetchedCoordinates[1], fetchedCoordinates[2]];
      _hitungTotalJarak3();
    }

    if (fetchedCoordinates.length >= 4) {
      listTitikTujuan4 = [fetchedCoordinates[2], fetchedCoordinates[3]];
      _hitungTotalJarak4();
    }

    if (fetchedCoordinates.length >= 5) {
      listTitikTujuan5 = [fetchedCoordinates[3], fetchedCoordinates[4]];
      _hitungTotalJarak5();
    }

    if (fetchedCoordinates.length >= 6) {
      listTitikTujuan6 = [fetchedCoordinates[4], fetchedCoordinates[5]];
      _hitungTotalJarak6();
    }

    _hitungTotalJarakSemua();
    safeNotifyListeners();
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
          // print('Status OK: $status');

          if (status == 'Selesai') {
            final id = selectedData['Id_pengantaran_paket'];

            final deleteResponse = await http.delete(
                Uri.parse('${ApiService.url}/dataPengantaran2/$id'),
                headers: {'Content-Type': 'application/json'});

            if (deleteResponse.statusCode == 200) {
              // print('Data pengantaran paket berhasil dihapus.');
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
              // print('Data pengantaran paket berhasil dihapus.');
            } else {
              print(
                  'Gagal menghapus data pengantaran paket: ${deleteResponse.statusCode}');
            }
          }
        } else {
          // print('Data tidak masuk karena: ${response.statusCode}');
        }
      } else {
        // print('Data tidak ditemukan');
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  void _hitungTotalJarakSemua() async {
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

  void _hitungTotalJarak1() async {
    _totalJarak1 = 0.0;

    for (int i = 0; i < listTitikTujuan1.length - 1; i++) {
      final route =
          await _getRoute(listTitikTujuan1[i], listTitikTujuan1[i + 1]);

      if (route != null) {
        for (int j = 0; j < route.length - 1; j++) {
          _totalJarak1 += Geolocator.distanceBetween(
            route[j].latitude,
            route[j].longitude,
            route[j + 1].latitude,
            route[j + 1].longitude,
          );
        }
      }
    }

    _totalJarak1 /= 1000;
    _waktuTempuh1 = calculateTravelTime(_totalJarak1, 30.0);
    _isLoading2 = false;
    if (_totalJarak1 != _lastTotalJarak1 ||
        _waktuTempuh1 != _lastWaktuTempuh1) {
      _lastTotalJarak1 = _totalJarak1;
      _lastWaktuTempuh1 = _waktuTempuh1;
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

    _isLoading2 = false;
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

    _isLoading2 = false;
    if (_totalJarak3 != _lastTotalJarak3 ||
        _waktuTempuh3 != _lastWaktuTempuh3) {
      _lastTotalJarak3 = _totalJarak3;

      _lastWaktuTempuh3 = _waktuTempuh3;

      _isLoading1 = false;

      safeNotifyListeners();
    }
  }

  void _hitungTotalJarak4() async {
    _totalJarak4 = 0.0;

    for (int i = 0; i < listTitikTujuan4.length - 1; i++) {
      final route =
          await _getRoute(listTitikTujuan4[i], listTitikTujuan4[i + 1]);

      if (route != null) {
        for (int j = 0; j < route.length - 1; j++) {
          _totalJarak4 += Geolocator.distanceBetween(
            route[j].latitude,
            route[j].longitude,
            route[j + 1].latitude,
            route[j + 1].longitude,
          );
        }
      }
    }

    _totalJarak4 /= 1000;

    _waktuTempuh4 = calculateTravelTime(_totalJarak4, 30.0);

    _isLoading2 = false;
    if (_totalJarak4 != _lastTotalJarak4 ||
        _waktuTempuh4 != _lastWaktuTempuh4) {
      _lastTotalJarak4 = _totalJarak4;

      _lastWaktuTempuh4 = _waktuTempuh4;

      _isLoading1 = false;

      safeNotifyListeners();
    }
  }

  void _hitungTotalJarak5() async {
    _totalJarak5 = 0.0;

    for (int i = 0; i < listTitikTujuan5.length - 1; i++) {
      final route =
          await _getRoute(listTitikTujuan5[i], listTitikTujuan5[i + 1]);

      if (route != null) {
        for (int j = 0; j < route.length - 1; j++) {
          _totalJarak5 += Geolocator.distanceBetween(
            route[j].latitude,
            route[j].longitude,
            route[j + 1].latitude,
            route[j + 1].longitude,
          );
        }
      }
    }

    _totalJarak5 /= 1000;

    _waktuTempuh5 = calculateTravelTime(_totalJarak5, 30.0);

    _isLoading2 = false;
    if (_totalJarak5 != _lastTotalJarak5 ||
        _waktuTempuh5 != _lastWaktuTempuh5) {
      _lastTotalJarak5 = _totalJarak5;

      _lastWaktuTempuh5 = _waktuTempuh5;

      _isLoading1 = false;

      safeNotifyListeners();
    }
  }

  void _hitungTotalJarak6() async {
    _totalJarak6 = 0.0;

    for (int i = 0; i < listTitikTujuan6.length - 1; i++) {
      final route =
          await _getRoute(listTitikTujuan6[i], listTitikTujuan6[i + 1]);

      if (route != null) {
        for (int j = 0; j < route.length - 1; j++) {
          _totalJarak6 += Geolocator.distanceBetween(
            route[j].latitude,
            route[j].longitude,
            route[j + 1].latitude,
            route[j + 1].longitude,
          );
        }
      }
    }

    _totalJarak6 /= 1000;

    _waktuTempuh6 = calculateTravelTime(_totalJarak6, 30.0);

    _isLoading2 = false;
    if (_totalJarak6 != _lastTotalJarak6 ||
        _waktuTempuh6 != _lastWaktuTempuh6) {
      _lastTotalJarak6 = _totalJarak6;

      _lastWaktuTempuh6 = _waktuTempuh6;

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
        // print('Izin Lokasi ditolak');
      } else if (status.isPermanentlyDenied) {
        // print('Izinkan Lokasi terlebih dahulu');
      }
    }
  }

  Future<void> _ambilPosisiTengah() async {
    bool serviceEnabled;

    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // print("Lokasi dinonaktifkan");

      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // print("Akses Lokasi Ditolak");

        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // print("Akses Lokasi Ditolak secara Permanen");

      return;
    }

    try {
      Position posisiSekarang = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // titikAwal = LatLng(posisiSekarang.latitude, posisiSekarang.longitude);

      // titikAwal = const LatLng(3.587524, 98.690725);
      titikAwal = const LatLng(3.569774, 98.696144);

      // print('Posisi sekarang: $titikAwal');

      print('GPS BERJALAN');

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
      // print("Tidak bisa ambil tengah karena $e");
    }
  }

  void handlePositionChange(MapCamera latLng, bool hasGesture) {
    // print('Current Location: $lokasiAwal, New Location: ${latLng.center}');

    if (lokasiAwal != latLng.center) {
      lokasiAwal = latLng.center;

      // print('Location updated to: $lokasiAwal');

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
      // print('$e');

      _prediksiAlamat = "";
    }

    // print('Alamat yang diprediksi: $_prediksiAlamat');

    if (!_isDisposed) {
      safeNotifyListeners();
    }
  }

  void _buatPolyline() async {
    if (titikTujuan.isNotEmpty && titikTujuan.length > 1) {
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
          Colors.cyan,
        ],
        points: polylinePoints,
        color: Colors.blue,
        borderColor: Colors.black,
        borderStrokeWidth: 2,
        strokeWidth: 5,
      );

      // print('Polyline dibuat dengan poin: $polylinePoints');

      // _totalJarak1 = polylinePoints.length.toDouble();

      _isLoading = false;
    } else {
      print('Jalur Tidak Muncul');

      jalurRute = null;

      _totalJarak1 = 0.0;
    }

    safeNotifyListeners();
  }

  Future<List<LatLng>?> _getRoute(LatLng start, LatLng end) async {
    String apiKey = '5b3ce3597851110001cf62484de604868349433ba74c5ccdf1add05b';

    final String url =
        'https://api.openrouteservice.org/v2/directions/cycling-road?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List coordinates = data['features'][0]['geometry']['coordinates'];

        // print('Koodinat Posisi Awal: $coordinates');

        print('ambil rute terbaca');

        return coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();
      } else {
        // print('Gagal mengambil koordinat posisi Awal: ${response.statusCode}');

        return null;
      }
    } catch (e) {
      // print("Error pengambilan posisi awal karena $e");

      return null;
    }
  }

  void startDelivery() {
    _buatPolyline();
  }

  void cancelDelivery() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    dataPengantaran = [];
    titikTujuan = [];
    polylinePoints = [];
    listTitikTujuan1 = [];
    listTitikTujuan2 = [];
    listTitikTujuan3 = [];
    listTitikTujuan4 = [];
    listTitikTujuan5 = [];
    listTitikTujuan6 = [];
    _totalJarak = 0.0;
    _waktuTempuh = '0';
    _lastTotalJarak = 0.0;
    _lastWaktuTempuh = '0';
    _totalJarak1 = 0.0;
    _waktuTempuh1 = '0';
    _lastTotalJarak1 = 0.0;
    _lastWaktuTempuh1 = '0';
    _totalJarak2 = 0.0;
    _waktuTempuh2 = '0';
    _lastTotalJarak2 = 0.0;
    _lastWaktuTempuh2 = '0';
    _totalJarak3 = 0.0;
    _waktuTempuh3 = '0';
    _lastTotalJarak3 = 0.0;
    _lastWaktuTempuh3 = '0';
    _totalJarak4 = 0.0;
    _waktuTempuh4 = '0';
    _lastTotalJarak4 = 0.0;
    _lastWaktuTempuh4 = '0';
    _totalJarak5 = 0.0;
    _waktuTempuh5 = '0';
    _lastTotalJarak5 = 0.0;
    _lastWaktuTempuh5 = '0';
    _totalJarak6 = 0.0;
    _waktuTempuh6 = '0';
    _lastTotalJarak6 = 0.0;
    _lastWaktuTempuh6 = '0';
    _isLoading = true;
    _isLoading1 = true;
    _isLoading2 = true;
    titikAwal = const LatLng(0.0, 0.0);
    lokasiAwal = const LatLng(0.0, 0.0);
    jalurRute = null;
    _prediksiAlamat = '';
    safeNotifyListeners();
    _isDisposed = false;
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
