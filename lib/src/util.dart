import 'dart:math';

const rad = pi / 180;

void kDSort(List<int> ids, List<num> coords, int nodeSize, int left, int right,
    int axis) {
  if (right - left <= nodeSize) return;

  final m = (left + right) >> 1; // middle index

  // sort ids and coords around the middle index so that the halves lie
  // either left/right or top/bottom correspondingly (taking turns)
  _select(ids, coords, m, left, right, axis);

  // recursively kd-sort first half and second half on the opposite axis
  kDSort(ids, coords, nodeSize, left, m - 1, 1 - axis);
  kDSort(ids, coords, nodeSize, m + 1, right, 1 - axis);
}

// Custom Floyd-Rivest selection algorithm: sort ids and coords so that
// [left..k-1] items are smaller than k-th item (on either x or y axis).
void _select(
  List<int> ids,
  List<num> coords,
  int k,
  int left,
  int right,
  int axis,
) {
  while (right > left) {
    if (right - left > 600) {
      final n = right - left + 1;
      final m = k - left + 1;
      final z = log(n);
      final s = 0.5 * exp(2 * z / 3);
      final sd = 0.5 * sqrt(z * s * (n - s) / n) * (m - n / 2 < 0 ? -1 : 1);
      final newLeft = max(left, (k - m * s / n + sd).floor());
      final newRight = min(right, (k + (n - m) * s / n + sd).floor());
      _select(ids, coords, k, newLeft, newRight, axis);
    }

    final t = coords[2 * k + axis];
    var i = left;
    var j = right;

    _swapItem(ids, coords, left, k);
    if (coords[2 * right + axis] > t) _swapItem(ids, coords, left, right);

    while (i < j) {
      _swapItem(ids, coords, i, j);
      i++;
      j--;
      while (coords[2 * i + axis] < t) {
        i++;
      }
      while (coords[2 * j + axis] > t) {
        j--;
      }
    }

    if (coords[2 * left + axis] == t) {
      _swapItem(ids, coords, left, j);
    } else {
      j++;
      _swapItem(ids, coords, j, right);
    }

    if (j <= k) left = j + 1;
    if (k <= j) right = j - 1;
  }
}

void _swapItem(List<int> ids, List coords, int i, int j) {
  _swap(ids, i, j);
  _swap(coords, 2 * i, 2 * j);
  _swap(coords, 2 * i + 1, 2 * j + 1);
}

void _swap(List arr, int i, int j) {
  final tmp = arr[i];
  arr[i] = arr[j];
  arr[j] = tmp;
}

typedef DistanceFilter = bool Function(num x1, num y1, num x2, num y2);

num sqDist(num x1, num y1, num x2, num y2) {
  final dx = x1 - x2;
  final dy = y1 - y2;
  return dx * dx + dy * dy;
}

DistanceFilter closeEnoughSpherical(num earthRadius, num searchRadius) =>
    (num lng1, num lat1, num lng2, num lat2) =>
        sphereDistance(lng1, lat1, lng2, lat2, earthRadius) <= searchRadius;

DistanceFilter closeEnoughSqDist(num searchRadius) {
  final r2 = searchRadius * searchRadius;
  return (num x1, num y1, num x2, num y2) => sqDist(x1, y1, x2, y2) <= r2;
}

num sphereDistance(num lng1, num lat1, num lng2, num lat2, num earthRadius) {
  final h = _haverSinDist(lng1, lat1, lng2, lat2, cos(lat1 * rad));
  return 2 * earthRadius * asin(sqrt(h));
}

num _haverSin(num theta) {
  final s = sin(theta / 2);
  return s * s;
}

num _haverSinDistPartial(num haverSinDLng, num cosLat1, num lat1, num lat2) {
  return cosLat1 * cos(lat2 * rad) * haverSinDLng +
      _haverSin((lat1 - lat2) * rad);
}

num _haverSinDist(num lng1, num lat1, num lng2, num lat2, num cosLat1) {
  final haverSinDLng = _haverSin((lng1 - lng2) * rad);
  return _haverSinDistPartial(haverSinDLng, cosLat1, lat1, lat2);
}
