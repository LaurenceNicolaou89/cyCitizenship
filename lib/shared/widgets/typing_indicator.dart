import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Animated three-dot typing indicator for chat screens.
///
/// Parameterized by [accentColor] and [avatarIcon] so it can be shared
/// between the AI Tutor and Greek Practice screens.
class TypingIndicator extends StatefulWidget {
  /// The accent color used for the avatar circle.
  final Color accentColor;

  /// The icon displayed in the avatar circle.
  final IconData avatarIcon;

  /// Optional override for the bubble background color.
  /// If null, falls back to [Theme.of(context).colorScheme.surfaceContainerHighest].
  final Color? bubbleColor;

  const TypingIndicator({
    super.key,
    this.accentColor = AppColors.primary,
    this.avatarIcon = Icons.school_rounded,
    this.bubbleColor,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.avatarIcon,
              color: Colors.white,
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            decoration: BoxDecoration(
              color: widget.bubbleColor ??
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animations[i].value),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
