import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// A reusable chat message bubble widget.
///
/// Parameterized by [accentColor] and [avatarIcon] so it can be shared
/// between the AI Tutor and Greek Practice screens.
class ChatMessageBubble extends StatelessWidget {
  /// The message text to display.
  final String text;

  /// Whether the message was sent by the user.
  final bool isUser;

  /// The accent color used for the AI avatar circle and user bubble.
  final Color accentColor;

  /// The icon displayed in the AI avatar circle.
  final IconData avatarIcon;

  /// Optional override for the AI-side bubble background.
  /// If null, falls back to [Theme.of(context).colorScheme.surfaceContainerHighest].
  final Color? aiBubbleColor;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.accentColor = AppColors.primary,
    this.avatarIcon = Icons.school_rounded,
    this.aiBubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                avatarIcon,
                color: Colors.white,
                size: 18,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : aiBubbleColor ??
                        Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: SelectableText(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
