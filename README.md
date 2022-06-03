A very fast static spatial index for 2D points based on a flat KD-tree. Ported from the [javascript kdbush package](https://github.com/mourner/kdbush). Only points are supported
(no rectangles) and points may not be added/removed.

## Usage

```dart
import 'dart:math';
import 'package:kdbush/kdbush.dart';

void main() {
  final points = <Point<int>>[
    Point(2, 2),
    Point(2, 4),
    Point(4, 2),
    Point(4, 4),
  ];

  final kdbush = KDBush<Point<int>, int>(
    points: points,
    getX: (p) => p.x,
    getY: (p) => p.y,
    nodeSize: 10,
  );

  final withinRadiusPoints = <Point<int>>[];
  for (final index in kdbush.withinRadius(4, 3, 2)) {
    withinRadiusPoints.add(points[index]);
  }
  print('Within radius: ${withinRadiusPoints.join(',')}'); // Within radius: Point(4, 2),Point(4, 4)

  final withinBoundsPoints = <Point<int>>[];
  for (final index in kdbush.withinBounds(0, 0, 2, 4)) {
    withinBoundsPoints.add(points[index]);
  }
  print('Within bounds: ${withinBoundsPoints.join(',')}'); // Within bounds: Point(2, 2),Point(2, 4)
}
```
