import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../core/models/exam_date_model.dart';
import '../../../shared/widgets/app_card.dart';

class ExamInfoScreen extends StatefulWidget {
  const ExamInfoScreen({super.key});

  @override
  State<ExamInfoScreen> createState() => _ExamInfoScreenState();
}

class _ExamInfoScreenState extends State<ExamInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Placeholder exam dates
  final List<ExamDateModel> _examDates = [
    ExamDateModel(
      id: 'feb_2026',
      date: DateTime(2026, 2, 14),
      registrationOpen: DateTime(2025, 11, 1),
      registrationClose: DateTime(2026, 1, 15),
      centers: [],
      year: 2026,
      session: 'February',
    ),
    ExamDateModel(
      id: 'jul_2026',
      date: DateTime(2026, 7, 11),
      registrationOpen: DateTime(2026, 4, 1),
      registrationClose: DateTime(2026, 6, 15),
      centers: [],
      year: 2026,
      session: 'July',
    ),
    ExamDateModel(
      id: 'feb_2027',
      date: DateTime(2027, 2, 13),
      registrationOpen: DateTime(2026, 11, 1),
      registrationClose: DateTime(2027, 1, 15),
      centers: [],
      year: 2027,
      session: 'February',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Info'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Exam Dates'),
            Tab(text: 'Centers'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExamDatesTab(context),
          _buildCentersTab(context),
          _buildResourcesTab(context),
        ],
      ),
    );
  }

  Widget _buildExamDatesTab(BuildContext context) {
    final theme = Theme.of(context);
    final upcomingExams =
        _examDates.where((e) => e.isUpcoming).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final nextExam = upcomingExams.isNotEmpty ? upcomingExams.first : null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Countdown to next exam
        if (nextExam != null) ...[
          AppCard(
            borderColor: AppColors.primary,
            child: Column(
              children: [
                Text(
                  'Next Exam',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${nextExam.daysUntilExam}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'days to go',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${nextExam.session} ${nextExam.year} Session',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(nextExam.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        Text(
          'Upcoming Exam Dates',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),

        ...upcomingExams.map((exam) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildExamDateCard(context, exam),
            )),

        // Past exams header
        if (_examDates.any((e) => !e.isUpcoming)) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Past Exams',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._examDates
              .where((e) => !e.isUpcoming)
              .map((exam) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildExamDateCard(context, exam, isPast: true),
                  )),
        ],
      ],
    );
  }

  Widget _buildExamDateCard(BuildContext context, ExamDateModel exam,
      {bool isPast = false}) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy');
    final registrationStatus = _getRegistrationStatus(exam);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: exam.session == 'February'
                      ? AppColors.info.withValues(alpha: 0.1)
                      : AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exam.session,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: exam.session == 'February'
                        ? AppColors.info
                        : AppColors.secondaryDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${exam.year}',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              _buildStatusChip(registrationStatus),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Exam: ${dateFormat.format(exam.date)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.edit_calendar, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Registration: ${dateFormat.format(exam.registrationOpen)} - ${dateFormat.format(exam.registrationClose)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (!isPast && exam.isUpcoming) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${exam.daysUntilExam} days until exam',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  _RegistrationStatus _getRegistrationStatus(ExamDateModel exam) {
    final now = DateTime.now();
    if (now.isBefore(exam.registrationOpen)) {
      return _RegistrationStatus.upcoming;
    } else if (exam.isRegistrationOpen) {
      return _RegistrationStatus.open;
    } else {
      return _RegistrationStatus.closed;
    }
  }

  Widget _buildStatusChip(_RegistrationStatus status) {
    final (label, color) = switch (status) {
      _RegistrationStatus.open => ('Registration Open', AppColors.success),
      _RegistrationStatus.closed => ('Registration Closed', AppColors.error),
      _RegistrationStatus.upcoming => ('Upcoming', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCentersTab(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exam Centers',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'View all available exam centers across Cyprus.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            onTap: () => context.push('/exam-map'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Exam Centers',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Addresses, directions & district info',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildResourceCard(
          context,
          icon: Icons.checklist_rounded,
          title: 'Application Checklist',
          subtitle: 'Track your documents and requirements',
          color: AppColors.success,
          onTap: () => context.push('/checklist'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildResourceCard(
          context,
          icon: Icons.school_rounded,
          title: 'Keep Learning',
          subtitle: 'Greek language & culture courses',
          color: AppColors.culture,
          onTap: () => context.push('/keep-learning'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildResourceCard(
          context,
          icon: Icons.bar_chart_rounded,
          title: 'Performance Heatmap',
          subtitle: 'See your strengths & weak areas',
          color: AppColors.politics,
          onTap: () => context.push('/heatmap'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Useful Links',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLinkRow(
                context,
                icon: Icons.language,
                label: 'Ministry of Interior - Citizenship',
              ),
              const Divider(height: 24),
              _buildLinkRow(
                context,
                icon: Icons.description,
                label: 'Application Form M127',
              ),
              const Divider(height: 24),
              _buildLinkRow(
                context,
                icon: Icons.menu_book,
                label: 'Official Exam Study Guide',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        const Icon(Icons.open_in_new, size: 16, color: AppColors.textSecondary),
      ],
    );
  }
}

enum _RegistrationStatus { open, closed, upcoming }
