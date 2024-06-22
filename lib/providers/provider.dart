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
  String _prediksiAlamat = '';
  List<dynamic> dataPengantaran = [];
  Map<String, dynamic>? dataPenerima;
  LatLng titikAwal = const LatLng(0.0, 0.0);
  List<LatLng> titikTujuan = [];
  List<LatLng> titikTujuan1 = [];
  List<LatLng> titikTujuan2 = [];
  Polyline? jalurRute;
  bool _isLoading = true;
  LatLng lokasiAwal = const LatLng(0.0, 0.0);
  final int idKurir;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _pollingTimer;
  double _totalJarak1 = 0.0;
  final AlgoritmaAStar _algoritmaAStar = AlgoritmaAStar();

  bool _isDisposed = false;
  bool get isloading => _isLoading;
  String get prediksiAlamat => _prediksiAlamat;
  double get totalJarak1 => _totalJarak1;

  OSMScreenProvider(this.globalkey, this.context, this.idKurir) {
    _memintaPerizinanLokasi();
    _fetchDataPengantaran();
    _pollingTime();
  }

  Future<void> _fetchDataPengantaran() async {
    try {
      dataPengantaran = await _ambilDataKurir.fetchDataPengantaran(idKurir);
      await _fetchCoordinatesAndBuildRoute();

      safeNotifyListeners();
    } catch (e) {
      _tampilkanSnackBar("Tidak bisa mengambil data $e");
    }
  }

  Future<void> _fetchCoordinatesAndBuildRoute() async {
    try {
      List<LatLng> fetchedCoordinates =
          await _ambilDataKurir.fetchCoordinates(idKurir);
      fetchedCoordinates =
          _algoritmaAStar.urutkanDenganAStar(titikAwal, fetchedCoordinates);

      titikTujuan = [titikAwal, fetchedCoordinates[0]];
      titikTujuan2 = [titikAwal, fetchedCoordinates[1]];

      print('Titik Awal: $titikAwal');
      print('Titik Tujuan: $titikTujuan');

      _buatPolyline();
      _hitungTotalJarak();
      _lokasiAlamat(titikAwal);
    } catch (e) {
      _tampilkanSnackBar("Error in _fetchCoordinatesAndBuildRoute: $e");
    }
  }

  Future<void> _hitungTotalJarak() async {
    try {
      _totalJarak1 = 0.0;

      for (int i = 0; i < titikTujuan.length - 1; i++) {
        final route = await _getRoute(titikAwal, titikTujuan[0]);
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

      print('Total Jarak: $_totalJarak1 km');

      safeNotifyListeners();
    } catch (e) {
      _tampilkanSnackBar("Error in _hitungTotalJarak: $e");
    }
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
      } else {
        _prediksiAlamat = "Alamat tidak ditemukan";
      }
    } catch (e) {
      _prediksiAlamat = "Error: $e";
    }
    if (!_isDisposed) {
      safeNotifyListeners();
    }
  }

  void _buatPolyline() async {
    try {
      if (titikTujuan.isNotEmpty) {
        final List<LatLng> polylinePoints = [];

        final LatLng start = titikAwal;
        final LatLng end = titikTujuan[0];

        final route = await _getRoute(start, end);
        if (route != null) {
          polylinePoints.addAll(route);
        }

        jalurRute = Polyline(
          points: polylinePoints,
          color: Colors.blue,
          borderColor: Colors.black,
          borderStrokeWidth: 2,
          strokeWidth: 5,
        );

        print('Jalur Rute: ${jalurRute?.points}');
        _hitungTotalJarak();
      } else {
        jalurRute = null;
        _totalJarak1 = 0.0;
      }

      _isLoading = false;
      safeNotifyListeners();
    } catch (e) {
      _tampilkanSnackBar("Error in _buatPolyline: $e");
    }
  }

  Future<List<LatLng>?> _getRoute(LatLng start, LatLng end) async {
    const String apiKey =
        '5b3ce3597851110001cf6248074c5f34906f46c5b334aff5b3087b82';
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['features'][0]['geometry']['coordinates'];

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
    titikTujuan1 = [];
    titikTujuan2 = [];
    _totalJarak1 = 0.0;
    _isLoading = true;
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
