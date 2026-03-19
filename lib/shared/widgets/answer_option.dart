import 'package:flutter/material.dart';
import '../../config/theme.dart';

enum AnswerState { idle, selected, correct, wrong }

class AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerOption({
    super.key,
    required this.label,
    required this.text,
    this.state = AnswerState.idle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (borderColor, bgColor, icon) = switch (state) {
      AnswerState.idle => (
          AppColors.border,
          Colors.transparent,
          null,
        ),
      AnswerState.selected => (
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.08),
          null,
        ),
      AnswerState.correct => (
          AppColors.success,
          AppColors.success.withValues(alpha: 0.08),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ),
      AnswerState.wrong => (
          AppColors.error,
          AppColors.error.withValues(alpha: 0.08),
          const Icon(Icons.cancel, color: AppColors.error, size: 20),
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state == AnswerState.selected
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: state == AnswerState.selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: state == AnswerState.selected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ?icon,
          ],
        ),
      ),
    );
  }
}
