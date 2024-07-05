import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
  String api = '5b3ce3597851110001cf62485d5c00507a554490bd236566906887cf';

  Future<List<LatLng>> urutkanDenganAStar(
      LatLng start, List<LatLng> points) async {
    List<LatLng> hasilHitungan = [];
    LatLng ambilStart = start;
    print('Hasil Hitungan: $hasilHitungan');
    while (points.isNotEmpty) {
      Node? jalur = await cariJalurTerpendek(ambilStart, points);
      if (jalur != null) {
        hasilHitungan.add(jalur.point);
        points.remove(jalur.point);
        ambilStart = jalur.point;
      } else {
        break;
      }
    }
    await cetakJarakAntarTitik(hasilHitungan);

    return hasilHitungan;
  }

  Future<Node?> cariJalurTerpendek(LatLng start, List<LatLng> points) async {
    List<Node> openList = [Node(start, 0, 0, 0)];
    List<LatLng> closedList = [];

    while (openList.isNotEmpty) {
      Node jalur = openList.reduce((a, b) => a.f < b.f ? a : b);
      openList.remove(jalur);

      if (points.contains(jalur.point)) {
        return jalur;
      }

      closedList.add(jalur.point);

      List<LatLng> simpanCloseList =
          points.where((point) => !closedList.contains(point)).toList();
      for (LatLng i in simpanCloseList) {
        double nilaiSementaraG = await jarak(jalur.point, i);
        double h = hitungHeuristic(i, start);
        double f = nilaiSementaraG + h;

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

    print('Closed List: $closedList');
    return null;
  }

  Future<void> cetakJarakAntarTitik(List<LatLng> points) async {
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        LatLng titik1 = points[i];
        LatLng titik2 = points[j];
        double jarakAntarTitik = await jarak(titik1, titik2);
        double h = hitungHeuristic(titik2, titik1);
        double f = jarakAntarTitik + h;

        String jarakFormatted =
            (jarakAntarTitik / 1000).toStringAsFixed(1) + ' km';
        String hFormatted = (h).toStringAsFixed(10);
        String fFormatted = (f / 1000).toStringAsFixed(2) + ' km';

        int index1 = i + 1;
        int index2 = j + 1;
        // print('$jarakFormatted');
        text +=
            '\nJarak antara $index1 dan $index2: \nJarak g(n): $jarakFormatted, h(n): $hFormatted, f(n): $fFormatted\n';
      }
    }
  }

  String formatLatLng(LatLng point) {
    return '(${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})';
  }

  double hitungHeuristic(LatLng a, LatLng b) {
    final deltaLat = a.latitude - b.latitude;
    final deltaLon = a.longitude - b.longitude;
    return sqrt(pow(deltaLat, 2) + pow(deltaLon, 2));
  }

  Future<double> jarak(LatLng a, LatLng b) async {
    double jarak = 0.0;
    final route = await _getRoute(a, b);
    if (route != null) {
      for (int j = 0; j < route.length - 1; j++) {
        jarak += Geolocator.distanceBetween(
          route[j].latitude,
          route[j].longitude,
          route[j + 1].latitude,
          route[j + 1].longitude,
        );
      }
    }
    return jarak;
  }

  Future<List<LatLng>?> _getRoute(LatLng start, LatLng end) async {
    String apiKey = api;
    final String url =
        'https://api.openrouteservice.org/v2/directions/cycling-regular?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['features'][0]['geometry']['coordinates'];
        return coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

extension FirstWhereOrNullExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
