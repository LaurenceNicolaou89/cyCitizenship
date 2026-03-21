import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Settings state (placeholder -- will persist later)
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  // Placeholder stats
  static const _streak = 12;
  static const _totalAnswered = 347;
  static const _averageScore = 71;

  // Placeholder badges
  static const _badges = [
    _Badge('First Quiz', Icons.emoji_events, true),
    _Badge('7-Day Streak', Icons.local_fire_department, true),
    _Badge('50 Questions', Icons.quiz, true),
    _Badge('Perfect Score', Icons.stars, false),
    _Badge('Geography Pro', Icons.public, false),
    _Badge('Culture Expert', Icons.museum, false),
    _Badge('30-Day Streak', Icons.whatshot, false),
    _Badge('All Categories', Icons.category, false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Avatar and user info (auth-dependent)
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, curr) =>
                prev.runtimeType != curr.runtimeType,
            builder: (context, state) {
              final isAuthenticated = state is AuthAuthenticated;
              final user = isAuthenticated ? state.user : null;
              final displayName = user?.displayName ?? 'Guest User';
              final email = user?.email ?? 'Not signed in';
              final initials = _getInitials(displayName);

              return Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      email,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stats row
              Row(
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.local_fire_department,
                    value: '$_streak',
                    label: 'Streak',
                    color: AppColors.secondary,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.quiz,
                    value: '$_totalAnswered',
                    label: 'Answered',
                    color: AppColors.primary,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.trending_up,
                    value: '$_averageScore%',
                    label: 'Avg Score',
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Subscription status
              AppCard(
                borderColor: AppColors.secondary,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.workspace_premium,
                          color: AppColors.secondary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Free Plan',
                              style: theme.textTheme.titleMedium),
                          Text('5 questions/day, limited features',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to paywall
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Upgrade'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Badges section
              Text('Badges', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.8,
                ),
                itemCount: _badges.length,
                itemBuilder: (context, index) {
                  final badge = _badges[index];
                  return _buildBadgeItem(context, badge);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Settings section
              Text('Settings', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Language
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      trailing: DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                              value: 'English', child: Text('English')),
                          DropdownMenuItem(
                              value: 'Greek', child: Text('Greek')),
                          DropdownMenuItem(
                              value: 'Russian', child: Text('Russian')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedLanguage = val);
                          }
                        },
                      ),
                    ),
                    const Divider(height: 0),

                    // Notifications
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      subtitle: const Text('Daily reminders & streak alerts'),
                      value: _notificationsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                      },
                    ),
                    const Divider(height: 0),

                    // Dark mode
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark Mode'),
                      value: _darkModeEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _darkModeEnabled = val);
                      },
                    ),
                    const Divider(height: 0),

                    // Exam target date
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Exam Target Date'),
                      trailing: Text(
                        'July 2026',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      onTap: () {
                        // TODO: Date picker
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

          // Sign out (auth-dependent)
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, curr) =>
                prev.runtimeType != curr.runtimeType,
            builder: (context, state) {
              final isAuthenticated = state is AuthAuthenticated;
              if (isAuthenticated) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOut());
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                );
              }
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, _Badge badge) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: badge.unlocked
                ? AppColors.secondary.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            badge.icon,
            size: 26,
            color: badge.unlocked
                ? AppColors.secondary
                : AppColors.disabled,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          badge.name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: badge.unlocked
                ? theme.colorScheme.onSurface
                : AppColors.disabled,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

class _Badge {
  final String name;
  final IconData icon;
  final bool unlocked;
  const _Badge(this.name, this.icon, this.unlocked);
}
