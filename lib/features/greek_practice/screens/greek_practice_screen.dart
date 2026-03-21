import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/gemini_service.dart';
import '../../../shared/widgets/chat_input_field.dart';
import '../../../shared/widgets/chat_message_bubble.dart';
import '../../../shared/widgets/typing_indicator.dart';
import '../bloc/greek_practice_bloc.dart';
import '../bloc/greek_practice_event.dart';
import '../bloc/greek_practice_state.dart';

class GreekPracticeScreen extends StatelessWidget {
  const GreekPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GreekPracticeBloc(
        geminiService: context.read<GeminiService>(),
      ),
      child: const _GreekPracticeView(),
    );
  }
}

class _GreekPracticeView extends StatefulWidget {
  const _GreekPracticeView();

  @override
  State<_GreekPracticeView> createState() => _GreekPracticeViewState();
}

class _GreekPracticeViewState extends State<_GreekPracticeView> {
  static const _scenarios = [
    ('Ordering food', Icons.restaurant_rounded),
    ('Asking directions', Icons.directions_rounded),
    ('At the doctor', Icons.local_hospital_rounded),
    ('Government office', Icons.account_balance_rounded),
  ];

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(milliseconds: 100), () {
        if (!mounted) return;
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    context.read<GreekPracticeBloc>().add(SendGreekMessage(text));
  }

  String _currentLevel(GreekPracticeState state) {
    return switch (state) {
      GreekPracticeInitial(:final level) => level,
      GreekPracticeLoading(:final level) => level,
      GreekPracticeLoaded(:final level) => level,
      GreekPracticeError(:final level) => level,
    };
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
          BlocBuilder<GreekPracticeBloc, GreekPracticeState>(
            builder: (context, state) {
              final messages = _extractMessages(state);
              if (messages.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    context
                        .read<GreekPracticeBloc>()
                        .add(const ResetGreekConversation());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLevelToggle(),
          Expanded(
            child: BlocConsumer<GreekPracticeBloc, GreekPracticeState>(
              listener: (context, state) {
                if (state is GreekPracticeLoaded ||
                    state is GreekPracticeLoading) {
                  _scrollToBottom();
                }
                if (state is GreekPracticeError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final messages = _extractMessages(state);
                final isLoading = state is GreekPracticeLoading;

                if (messages.isEmpty && !isLoading) {
                  return _buildScenarioSelector(state);
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isLoading) {
                      return TypingIndicator(
                        accentColor: AppColors.success,
                        avatarIcon: Icons.translate_rounded,
                        bubbleColor: _aiBubbleColor(context),
                      );
                    }
                    final msg = messages[index];
                    return ChatMessageBubble(
                      text: msg.content,
                      isUser: msg.isUser,
                      accentColor: AppColors.success,
                      avatarIcon: Icons.translate_rounded,
                      aiBubbleColor: _aiBubbleColor(context),
                    );
                  },
                );
              },
            ),
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

  List<ChatMessage> _extractMessages(GreekPracticeState state) {
    return switch (state) {
      GreekPracticeLoaded(:final messages) => messages,
      GreekPracticeLoading(:final messages) => messages,
      GreekPracticeError(:final previousMessages) => previousMessages,
      _ => <ChatMessage>[],
    };
  }

  Widget _buildLevelToggle() {
    return BlocBuilder<GreekPracticeBloc, GreekPracticeState>(
      builder: (context, state) {
        final level = _currentLevel(state);
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
                isSelected: level == 'A2',
                onTap: () => context
                    .read<GreekPracticeBloc>()
                    .add(const SwitchLanguageLevel('A2')),
              ),
              const SizedBox(width: AppSpacing.sm),
              _LevelButton(
                label: 'B1',
                subtitle: 'Intermediate',
                isSelected: level == 'B1',
                onTap: () => context
                    .read<GreekPracticeBloc>()
                    .add(const SwitchLanguageLevel('B1')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScenarioSelector(GreekPracticeState state) {
    final level = _currentLevel(state);
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
                      "Start the dialogue in Greek at $level level.",
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
