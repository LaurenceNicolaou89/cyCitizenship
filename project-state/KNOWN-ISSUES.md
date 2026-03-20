# Known Issues

## Frontend
- L-4: Hardcoded locale 'en' in exam/flashcard screens — should read user's selected language and pass to getText()
- L-3: Profile settings (notifications, dark mode, language) not persisted — toggles reset on navigation
- L-5: Multiple unresolved TODOs for navigation (paywall, notifications, answer review, date picker)
- M-7: Category name/color mapping duplicated across flashcards, exam results, heatmap — should extract to shared util

## Backend
- M-1: HomeBloc uses hardcoded placeholder data — needs wiring to FirestoreService
- M-2: AI Tutor daily limit stored in memory — resets on app restart, should persist via Hive/SharedPreferences
- M-3: ExamSimulatorBloc fetches directly from Firestore (4 queries per exam) — should use QuestionRepository for offline caching
- M-8: ExamSimulatorBloc creates its own FirestoreService instead of using DI from context
- M-9: BillingService.buyPremium() throws if product list doesn't contain premiumProductId — needs orElse guard
- L-9: PaywallScreen.show() creates widget with null callbacks — purchase/restore buttons non-functional

## Database
- M-5: User progress Firestore rules allow arbitrary writes — no schema validation on answers/mock_exams subcollections

## Security
- **FIXED** C-3: Auth guard added to routes with onboarding/login redirect
- **FIXED** M-4: Firestore rules now prevent clients from self-granting isPremium/purchaseDate
- M-6: BillingService completes purchase without server-side receipt verification — premium can be spoofed
- C-1: Firebase API keys in source control — enable App Check and restrict keys in Google Cloud Console

## Infrastructure
- L-6: Basic FlutterError.onError added — consider adding Firebase Crashlytics for production
- L-7: AnalyticsService observer not wired to GoRouter — screen tracking not happening
- L-8: Silent error swallowing in QuestionRepository sync — should log errors

## Patterns
- **FIXED** H-1/H-7: All Hive boxes now opened in main.dart before runApp
- **FIXED** H-2: GeminiService registered as singleton RepositoryProvider
- **FIXED** H-3/H-4: Stream subscriptions stored with dispose() methods
- **FIXED** H-5: ProgressSyncService no longer mutates data in-place during sync
- **FIXED** H-6: FlashcardsScreen wrapped in BlocProvider
- Services should be initialized in main.dart or via RepositoryProvider.create for lazy init
