import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// A reusable chat input field with a send button.
///
/// Parameterized by [sendButtonColor] and [hintText] so it can be shared
/// between the AI Tutor and Greek Practice screens.
class ChatInputField extends StatelessWidget {
  /// Controller for the text field.
  final TextEditingController controller;

  /// Focus node for the text field.
  final FocusNode focusNode;

  /// Called when the user taps send or presses the keyboard send action.
  final VoidCallback onSend;

  /// The color of the circular send button.
  final Color sendButtonColor;

  /// Placeholder text shown when the field is empty.
  final String hintText;

  /// Optional override for the text field fill color.
  /// If null, falls back to [Theme.of(context).colorScheme.surfaceContainerHighest].
  final Color? fillColor;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.sendButtonColor = AppColors.primary,
    this.hintText = 'Ask a question...',
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: fillColor ??
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Send message',
            child: Material(
              color: sendButtonColor,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onSend,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
