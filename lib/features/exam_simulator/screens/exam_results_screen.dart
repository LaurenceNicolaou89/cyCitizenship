import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../bloc/exam_simulator_bloc.dart';
import '../bloc/exam_simulator_event.dart';
import '../bloc/exam_simulator_state.dart';

/// Standalone screen for the /exam-results route.
/// Falls back gracefully if no BLoC is available.
class ExamResultsScreen extends StatelessWidget {
  const ExamResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final bloc = context.read<ExamSimulatorBloc>();
      return BlocBuilder<ExamSimulatorBloc, ExamSimulatorState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ExamCompleted) {
            return ExamResultsView(state: state);
          }
          return _NoResultsFallback();
        },
      );
    } catch (_) {
      return _NoResultsFallback();
    }
  }
}

class _NoResultsFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: AppSpacing.md),
              const Text('No exam results available.'),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Take a Mock Exam',
                onPressed: () => context.go('/exam-simulator'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Go Home',
                variant: AppButtonVariant.text,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable results view, used both from ExamSimulatorScreen (inline)
/// and from the standalone ExamResultsScreen route.
class ExamResultsView extends StatefulWidget {
  final ExamCompleted state;

  const ExamResultsView({super.key, required this.state});

  @override
  State<ExamResultsView> createState() => _ExamResultsViewState();
}

class _ExamResultsViewState extends State<ExamResultsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.state.percentage,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),

            // Animated Score Display
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return _ScoreCircle(
                  score: result.score,
                  total: result.total,
                  percentage: _scoreAnimation.value,
                  passed: result.passed,
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Pass/Fail Indicator
            _PassFailBanner(passed: result.passed),
            const SizedBox(height: AppSpacing.lg),

            // Category Breakdown
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Breakdown',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...result.categoryBreakdown.entries.map(
                    (entry) => _CategoryBreakdownBar(
                      category: entry.key,
                      correct: entry.value['correct'] ?? 0,
                      total: entry.value['total'] ?? 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Weak Category Recommendation
            if (_weakestCategory(result) != null)
              _RecommendationCard(category: _weakestCategory(result)!),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons
            AppButton(
              label: 'Review Answers',
              icon: Icons.visibility,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                // TODO: Navigate to answer review screen
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Try Again',
              icon: Icons.replay,
              onPressed: () {
                context.read<ExamSimulatorBloc>().add(const StartExam());
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Back to Home',
              variant: AppButtonVariant.text,
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String? _weakestCategory(ExamCompleted result) {
    String? weakest;
    double worstRate = 1.0;

    for (final entry in result.categoryBreakdown.entries) {
      final total = entry.value['total'] ?? 0;
      if (total == 0) continue;
      final rate = (entry.value['correct'] ?? 0) / total;
      if (rate < worstRate) {
        worstRate = rate;
        weakest = entry.key;
      }
    }
    return weakest;
  }
}

class _ScoreCircle extends StatelessWidget {
  final int score;
  final int total;
  final double percentage;
  final bool passed;

  const _ScoreCircle({
    required this.score,
    required this.total,
    required this.percentage,
    required this.passed,
  });

  @override
  Widget build(BuildContext context) {
    final color = passed ? AppColors.success : AppColors.error;

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 12,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score/$total',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                '${percentage.round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PassFailBanner extends StatelessWidget {
  final bool passed;

  const _PassFailBanner({required this.passed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: passed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            passed ? Icons.celebration : Icons.info_outline,
            color: passed ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              passed
                  ? 'Congratulations! You passed!'
                  : 'Not quite. Keep studying!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: passed ? AppColors.success : AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownBar extends StatelessWidget {
  final String category;
  final int correct;
  final int total;

  const _CategoryBreakdownBar({
    required this.category,
    required this.correct,
    required this.total,
  });

  Color get _categoryColor {
    switch (category) {
      case 'geography':
        return AppColors.geography;
      case 'politics':
        return AppColors.politics;
      case 'culture':
        return AppColors.culture;
      case 'daily_life':
        return AppColors.dailyLife;
      default:
        return AppColors.primary;
    }
  }

  String get _displayName {
    switch (category) {
      case 'geography':
        return 'Geography';
      case 'politics':
        return 'Politics';
      case 'culture':
        return 'Culture';
      case 'daily_life':
        return 'Daily Life';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? correct / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '$correct/$total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_categoryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String category;

  const _RecommendationCard({required this.category});

  String get _displayName {
    switch (category) {
      case 'geography':
        return 'Geography';
      case 'politics':
        return 'Politics';
      case 'culture':
        return 'Culture';
      case 'daily_life':
        return 'Daily Life';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.warning,
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus on $_displayName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'This was your weakest category. Practice more to improve your score.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
