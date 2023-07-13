import 'package:kdbush/src/kdbush.dart';
import 'package:kdbush/src/util.dart' as util;

class KDBushImpl<T, U extends num> implements KDBush<T, U> {
  final int _nodeSize;

  final List<int> ids = [];
  final List<U> coords = [];

  @override
  int get length => ids.length;

  KDBushImpl({
    required List<T> points,
    required U Function(T) getX,
    required U Function(T) getY,
    int nodeSize = 64,
  }) : _nodeSize = nodeSize {
    for (var i = 0; i < points.length; i++) {
      ids.insert(i, i);
      coords.insert(2 * i, getX(points[i]));
      coords.insert(2 * i + 1, getY(points[i]));
    }

    util.kDSort(ids, coords, nodeSize, 0, ids.length - 1, 0);
  }

  @override
  List<int> withinBounds(num minX, num minY, num maxX, num maxY) {
    final stack = [0, ids.length - 1, 0];
    final result = <int>[];

    // Recursively search for items in range in the kd-sorted arrays
    while (stack.isNotEmpty) {
      final axis = stack.removeLast();
      final right = stack.removeLast();
      final left = stack.removeLast();

      // If we reached "tree node", search linearly
      if (right - left <= _nodeSize) {
        for (var i = left; i <= right; i++) {
          final x = coords[2 * i];
          final y = coords[2 * i + 1];
          if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
            result.insert(result.length, ids[i]);
          }
        }
        continue;
      }

      // Otherwise find the middle index
      final m = (left + right) >> 1;

      // Include the middle item if it's in range
      final x = coords[2 * m];
      final y = coords[2 * m + 1];
      if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
        result.insert(result.length, ids[m]);
      }

      // Queue search in halves that intersect the query
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

  @override
  List<int> withinRadius(num x, num y, num radius) {
    return _withinImpl(
      x,
      y,
      radius,
      closeEnough: util.closeEnoughSqDist(radius),
    );
  }

  @override
  List<int> withinGeographicalRadius(
    num x,
    num y,
    num radiusInKm, {
    num earthRadiusInKm = KDBush.averageEarthRadiusInKm,
  }) =>
      _withinImpl(
        x,
        y,
        radiusInKm,
        closeEnough: util.closeEnoughSpherical(earthRadiusInKm, radiusInKm),
      );

  List<int> _withinImpl(
    num qx,
    num qy,
    num radiusInKm, {
    required util.DistanceFilter closeEnough,
  }) {
    final stack = <int>[0, ids.length - 1, 0];
    final result = <int>[];

    // Recursively search for items within radius in the kd-sorted arrays
    while (stack.isNotEmpty) {
      final axis = stack.removeLast();
      final right = stack.removeLast();
      final left = stack.removeLast();

      // if we reached "tree node", search linearly
      if (right - left <= _nodeSize) {
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
      if (axis == 0 ? qx - radiusInKm <= x : qy - radiusInKm <= y) {
        stack.insert(stack.length, left);
        stack.insert(stack.length, m - 1);
        stack.insert(stack.length, 1 - axis);
      }
      if (axis == 0 ? qx + radiusInKm >= x : qy + radiusInKm >= y) {
        stack.insert(stack.length, m + 1);
        stack.insert(stack.length, right);
        stack.insert(stack.length, 1 - axis);
      }
    }

    return result;
  }
}
