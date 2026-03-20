import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/screens/home_screen.dart';
import '../features/exam_simulator/screens/exam_simulator_screen.dart';
import '../features/exam_simulator/screens/exam_results_screen.dart';
import '../features/flashcards/screens/flashcards_screen.dart';
import '../features/ai_tutor/screens/ai_tutor_screen.dart';
import '../features/ai_practice/screens/ai_practice_screen.dart';
import '../features/greek_practice/screens/greek_practice_screen.dart';
import '../core/services/gemini_service.dart';
import '../features/exam_info/screens/exam_info_screen.dart';
import '../features/exam_info/screens/exam_map_screen.dart';
import '../features/checklist/screens/checklist_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/keep_learning/screens/keep_learning_screen.dart';
import '../features/heatmap/screens/heatmap_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
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
        geminiService: GeminiService(apiKey: const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '')),
      ),
    ),
    GoRoute(
      path: '/greek-practice',
      builder: (context, state) => GreekPracticeScreen(
        geminiService: GeminiService(apiKey: const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '')),
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
  ],
);
