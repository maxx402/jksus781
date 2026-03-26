import 'package:flutter/material.dart';

/// Themed switch matching the shadcn design system.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final switchWidget = Switch.adaptive(
      value: value,
      onChanged: onChanged,
    );

    if (label == null) return switchWidget;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        ),
        switchWidget,
      ],
    );
  }
}
