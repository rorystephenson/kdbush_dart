import 'package:kdbush/src/kdbush_impl.dart';

abstract class KDBush<T, U extends num> {
  /// Length of the index
  int get length;

  /// A very fast static spatial index for 2D points based on a flat KD-tree.
  /// Supports points only and the index cannot be modified.
  ///
  /// Ported from the javascript kdbush library: https://github.com/mourner/kdbush
  factory KDBush({
    required List<T> points,
    required U Function(T) getX,
    required U Function(T) getY,
    int nodeSize,
  }) = KDBushImpl;

  /// Returns the indexes of the input points which are within the specified
  /// bounds.
  List<int> withinBounds(U minX, U minY, U maxX, U maxY);

  /// Returns the indexes of the input points which are within the specified
  /// [radius] from the [x] and [y] point.
  List<int> withinRadius(num x, num y, num radius);

  /// Returns the indexes of the input points which are within the specified
  /// [radiusInKm] from the specified [longitude] and [latitude]. More
  /// specifically this returns the
  List<int> withinGeographicalRadius(
    num longitude,
    num latitude,
    num radiusInKm,
  );
}
