import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../core/services/gemini_service.dart';
import '../../../shared/widgets/answer_option.dart';
import '../bloc/ai_practice_bloc.dart';
import '../bloc/ai_practice_event.dart';
import '../bloc/ai_practice_state.dart';

class AiPracticeScreen extends StatelessWidget {
  const AiPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiPracticeBloc(
        geminiService: context.read<GeminiService>(),
      ),
      child: const _AiPracticeView(),
    );
  }
}

class _AiPracticeView extends StatelessWidget {
  const _AiPracticeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Practice'),
      ),
      body: Column(
        children: [
          _buildCategorySelector(context),
          Expanded(
            child: BlocBuilder<AiPracticeBloc, AiPracticeState>(
              builder: (context, state) {
                if (state is AiPracticeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AiPracticeLoaded) {
                  return _buildQuestionView(context, state);
                }
                if (state is AiPracticeError) {
                  return _buildErrorState(context, state);
                }
                return _buildEmptyState(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return BlocBuilder<AiPracticeBloc, AiPracticeState>(
      buildWhen: (previous, current) =>
          previous.selectedCategory != current.selectedCategory,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AiPracticeBloc.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = AiPracticeBloc.categories[index];
              final isSelected = state.selectedCategory == category;
              final isWeak = state.weakCategories.contains(category);

              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category),
                    if (isWeak) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.trending_down_rounded,
                        size: 14,
                        color: isSelected ? Colors.white : AppColors.warning,
                      ),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  context
                      .read<AiPracticeBloc>()
                      .add(SelectCategory(category));
                },
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                backgroundColor: isWeak
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : null,
                side: BorderSide(
                  color: isWeak && !isSelected
                      ? AppColors.warning.withValues(alpha: 0.4)
                      : Colors.transparent,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'AI-Powered Practice',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Generate unique exam questions tailored to your weak areas. Select a category and start practicing.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<AiPracticeBloc>()
                    .add(const GenerateQuestion());
              },
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate Question'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(BuildContext context, AiPracticeLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.selectedCategory,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            state.question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(state.options.length, (index) {
            final label = String.fromCharCode(65 + index);
            var optionText = state.options[index];
            if (optionText.length > 3 &&
                optionText[1] == '.' &&
                optionText[2] == ' ') {
              optionText = optionText.substring(3);
            }

            AnswerState answerState;
            if (!state.answered) {
              answerState = state.selectedAnswer == index
                  ? AnswerState.selected
                  : AnswerState.idle;
            } else {
              if (index == state.correctIndex) {
                answerState = AnswerState.correct;
              } else if (index == state.selectedAnswer) {
                answerState = AnswerState.wrong;
              } else {
                answerState = AnswerState.idle;
              }
            }

            return AnswerOption(
              label: label,
              text: optionText,
              state: answerState,
              onTap: state.answered
                  ? null
                  : () {
                      context
                          .read<AiPracticeBloc>()
                          .add(SelectAnswer(index));
                    },
            );
          }),
          if (state.answered && state.explanation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.info, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Explanation',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.explanation!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AiPracticeBloc>()
                      .add(const GenerateQuestion());
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Next Question'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AiPracticeError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<AiPracticeBloc>()
                    .add(const GenerateQuestion());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
