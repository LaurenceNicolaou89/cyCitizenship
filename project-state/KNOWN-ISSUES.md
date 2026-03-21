# Known Issues

## Frontend
- L-4: Hardcoded locale 'en' in exam/flashcard screens — should read user's selected language and pass to getText() → CYC-099
- L-3: Profile settings (notifications, dark mode, language) not persisted — toggles reset on navigation → CYC-092
- L-5: Multiple unresolved TODOs for navigation (paywall, notifications, answer review, date picker) → CYC-096
- M-7: Category name/color mapping duplicated across flashcards, exam results, heatmap, recommendations — should extract to shared util → CYC-073
- **NEW** CR-C3: AiPracticeScreen uses raw setState instead of BLoC — violates architecture mandate → CYC-064
- **NEW** CR-C4: GreekPracticeScreen uses raw setState instead of BLoC — duplicates ChatMessage model → CYC-065
- **NEW** CR-H6: ~170 lines duplicated chat UI (MessageBubble, TypingIndicator, input field) across ai_tutor and greek_practice → CYC-072
- **NEW** CR-H8: QuestionModel Equatable props incomplete — missing correctIndex, options, textRu, textEl → CYC-074
- **NEW** CR-H9: UserModel Equatable props incomplete — missing displayName, language, badges, etc. → CYC-075
- **NEW** CR-M16: HeatmapScreen entirely hardcoded placeholder data, no BLoC → CYC-091
- **NEW** CR-M17: ProfileScreen stats hardcoded (streak=12, totalAnswered=347) — no BLoC → CYC-092
- **NEW** CR-M18: ExamInfoScreen hardcoded exam dates despite Firestore seed data → CYC-093
- **NEW** CR-M19: No abstract service interfaces — violates coding-style testability mandate → CYC-094
- **NEW** CR-M20: Hardcoded _weakCategories in AiPracticeScreen with no TODO marker → CYC-095
- **NEW** O-3: ExamSimulatorScreen full rebuild every second from timer tick — need scoped BlocBuilder → CYC-077
- **NEW** O-8: HomeBloc recreated on every tab switch — should move to ShellRoute → CYC-088
- **NEW** O-9: AiTutorBloc recreated on every tab switch — loses conversation state → CYC-089
- **NEW** O-12/O-13/O-14: Missing const constructors, wide BlocBuilder scopes in multiple screens → CYC-100

## Backend
- M-1: HomeBloc uses hardcoded placeholder data — needs wiring to FirestoreService → CYC-091
- M-2: AI Tutor daily limit stored in memory — resets on app restart, should persist via Hive/SharedPreferences → CYC-067
- M-3: ExamSimulatorBloc fetches directly from Firestore (4 queries per exam) — should use QuestionRepository → CYC-084
- M-8: ExamSimulatorBloc creates its own FirestoreService instead of using DI from context → CYC-097
- M-9: BillingService.buyPremium() throws if product list doesn't contain premiumProductId — needs orElse guard → CYC-098
- L-9: PaywallScreen.show() creates widget with null callbacks — purchase/restore buttons non-functional → CYC-096
- **NEW** ML-H5: Services (ProgressSync, Notification, Billing) hold active subscriptions but dispose() never called → CYC-071
- **NEW** ML-M1/M2: Fire-and-forget Timers in ai_tutor_screen and greek_practice_screen — no cancel in dispose → CYC-078
- **NEW** ML-M3/M4: Unbounded _messages list in AI tutor and Greek practice — grows without limit → CYC-079
- **NEW** O-1: FlashcardsBloc bypasses QuestionRepository cache, hits Firestore directly → CYC-084
- **NEW** O-5: QuestionRepository deserializes all questions from Hive on every call — needs in-memory cache → CYC-085
- **NEW** O-6: QuestionRepository _syncFromFirestore uses sequential box.put() — should batch with putAll() → CYC-086
- **NEW** O-7: FlashcardsBloc _saveBoxLevels() fires on every swipe — should debounce → CYC-087
- **NEW** O-11: All services initialized eagerly via ..initialize() cascade — defeats lazy providers → CYC-090
- **NEW** O-16: Gemini chat session recreated per message — re-sends entire history each time → CYC-101
- **NEW** CR-18: AI limit magic numbers (50/3) instead of AppConstants → CYC-102

## Database
- M-5: User progress Firestore rules allow arbitrary writes — no schema validation on answers/mock_exams → CYC-070

## Security
- **FIXED** C-3: Auth guard added to routes with onboarding/login redirect
- **FIXED** M-4: Firestore rules now prevent clients from self-granting isPremium/purchaseDate
- M-6: BillingService completes purchase without server-side receipt verification — premium can be spoofed → CYC-063
- C-1: Firebase API keys in source control — enable App Check and restrict keys → CYC-081
- **NEW** S-1: AI prompt injection — user input passed directly to Gemini with no sanitization → CYC-062
- **NEW** S-5: Firestore rules operator precedence bug in create rule — || may bypass auth check → CYC-066
- **NEW** S-3: Client-side AI rate limit bypass — unlimited Gemini API costs on app restart → CYC-067
- **NEW** S-4: Gemini API key embedded in binary via --dart-define — extractable by decompilation → CYC-068
- **NEW** S-5: Guest users can access premium AI features — missing route guards → CYC-069
- **NEW** S-7: Open redirect via push notification route data — no whitelist validation → CYC-080
- **NEW** S-10: No input validation on Firestore writes — raw Map<String, dynamic> accepted → CYC-082
- **NEW** S-11: toFirestore() includes protected isPremium/purchaseDate fields → CYC-083
- **NEW** S-13: Error messages leak internal details (Firestore paths, exceptions) → CYC-103
- **NEW** S-16: Weak email validation — only checks contains('@') → CYC-103

## Infrastructure
- L-6: Basic FlutterError.onError added — consider adding Firebase Crashlytics for production
- L-7: AnalyticsService observer not wired to GoRouter — screen tracking not happening
- L-8: Silent error swallowing in QuestionRepository sync — should log errors → CYC-076
- **NEW** S-8/S-9: google-services.json and firebase_options.dart expose Firebase config → CYC-081
- **NEW** S-14: Debug prints in production code — not gated with kDebugMode → CYC-103

## Patterns
- **FIXED** H-1/H-7: All Hive boxes now opened in main.dart before runApp
- **FIXED** H-2: GeminiService registered as singleton RepositoryProvider
- **FIXED** H-3/H-4: Stream subscriptions stored with dispose() methods
- **FIXED** H-5: ProgressSyncService no longer mutates data in-place during sync
- **FIXED** H-6: FlashcardsScreen wrapped in BlocProvider
- Services should be initialized in main.dart or via RepositoryProvider.create for lazy init
- **NEW** FlashcardsBloc also bypasses DI (same pattern as M-8) → CYC-097
- **NEW** Redundant Hive box open in QuestionRepository — box already opened in main.dart → CYC-102
- **NEW** Duplicated checklist data — general/fast-track share 8/10 items → CYC-102
- **NEW** Repeated Hive box access pattern with cast gymnastics in ProgressSyncService → CYC-102
