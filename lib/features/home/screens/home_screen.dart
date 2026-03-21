import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_card.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const LoadHome()),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CyCitizenship',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const LoadHome()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loaded = state as HomeLoaded;
          return _HomeContent(state: loaded);
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded state;

  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam Countdown Card
          _ExamCountdownCard(
            nextExamDate: state.nextExamDate,
            daysUntilExam: state.daysUntilExam,
          ),
          const SizedBox(height: AppSpacing.md),

          // Daily Question Card
          _DailyQuestionCard(
            questionsAnswered: state.questionsAnsweredToday,
            isPremium: state.isPremium,
          ),
          const SizedBox(height: AppSpacing.md),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  value: '${state.streak}',
                  label: 'Day Streak',
                  iconColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  icon: Icons.trending_up,
                  value: '${state.averageScore.round()}%',
                  label: 'Avg Score',
                  iconColor: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickActionsGrid(),
        ],
      ),
    );
  }
}

class _ExamCountdownCard extends StatelessWidget {
  final DateTime? nextExamDate;
  final int daysUntilExam;

  const _ExamCountdownCard({
    required this.nextExamDate,
    required this.daysUntilExam,
  });

  @override
  Widget build(BuildContext context) {
    // Progress: assume a 90-day prep window
    const totalPrepDays = 90;
    final daysPassed = totalPrepDays - daysUntilExam;
    final progress = (daysPassed / totalPrepDays).clamp(0.0, 1.0);

    return AppCard(
      borderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Next Exam',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (nextExamDate != null)
                Text(
                  DateFormat('MMM d, yyyy').format(nextExamDate!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$daysUntilExam days remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuestionCard extends StatelessWidget {
  final int questionsAnswered;
  final bool isPremium;

  const _DailyQuestionCard({
    required this.questionsAnswered,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final limit =
        isPremium ? 'Unlimited' : '${AppConstants.freeQuestionsPerDay}';
    final remaining = isPremium
        ? null
        : AppConstants.freeQuestionsPerDay - questionsAnswered;

    return AppCard(
      onTap: () {
        context.push('/ai-practice');
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Question',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  remaining != null && remaining > 0
                      ? '$questionsAnswered / $limit answered today'
                      : isPremium
                          ? '$questionsAnswered answered today'
                          : 'Daily limit reached',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.quiz,
        label: 'Mock Exam',
        color: AppColors.primary,
        route: '/exam-simulator',
      ),
      _QuickAction(
        icon: Icons.style,
        label: 'Flashcards',
        color: AppColors.culture,
        route: '/flashcards',
      ),
      _QuickAction(
        icon: Icons.smart_toy,
        label: 'AI Tutor',
        color: AppColors.politics,
        route: '/ai',
      ),
      _QuickAction(
        icon: Icons.translate,
        label: 'Greek Practice',
        color: AppColors.dailyLife,
        route: '/greek-practice',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: actions,
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
