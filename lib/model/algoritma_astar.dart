import 'dart:math';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class Node {
  LatLng node;
  double gn;
  double hn;
  double fn;
  Node? parent;

  Node(this.node, this.gn, this.hn, this.fn, {this.parent});
}

class AlgoritmaAStar {
  String text = '';
  String text2 = '';
  bool load = true;

  Future<List<LatLng>> urutkanDenganAStar(
      LatLng titikAwal, List<LatLng> titikTujuan) async {
    List<LatLng> hasilHitungan = [];
    LatLng titikSekarang = titikAwal;
    List<LatLng> semuaTitik = [titikAwal, ...titikTujuan];

    while (titikTujuan.isNotEmpty) {
      Node? jalur =
          await cariJalurTerpendek(titikSekarang, titikTujuan, semuaTitik);
      if (jalur != null) {
        hasilHitungan.add(jalur.node);
        titikTujuan.remove(jalur.node);
        titikSekarang = jalur.node;
      } else {
        break;
      }
    }

    return hasilHitungan;
  }

  Future<Node?> cariJalurTerpendek(LatLng titikAwal, List<LatLng> titikTujuan,
      List<LatLng> semuaTitik) async {
    List<Node> openList = [Node(titikAwal, 0, 0, 0)];
    List<LatLng> closedList = [];

    while (openList.isNotEmpty) {
      Node jalur = openList.reduce((a, b) => a.fn < b.fn ? a : b);
      String gnTerpakai = '${jalur.gn.toStringAsFixed(2)} km';
      String hnTerpakai = jalur.hn.toStringAsFixed(7);
      String fnTerpakai = '${jalur.fn.toStringAsFixed(2)} km';

      if (jalur.fn != 0.00) {
        int indextitikAwal =
            semuaTitik.indexOf(jalur.parent?.node ?? titikAwal) + 1;
        int indexTitik = semuaTitik.indexOf(jalur.node) + 1;

        String alamattitikAwal =
            await dapatkanAlamat(jalur.parent?.node ?? titikAwal);
        String alamatTitik = await dapatkanAlamat(jalur.node);
        text2 +=
            '\nJarak antara titik $indextitikAwal ($alamattitikAwal) ke titik $indexTitik ($alamatTitik)\n \n gn:$gnTerpakai, h(n):$hnTerpakai, f(n):$fnTerpakai \n';
        load = false;
      }

      openList.remove(jalur);

      if (titikTujuan.contains(jalur.node)) {
        return jalur;
      }

      closedList.add(jalur.node);

      List<LatLng> titikTersisa =
          titikTujuan.where((titik) => !closedList.contains(titik)).toList();
      for (LatLng titik in titikTersisa) {
        double jarak = await hitungJarak(jalur.node, titik);
        double nilaiSementaraGn = jarak;
        double hn = hitungHeuristic(titik, titikAwal);
        double fn = nilaiSementaraGn + hn;

        String gn = '${nilaiSementaraGn.toStringAsFixed(2)} km';
        String hnStr = hn.toStringAsFixed(7);
        String fnStr = '${fn.toStringAsFixed(2)} km';

        text +=
            '\nJarak ${semuaTitik.indexOf(jalur.node) + 1} ke titik ${semuaTitik.indexOf(titik) + 1} =>  g(n): $gn, h(n): $hnStr, f(n): $fnStr\n ';

        Node? nodeTerpakai =
            openList.firstWhereOrNull((node) => node.node == titik);
        if (nodeTerpakai != null) {
          if (nilaiSementaraGn < nodeTerpakai.gn) {
            nodeTerpakai.gn = nilaiSementaraGn;
            nodeTerpakai.fn = fn;
            nodeTerpakai.parent = jalur;
          }
        } else {
          openList.add(Node(titik, nilaiSementaraGn, hn, fn, parent: jalur));
        }
      }
    }

    return null;
  }

  double hitungHeuristic(LatLng a, LatLng b) {
    final deltaLat = a.latitude - b.latitude;
    final deltaLon = a.longitude - b.longitude;
    return sqrt(pow(deltaLat, 2) + pow(deltaLon, 2));
  }

  Future<double> hitungJarak(LatLng a, LatLng b) async {
    String apiKey = '3de6b880-d16f-4d67-b69c-11eedadce956';
    final String url =
        'https://graphhopper.com/api/1/route?point=${a.latitude},${a.longitude}&point=${b.latitude},${b.longitude}&profile=car_delivery&unit_system=metric&calc_points=false&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['paths'] != null && data['paths'].isNotEmpty) {
          final distance = data['paths'][0]['distance'];
          return distance / 1000;
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  Future<String> dapatkanAlamat(LatLng titik) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(titik.latitude, titik.longitude);
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return "Alamat tidak ditemukan";
    }
  }
}
