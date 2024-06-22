import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class AlgoritmaAStar {
  List<LatLng> urutkanDenganAStar(LatLng start, List<LatLng> points) {
    List<LatLng> openList = [start];
    List<LatLng> closedList = [];
    List<LatLng> result = [];

    while (openList.isNotEmpty) {
      LatLng q = openList.reduce((a, b) =>
          hitungHeuristic(a, start) < hitungHeuristic(b, start) ? a : b);
      openList.remove(q);

      if (points.contains(q)) {
        points.remove(q);
        result.add(q);
      }

      List<LatLng> successors =
          points.where((point) => !closedList.contains(point)).toList();
      for (LatLng successor in successors) {
        double g = jarak(start, q) + jarak(q, successor);
        double h = hitungHeuristic(successor, start);
        double f = g + h;

        if (openList.any(
            (node) => node == successor && hitungHeuristic(node, start) < f)) {
          continue;
        }
        if (closedList.any(
            (node) => node == successor && hitungHeuristic(node, start) < f)) {
          continue;
        }

        openList.add(successor);
      }

      closedList.add(q);
    }

    return result;
  }

  double hitungHeuristic(LatLng a, LatLng b) {
    return jarak(a, b);
  }

  double jarak(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
  }
}
