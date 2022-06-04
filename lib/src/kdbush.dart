import 'kdbush_impl.dart';

class KDBush<T, U extends num> {
  final List<T> points;
  final KDBushImpl<T, U> _kdbushImpl;

  /// A very fast static spatial index for 2D points based on a flat KD-tree.
  /// Supports points only and the index cannot be modified.
  ///
  /// Ported from the javascript kdbush library: https://github.com/mourner/kdbush
  KDBush({
    required this.points,
    required U Function(T) getX,
    required U Function(T) getY,
    int nodeSize = 64,
  }) : _kdbushImpl = KDBushImpl(
            points: points, getX: getX, getY: getY, nodeSize: nodeSize);

  /// Returns the indexes of the input points which are within the specified
  /// bounds.
  List<int> withinBounds(U minX, U minY, U maxX, U maxY) =>
      _kdbushImpl.withinBounds(minX, minY, maxX, maxY);

  /// Returns the indexes of the input points which are within the specified
  /// [radius] from the [x] and [y] point.
  List<int> withinRadius(num x, num y, num radius) =>
      _kdbushImpl.withinRadius(x, y, radius);
}
