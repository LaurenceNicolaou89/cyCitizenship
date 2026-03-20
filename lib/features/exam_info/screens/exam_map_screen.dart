import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';
import '../../../core/models/exam_date_model.dart';
import '../../../shared/widgets/app_card.dart';

class ExamMapScreen extends StatelessWidget {
  const ExamMapScreen({super.key});

  static const List<ExamCenter> _centers = [
    ExamCenter(
      name: 'University of Cyprus',
      address: '75 Kallipoleos Ave, 1678 Nicosia',
      lat: 35.1475,
      lng: 33.3614,
      district: 'Nicosia',
    ),
    ExamCenter(
      name: 'Frederick University - Nicosia',
      address: '7 Yianni Frederickou, 1036 Nicosia',
      lat: 35.1735,
      lng: 33.3616,
      district: 'Nicosia',
    ),
    ExamCenter(
      name: 'Frederick University - Limassol',
      address: '18 Mariou Agathangelou, 3080 Limassol',
      lat: 34.6823,
      lng: 33.0464,
      district: 'Limassol',
    ),
    ExamCenter(
      name: 'European University Cyprus',
      address: '6 Diogenous Str, 2404 Engomi, Nicosia',
      lat: 35.1613,
      lng: 33.3407,
      district: 'Nicosia',
    ),
    ExamCenter(
      name: 'Paphos Regional Exam Centre',
      address: '1 Apostolou Pavlou Ave, 8046 Paphos',
      lat: 34.7554,
      lng: 32.4218,
      district: 'Paphos',
    ),
    ExamCenter(
      name: 'Larnaca Exam Centre',
      address: '12 Gregori Afxentiou, 6023 Larnaca',
      lat: 34.9163,
      lng: 33.6217,
      district: 'Larnaca',
    ),
  ];

  static const Map<String, _DistrictInfo> _districtInfo = {
    'Nicosia': _DistrictInfo(Icons.account_balance, AppColors.primary),
    'Limassol': _DistrictInfo(Icons.beach_access, AppColors.geography),
    'Paphos': _DistrictInfo(Icons.temple_hindu, AppColors.culture),
    'Larnaca': _DistrictInfo(Icons.flight, AppColors.politics),
    'Famagusta': _DistrictInfo(Icons.castle, AppColors.dailyLife),
  };

  Future<void> _openDirections(ExamCenter center) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${center.lat},${center.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group centers by district
    final grouped = <String, List<ExamCenter>>{};
    for (final center in _centers) {
      grouped.putIfAbsent(center.district, () => []).add(center);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Centers'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Header info
          AppCard(
            borderColor: AppColors.info,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Tap "Get Directions" to open the location in Google Maps.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // District groups
          ...grouped.entries.map((entry) {
            final district = entry.key;
            final centers = entry.value;
            final info = _districtInfo[district] ??
                const _DistrictInfo(Icons.location_city, AppColors.textSecondary);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: info.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(info.icon, color: info.color, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      district,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: info.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${centers.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: info.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...centers.map((center) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildCenterCard(context, center, info.color),
                    )),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCenterCard(
      BuildContext context, ExamCenter center, Color accentColor) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            center.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  center.address,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () => _openDirections(center),
              icon: const Icon(Icons.directions, size: 18),
              label: const Text('Get Directions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.zero,
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistrictInfo {
  final IconData icon;
  final Color color;
  const _DistrictInfo(this.icon, this.color);
}
