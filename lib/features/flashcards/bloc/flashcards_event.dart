import 'package:equatable/equatable.dart';

abstract class FlashcardsEvent extends Equatable {
  const FlashcardsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlashcards extends FlashcardsEvent {
  final String? category;

  const LoadFlashcards({this.category});

  @override
  List<Object?> get props => [category];
}

class SwipeRight extends FlashcardsEvent {
  const SwipeRight();
}

class SwipeLeft extends FlashcardsEvent {
  const SwipeLeft();
}

class FlipCard extends FlashcardsEvent {
  const FlipCard();
}

class NextCard extends FlashcardsEvent {
  const NextCard();
}
