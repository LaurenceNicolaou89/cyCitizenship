import 'package:flutter_test/flutter_test.dart';
import 'package:cy_citizenship/core/models/question_model.dart';

void main() {
  group('QuestionModel', () {
    test('getText returns correct language', () {
      const question = QuestionModel(
        id: '1',
        textEn: 'English text',
        textRu: 'Russian text',
        textEl: 'Greek text',
        options: [],
        correctIndex: 0,
        category: 'geography',
        difficulty: 'easy',
        explanation: {'en': 'Explain', 'ru': 'Объяснение', 'el': 'Εξήγηση'},
        source: 'test',
      );

      expect(question.getText('en'), 'English text');
      expect(question.getText('ru'), 'Russian text');
      expect(question.getText('el'), 'Greek text');
      expect(question.getText('fr'), 'English text'); // fallback
    });

    test('getExplanation returns correct language with fallback', () {
      const question = QuestionModel(
        id: '1',
        textEn: 'Q',
        textRu: 'Q',
        textEl: 'Q',
        options: [],
        correctIndex: 0,
        category: 'geography',
        difficulty: 'easy',
        explanation: {'en': 'English explanation'},
        source: 'test',
      );

      expect(question.getExplanation('en'), 'English explanation');
      expect(question.getExplanation('ru'), 'English explanation'); // fallback to en
    });

    test('getExplanation returns empty string when no explanation', () {
      const question = QuestionModel(
        id: '1',
        textEn: 'Q',
        textRu: 'Q',
        textEl: 'Q',
        options: [],
        correctIndex: 0,
        category: 'geography',
        difficulty: 'easy',
        explanation: {},
        source: 'test',
      );

      expect(question.getExplanation('en'), '');
    });

    test('toFirestore produces valid map', () {
      const question = QuestionModel(
        id: '1',
        textEn: 'Q',
        textRu: 'Q',
        textEl: 'Q',
        options: [],
        correctIndex: 2,
        category: 'politics',
        difficulty: 'hard',
        explanation: {},
        source: 'test',
      );

      final map = question.toFirestore();
      expect(map['textEn'], 'Q');
      expect(map['correctIndex'], 2);
      expect(map['category'], 'politics');
      expect(map['difficulty'], 'hard');
      expect(map['source'], 'test');
      expect(map['options'], isEmpty);
    });

    test('equatable uses id, textEn, category, difficulty', () {
      const q1 = QuestionModel(
        id: '1',
        textEn: 'Q',
        textRu: 'Q1',
        textEl: 'Q1',
        options: [],
        correctIndex: 0,
        category: 'geography',
        difficulty: 'easy',
        explanation: {},
        source: 'test',
      );
      const q2 = QuestionModel(
        id: '1',
        textEn: 'Q',
        textRu: 'Q1',
        textEl: 'Q1',
        options: [],
        correctIndex: 0,
        category: 'geography',
        difficulty: 'easy',
        explanation: {},
        source: 'test',
      );
      // All fields match => equal
      expect(q1, equals(q2));
    });
  });

  group('QuestionOption', () {
    test('getText returns correct language', () {
      const option = QuestionOption(
        textEn: 'Nicosia',
        textRu: 'Никосия',
        textEl: 'Λευκωσία',
      );

      expect(option.getText('en'), 'Nicosia');
      expect(option.getText('ru'), 'Никосия');
      expect(option.getText('el'), 'Λευκωσία');
    });

    test('getText falls back to English', () {
      const option = QuestionOption(
        textEn: 'Nicosia',
        textRu: 'Никосия',
        textEl: 'Λευκωσία',
      );

      expect(option.getText('fr'), 'Nicosia');
    });

    test('fromMap creates correct option', () {
      final option = QuestionOption.fromMap({
        'textEn': 'A',
        'textRu': 'Б',
        'textEl': 'Γ',
      });

      expect(option.textEn, 'A');
      expect(option.textRu, 'Б');
      expect(option.textEl, 'Γ');
    });

    test('fromMap handles missing keys', () {
      final option = QuestionOption.fromMap({});

      expect(option.textEn, '');
      expect(option.textRu, '');
      expect(option.textEl, '');
    });

    test('toMap produces correct map', () {
      const option = QuestionOption(
        textEn: 'A',
        textRu: 'Б',
        textEl: 'Γ',
      );

      final map = option.toMap();
      expect(map['textEn'], 'A');
      expect(map['textRu'], 'Б');
      expect(map['textEl'], 'Γ');
    });

    test('equatable works', () {
      const opt1 = QuestionOption(textEn: 'A', textRu: 'Б', textEl: 'Γ');
      const opt2 = QuestionOption(textEn: 'A', textRu: 'Б', textEl: 'Γ');
      expect(opt1, equals(opt2));
    });
  });
}
