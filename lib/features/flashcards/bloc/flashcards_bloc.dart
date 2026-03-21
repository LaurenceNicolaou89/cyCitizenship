import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../config/constants.dart';
import '../../../core/models/question_model.dart';
import '../../../core/services/question_repository.dart';
import 'flashcards_event.dart';
import 'flashcards_state.dart';

class FlashcardsBloc extends Bloc<FlashcardsEvent, FlashcardsState> {
  final QuestionRepository _questionRepository;
  static const String _boxLevelsKey = 'flashcard_box_levels';

  FlashcardsBloc({required QuestionRepository questionRepository})
      : _questionRepository = questionRepository,
        super(const FlashcardsInitial()) {
    on<LoadFlashcards>(_onLoadFlashcards);
    on<SwipeRight>(_onSwipeRight);
    on<SwipeLeft>(_onSwipeLeft);
    on<FlipCard>(_onFlipCard);
    on<NextCard>(_onNextCard);
  }

  /// Load saved box levels from Hive local storage.
  Map<String, int> _loadBoxLevels() {
    try {
      final box = Hive.box('flashcards');
      final raw = box.get(_boxLevelsKey);
      if (raw != null) {
        return Map<String, int>.from(raw as Map);
      }
    } catch (_) {
      // Box not opened or not available — return empty.
    }
    return {};
  }

  /// Persist box levels to Hive.
  Future<void> _saveBoxLevels(Map<String, int> levels) async {
    try {
      final box = Hive.box('flashcards');
      await box.put(_boxLevelsKey, levels);
    } catch (_) {
      // Silently fail — non-critical.
    }
  }

  Future<void> _onLoadFlashcards(
    LoadFlashcards event,
    Emitter<FlashcardsState> emit,
  ) async {
    emit(const FlashcardsLoading());

    try {
      final allQuestions = await _questionRepository.getQuestions(
        category: event.category,
      );

      if (allQuestions.isEmpty) {
        emit(const FlashcardsError(
          'No flashcards available. Please check your internet connection.',
        ));
        return;
      }

      // Load persisted box levels
      final boxLevels = _loadBoxLevels();

      // Prioritize cards: Box 1 (level 0) first, then by ascending box level.
      // Cards due for review based on Leitner intervals are prioritized.
      allQuestions.sort((a, b) {
        final levelA = boxLevels[a.id] ?? 0;
        final levelB = boxLevels[b.id] ?? 0;
        return levelA.compareTo(levelB);
      });

      // Shuffle within same box level groups for variety
      final grouped = <int, List<QuestionModel>>{};
      for (final q in allQuestions) {
        final level = boxLevels[q.id] ?? 0;
        grouped.putIfAbsent(level, () => []).add(q);
      }
      final sortedCards = <QuestionModel>[];
      for (final level in grouped.keys.toList()..sort()) {
        final group = grouped[level]!;
        group.shuffle();
        sortedCards.addAll(group);
      }

      if (sortedCards.isEmpty) {
        emit(const FlashcardsError('No flashcards found.'));
        return;
      }

      // Count mastered cards (box level 4 = last box)
      final masteredCount = boxLevels.values
          .where((level) => level >= AppConstants.leitnerIntervals.length - 1)
          .length;

      emit(FlashcardsLoaded(
        cards: sortedCards,
        currentIndex: 0,
        totalCards: sortedCards.length,
        masteredCount: masteredCount,
        boxLevels: boxLevels,
      ));
    } catch (e) {
      emit(FlashcardsError('Failed to load flashcards: $e'));
    }
  }

  void _onSwipeRight(
    SwipeRight event,
    Emitter<FlashcardsState> emit,
  ) {
    if (state is! FlashcardsLoaded) return;
    final current = state as FlashcardsLoaded;

    final questionId = current.currentCard.id;
    final updatedLevels = Map<String, int>.from(current.boxLevels);
    final currentLevel = updatedLevels[questionId] ?? 0;

    // Advance to next box (max = last box index)
    final maxBox = AppConstants.leitnerIntervals.length - 1;
    updatedLevels[questionId] = (currentLevel + 1).clamp(0, maxBox);

    _saveBoxLevels(updatedLevels);

    final newMastered = updatedLevels.values
        .where((level) => level >= maxBox)
        .length;

    final newReviewed = current.cardsReviewed + 1;
    final newCorrect = current.correctCount + 1;

    if (current.isLastCard) {
      emit(FlashcardsCompleted(
        reviewed: newReviewed,
        correct: newCorrect,
        incorrect: current.incorrectCount,
      ));
      return;
    }

    emit(current.copyWith(
      currentIndex: current.currentIndex + 1,
      isFlipped: false,
      cardsReviewed: newReviewed,
      correctCount: newCorrect,
      masteredCount: newMastered,
      boxLevels: updatedLevels,
    ));
  }

  void _onSwipeLeft(
    SwipeLeft event,
    Emitter<FlashcardsState> emit,
  ) {
    if (state is! FlashcardsLoaded) return;
    final current = state as FlashcardsLoaded;

    final questionId = current.currentCard.id;
    final updatedLevels = Map<String, int>.from(current.boxLevels);

    // Send back to Box 1 (level 0)
    updatedLevels[questionId] = 0;

    _saveBoxLevels(updatedLevels);

    final maxBox = AppConstants.leitnerIntervals.length - 1;
    final newMastered = updatedLevels.values
        .where((level) => level >= maxBox)
        .length;

    final newReviewed = current.cardsReviewed + 1;
    final newIncorrect = current.incorrectCount + 1;

    if (current.isLastCard) {
      emit(FlashcardsCompleted(
        reviewed: newReviewed,
        correct: current.correctCount,
        incorrect: newIncorrect,
      ));
      return;
    }

    emit(current.copyWith(
      currentIndex: current.currentIndex + 1,
      isFlipped: false,
      cardsReviewed: newReviewed,
      incorrectCount: newIncorrect,
      masteredCount: newMastered,
      boxLevels: updatedLevels,
    ));
  }

  void _onFlipCard(
    FlipCard event,
    Emitter<FlashcardsState> emit,
  ) {
    if (state is! FlashcardsLoaded) return;
    final current = state as FlashcardsLoaded;
    emit(current.copyWith(isFlipped: !current.isFlipped));
  }

  void _onNextCard(
    NextCard event,
    Emitter<FlashcardsState> emit,
  ) {
    if (state is! FlashcardsLoaded) return;
    final current = state as FlashcardsLoaded;

    if (current.isLastCard) {
      emit(FlashcardsCompleted(
        reviewed: current.cardsReviewed,
        correct: current.correctCount,
        incorrect: current.incorrectCount,
      ));
      return;
    }

    emit(current.copyWith(
      currentIndex: current.currentIndex + 1,
      isFlipped: false,
    ));
  }
}
