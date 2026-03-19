# CyCitizenship — Architecture

## System Overview

```
┌─────────────────────────────────────────────────┐
│                 Flutter App                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │   UI     │ │  State   │ │  Local Storage   │ │
│  │  Layer   │ │ Management│ │  (Hive/SQLite)  │ │
│  └────┬─────┘ └────┬─────┘ └────────┬─────────┘ │
│       └─────────┬──┘                │            │
│            ┌────┴────┐              │            │
│            │ Service  │◄────────────┘            │
│            │  Layer   │                          │
│            └────┬────┘                           │
└─────────────────┼───────────────────────────────┘
                  │
    ┌─────────────┼──────────────┐
    │             │              │
    ▼             ▼              ▼
┌────────┐  ┌─────────┐  ┌──────────┐
│Firebase │  │Firebase  │  │ Gemini   │
│Firestore│  │Auth/FCM  │  │ Flash    │
│  + Storage│  │         │  │  API     │
└────────┘  └─────────┘  └──────────┘
                              │
                    ┌─────────┼──────────┐
                    ▼         ▼          ▼
              ┌────────┐ ┌────────┐ ┌────────┐
              │ Tutor  │ │ Smart  │ │ Greek  │
              │Chatbot │ │Practice│ │Practice│
              └────────┘ └────────┘ └────────┘
```

## Architecture Pattern
- **Clean Architecture** with separation of concerns
- **BLoC pattern** (Business Logic Component) for state management
- **Repository pattern** for data access

## Project Structure

```
lib/
├── app.dart                    # App entry point, theme, routing
├── main.dart                   # Bootstrap, Firebase init
├── config/
│   ├── theme.dart              # App theme & design tokens
│   ├── routes.dart             # Route definitions
│   └── constants.dart          # App-wide constants
├── core/
│   ├── l10n/                   # Localization (EN, RU, EL)
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── notification_service.dart
│   │   ├── gemini_service.dart
│   │   ├── billing_service.dart
│   │   └── analytics_service.dart
│   ├── models/                 # Shared data models
│   └── utils/                  # Helpers, extensions
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── home/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── exam_simulator/
│   │   ├── bloc/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   ├── flashcards/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── ai_tutor/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── ai_practice/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── greek_practice/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── exam_info/
│   │   ├── bloc/
│   │   ├── screens/        # Dates, countdown, map
│   │   └── widgets/
│   ├── checklist/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── profile/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── keep_learning/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   └── heatmap/
│       ├── bloc/
│       ├── screens/
│       └── widgets/
└── shared/
    └── widgets/                # Reusable UI components
```

## Data Flow

### Question Flow
1. Questions stored in Firestore (`questions` collection)
2. App syncs questions to local storage on launch / periodically
3. Exam simulator and flashcards read from local storage (offline-capable)
4. User answers stored locally, synced to Firestore for cross-device access

### AI Flow
1. User sends message → BLoC → GeminiService
2. GeminiService calls Gemini Flash API with system prompt + conversation history
3. System prompts customized per feature (tutor vs smart practice vs Greek)
4. Response streamed back to UI
5. Conversation history maintained in-memory, key interactions saved to Firestore

### Auth Flow
1. Firebase Auth handles sign-in/sign-up
2. Auth state managed via StreamProvider
3. User document created in Firestore on first sign-up
4. Guest mode: limited access, no data persistence

### Payment Flow
1. User taps "Upgrade" → Platform billing UI (Play Store / App Store)
2. Purchase verified server-side via Firebase Cloud Function
3. User document updated with `isPremium: true`
4. App checks subscription status on launch

## Firestore Schema

```
users/
  {userId}/
    email: string
    displayName: string
    language: string (en|ru|el)
    isPremium: boolean
    purchaseDate: timestamp
    createdAt: timestamp
    streak: number
    lastStudyDate: timestamp
    badges: array<string>
    examTarget: string (general|fast-track)
    checklist: map<string, boolean>

questions/
  {questionId}/
    textEn: string
    textRu: string
    textEl: string
    options: array<map> [{textEn, textRu, textEl}]
    correctIndex: number
    category: string (geography|politics|culture|daily-life)
    difficulty: string (easy|medium|hard)
    explanation: map {en, ru, el}
    source: string
    updatedAt: timestamp

user_progress/
  {userId}/
    answers/
      {answerId}/
        questionId: string
        correct: boolean
        answeredAt: timestamp
        category: string
    mock_exams/
      {examId}/
        score: number
        totalQuestions: number
        duration: number
        completedAt: timestamp
        answers: array<map>
    category_stats/
      {category}/
        totalAnswered: number
        totalCorrect: number
        lastUpdated: timestamp

exam_dates/
  {examId}/
    date: timestamp
    registrationOpen: timestamp
    registrationClose: timestamp
    centers: array<map> [{name, address, lat, lng, district}]
    year: number
    session: string (february|july)

keep_learning/
  courses/
    {courseId}/
      titleEn: string
      titleRu: string
      titleEl: string
      description: map {en, ru, el}
      bookingUrl: string
      price: number
      type: string (online|in-person)

ai_conversations/
  {userId}/
    tutor/
      {conversationId}/
        messages: array<map> [{role, content, timestamp}]
    greek/
      {conversationId}/
        messages: array<map> [{role, content, timestamp}]
```

## Firebase Cloud Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `verifyPurchase` | HTTPS callable | Validate Play Store / App Store receipt |
| `sendDailyQuestion` | Scheduled (daily 9am) | Push notification with daily question |
| `sendExamReminder` | Scheduled (check daily) | Reminders for registration/exam dates |
| `updateStreaks` | Scheduled (daily midnight) | Reset broken streaks |
| `syncQuestions` | Firestore trigger | Notify clients of question updates |

## Third-Party Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `firebase_messaging` | Push notifications |
| `firebase_analytics` | Analytics |
| `flutter_bloc` | State management |
| `google_generative_ai` | Gemini Flash API |
| `in_app_purchase` | Play Store / App Store billing |
| `google_maps_flutter` | Exam center maps |
| `hive` | Local storage for offline |
| `flutter_localizations` | i18n support |
| `go_router` | Navigation |
| `cached_network_image` | Image caching |
| `fl_chart` | Heatmap & statistics charts |
| `flutter_card_swiper` | Flashcard swiping |
