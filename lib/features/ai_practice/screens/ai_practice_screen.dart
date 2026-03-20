import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../core/services/gemini_service.dart';
import '../../../shared/widgets/answer_option.dart';

class AiPracticeScreen extends StatefulWidget {
  final GeminiService geminiService;

  const AiPracticeScreen({super.key, required this.geminiService});

  @override
  State<AiPracticeScreen> createState() => _AiPracticeScreenState();
}

class _AiPracticeScreenState extends State<AiPracticeScreen> {
  static const _categories = [
    'History',
    'Politics',
    'Geography',
    'Culture',
    'Daily Life',
  ];

  // Categories where the user tends to score lower (placeholder for now)
  static const _weakCategories = {'Politics', 'Geography'};

  String _selectedCategory = 'History';
  bool _isLoading = false;
  String? _errorMessage;

  // Current question state
  String? _question;
  List<String> _options = [];
  int? _correctIndex;
  String? _explanation;
  int? _selectedIndex;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Practice'),
      ),
      body: Column(
        children: [
          _buildCategorySelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _question != null
                    ? _buildQuestionView()
                    : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          final isWeak = _weakCategories.contains(category);

          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category),
                if (isWeak) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.trending_down_rounded,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.warning,
                  ),
                ],
              ],
            ),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            backgroundColor: isWeak
                ? AppColors.warning.withValues(alpha: 0.1)
                : null,
            side: BorderSide(
              color: isWeak && !isSelected
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'AI-Powered Practice',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Generate unique exam questions tailored to your weak areas. Select a category and start practicing.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _generateQuestion,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate Question'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selectedCategory,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _question!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(_options.length, (index) {
            final label = String.fromCharCode(65 + index); // A, B, C, D
            // Strip "A. " prefix if present
            var optionText = _options[index];
            if (optionText.length > 3 &&
                optionText[1] == '.' &&
                optionText[2] == ' ') {
              optionText = optionText.substring(3);
            }

            AnswerState answerState;
            if (!_answered) {
              answerState = _selectedIndex == index
                  ? AnswerState.selected
                  : AnswerState.idle;
            } else {
              if (index == _correctIndex) {
                answerState = AnswerState.correct;
              } else if (index == _selectedIndex) {
                answerState = AnswerState.wrong;
              } else {
                answerState = AnswerState.idle;
              }
            }

            return AnswerOption(
              label: label,
              text: optionText,
              state: answerState,
              onTap: _answered ? null : () => _onSelectAnswer(index),
            );
          }),
          if (_answered && _explanation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.info, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Explanation',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _explanation!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateQuestion,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Next Question'),
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onSelectAnswer(int index) {
    setState(() {
      if (_answered) return;
      _selectedIndex = index;
      _answered = true;
    });
  }

  Future<void> _generateQuestion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _question = null;
      _options = [];
      _correctIndex = null;
      _explanation = null;
      _selectedIndex = null;
      _answered = false;
    });

    try {
      final response = await widget.geminiService.generatePracticeQuestion(
        category: _selectedCategory,
        difficulty: 'medium',
        language: 'English',
      );

      final parsed = _parseQuestionResponse(response);
      if (parsed != null) {
        setState(() {
          _question = parsed['question'] as String;
          _options = List<String>.from(parsed['options'] as List);
          _correctIndex = parsed['correctIndex'] as int;
          _explanation = parsed['explanation'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to parse question. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate question. Please try again.';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _parseQuestionResponse(String response) {
    try {
      // Try to extract JSON from the response (it might be wrapped in markdown)
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
