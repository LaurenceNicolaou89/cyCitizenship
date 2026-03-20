import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/theme.dart';
import '../../../shared/widgets/app_card.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool _isFastTrack = false;
  Map<String, bool> _checked = {};
  bool _loading = true;

  static const _generalItems = [
    _ChecklistItem(
      key: 'passport',
      title: 'Valid passport',
      subtitle: 'Original + certified copy',
      icon: Icons.badge,
    ),
    _ChecklistItem(
      key: 'residence_general',
      title: 'Residence permit (7+ years)',
      subtitle: 'Proof of 7 consecutive years of legal residence',
      icon: Icons.home,
    ),
    _ChecklistItem(
      key: 'criminal_record',
      title: 'Criminal record certificate',
      subtitle: 'Clean criminal record from Cyprus Police',
      icon: Icons.gavel,
    ),
    _ChecklistItem(
      key: 'proof_address',
      title: 'Proof of address',
      subtitle: 'Recent utility bill or bank statement',
      icon: Icons.location_on,
    ),
    _ChecklistItem(
      key: 'financial',
      title: 'Financial self-sufficiency evidence',
      subtitle: 'Bank statements, employment contract, or tax returns',
      icon: Icons.account_balance_wallet,
    ),
    _ChecklistItem(
      key: 'greek_b1',
      title: 'B1 Greek language certificate',
      subtitle: 'From an accredited institution',
      icon: Icons.translate,
    ),
    _ChecklistItem(
      key: 'culture_exam',
      title: 'Culture exam pass certificate',
      subtitle: 'Citizenship knowledge exam result',
      icon: Icons.school,
    ),
    _ChecklistItem(
      key: 'form_m127',
      title: 'Application form M127',
      subtitle: 'Completed and signed',
      icon: Icons.description,
    ),
    _ChecklistItem(
      key: 'fee',
      title: 'Application fee',
      subtitle: '\u20ac500 + \u20ac17.08 stamps',
      icon: Icons.payments,
    ),
    _ChecklistItem(
      key: 'photos',
      title: 'Passport photos (2)',
      subtitle: 'Recent passport-size photographs',
      icon: Icons.photo_camera,
    ),
  ];

  static const _fastTrackItems = [
    _ChecklistItem(
      key: 'passport',
      title: 'Valid passport',
      subtitle: 'Original + certified copy',
      icon: Icons.badge,
    ),
    _ChecklistItem(
      key: 'residence_fast',
      title: 'Residence permit (3-4 years)',
      subtitle: 'Proof of 3-4 years of legal residence',
      icon: Icons.home,
    ),
    _ChecklistItem(
      key: 'degree',
      title: 'University degree or professional certification',
      subtitle: 'Accredited degree or professional qualification',
      icon: Icons.workspace_premium,
    ),
    _ChecklistItem(
      key: 'criminal_record',
      title: 'Criminal record certificate',
      subtitle: 'Clean criminal record from Cyprus Police',
      icon: Icons.gavel,
    ),
    _ChecklistItem(
      key: 'proof_address',
      title: 'Proof of address',
      subtitle: 'Recent utility bill or bank statement',
      icon: Icons.location_on,
    ),
    _ChecklistItem(
      key: 'financial',
      title: 'Financial self-sufficiency evidence',
      subtitle: 'Bank statements, employment contract, or tax returns',
      icon: Icons.account_balance_wallet,
    ),
    _ChecklistItem(
      key: 'greek_b1',
      title: 'B1 Greek language certificate',
      subtitle: 'From an accredited institution',
      icon: Icons.translate,
    ),
    _ChecklistItem(
      key: 'culture_exam',
      title: 'Culture exam pass certificate',
      subtitle: 'Citizenship knowledge exam result',
      icon: Icons.school,
    ),
    _ChecklistItem(
      key: 'form_m127',
      title: 'Application form M127',
      subtitle: 'Completed and signed',
      icon: Icons.description,
    ),
    _ChecklistItem(
      key: 'fee',
      title: 'Application fee',
      subtitle: '\u20ac500 + \u20ac17.08 stamps',
      icon: Icons.payments,
    ),
    _ChecklistItem(
      key: 'photos',
      title: 'Passport photos (2)',
      subtitle: 'Recent passport-size photographs',
      icon: Icons.photo_camera,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadChecked();
  }

  Future<void> _loadChecked() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('checklist_'));
    final map = <String, bool>{};
    for (final k in keys) {
      map[k.replaceFirst('checklist_', '')] = prefs.getBool(k) ?? false;
    }
    setState(() {
      _checked = map;
      _isFastTrack = prefs.getBool('checklist_fast_track') ?? false;
      _loading = false;
    });
  }

  Future<void> _toggleItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !(_checked[key] ?? false);
    await prefs.setBool('checklist_$key', newVal);
    setState(() {
      _checked[key] = newVal;
    });
  }

  Future<void> _toggleRoute(bool fastTrack) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checklist_fast_track', fastTrack);
    setState(() {
      _isFastTrack = fastTrack;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _isFastTrack ? _fastTrackItems : _generalItems;
    final checkedCount = items.where((i) => _checked[i.key] == true).length;
    final total = items.length;
    final progress = total > 0 ? checkedCount / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Checklist'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Route toggle
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _RouteButton(
                          label: 'General Route',
                          selected: !_isFastTrack,
                          onTap: () => _toggleRoute(false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _RouteButton(
                          label: 'Fast-Track',
                          selected: _isFastTrack,
                          onTap: () => _toggleRoute(true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Progress indicator
                AppCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              backgroundColor:
                                  AppColors.border,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                progress == 1.0
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: progress == 1.0
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$checkedCount / $total documents ready',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              progress == 1.0
                                  ? 'All documents ready!'
                                  : '${total - checkedCount} remaining',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: progress == 1.0
                                    ? AppColors.success
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Checklist items
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildChecklistItem(context, item),
                    )),
              ],
            ),
    );
  }

  Widget _buildChecklistItem(BuildContext context, _ChecklistItem item) {
    final theme = Theme.of(context);
    final isChecked = _checked[item.key] ?? false;

    return AppCard(
      onTap: () => _toggleItem(item.key),
      borderColor: isChecked ? AppColors.success : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isChecked
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: isChecked ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration:
                        isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? AppColors.textSecondary : null,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Checkbox(
            value: isChecked,
            onChanged: (_) => _toggleItem(item.key),
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RouteButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ChecklistItem {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  const _ChecklistItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
