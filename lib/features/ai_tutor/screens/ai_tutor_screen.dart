import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../shared/widgets/chat_input_field.dart';
import '../../../shared/widgets/chat_message_bubble.dart';
import '../../../shared/widgets/paywall_screen.dart';
import '../../../shared/widgets/typing_indicator.dart';
import '../bloc/ai_tutor_bloc.dart';
import '../bloc/ai_tutor_event.dart';
import '../bloc/ai_tutor_state.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<AiTutorBloc>().add(SendMessage(text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        actions: [
          BlocBuilder<AiTutorBloc, AiTutorState>(
            builder: (context, state) {
              if (state is AiTutorLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: state.limitReached
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.messagesUsedToday}/${state.dailyLimit} today',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: state.limitReached
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear conversation',
            onPressed: () {
              context.read<AiTutorBloc>().add(const ClearConversation());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiTutorBloc, AiTutorState>(
              listener: (context, state) {
                if (state is AiTutorLoaded || state is AiTutorLoading) {
                  _scrollToBottom();
                }
                if (state is AiTutorError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final messages = switch (state) {
                  AiTutorLoaded(:final messages) => messages,
                  AiTutorLoading(:final messages) => messages,
                  AiTutorError(:final previousMessages) => previousMessages,
                  _ => <AiTutorChatMessage>[],
                };
                final isLoading = state is AiTutorLoading;

                if (messages.isEmpty && !isLoading) {
                  return _buildGreeting(context);
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isLoading) {
                      return const TypingIndicator(
                        accentColor: AppColors.primary,
                        avatarIcon: Icons.school_rounded,
                      );
                    }
                    final msg = messages[index];
                    return ChatMessageBubble(
                      text: msg.content,
                      isUser: msg.isUser,
                      accentColor: AppColors.primary,
                      avatarIcon: Icons.school_rounded,
                    );
                  },
                );
              },
            ),
          ),
          BlocBuilder<AiTutorBloc, AiTutorState>(
            builder: (context, state) {
              final limitReached =
                  state is AiTutorLoaded && state.limitReached;

              if (limitReached) {
                return _buildUpgradePrompt(context);
              }

              return ChatInputField(
                controller: _controller,
                focusNode: _focusNode,
                onSend: _sendMessage,
                sendButtonColor: AppColors.primary,
                hintText: 'Ask a question...',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cyprus Citizenship Tutor',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ask me anything about the Cyprus citizenship exam -- history, politics, geography, culture, or daily life in Cyprus.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: 'History of Cyprus',
                  onTap: () =>
                      _sendSuggestion('Tell me about the history of Cyprus'),
                ),
                _SuggestionChip(
                  label: 'Political system',
                  onTap: () => _sendSuggestion(
                      'How does the political system of Cyprus work?'),
                ),
                _SuggestionChip(
                  label: 'Exam tips',
                  onTap: () => _sendSuggestion(
                      'What are the most important topics for the citizenship exam?'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendSuggestion(String text) {
    context.read<AiTutorBloc>().add(SendMessage(text));
  }

  Widget _buildUpgradePrompt(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.secondary,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Daily message limit reached',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Upgrade to Premium for 50 messages per day',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                PaywallScreen.show(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('Upgrade to Premium'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
