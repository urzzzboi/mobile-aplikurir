import 'dart:math';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class Node {
  LatLng point;
  double g;
  double h;
  double f;
  Node? parent;

  Node(this.point, this.g, this.h, this.f, {this.parent});
}

class AlgoritmaAStar {
  String text = '';
  String text2 = '';
  bool load = true;

  Future<List<LatLng>> urutkanDenganAStar(
      LatLng start, List<LatLng> points) async {
    List<LatLng> hasilHitungan = [];
    LatLng ambilStart = start;
    List<LatLng> semuaTitik = [start, ...points]; // Include start in all points

    while (points.isNotEmpty) {
      Node? jalur = await cariJalurTerpendek(ambilStart, points, semuaTitik);
      if (jalur != null) {
        hasilHitungan.add(jalur.point);
        points.remove(jalur.point);
        ambilStart = jalur.point;
      } else {
        break;
      }
    }

    return hasilHitungan;
  }

  Future<Node?> cariJalurTerpendek(
      LatLng start, List<LatLng> points, List<LatLng> semuaTitik) async {
    List<Node> openList = [Node(start, 0, 0, 0)];
    List<LatLng> closedList = [];

    while (openList.isNotEmpty) {
      Node jalur = openList.reduce((a, b) => a.f < b.f ? a : b);
      String gnTerpakai = '${jalur.g.toStringAsFixed(2)} km';
      String hnTerpakai = jalur.h.toStringAsFixed(7);
      String fnTerpakai = '${jalur.f.toStringAsFixed(2)} km';

      if (jalur.f != 0.00) {
        int indexStart = semuaTitik.indexOf(jalur.parent?.point ?? start) + 1;
        int indexPoint = semuaTitik.indexOf(jalur.point) + 1;

        String startAddress = await getAddress(jalur.parent?.point ?? start);
        String endAddress = await getAddress(jalur.point);
        text2 +=
            '\nJarak antara titik $indexStart ($startAddress) ke titik $indexPoint ($endAddress)\n \n gn:$gnTerpakai, h(n):$hnTerpakai, f(n):$fnTerpakai \n';
        load = false;
      }

      openList.remove(jalur);

      if (points.contains(jalur.point)) {
        return jalur;
      }

      closedList.add(jalur.point);

      List<LatLng> simpanCloseList =
          points.where((point) => !closedList.contains(point)).toList();
      for (LatLng i in simpanCloseList) {
        double distance = await _getRoute(jalur.point, i);
        double nilaiSementaraG = distance;
        double h = hitungHeuristic(i, start);
        double f = nilaiSementaraG + h;

        String gn = '${nilaiSementaraG.toStringAsFixed(2)} km';
        String hn = h.toStringAsFixed(7);
        String fn = '${f.toStringAsFixed(2)} km';

        text +=
            '\nJarak ${semuaTitik.indexOf(jalur.point) + 1} ke titik ${semuaTitik.indexOf(i) + 1} =>  g(n): $gn, h(n): $hn, f(n): $fn\n ';

        Node? nodeTerpakai =
            openList.firstWhereOrNull((node) => node.point == i);
        if (nodeTerpakai != null) {
          if (nilaiSementaraG < nodeTerpakai.g) {
            nodeTerpakai.g = nilaiSementaraG;
            nodeTerpakai.f = f;
            nodeTerpakai.parent = jalur;
          }
        } else {
          openList.add(Node(i, nilaiSementaraG, h, f, parent: jalur));
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

  Future<double> _getRoute(LatLng a, LatLng b) async {
    String apiKey = '3de6b880-d16f-4d67-b69c-11eedadce956';
    final String url =
        'https://graphhopper.com/api/1/route?point=${a.latitude},${a.longitude}&point=${b.latitude},${b.longitude}&profile=bike&unit_system=metric&calc_points=false&key=$apiKey';

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

  Future<String> getAddress(LatLng point) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return "Alamat tidak ditemukan";
    }
  }
}
