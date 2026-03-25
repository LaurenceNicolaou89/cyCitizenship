import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/paywall_screen.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Settings state — persisted via SharedPreferences
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  // Stats from Firestore
  int _streak = 0;
  int _totalAnswered = 0;
  int _averageScore = 0;

  // User model from Firestore
  UserModel? _userModel;

  // Exam target date
  DateTime? _examDate;

  // Loading flag
  bool _isLoading = true;

  // TODO(CYC-095): wire to real data — badge definitions (IDs, labels, icons)
  // should be driven by a config document in Firestore or a shared constants
  // file so new badges can be added without a client release.
  static const _badgeDefinitions = [
    _BadgeDef('first_quiz', 'First Quiz', Icons.emoji_events),
    _BadgeDef('7_day_streak', '7-Day Streak', Icons.local_fire_department),
    _BadgeDef('50_questions', '50 Questions', Icons.quiz),
    _BadgeDef('perfect_score', 'Perfect Score', Icons.stars),
    _BadgeDef('geography_pro', 'Geography Pro', Icons.public),
    _BadgeDef('culture_expert', 'Culture Expert', Icons.museum),
    _BadgeDef('30_day_streak', '30-Day Streak', Icons.whatshot),
    _BadgeDef('all_categories', 'All Categories', Icons.category),
  ];

  // SharedPreferences keys
  static const _keyDarkMode = 'profile_dark_mode';
  static const _keyNotifications = 'profile_notifications';
  static const _keyLanguage = 'profile_language';
  static const _keyExamDate = 'profile_exam_date';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserData();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final examDateMs = prefs.getInt(_keyExamDate);
    setState(() {
      _darkModeEnabled = prefs.getBool(_keyDarkMode) ?? false;
      _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
      _selectedLanguage = prefs.getString(_keyLanguage) ?? 'English';
      if (examDateMs != null) {
        _examDate = DateTime.fromMillisecondsSinceEpoch(examDateMs);
      }
    });
  }

  Future<void> _loadUserData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final userId = authState.user.uid;
    final firestoreService = context.read<FirestoreService>();

    try {
      // Fetch user document and aggregate stats in parallel
      final results = await Future.wait([
        firestoreService.getUser(userId),
        firestoreService.getUserAggregateStats(userId),
      ]);

      final userDoc = results[0] as dynamic;
      final aggStats = results[1] as Map<String, int>;

      UserModel? userModel;
      if (userDoc.exists) {
        userModel = UserModel.fromFirestore(userDoc);
      }

      if (!mounted) return;
      setState(() {
        _userModel = userModel;
        _streak = userModel?.streak ?? 0;
        _totalAnswered = aggStats['totalAnswered'] ?? 0;
        _averageScore = aggStats['averageScore'] ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isAuthenticated = state is AuthAuthenticated;
          final user = isAuthenticated ? state.user : null;
          final displayName =
              _userModel?.displayName ?? user?.displayName ?? 'Guest User';
          final email = user?.email ?? 'Not signed in';
          final initials = _getInitials(displayName);
          final userBadges = _userModel?.badges ?? [];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Avatar and user info
              Center(
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
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats row
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
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
                          Text(
                            (_userModel?.isPremium ?? false)
                                ? 'Premium'
                                : 'Free Plan',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            (_userModel?.isPremium ?? false)
                                ? 'All features unlocked'
                                : '5 questions/day, limited features',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (!(_userModel?.isPremium ?? false))
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            PaywallScreen.show(context);
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
                itemCount: _badgeDefinitions.length,
                itemBuilder: (context, index) {
                  final def = _badgeDefinitions[index];
                  final unlocked = userBadges.contains(def.id);
                  return _buildBadgeItem(
                    context,
                    _Badge(def.label, def.icon, unlocked),
                  );
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
                        // TODO(CYC-095): wire to real data — supported locales
                        // should come from a shared app-level constant or
                        // l10n config rather than being hardcoded here.
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
                            _saveSetting(_keyLanguage, val);
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
                        _saveSetting(_keyNotifications, val);
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
                        _saveSetting(_keyDarkMode, val);
                      },
                    ),
                    const Divider(height: 0),

                    // Exam target date
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Exam Target Date'),
                      trailing: Text(
                        _examDate != null
                            ? DateFormat('MMM d, yyyy').format(_examDate!)
                            : 'Not set',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _examDate ?? DateTime.now().add(const Duration(days: 90)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                          helpText: 'Select your exam target date',
                        );
                        if (picked != null && mounted) {
                          setState(() => _examDate = picked);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt(_keyExamDate, picked.millisecondsSinceEpoch);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sign out (auth-dependent)
              if (isAuthenticated)
                SizedBox(
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
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
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
                : Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            badge.icon,
            size: 26,
            color: badge.unlocked ? AppColors.secondary : AppColors.disabled,
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

class _BadgeDef {
  final String id;
  final String label;
  final IconData icon;
  const _BadgeDef(this.id, this.label, this.icon);
}

class _Badge {
  final String name;
  final IconData icon;
  final bool unlocked;
  const _Badge(this.name, this.icon, this.unlocked);
}
