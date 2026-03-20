import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/theme.dart';
import '../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  String _selectedLanguage = 'en';
  String _selectedRoute = 'general';
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    if (onboardingComplete && mounted) {
      context.go('/home');
    }
  }

  static const _languages = [
    {'code': 'en', 'name': 'English', 'flag': '\u{1F1EC}\u{1F1E7}'},
    {'code': 'ru', 'name': '\u0420\u0443\u0441\u0441\u043A\u0438\u0439', 'flag': '\u{1F1F7}\u{1F1FA}'},
    {'code': 'el', 'name': '\u0395\u03BB\u03BB\u03B7\u03BD\u03B9\u03BA\u03AC', 'flag': '\u{1F1E8}\u{1F1FE}'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('exam_route', _selectedRoute);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildLanguagePage(),
                  _buildRoutePage(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Welcome to CyCitizenship',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your path to Cyprus citizenship.\nPractice for the culture & politics exam with AI-powered tools.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select your language',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ..._languages.map((lang) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _LanguageOption(
                  flag: lang['flag']!,
                  name: lang['name']!,
                  selected: _selectedLanguage == lang['code'],
                  onTap: () {
                    setState(() {
                      _selectedLanguage = lang['code']!;
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRoutePage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select your route',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'This determines your exam pass threshold and document checklist.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _RouteOption(
            title: 'General Route',
            subtitle: '7+ years residence\n60% pass mark (15/25)',
            icon: Icons.timeline,
            selected: _selectedRoute == 'general',
            onTap: () => setState(() => _selectedRoute = 'general'),
          ),
          const SizedBox(height: AppSpacing.md),
          _RouteOption(
            title: 'Fast-Track',
            subtitle: '3-4 years residence (skilled workers)\n60% pass mark (15/25)',
            icon: Icons.bolt,
            selected: _selectedRoute == 'fast-track',
            onTap: () => setState(() => _selectedRoute = 'fast-track'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: _currentPage == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Buttons
          if (_currentPage < 2)
            AppButton(
              label: 'Next',
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          else
            AppButton(
              label: 'Get Started',
              onPressed: _completeOnboarding,
            ),
          if (_currentPage == 0) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Skip',
              variant: AppButtonVariant.text,
              onPressed: _completeOnboarding,
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$name language option${selected ? ', selected' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: selected ? AppColors.primary.withValues(alpha: 0.05) : null,
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
        ),
      ),
    );
  }
}

class _RouteOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RouteOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title route option${selected ? ', selected' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: selected ? AppColors.primary.withValues(alpha: 0.05) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
        ),
      ),
    );
  }
}
