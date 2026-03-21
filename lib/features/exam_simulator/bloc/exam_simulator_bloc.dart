import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/constants.dart';
import '../../../core/models/question_model.dart';
import '../../../core/services/firestore_service.dart';
import 'exam_simulator_event.dart';
import 'exam_simulator_state.dart';

class ExamSimulatorBloc
    extends Bloc<ExamSimulatorEvent, ExamSimulatorState> {
  final FirestoreService _firestoreService;
  Timer? _timer;

  ExamSimulatorBloc({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService(),
        super(const ExamInitial()) {
    on<StartExam>(_onStartExam);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<SubmitExam>(_onSubmitExam);
    on<TimerTick>(_onTimerTick);
  }

  Future<void> _onStartExam(
    StartExam event,
    Emitter<ExamSimulatorState> emit,
  ) async {
    emit(const ExamLoading());

    try {
      final questions = <QuestionModel>[];

      // Load questions by category with weighted distribution
      final categoryDistribution = {
        'geography': AppConstants.geographyQuestions,
        'politics': AppConstants.politicsQuestions,
        'culture': AppConstants.cultureQuestions,
        'daily_life': AppConstants.dailyLifeQuestions,
      };

      for (final entry in categoryDistribution.entries) {
        final snapshot = await _firestoreService.getQuestions(
          category: entry.key,
          limit: entry.value,
        );

        final categoryQuestions = snapshot.docs
            .map((doc) => QuestionModel.fromFirestore(doc))
            .toList();

        questions.addAll(categoryQuestions);
      }

      if (questions.isEmpty) {
        emit(const ExamError(
          'No questions available. Please check your internet connection.',
        ));
        return;
      }

      // Shuffle all questions
      questions.shuffle();

      // Ensure we have exactly the exam question count (or fewer if not enough)
      final examQuestions = questions.length > AppConstants.examQuestionCount
          ? questions.sublist(0, AppConstants.examQuestionCount)
          : questions;

      // Start timer
      _startTimer();

      emit(ExamInProgress(
        questions: examQuestions,
        currentIndex: 0,
        answers: const {},
        remainingSeconds: AppConstants.examDurationMinutes * 60,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load exam questions: $e');
      }
      emit(const ExamError('Something went wrong. Please try again.'));
    }
  }

  void _onAnswerQuestion(
    AnswerQuestion event,
    Emitter<ExamSimulatorState> emit,
  ) {
    if (state is! ExamInProgress) return;
    final current = state as ExamInProgress;

    final updatedAnswers = Map<int, int>.from(current.answers);
    updatedAnswers[current.currentIndex] = event.selectedIndex;

    emit(current.copyWith(
      answers: updatedAnswers,
      selectedIndex: () => event.selectedIndex,
    ));
  }

  void _onNextQuestion(
    NextQuestion event,
    Emitter<ExamSimulatorState> emit,
  ) {
    if (state is! ExamInProgress) return;
    final current = state as ExamInProgress;

    if (current.isLastQuestion) {
      // Auto-submit on last question
      add(const SubmitExam());
      return;
    }

    emit(current.copyWith(
      currentIndex: current.currentIndex + 1,
      selectedIndex: () => current.answers[current.currentIndex + 1],
    ));
  }

  void _onSubmitExam(
    SubmitExam event,
    Emitter<ExamSimulatorState> emit,
  ) {
    if (state is! ExamInProgress) return;
    final current = state as ExamInProgress;

    _timer?.cancel();

    // Calculate score and category breakdown
    int correctCount = 0;
    final categoryBreakdown = <String, Map<String, int>>{};

    for (int i = 0; i < current.questions.length; i++) {
      final question = current.questions[i];
      final category = question.category;

      categoryBreakdown.putIfAbsent(
        category,
        () => {'correct': 0, 'total': 0},
      );
      categoryBreakdown[category]!['total'] =
          (categoryBreakdown[category]!['total'] ?? 0) + 1;

      if (current.answers.containsKey(i) &&
          current.answers[i] == question.correctIndex) {
        correctCount++;
        categoryBreakdown[category]!['correct'] =
            (categoryBreakdown[category]!['correct'] ?? 0) + 1;
      }
    }

    final passed = current.questions.isNotEmpty &&
        (correctCount / current.questions.length) >=
            AppConstants.citizenshipPassRate;

    emit(ExamCompleted(
      score: correctCount,
      total: current.questions.length,
      categoryBreakdown: categoryBreakdown,
      answers: current.answers,
      questions: current.questions,
      passed: passed,
    ));
  }

  void _onTimerTick(
    TimerTick event,
    Emitter<ExamSimulatorState> emit,
  ) {
    if (state is! ExamInProgress) return;
    final current = state as ExamInProgress;

    if (current.remainingSeconds <= 1) {
      add(const SubmitExam());
      return;
    }

    emit(current.copyWith(
      remainingSeconds: current.remainingSeconds - 1,
    ));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const TimerTick()),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
