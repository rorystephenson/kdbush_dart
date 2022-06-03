import 'dart:math';

void sortImpl<U extends num>(List<int> ids, List<U> coords, int nodeSize,
    int left, int right, int axis) {
  if (right - left <= nodeSize) return;

  final m = (left + right) >> 1; // middle index

  // sort ids and coords around the middle index so that the halves lie
  // either left/right or top/bottom correspondingly (taking turns)
  _select(ids, coords, m, left, right, axis);

  // recursively kd-sort first half and second half on the opposite axis
  sortImpl(ids, coords, nodeSize, left, m - 1, 1 - axis);
  sortImpl(ids, coords, nodeSize, m + 1, right, 1 - axis);
}

// custom Floyd-Rivest selection algorithm: sort ids and coords so that
// [left..k-1] items are smaller than k-th item (on either x or y axis)
void _select<U extends num>(
    List<int> ids, List<U> coords, int k, int left, int right, int axis) {
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
