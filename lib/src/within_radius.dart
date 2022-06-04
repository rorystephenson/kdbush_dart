List<int> withinImpl<U extends num>(
    List<int> ids, List<U> coords, num qx, num qy, num r, int nodeSize) {
  final stack = <int>[0, ids.length - 1, 0];
  final result = <int>[];
  final r2 = r * r;

  // recursively search for items within radius in the kd-sorted arrays
  while (stack.isNotEmpty) {
    final axis = stack.removeLast();
    final right = stack.removeLast();
    final left = stack.removeLast();

    // if we reached "tree node", search linearly
    if (right - left <= nodeSize) {
      for (var i = left; i <= right; i++) {
        if (_sqDist(coords[2 * i], coords[2 * i + 1], qx, qy) <= r2) {
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
    if (_sqDist(x, y, qx, qy) <= r2) result.insert(result.length, ids[m]);

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

U _sqDist<U extends num>(U ax, U ay, U bx, U by) {
  final dx = ax - bx;
  final dy = ay - by;
  return (dx * dx + dy * dy as U);
}
