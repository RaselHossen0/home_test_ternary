import 'package:flutter/material.dart';

Color priorityColor(BuildContext context, String priority) {
  final scheme = Theme.of(context).colorScheme;
  return switch (priority) {
    'high' => scheme.error,
    'medium' => (scheme.tertiary),
    _ => scheme.primary,
  };
}

Color statusColor(BuildContext context, String status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    'completed' => Colors.green,
    'in-progress' => scheme.secondary,
    'pending' => Colors.amber,
    _ => scheme.primary,
  };
}

Widget statusDot(BuildContext context, String status) {
  return Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: statusColor(context, status),
      shape: BoxShape.circle,
    ),
  );
}

Widget priorityChip(BuildContext context, String priority) {
  final color = priorityColor(context, priority);
  return Chip(
    avatar: const Icon(Icons.priority_high, size: 16),
    label: Text(priority),
    backgroundColor: color.withOpacity(0.15),
    labelStyle: TextStyle(color: color),
  );
}

Widget coloredChip(BuildContext context,
    {required String label, required Color color, IconData? icon}) {
  return Chip(
    avatar: icon != null ? Icon(icon, size: 16, color: color) : null,
    label: Text(label),
    backgroundColor: color.withOpacity(0.15),
    labelStyle: TextStyle(color: color),
  );
}

// Generate a stable, vibrant color for categories
Color categoryColor(BuildContext context, String category) {
  if (category.isEmpty) return Theme.of(context).colorScheme.outline;
  final hash =
      category.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0xFFFFFFFF);
  final hue = (hash % 360).toDouble();
  final hsl = HSLColor.fromAHSL(1, hue, 0.55, 0.55);
  return hsl.toColor();
}

// Left-side border decoration for priority emphasis
BoxDecoration priorityBorderDecoration(BuildContext context, String priority) {
  final color = priorityColor(context, priority);
  return BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border(
      left: BorderSide(color: color, width: 5),
    ),
  );
}
