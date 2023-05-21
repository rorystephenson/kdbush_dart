import 'package:kdbush/src/kdbush.dart';
import 'package:kdbush/src/sort.dart';
import 'package:kdbush/src/within_bounds.dart';
import 'package:kdbush/src/within_radius.dart';

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

    sortImpl<U>(ids, coords, nodeSize, 0, ids.length - 1, 0);
  }

  @override
  List<int> withinBounds(U minX, U minY, U maxX, U maxY) {
    return rangeImpl<U>(ids, coords, minX, minY, maxX, maxY, _nodeSize);
  }

  @override
  List<int> withinRadius(num x, num y, num radius) {
    return withinImpl<U>(
      ids,
      coords,
      x,
      y,
      radius,
      _nodeSize,
    );
  }

  @override
  List<int> withinGeographicalRadius(num x, num y, num radiusInKm) {
    return withinImpl<U>(
      ids,
      coords,
      x,
      y,
      radiusInKm,
      _nodeSize,
      distanceInKmSpherical: true,
    );
  }
}
