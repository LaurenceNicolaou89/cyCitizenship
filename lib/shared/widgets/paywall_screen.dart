import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

class PaywallScreen extends StatelessWidget {
  final VoidCallback? onPurchase;
  final VoidCallback? onRestore;
  final bool isLoading;

  const PaywallScreen({
    super.key,
    this.onPurchase,
    this.onRestore,
    this.isLoading = false,
  });

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaywallScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Crown icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 44,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Upgrade to Premium',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'One-time payment. Lifetime access.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Benefits list
              Expanded(
                child: ListView(
                  children: const [
                    _BenefitItem(
                      icon: Icons.all_inclusive,
                      title: 'Unlimited Practice Questions',
                      subtitle: 'No daily limit',
                    ),
                    _BenefitItem(
                      icon: Icons.quiz,
                      title: 'Mock Exam Simulator',
                      subtitle: 'Timed 25-question exams',
                    ),
                    _BenefitItem(
                      icon: Icons.smart_toy,
                      title: 'AI Tutor (${AppConstants.premiumAiLimit} msgs/day)',
                      subtitle: 'Ask anything about Cyprus',
                    ),
                    _BenefitItem(
                      icon: Icons.psychology,
                      title: 'Smart Practice',
                      subtitle: 'AI targets your weak areas',
                    ),
                    _BenefitItem(
                      icon: Icons.translate,
                      title: 'Greek Language Practice',
                      subtitle: 'AI conversation partner',
                    ),
                    _BenefitItem(
                      icon: Icons.style,
                      title: 'Unlimited Flashcards',
                      subtitle: 'Spaced repetition learning',
                    ),
                    _BenefitItem(
                      icon: Icons.bar_chart,
                      title: 'Weak Area Analysis',
                      subtitle: 'Detailed performance heatmap',
                    ),
                    _BenefitItem(
                      icon: Icons.checklist,
                      title: 'Interactive Checklist',
                      subtitle: 'Track your application documents',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Price
              Text(
                '\u20ac20',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'One-time purchase',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Purchase button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Get Premium Access'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Restore
              TextButton(
                onPressed: onRestore,
                child: const Text('Restore Purchase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}
