import 'package:flutter_test/flutter_test.dart';
import 'package:cy_citizenship/features/exam_simulator/bloc/exam_simulator_event.dart';
import 'package:cy_citizenship/features/exam_simulator/bloc/exam_simulator_state.dart';
import 'package:cy_citizenship/config/constants.dart';

void main() {
  group('ExamSimulatorState', () {
    test('ExamInitial is correct initial state', () {
      expect(const ExamInitial(), isA<ExamSimulatorState>());
    });

    test('ExamCompleted calculates pass correctly for citizenship', () {
      const state = ExamCompleted(
        score: 15,
        total: 25,
        categoryBreakdown: {
          'geography': {'correct': 4, 'total': 6},
          'politics': {'correct': 5, 'total': 7},
          'culture': {'correct': 3, 'total': 6},
          'daily_life': {'correct': 3, 'total': 6},
        },
        answers: {},
        questions: [],
        passed: true,
      );

      expect(state.score, 15);
      expect(state.total, 25);
      expect(state.passed, true);
      expect(state.percentage, 60.0);
    });

    test('ExamCompleted detects failure', () {
      const state = ExamCompleted(
        score: 10,
        total: 25,
        categoryBreakdown: {},
        answers: {},
        questions: [],
        passed: false,
      );

      expect(state.passed, false);
      expect(state.percentage, 40.0);
    });

    test('ExamCompleted percentage is 0 when total is 0', () {
      const state = ExamCompleted(
        score: 0,
        total: 0,
        categoryBreakdown: {},
        answers: {},
        questions: [],
        passed: false,
      );

      expect(state.percentage, 0);
    });
  });

  group('ExamSimulatorEvent', () {
    test('StartExam is equatable', () {
      expect(const StartExam(), equals(const StartExam()));
    });

    test('AnswerQuestion has selectedIndex', () {
      const event = AnswerQuestion(2);
      expect(event.selectedIndex, 2);
    });

    test('AnswerQuestion equality', () {
      expect(const AnswerQuestion(1), equals(const AnswerQuestion(1)));
    });

    test('TimerTick is equatable', () {
      expect(const TimerTick(), equals(const TimerTick()));
    });

    test('NextQuestion is equatable', () {
      expect(const NextQuestion(), equals(const NextQuestion()));
    });

    test('SubmitExam is equatable', () {
      expect(const SubmitExam(), equals(const SubmitExam()));
    });
  });

  group('AppConstants exam values', () {
    test('exam has correct question count', () {
      expect(AppConstants.examQuestionCount, 25);
    });

    test('exam has correct duration', () {
      expect(AppConstants.examDurationMinutes, 45);
    });

    test('citizenship pass rate is 60%', () {
      expect(AppConstants.citizenshipPassRate, 0.60);
    });

    test('LTR pass rate is 50%', () {
      expect(AppConstants.ltrPassRate, 0.50);
    });

    test('category distribution adds up to 25', () {
      final total = AppConstants.geographyQuestions +
          AppConstants.politicsQuestions +
          AppConstants.cultureQuestions +
          AppConstants.dailyLifeQuestions;
      expect(total, 25);
    });

    test('Leitner intervals are correct', () {
      expect(AppConstants.leitnerIntervals, [1, 3, 7, 14, 30]);
      expect(AppConstants.leitnerIntervals.length, 5);
    });

    test('supported languages', () {
      expect(AppConstants.supportedLanguages, ['en', 'ru', 'el']);
    });
  });
}
