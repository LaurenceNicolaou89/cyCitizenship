import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../../config/theme.dart';
import '../../../core/services/question_repository.dart';
import '../../../shared/widgets/app_chip.dart';
import '../bloc/flashcards_bloc.dart';
import '../bloc/flashcards_event.dart';
import '../bloc/flashcards_state.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlashcardsBloc(
        questionRepository: context.read<QuestionRepository>(),
      )..add(const LoadFlashcards()),
      child: const _FlashcardsView(),
    );
  }
}

class _FlashcardsView extends StatefulWidget {
  const _FlashcardsView();

  @override
  State<_FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<_FlashcardsView> {
  String? _selectedCategory;
  final CardSwiperController _swiperController = CardSwiperController();

  static const _categories = [
    {'label': 'All', 'value': null, 'color': null},
    {'label': 'Geography', 'value': 'geography', 'color': AppColors.geography},
    {'label': 'Politics', 'value': 'politics', 'color': AppColors.politics},
    {'label': 'Culture', 'value': 'culture', 'color': AppColors.culture},
    {
      'label': 'Daily Life',
      'value': 'daily_life',
      'color': AppColors.dailyLife
    },
  ];

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    context.read<FlashcardsBloc>().add(LoadFlashcards(category: category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(
            child: BlocBuilder<FlashcardsBloc, FlashcardsState>(
              builder: (context, state) {
                if (state is FlashcardsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FlashcardsError) {
                  return _buildErrorView(state.message);
                }
                if (state is FlashcardsCompleted) {
                  return _buildCompletionView(state);
                }
                if (state is FlashcardsLoaded) {
                  return _buildFlashcardView(state);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: _categories.map((cat) {
          final value = cat['value'] as String?;
          final label = cat['label'] as String;
          final color = cat['color'] as Color?;
          final isSelected = _selectedCategory == value;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppChip(
              label: label,
              selected: isSelected,
              backgroundColor: color,
              onTap: () => _onCategorySelected(value),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlashcardView(FlashcardsLoaded state) {
    return Column(
      children: [
        // Card counter
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.currentIndex + 1}/${state.totalCards}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${state.correctCount}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.cancel, color: AppColors.error, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${state.incorrectCount}',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: LinearProgressIndicator(
            value: state.totalCards > 0
                ? (state.currentIndex + 1) / state.totalCards
                : 0,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Swipeable card area
        Expanded(
          child: CardSwiper(
            controller: _swiperController,
            cardsCount: state.cards.length,
            initialIndex: state.currentIndex,
            numberOfCardsDisplayed: 1,
            isLoop: false,
            backCardOffset: const Offset(0, 0),
            allowedSwipeDirection:
                const AllowedSwipeDirection.symmetric(horizontal: true),
            onSwipe: _onSwipe,
            onEnd: () {
              // All cards swiped
            },
            cardBuilder: (context, index, percentThresholdX,
                percentThresholdY) {
              if (index >= state.cards.length) return const SizedBox.shrink();
              final card = state.cards[index];
              final isCurrentCard = index == state.currentIndex;
              final isFlipped = isCurrentCard && state.isFlipped;

              return _FlashcardWidget(
                question: card.getText('en'),
                answer: card.options.isNotEmpty
                    ? card.options[card.correctIndex].getText('en')
                    : card.getExplanation('en'),
                category: card.category,
                boxLevel: state.boxLevels[card.id] ?? 0,
                isFlipped: isFlipped,
                onTap: () {
                  context.read<FlashcardsBloc>().add(const FlipCard());
                },
                swipeProgress: percentThresholdX.toDouble(),
              );
            },
          ),
        ),

        // Swipe hint text
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            'Tap to flip, swipe to answer',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),

        // Fallback buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _swiperController.swipe(CardSwiperDirection.left);
                  },
                  icon: const Icon(Icons.close, color: AppColors.error),
                  label: const Text("Don't Know"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _swiperController.swipe(CardSwiperDirection.right);
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Know It'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.right) {
      context.read<FlashcardsBloc>().add(const SwipeRight());
    } else if (direction == CardSwiperDirection.left) {
      context.read<FlashcardsBloc>().add(const SwipeLeft());
    }
    return true;
  }

  Widget _buildCompletionView(FlashcardsCompleted state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration_outlined,
              size: 80,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Session Complete!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'You reviewed ${state.reviewed} cards',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  'Correct',
                  '${state.correct}',
                  AppColors.success,
                  Icons.check_circle,
                ),
                _buildStatColumn(
                  'Incorrect',
                  '${state.incorrect}',
                  AppColors.error,
                  Icons.cancel,
                ),
                _buildStatColumn(
                  'Accuracy',
                  '${state.accuracy.toStringAsFixed(0)}%',
                  AppColors.primary,
                  Icons.analytics,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Restart button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<FlashcardsBloc>().add(
                        LoadFlashcards(category: _selectedCategory),
                      );
                },
                icon: const Icon(Icons.replay),
                label: const Text('Study Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                context.read<FlashcardsBloc>().add(
                      LoadFlashcards(category: _selectedCategory),
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Flip-animated flashcard widget ----------

class _FlashcardWidget extends StatelessWidget {
  final String question;
  final String answer;
  final String category;
  final int boxLevel;
  final bool isFlipped;
  final VoidCallback onTap;
  final double swipeProgress;

  const _FlashcardWidget({
    required this.question,
    required this.answer,
    required this.category,
    required this.boxLevel,
    required this.isFlipped,
    required this.onTap,
    this.swipeProgress = 0,
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

  String get _categoryLabel {
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
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: isFlipped ? 1 : 0,
          end: isFlipped ? 1 : 0,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          final angle = value * pi;
          final showBack = value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardFace(
                      context,
                      isBack: true,
                    ),
                  )
                : _buildCardFace(context, isBack: false),
          );
        },
      ),
    );
  }

  Widget _buildCardFace(BuildContext context, {required bool isBack}) {
    // Overlay color based on swipe direction
    Color? overlayColor;
    double overlayOpacity = 0;
    if (swipeProgress > 0.1) {
      overlayColor = AppColors.success;
      overlayOpacity = (swipeProgress.abs() * 0.3).clamp(0.0, 0.3);
    } else if (swipeProgress < -0.1) {
      overlayColor = AppColors.error;
      overlayOpacity = (swipeProgress.abs() * 0.3).clamp(0.0, 0.3);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _categoryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isBack
                    ? [
                        _categoryColor.withValues(alpha: 0.05),
                        _categoryColor.withValues(alpha: 0.15),
                      ]
                    : [
                        Theme.of(context).colorScheme.surface,
                        _categoryColor.withValues(alpha: 0.05),
                      ],
              ),
            ),
            child: Column(
              children: [
                // Top row: category + box level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppChip(
                      label: _categoryLabel,
                      backgroundColor: _categoryColor,
                      selected: true,
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: i <= boxLevel
                                ? _categoryColor
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                // Card content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isBack ? Icons.lightbulb_outline : Icons.quiz_outlined,
                          size: 36,
                          color: _categoryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          isBack ? 'ANSWER' : 'QUESTION',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: _categoryColor,
                                    letterSpacing: 2,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          isBack ? answer : question,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    height: 1.4,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom hint
                Text(
                  isBack ? 'Swipe or tap buttons below' : 'Tap to reveal answer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),

          // Swipe direction overlay
          if (overlayColor != null && overlayOpacity > 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: overlayColor.withValues(alpha: overlayOpacity),
                ),
                child: Center(
                  child: Icon(
                    swipeProgress > 0 ? Icons.check : Icons.close,
                    size: 80,
                    color: Colors.white.withValues(
                        alpha: (overlayOpacity * 3).clamp(0.0, 1.0)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
