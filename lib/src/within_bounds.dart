List<int> rangeImpl<U extends num>(List<int> ids, List<U> coords, U minX,
    U minY, U maxX, U maxY, int nodeSize) {
  final stack = [0, ids.length - 1, 0];
  final result = <int>[];

  // recursively search for items in range in the kd-sorted arrays
  while (stack.isNotEmpty) {
    final axis = stack.removeLast();
    final right = stack.removeLast();
    final left = stack.removeLast();

    // if we reached "tree node", search linearly
    if (right - left <= nodeSize) {
      for (var i = left; i <= right; i++) {
        final x = coords[2 * i];
        final y = coords[2 * i + 1];
        if (x >= minX && x <= maxX && y >= minY && y <= maxY)
          result.insert(result.length, ids[i]);
      }
      continue;
    }

    // otherwise find the middle index
    final m = (left + right) >> 1;

    // include the middle item if it's in range
    final x = coords[2 * m];
    final y = coords[2 * m + 1];
    if (x >= minX && x <= maxX && y >= minY && y <= maxY)
      result.insert(result.length, ids[m]);

    // queue search in halves that intersect the query
    if (axis == 0 ? minX <= x : minY <= y) {
      stack.insert(stack.length, left);
      stack.insert(stack.length, m - 1);
      stack.insert(stack.length, 1 - axis);
    }
    if (axis == 0 ? maxX >= x : maxY >= y) {
      stack.insert(stack.length, m + 1);
      stack.insert(stack.length, right);
      stack.insert(stack.length, 1 - axis);
    }
  }

  return result;
}
