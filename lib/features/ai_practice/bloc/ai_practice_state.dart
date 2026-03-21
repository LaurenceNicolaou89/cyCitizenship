import 'package:equatable/equatable.dart';

sealed class AiPracticeState extends Equatable {
  final String selectedCategory;
  final Set<String> weakCategories;

  const AiPracticeState({
    required this.selectedCategory,
    required this.weakCategories,
  });

  @override
  List<Object?> get props => [selectedCategory, weakCategories];
}

class AiPracticeInitial extends AiPracticeState {
  const AiPracticeInitial({
    super.selectedCategory = 'History',
    super.weakCategories = const {'Politics', 'Geography'},
  });
}

class AiPracticeLoading extends AiPracticeState {
  const AiPracticeLoading({
    required super.selectedCategory,
    required super.weakCategories,
  });
}

class AiPracticeLoaded extends AiPracticeState {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final int? selectedAnswer;
  final bool answered;

  const AiPracticeLoaded({
    required super.selectedCategory,
    required super.weakCategories,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.selectedAnswer,
    this.answered = false,
  });

  AiPracticeLoaded copyWith({
    String? selectedCategory,
    Set<String>? weakCategories,
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    int? Function()? selectedAnswer,
    bool? answered,
  }) {
    return AiPracticeLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      weakCategories: weakCategories ?? this.weakCategories,
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      selectedAnswer:
          selectedAnswer != null ? selectedAnswer() : this.selectedAnswer,
      answered: answered ?? this.answered,
    );
  }

  @override
  List<Object?> get props => [
        selectedCategory,
        weakCategories,
        question,
        options,
        correctIndex,
        explanation,
        selectedAnswer,
        answered,
      ];
}

class AiPracticeError extends AiPracticeState {
  final String message;

  const AiPracticeError({
    required this.message,
    required super.selectedCategory,
    required super.weakCategories,
  });

  @override
  List<Object?> get props => [message, selectedCategory, weakCategories];
}
