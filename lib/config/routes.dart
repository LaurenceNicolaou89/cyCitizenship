import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/services/gemini_service.dart';
import '../features/home/screens/home_screen.dart';
import '../features/exam_simulator/screens/exam_simulator_screen.dart';
import '../features/exam_simulator/screens/exam_results_screen.dart';
import '../features/flashcards/screens/flashcards_screen.dart';
import '../features/ai_tutor/screens/ai_tutor_screen.dart';
import '../features/ai_practice/screens/ai_practice_screen.dart';
import '../features/greek_practice/screens/greek_practice_screen.dart';
import '../features/exam_info/screens/exam_info_screen.dart';
import '../features/exam_info/screens/exam_map_screen.dart';
import '../features/checklist/screens/checklist_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/keep_learning/screens/keep_learning_screen.dart';
import '../features/heatmap/screens/heatmap_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/home/bloc/home_bloc.dart';
import '../features/home/bloc/home_state.dart';
import '../shared/widgets/app_shell.dart';
import '../shared/widgets/paywall_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Routes that require a real Firebase auth (not guest).
/// Guest users will be redirected to /login for these routes.
const _authRequiredRoutes = {
  '/exam-simulator',
  '/exam-results',
  '/flashcards',
  '/ai-practice',
  '/greek-practice',
  '/checklist',
  '/heatmap',
  '/profile',
};

/// Routes that require a premium subscription.
/// Free users will be redirected to /paywall for these routes.
const _premiumOnlyRoutes = {
  '/ai-practice',
  '/greek-practice',
  '/exam-simulator',
  '/heatmap',
};

GoRouter createRouter({required bool onboardingComplete}) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: onboardingComplete ? '/home' : '/onboarding',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final location = state.uri.path;

    // Allow access to onboarding, login, and paywall without further checks
    final isPublicRoute = location == '/onboarding' ||
        location == '/login' ||
        location == '/paywall';

    // If unauthenticated (not guest), redirect to login
    if (authState is AuthUnauthenticated && !isPublicRoute) {
      return '/login';
    }

    // If authenticated and on auth route, redirect to home
    if ((authState is AuthAuthenticated || authState is AuthGuest) &&
        (location == '/onboarding' || location == '/login')) {
      return '/home';
    }

    // Guest users cannot access auth-required routes (Firestore calls will fail)
    if (authState is AuthGuest && _authRequiredRoutes.contains(location)) {
      return '/login';
    }

    // Premium route guard — only check for authenticated (non-guest) users
    if (authState is AuthAuthenticated &&
        _premiumOnlyRoutes.contains(location)) {
      final homeState = context.read<HomeBloc>().state;
      final isPremium =
          homeState is HomeLoaded ? homeState.isPremium : false;
      if (!isPremium) {
        return '/paywall';
      }
    }

    return null;
  },
  routes: [
    // Onboarding & Auth (no bottom nav)
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Main app with bottom nav shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/practice',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExamSimulatorScreen(),
          ),
        ),
        GoRoute(
          path: '/ai',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AiTutorScreen(),
          ),
        ),
        GoRoute(
          path: '/info',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExamInfoScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),

    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/exam-simulator',
      builder: (context, state) => const ExamSimulatorScreen(),
    ),
    GoRoute(
      path: '/exam-results',
      builder: (context, state) => const ExamResultsScreen(),
    ),
    GoRoute(
      path: '/flashcards',
      builder: (context, state) => const FlashcardsScreen(),
    ),
    GoRoute(
      path: '/ai-practice',
      builder: (context, state) => AiPracticeScreen(
        geminiService: context.read<GeminiService>(),
      ),
    ),
    GoRoute(
      path: '/greek-practice',
      builder: (context, state) => GreekPracticeScreen(
        geminiService: context.read<GeminiService>(),
      ),
    ),
    GoRoute(
      path: '/exam-map',
      builder: (context, state) => const ExamMapScreen(),
    ),
    GoRoute(
      path: '/checklist',
      builder: (context, state) => const ChecklistScreen(),
    ),
    GoRoute(
      path: '/keep-learning',
      builder: (context, state) => const KeepLearningScreen(),
    ),
    GoRoute(
      path: '/heatmap',
      builder: (context, state) => const HeatmapScreen(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Premium'),
        ),
        body: const PaywallScreen(),
      ),
    ),
  ],
);
