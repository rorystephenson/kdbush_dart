import 'package:kdbush/src/sort.dart';
import 'package:kdbush/src/within_bounds.dart';
import 'package:kdbush/src/within_radius.dart';

class KDBushImpl<T, U extends num> {
  final int _nodeSize;

  final List<int> ids = [];
  final List<U> coords = [];

  KDBushImpl({
    required List<T> points,
    required U Function(T) getX,
    required U Function(T) getY,
    required int nodeSize,
  }) : _nodeSize = nodeSize {
    for (var i = 0; i < points.length; i++) {
      ids.insert(i, i);
      coords.insert(2 * i, getX(points[i]));
      coords.insert(2 * i + 1, getY(points[i]));
    }

    sortImpl<U>(ids, coords, nodeSize, 0, ids.length - 1, 0);
  }

  List<int> withinBounds(U minX, U minY, U maxX, U maxY) {
    return rangeImpl<U>(ids, coords, minX, minY, maxX, maxY, _nodeSize);
  }

  List<int> withinRadius(num x, num y, num radius) {
    return withinImpl<U>(ids, coords, x, y, radius, _nodeSize);
  }
}
