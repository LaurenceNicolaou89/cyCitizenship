import 'package:equatable/equatable.dart';

import '../../../core/models/question_model.dart';

abstract class FlashcardsState extends Equatable {
  const FlashcardsState();

  @override
  List<Object?> get props => [];
}

class FlashcardsInitial extends FlashcardsState {
  const FlashcardsInitial();
}

class FlashcardsLoading extends FlashcardsState {
  const FlashcardsLoading();
}

class FlashcardsLoaded extends FlashcardsState {
  final List<QuestionModel> cards;
  final int currentIndex;
  final bool isFlipped;
  final int cardsReviewed;
  final int totalCards;
  final int masteredCount;
  final int correctCount;
  final int incorrectCount;
  final Map<String, int> boxLevels; // questionId -> box level (0-4)

  const FlashcardsLoaded({
    required this.cards,
    required this.currentIndex,
    this.isFlipped = false,
    this.cardsReviewed = 0,
    required this.totalCards,
    this.masteredCount = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.boxLevels = const {},
  });

  QuestionModel get currentCard => cards[currentIndex];
  bool get isLastCard => currentIndex >= cards.length - 1;

  FlashcardsLoaded copyWith({
    List<QuestionModel>? cards,
    int? currentIndex,
    bool? isFlipped,
    int? cardsReviewed,
    int? totalCards,
    int? masteredCount,
    int? correctCount,
    int? incorrectCount,
    Map<String, int>? boxLevels,
  }) {
    return FlashcardsLoaded(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      totalCards: totalCards ?? this.totalCards,
      masteredCount: masteredCount ?? this.masteredCount,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      boxLevels: boxLevels ?? this.boxLevels,
    );
  }

  @override
  List<Object?> get props => [
        cards,
        currentIndex,
        isFlipped,
        cardsReviewed,
        totalCards,
        masteredCount,
        correctCount,
        incorrectCount,
        boxLevels,
      ];
}

class FlashcardsCompleted extends FlashcardsState {
  final int reviewed;
  final int correct;
  final int incorrect;

  const FlashcardsCompleted({
    required this.reviewed,
    required this.correct,
    required this.incorrect,
  });

  double get accuracy => reviewed > 0 ? (correct / reviewed) * 100 : 0;

  @override
  List<Object?> get props => [reviewed, correct, incorrect];
}

class FlashcardsError extends FlashcardsState {
  final String message;

  const FlashcardsError(this.message);

  @override
  List<Object?> get props => [message];
}
