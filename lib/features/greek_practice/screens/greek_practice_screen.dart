import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../config/theme.dart';
import '../../../core/services/gemini_service.dart';
import '../../../shared/widgets/chat_input_field.dart';
import '../../../shared/widgets/chat_message_bubble.dart';
import '../../../shared/widgets/typing_indicator.dart';

class _GreekChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  const _GreekChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';
}

class GreekPracticeScreen extends StatefulWidget {
  final GeminiService geminiService;

  const GreekPracticeScreen({super.key, required this.geminiService});

  @override
  State<GreekPracticeScreen> createState() => _GreekPracticeScreenState();
}

class _GreekPracticeScreenState extends State<GreekPracticeScreen> {
  static const _scenarios = [
    ('Ordering food', Icons.restaurant_rounded),
    ('Asking directions', Icons.directions_rounded),
    ('At the doctor', Icons.local_hospital_rounded),
    ('Government office', Icons.account_balance_rounded),
  ];

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  String _level = 'B1';
  final List<_GreekChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Timer(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  List<Content> _buildHistory() {
    // Exclude the last user message (it will be sent as the new message)
    final historyMessages =
        _messages.length > 1 ? _messages.sublist(0, _messages.length - 1) : [];
    return historyMessages
        .map((m) => Content(m.isUser ? 'user' : 'model', [
              TextPart(m.content),
            ]))
        .toList();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_GreekChatMessage(
        role: 'user',
        content: text.trim(),
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final history = _buildHistory();
      final response = await widget.geminiService.greekPractice(
        history,
        text.trim(),
        level: _level,
      );

      setState(() {
        _messages.add(_GreekChatMessage(
          role: 'assistant',
          content: response,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get response. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _aiBubbleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkSurface
        : const Color(0xFFF0F0F0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Greek Practice'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildLevelToggle(),
          Expanded(
            child: _messages.isEmpty
                ? _buildScenarioSelector()
                : _buildChatView(),
          ),
          ChatInputField(
            controller: _controller,
            focusNode: _focusNode,
            onSend: () => _sendMessage(_controller.text),
            sendButtonColor: AppColors.success,
            hintText: 'Type in Greek or English...',
            fillColor: AppColors.background,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Level:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _LevelButton(
            label: 'A2',
            subtitle: 'Elementary',
            isSelected: _level == 'A2',
            onTap: () => setState(() => _level = 'A2'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _LevelButton(
            label: 'B1',
            subtitle: 'Intermediate',
            isSelected: _level == 'B1',
            onTap: () => setState(() => _level = 'B1'),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSelector() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.translate_rounded,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Practice Greek',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Practice conversational Greek with AI. Choose a scenario to get started or type your own message.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ...List.generate(_scenarios.length, (index) {
              final (label, icon) = _scenarios[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _sendMessage(
                      "Let's practice a conversation about: $label. "
                      "Start the dialogue in Greek at $_level level.",
                    ),
                    icon: Icon(icon),
                    label: Text(label),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return TypingIndicator(
            accentColor: AppColors.success,
            avatarIcon: Icons.translate_rounded,
            bubbleColor: _aiBubbleColor(context),
          );
        }
        final msg = _messages[index];
        return ChatMessageBubble(
          text: msg.content,
          isUser: msg.isUser,
          accentColor: AppColors.success,
          avatarIcon: Icons.translate_rounded,
          aiBubbleColor: _aiBubbleColor(context),
        );
      },
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.success.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.success : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
