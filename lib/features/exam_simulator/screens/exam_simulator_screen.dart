import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../config/constants.dart';
import '../../../core/services/question_repository.dart';
import '../../../shared/widgets/answer_option.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../bloc/exam_simulator_bloc.dart';
import '../bloc/exam_simulator_event.dart';
import '../bloc/exam_simulator_state.dart';
import 'exam_results_screen.dart';

class ExamSimulatorScreen extends StatelessWidget {
  const ExamSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExamSimulatorBloc(
        questionRepository: context.read<QuestionRepository>(),
      ),
      child: const _ExamSimulatorView(),
    );
  }
}

class _ExamSimulatorView extends StatelessWidget {
  const _ExamSimulatorView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamSimulatorBloc, ExamSimulatorState>(
      builder: (context, state) {
        if (state is ExamInitial) {
          return _PreExamView();
        }
        if (state is ExamLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mock Exam')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ExamInProgress) {
          return _InExamView(state: state);
        }
        if (state is ExamCompleted) {
          return ExamResultsView(state: state);
        }
        if (state is ExamError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mock Exam')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Try Again',
                      onPressed: () => context
                          .read<ExamSimulatorBloc>()
                          .add(const StartExam()),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PreExamView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Exam')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz,
              size: 72,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cyprus Citizenship\nMock Exam',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Exam info cards
            AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.help_outline,
                    label: 'Questions',
                    value: '${AppConstants.examQuestionCount}',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: '${AppConstants.examDurationMinutes} minutes',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(
                    icon: Icons.check_circle_outline,
                    label: 'Pass Rate',
                    value:
                        '${(AppConstants.citizenshipPassRate * 100).toInt()}%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Category breakdown
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Distribution',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _CategoryRow(
                    color: AppColors.geography,
                    label: 'Geography',
                    count: AppConstants.geographyQuestions,
                  ),
                  _CategoryRow(
                    color: AppColors.politics,
                    label: 'Politics',
                    count: AppConstants.politicsQuestions,
                  ),
                  _CategoryRow(
                    color: AppColors.culture,
                    label: 'Culture',
                    count: AppConstants.cultureQuestions,
                  ),
                  _CategoryRow(
                    color: AppColors.dailyLife,
                    label: 'Daily Life',
                    count: AppConstants.dailyLifeQuestions,
                  ),
                ],
              ),
            ),

            const Spacer(),

            AppButton(
              label: 'Start Mock Exam',
              icon: Icons.play_arrow,
              onPressed: () {
                context.read<ExamSimulatorBloc>().add(const StartExam());
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _CategoryRow({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            '$count questions',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InExamView extends StatelessWidget {
  final ExamInProgress state;

  const _InExamView({required this.state});

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    final labels = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${state.currentIndex + 1} of ${state.totalQuestions}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Exit exam',
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: _TimerChip(timerDisplay: state.timerDisplay),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (state.currentIndex + 1) / state.totalQuestions,
            minHeight: 4,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Text(
                    question.getText('en'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Answer options
                  ...List.generate(question.options.length, (index) {
                    final isSelected = state.selectedIndex == index;
                    return AnswerOption(
                      label: index < labels.length ? labels[index] : '$index',
                      text: question.options[index].getText('en'),
                      state: isSelected
                          ? AnswerState.selected
                          : AnswerState.idle,
                      onTap: () {
                        context
                            .read<ExamSimulatorBloc>()
                            .add(AnswerQuestion(index));
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Question counter
                  Text(
                    '${state.answers.length}/${state.totalQuestions} answered',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (state.isLastQuestion)
                    SizedBox(
                      width: 160,
                      child: AppButton(
                        label: 'Submit Exam',
                        icon: Icons.check,
                        onPressed: state.hasAnsweredCurrent
                            ? () => context
                                .read<ExamSimulatorBloc>()
                                .add(const SubmitExam())
                            : null,
                      ),
                    )
                  else
                    SizedBox(
                      width: 140,
                      child: AppButton(
                        label: 'Next',
                        icon: Icons.arrow_forward,
                        onPressed: state.hasAnsweredCurrent
                            ? () => context
                                .read<ExamSimulatorBloc>()
                                .add(const NextQuestion())
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue Exam'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final String timerDisplay;

  const _TimerChip({required this.timerDisplay});

  @override
  Widget build(BuildContext context) {
    // Parse minutes to determine urgency
    final parts = timerDisplay.split(':');
    final minutes = int.tryParse(parts[0]) ?? 0;
    final isUrgent = minutes < 5;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: isUrgent ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            timerDisplay,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isUrgent ? AppColors.error : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
