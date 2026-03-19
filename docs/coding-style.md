# CyCitizenship — Coding Style Guide

## Dart / Flutter Conventions

### General
- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use `dart format` for consistent formatting
- Enable and follow `flutter_lints` (or `very_good_analysis` for stricter rules)
- Max line length: 80 characters

### Naming
- Classes: `PascalCase` — `ExamSimulatorBloc`, `QuestionModel`
- Files: `snake_case` — `exam_simulator_bloc.dart`, `question_model.dart`
- Variables/functions: `camelCase` — `totalScore`, `calculateResult()`
- Constants: `camelCase` — `maxQuestions`, `examDuration`
- Enums: `PascalCase` type, `camelCase` values — `QuestionCategory.geography`
- Private members: prefix with `_` — `_currentScore`

### File Organization
- One class per file (exceptions: small related classes like events/states)
- Feature-based folder structure (already defined in architecture)
- Barrel files (`index.dart`) for feature exports — keep minimal

### BLoC Pattern
- Events: past tense — `QuestionAnswered`, `ExamStarted`, `ExamCompleted`
- States: adjective/noun — `ExamInitial`, `ExamInProgress`, `ExamCompleted`
- One BLoC per feature
- Keep BLoCs thin — business logic in services/repositories
- Use `Equatable` for events and states

```dart
// Example BLoC event
class ExamSimulatorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExamStarted extends ExamSimulatorEvent {}

class QuestionAnswered extends ExamSimulatorEvent {
  final int selectedIndex;
  const QuestionAnswered(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}
```

### Models
- Use `freezed` or manual `copyWith` for immutable models
- JSON serialization via `json_serializable`
- Separate model from entity if needed (Firestore ↔ domain)

```dart
class QuestionModel {
  final String id;
  final String textEn;
  final String textRu;
  final String textEl;
  final List<OptionModel> options;
  final int correctIndex;
  final String category;

  const QuestionModel({
    required this.id,
    required this.textEn,
    // ...
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

### Services
- Abstract service classes (interfaces) for testability
- Concrete implementations injected via dependency injection
- Use `get_it` or `provider` for DI

### Error Handling
- Use `Either<Failure, Success>` pattern or try/catch with custom exceptions
- Never silently swallow errors
- User-facing errors: localized, friendly messages
- Log errors to Firebase Crashlytics

### Testing
- Unit tests for BLoCs and services
- Widget tests for key UI components
- Integration tests for critical flows (auth, purchase, exam completion)
- Test file naming: `{file_name}_test.dart`

## Firebase Conventions

### Firestore
- Collection names: `snake_case` plural — `questions`, `user_progress`, `exam_dates`
- Document field names: `camelCase` — `createdAt`, `isPremium`, `totalScore`
- Always use batch writes for multiple document updates
- Index queries proactively

### Security Rules
- Default deny
- Authenticated users can only read/write their own data
- Questions collection: read-only for all authenticated users
- Admin writes via Cloud Functions only

### Cloud Functions
- TypeScript for Cloud Functions
- Function names: `camelCase` — `verifyPurchase`, `sendDailyQuestion`
- Use structured logging
- Set appropriate memory/timeout limits

## Localization
- Use Flutter's built-in `intl` package
- ARB files per language: `app_en.arb`, `app_ru.arb`, `app_el.arb`
- Never hardcode user-facing strings
- Key naming: `featureName_context` — `examSimulator_startButton`, `aiTutor_placeholder`

## Git Conventions
- Branch naming: `{type}/{ticket-id}-{short-desc}` — `feature/CYC-001-exam-simulator`
- Commit messages: conventional commits — `feat:`, `fix:`, `chore:`, `docs:`
- One feature per branch, one PR per feature
- Squash merge to main

## Code Comments
- Only where logic isn't self-evident
- TODO format: `// TODO(CYC-XXX): description`
- No commented-out code in commits
