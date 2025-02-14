import 'package:flutter/material.dart';

enum CarouselDirection {
  previous,
  next,
}

class CarouselControls extends StatelessWidget {
  final CarouselDirection direction;
  final VoidCallback onTap;
  final bool enabled;

  const CarouselControls({
    super.key,
    required this.direction,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: enabled
                  ? Theme.of(context).colorScheme.surface.withAlpha(204)
                  : Theme.of(context).colorScheme.surface.withAlpha(77),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              direction == CarouselDirection.next
                  ? Icons.chevron_right
                  : Icons.chevron_left,
              color: enabled
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withAlpha(77),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
