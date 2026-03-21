import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../config/theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/heatmap_event.dart';
import '../bloc/heatmap_state.dart';

class HeatmapScreen extends StatelessWidget {
  const HeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HeatmapBloc(
        firestoreService: context.read<FirestoreService>(),
        authService: context.read<AuthService>(),
      )..add(const LoadHeatmapData()),
      child: const _HeatmapView(),
    );
  }
}

class _HeatmapView extends StatelessWidget {
  const _HeatmapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Heatmap'),
      ),
      body: BlocBuilder<HeatmapBloc, HeatmapState>(
        builder: (context, state) {
          if (state is HeatmapLoading || state is HeatmapInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HeatmapError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => context
                          .read<HeatmapBloc>()
                          .add(const LoadHeatmapData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is HeatmapLoaded) {
            if (state.categoryStats.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: AppColors.border),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'No stats yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Answer some questions to see your performance breakdown.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return _HeatmapContent(categoryStats: state.categoryStats);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HeatmapContent extends StatelessWidget {
  final List<CategoryStat> categoryStats;

  const _HeatmapContent({required this.categoryStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalCorrect =
        categoryStats.fold<int>(0, (sum, c) => sum + c.totalCorrect);
    final totalQuestions =
        categoryStats.fold<int>(0, (sum, c) => sum + c.totalAnswered);
    final overallScore =
        totalQuestions > 0 ? (totalCorrect / totalQuestions * 100).round() : 0;

    final weakest = List<CategoryStat>.from(categoryStats)
      ..sort((a, b) => a.scorePercent.compareTo(b.scorePercent));
    final weakestCategory = weakest.first;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Overall score
        AppCard(
          child: Column(
            children: [
              Text('Overall Score', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: overallScore / 100,
                      strokeWidth: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _scoreColor(overallScore),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$overallScore%',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: _scoreColor(overallScore),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$totalCorrect / $totalQuestions questions correct',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Bar chart
        Text('Category Breakdown', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final cat = categoryStats[group.x];
                      return BarTooltipItem(
                        '${_displayName(cat.category)}\n${cat.scorePercent}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= categoryStats.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _displayName(categoryStats[idx].category),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 25,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(categoryStats.length, (i) {
                  final cat = categoryStats[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: cat.scorePercent.toDouble(),
                        color: _categoryColor(cat.category),
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Category detail bars
        Text('Detailed Scores', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ...categoryStats.map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildCategoryBar(context, cat),
            )),

        const SizedBox(height: AppSpacing.lg),

        // Weakest area recommendation
        AppCard(
          borderColor: _categoryColor(weakestCategory.category),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _categoryColor(weakestCategory.category)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lightbulb_outline,
                    color: _categoryColor(weakestCategory.category), size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Area: ${_displayName(weakestCategory.category)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _categoryColor(weakestCategory.category),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your weakest category at ${weakestCategory.scorePercent}%. '
                      'We recommend focusing your practice sessions on ${_displayName(weakestCategory.category)} '
                      'questions to improve your overall score.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar(BuildContext context, CategoryStat cat) {
    final theme = Theme.of(context);
    final color = _categoryColor(cat.category);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_categoryIcon(cat.category), color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _displayName(cat.category),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${cat.scorePercent}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: cat.scorePercent / 100,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${cat.totalCorrect} / ${cat.totalAnswered} correct',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  static Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'geography':
        return AppColors.geography;
      case 'politics':
        return AppColors.politics;
      case 'culture':
        return AppColors.culture;
      case 'daily-life':
        return AppColors.dailyLife;
      default:
        return AppColors.primary;
    }
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'geography':
        return Icons.public;
      case 'politics':
        return Icons.account_balance;
      case 'culture':
        return Icons.museum;
      case 'daily-life':
        return Icons.groups;
      default:
        return Icons.quiz;
    }
  }

  static String _displayName(String category) {
    switch (category) {
      case 'geography':
        return 'Geography';
      case 'politics':
        return 'Politics';
      case 'culture':
        return 'Culture';
      case 'daily-life':
        return 'Daily Life';
      default:
        // Capitalize first letter of unknown categories
        return category.isNotEmpty
            ? '${category[0].toUpperCase()}${category.substring(1)}'
            : category;
    }
  }
}
