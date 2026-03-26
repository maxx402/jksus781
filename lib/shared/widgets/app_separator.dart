import 'package:flutter/material.dart';

/// Simple horizontal or vertical separator line.
class AppSeparator extends StatelessWidget {
  const AppSeparator({
    super.key,
    this.direction = Axis.horizontal,
    this.indent = 0,
  });

  final Axis direction;
  final double indent;

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return Divider(indent: indent, endIndent: indent, height: 1);
    }
    return VerticalDivider(indent: indent, endIndent: indent, width: 1);
  }
}
