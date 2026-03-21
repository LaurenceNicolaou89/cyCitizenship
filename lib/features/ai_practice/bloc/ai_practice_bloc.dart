import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/gemini_service.dart';
import 'ai_practice_event.dart';
import 'ai_practice_state.dart';

class AiPracticeBloc extends Bloc<AiPracticeEvent, AiPracticeState> {
  final GeminiService _geminiService;

  static const categories = [
    'History',
    'Politics',
    'Geography',
    'Culture',
    'Daily Life',
  ];

  AiPracticeBloc({required GeminiService geminiService})
      : _geminiService = geminiService,
        super(const AiPracticeInitial()) {
    on<GenerateQuestion>(_onGenerateQuestion);
    on<SelectCategory>(_onSelectCategory);
    on<SelectAnswer>(_onSelectAnswer);
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<AiPracticeState> emit,
  ) {
    emit(AiPracticeInitial(
      selectedCategory: event.category,
      weakCategories: state.weakCategories,
    ));
  }

  void _onSelectAnswer(
    SelectAnswer event,
    Emitter<AiPracticeState> emit,
  ) {
    if (state is! AiPracticeLoaded) return;
    final current = state as AiPracticeLoaded;
    if (current.answered) return;

    emit(current.copyWith(
      selectedAnswer: () => event.index,
      answered: true,
    ));
  }

  Future<void> _onGenerateQuestion(
    GenerateQuestion event,
    Emitter<AiPracticeState> emit,
  ) async {
    emit(AiPracticeLoading(
      selectedCategory: state.selectedCategory,
      weakCategories: state.weakCategories,
    ));

    try {
      final response = await _geminiService.generatePracticeQuestion(
        category: state.selectedCategory,
        difficulty: 'medium',
        language: 'English',
      );

      final parsed = _parseQuestionResponse(response);
      if (parsed != null) {
        emit(AiPracticeLoaded(
          selectedCategory: state.selectedCategory,
          weakCategories: state.weakCategories,
          question: parsed['question'] as String,
          options: List<String>.from(parsed['options'] as List),
          correctIndex: parsed['correctIndex'] as int,
          explanation: parsed['explanation'] as String?,
        ));
      } else {
        emit(AiPracticeError(
          message: 'Failed to parse question. Please try again.',
          selectedCategory: state.selectedCategory,
          weakCategories: state.weakCategories,
        ));
      }
    } catch (e) {
      emit(AiPracticeError(
        message: 'Failed to generate question. Please try again.',
        selectedCategory: state.selectedCategory,
        weakCategories: state.weakCategories,
      ));
    }
  }

  Map<String, dynamic>? _parseQuestionResponse(String response) {
    try {
      var jsonStr = response;
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        jsonStr = jsonMatch.group(0)!;
      }
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;

      if (decoded.containsKey('question') &&
          decoded.containsKey('options') &&
          decoded.containsKey('correctIndex')) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }
}
