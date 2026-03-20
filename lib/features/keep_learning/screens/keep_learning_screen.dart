import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';

class KeepLearningScreen extends StatelessWidget {
  const KeepLearningScreen({super.key});

  static const _courses = [
    _Course(
      title: 'Greek Language B1 Preparation',
      description:
          'Intensive B1-level Greek course designed specifically for citizenship '
          'exam candidates. Covers reading, writing, listening, and speaking '
          'skills required for the official language test.',
      price: '\u20ac450',
      type: _CourseType.inPerson,
      duration: '3 months',
      url: 'https://keeplearning.com.cy/greek-b1',
    ),
    _Course(
      title: 'Cyprus History & Culture Online Course',
      description:
          'Comprehensive online course covering Cypriot history from antiquity '
          'to modern times, political system, geography, and daily life topics. '
          'Aligned with the official citizenship exam syllabus.',
      price: '\u20ac120',
      type: _CourseType.online,
      duration: '6 weeks',
      url: 'https://keeplearning.com.cy/culture-online',
    ),
    _Course(
      title: 'Citizenship Exam Crash Course',
      description:
          'Weekend intensive workshop covering all exam categories: geography, '
          'politics, culture, and daily life. Includes mock exams, study materials, '
          'and personalized feedback from experienced instructors.',
      price: '\u20ac200',
      type: _CourseType.inPerson,
      duration: '2 weekends',
      url: 'https://keeplearning.com.cy/crash-course',
    ),
  ];

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keep Learning'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Branding header
          AppCard(
            borderColor: AppColors.primary,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Keep Learning',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Professional courses to help you prepare for the\n'
                  'Cyprus citizenship exam and Greek language test.',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Available Courses', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),

          ..._courses.map((course) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildCourseCard(context, course),
              )),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, _Course course) {
    final theme = Theme.of(context);
    final isOnline = course.type == _CourseType.online;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge and price
          Row(
            children: [
              AppChip(
                label: isOnline ? 'Online' : 'In-Person',
                backgroundColor: isOnline ? AppColors.info : AppColors.culture,
                selected: true,
              ),
              const Spacer(),
              Text(
                course.price,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Title
          Text(
            course.title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Description
          Text(
            course.description,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Duration
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Duration: ${course.duration}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Book now button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openUrl(course.url),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Book Now'),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CourseType { online, inPerson }

class _Course {
  final String title;
  final String description;
  final String price;
  final _CourseType type;
  final String duration;
  final String url;

  const _Course({
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.duration,
    required this.url,
  });
}
