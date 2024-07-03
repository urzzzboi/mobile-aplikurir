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
  List<LatLng> urutkanDenganAStar(LatLng start, List<LatLng> points) {
    List<LatLng> hasilHitungan = [];
    LatLng ambilStart = start;

    while (points.isNotEmpty) {
      Node? jalur = cariJalurTerpendek(ambilStart, points);
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

  Node? cariJalurTerpendek(LatLng start, List<LatLng> points) {
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
        double nilaiSementaraG = jalur.g + jarak(jalur.point, i);
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

    return null;
  }

  double hitungHeuristic(LatLng a, LatLng b) {
    return jarak(a, b);
  }

  double jarak(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
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
