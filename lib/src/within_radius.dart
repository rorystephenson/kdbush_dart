import 'dart:math';

const earthRadius = 6371.0;
const rad = pi / 180;

List<int> withinImpl<U extends num>(
    List<int> ids, List<U> coords, num qx, num qy, num r, int nodeSize,
    {bool distanceInKmSpherical = false}) {
  final bool Function(num, num, num, num) closeEnough;
  if (distanceInKmSpherical) {
    closeEnough = (ax, ay, bx, by) => _sphereDistance(ax, ay, bx, by) <= r;
  } else {
    final r2 = r * r;
    closeEnough = (ax, ay, bx, by) => _sqDist(ax, ay, bx, by) <= r2;
  }

  final stack = <int>[0, ids.length - 1, 0];
  final result = <int>[];

  // recursively search for items within radius in the kd-sorted arrays
  while (stack.isNotEmpty) {
    final axis = stack.removeLast();
    final right = stack.removeLast();
    final left = stack.removeLast();

    // if we reached "tree node", search linearly
    if (right - left <= nodeSize) {
      for (var i = left; i <= right; i++) {
        if (closeEnough(coords[2 * i], coords[2 * i + 1], qx, qy)) {
          result.insert(result.length, ids[i]);
        }
      }
      continue;
    }

    // otherwise find the middle index
    final m = (left + right) >> 1;

    // include the middle item if it's in range
    final x = coords[2 * m];
    final y = coords[2 * m + 1];
    if (closeEnough(x, y, qx, qy)) result.insert(result.length, ids[m]);

    // queue search in halves that intersect the query
    if (axis == 0 ? qx - r <= x : qy - r <= y) {
      stack.insert(stack.length, left);
      stack.insert(stack.length, m - 1);
      stack.insert(stack.length, 1 - axis);
    }
    if (axis == 0 ? qx + r >= x : qy + r >= y) {
      stack.insert(stack.length, m + 1);
      stack.insert(stack.length, right);
      stack.insert(stack.length, 1 - axis);
    }
  }

  return result;
}

num _sqDist<U extends num>(U ax, U ay, U bx, U by) {
  final dx = ax - bx;
  final dy = ay - by;
  return (dx * dx + dy * dy as U);
}

num _sphereDistance<U extends num>(U lng1, U lat1, U lng2, U lat2) {
  var h = _haverSinDist(lng1, lat1, lng2, lat2, cos(lat1 * rad));
  return 2 * earthRadius * asin(sqrt(h));
}

num _haverSin(num theta) {
  var s = sin(theta / 2);
  return s * s;
}

num _haverSinDistPartial(num haverSinDLng, num cosLat1, num lat1, num lat2) {
  return cosLat1 * cos(lat2 * rad) * haverSinDLng +
      _haverSin((lat1 - lat2) * rad);
}

num _haverSinDist(num lng1, num lat1, num lng2, num lat2, num cosLat1) {
  var haverSinDLng = _haverSin((lng1 - lng2) * rad);
  return _haverSinDistPartial(haverSinDLng, cosLat1, lat1, lat2);
}
