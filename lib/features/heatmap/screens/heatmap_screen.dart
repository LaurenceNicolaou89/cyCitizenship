import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../config/theme.dart';
import '../../../shared/widgets/app_card.dart';

class HeatmapScreen extends StatelessWidget {
  const HeatmapScreen({super.key});

  // Placeholder data -- will wire to Firestore later
  static const _categoryData = [
    _CategoryScore(
      name: 'Geography',
      score: 72,
      total: 50,
      correct: 36,
      color: AppColors.geography,
      icon: Icons.public,
    ),
    _CategoryScore(
      name: 'Politics',
      score: 58,
      total: 55,
      correct: 32,
      color: AppColors.politics,
      icon: Icons.account_balance,
    ),
    _CategoryScore(
      name: 'Culture',
      score: 85,
      total: 48,
      correct: 41,
      color: AppColors.culture,
      icon: Icons.museum,
    ),
    _CategoryScore(
      name: 'Daily Life',
      score: 64,
      total: 42,
      correct: 27,
      color: AppColors.dailyLife,
      icon: Icons.groups,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalCorrect =
        _categoryData.fold<int>(0, (sum, c) => sum + c.correct);
    final totalQuestions =
        _categoryData.fold<int>(0, (sum, c) => sum + c.total);
    final overallScore =
        totalQuestions > 0 ? (totalCorrect / totalQuestions * 100).round() : 0;

    final weakest =
        List<_CategoryScore>.from(_categoryData)
          ..sort((a, b) => a.score.compareTo(b.score));
    final weakestCategory = weakest.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Heatmap'),
      ),
      body: ListView(
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
                        final cat = _categoryData[group.x];
                        return BarTooltipItem(
                          '${cat.name}\n${cat.score}%',
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
                          if (idx < 0 || idx >= _categoryData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _categoryData[idx].name,
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
                  barGroups: List.generate(_categoryData.length, (i) {
                    final cat = _categoryData[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: cat.score.toDouble(),
                          color: cat.color,
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
          ..._categoryData.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildCategoryBar(context, cat),
              )),

          const SizedBox(height: AppSpacing.lg),

          // Weakest area recommendation
          AppCard(
            borderColor: weakestCategory.color,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: weakestCategory.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.lightbulb_outline,
                      color: weakestCategory.color, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus Area: ${weakestCategory.name}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: weakestCategory.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your weakest category at ${weakestCategory.score}%. '
                        'We recommend focusing your practice sessions on ${weakestCategory.name} '
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
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context, _CategoryScore cat) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cat.icon, color: cat.color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                cat.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${cat.score}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cat.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: cat.score / 100,
              minHeight: 8,
              backgroundColor: cat.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(cat.color),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${cat.correct} / ${cat.total} correct',
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
}

class _CategoryScore {
  final String name;
  final int score;
  final int total;
  final int correct;
  final Color color;
  final IconData icon;

  const _CategoryScore({
    required this.name,
    required this.score,
    required this.total,
    required this.correct,
    required this.color,
    required this.icon,
  });
}
