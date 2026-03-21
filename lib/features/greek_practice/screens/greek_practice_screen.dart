import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/gemini_service.dart';
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
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          _buildInputField(),
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

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type in Greek or English...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _sendMessage(_controller.text),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
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
                color:
                    isSelected ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.translate_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: SelectableText(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : const Color(0xFFF0F0F0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animations[i].value),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
