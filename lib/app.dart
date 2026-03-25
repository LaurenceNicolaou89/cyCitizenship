import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'core/services/ai_rate_limit_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/gemini_service.dart';
import 'core/services/question_repository.dart';
import 'core/services/progress_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/billing_service.dart';
import 'core/services/analytics_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/home/bloc/home_event.dart';

class CyCitizenshipApp extends StatefulWidget {
  const CyCitizenshipApp({
    super.key,
    required this.onboardingComplete,
    required this.prefs,
  });

  final bool onboardingComplete;
  final SharedPreferences prefs;

  @override
  State<CyCitizenshipApp> createState() => _CyCitizenshipAppState();
}

class _CyCitizenshipAppState extends State<CyCitizenshipApp> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => FirestoreService()),
        RepositoryProvider(create: (_) => GeminiService()),
        RepositoryProvider(
          create: (_) => QuestionRepository()..initialize(),
        ),
        // CYC-090: moved from initState — RepositoryProvider calls dispose()
        // automatically when the widget tree is removed, so no manual dispose needed.
        RepositoryProvider(
          create: (_) => ProgressSyncService()..initialize(),
        ),
        RepositoryProvider(
          create: (_) => NotificationService()..initialize(),
        ),
        RepositoryProvider(
          create: (_) => BillingService()..initialize(),
        ),
        RepositoryProvider(create: (_) => AnalyticsService()),
        RepositoryProvider(create: (_) => AiRateLimitService(widget.prefs)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
              firestoreService: context.read<FirestoreService>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (_) => HomeBloc()..add(const LoadHome()),
          ),
        ],
        child: MaterialApp.router(
          title: 'CyCitizenship',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig:
              createRouter(onboardingComplete: widget.onboardingComplete),
        ),
      ),
    );
  }
}
