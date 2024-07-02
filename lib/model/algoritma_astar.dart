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
    LatLng currentStart = start;

    while (points.isNotEmpty) {
      Node? current = findShortestPath(currentStart, points);
      if (current != null) {
        hasilHitungan.add(current.point);
        points.remove(current.point);
        currentStart = current.point;
      } else {
        break;
      }
    }

    return hasilHitungan;
  }

  Node? findShortestPath(LatLng start, List<LatLng> points) {
    List<Node> openList = [Node(start, 0, 0, 0)];
    List<LatLng> closedList = [];

    while (openList.isNotEmpty) {
      Node current = openList.reduce((a, b) => a.f < b.f ? a : b);
      openList.remove(current);

      if (points.contains(current.point)) {
        return current;
      }

      closedList.add(current.point);

      List<LatLng> successors =
          points.where((point) => !closedList.contains(point)).toList();
      for (LatLng successor in successors) {
        double tentativeG = current.g + jarak(current.point, successor);
        double h = hitungHeuristic(successor, start);
        double f = tentativeG + h;

        Node? existingNode =
            openList.firstWhereOrNull((node) => node.point == successor);
        if (existingNode != null && tentativeG >= existingNode.g) {
          continue;
        }

        openList.add(Node(successor, tentativeG, h, f, parent: current));
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
