import 'package:equatable/equatable.dart';

import '../../../core/models/question_model.dart';

abstract class ExamSimulatorState extends Equatable {
  const ExamSimulatorState();

  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamSimulatorState {
  const ExamInitial();
}

class ExamLoading extends ExamSimulatorState {
  const ExamLoading();
}

class ExamInProgress extends ExamSimulatorState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<int, int> answers; // questionIndex -> selectedOptionIndex
  final int remainingSeconds;
  final int? selectedIndex;

  const ExamInProgress({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.remainingSeconds,
    this.selectedIndex,
  });

  int get totalQuestions => questions.length;
  QuestionModel get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex == questions.length - 1;
  bool get hasAnsweredCurrent => answers.containsKey(currentIndex);

  String get timerDisplay {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ExamInProgress copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    Map<int, int>? answers,
    int? remainingSeconds,
    int? Function()? selectedIndex,
  }) {
    return ExamInProgress(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      selectedIndex:
          selectedIndex != null ? selectedIndex() : this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        answers,
        remainingSeconds,
        selectedIndex,
      ];
}

class ExamCompleted extends ExamSimulatorState {
  final int score;
  final int total;
  final Map<String, Map<String, int>> categoryBreakdown; // category -> {correct, total}
  final Map<int, int> answers;
  final List<QuestionModel> questions;
  final bool passed;

  const ExamCompleted({
    required this.score,
    required this.total,
    required this.categoryBreakdown,
    required this.answers,
    required this.questions,
    required this.passed,
  });

  double get percentage => total > 0 ? (score / total) * 100 : 0;

  @override
  List<Object?> get props => [score, total, passed, categoryBreakdown];
}

class ExamError extends ExamSimulatorState {
  final String message;

  const ExamError(this.message);

  @override
  List<Object?> get props => [message];
}
