# Tickets

## Epic 1: Project Foundation
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-001 | Flutter project scaffolding & folder structure | DevOps | done | P0 |
| CYC-002 | Firebase project setup (Auth, Firestore, FCM, Analytics) | Backend Dev | done | P0 |
| CYC-003 | Theme, design tokens & shared widgets | Frontend Dev | done | P0 |
| CYC-004 | Localization setup (EN, RU, EL) with ARB files | Frontend Dev | done | P0 |
| CYC-005 | Navigation setup (go_router + bottom nav) | Frontend Dev | done | P0 |
| CYC-006 | Firestore security rules | Security Dev | done | P0 |

### Acceptance Criteria
- **CYC-001**: Flutter project runs on iOS & Android emulators, clean architecture folder structure matches `docs/architecture.md`, all core dependencies in pubspec.yaml
- **CYC-002**: Firebase initialized, Auth/Firestore/FCM/Analytics configured, `.env` for API keys, Cloud Functions project bootstrapped (TypeScript)
- **CYC-003**: Theme file with full color system, typography scale, spacing, component styles matching `docs/design-style.md`. Shared widgets: AppButton, AppCard, AppTextField, AppChip
- **CYC-004**: `intl` package configured, 3 ARB files created with initial strings (onboarding, nav labels, common actions). Language switching works at runtime
- **CYC-005**: Bottom nav with 5 tabs, go_router configured with all route stubs, deep link support for notifications
- **CYC-006**: Default deny rules, users can only read/write own data, questions collection read-only, admin writes via Cloud Functions only

---

## Epic 2: Authentication & User Management
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-007 | Auth screens (sign up, sign in, forgot password) | Frontend Dev | done | P0 |
| CYC-008 | Firebase Auth integration (email, Google, Apple) | Backend Dev | done | P0 |
| CYC-009 | User Firestore document creation on sign-up | Backend Dev | done | P0 |
| CYC-010 | Guest mode with limited access | Backend Dev | done | P1 |
| CYC-011 | Onboarding flow (language, route selection) | Frontend Dev | done | P0 |

### Acceptance Criteria
- **CYC-007**: Sign up/in screens match wireframes, form validation, error handling, loading states. Apple Sign-In button on iOS
- **CYC-008**: Email/password, Google, Apple sign-in all functional. Auth state persisted, auto-login on app restart
- **CYC-009**: User document created in `users/` collection on first sign-up with all fields from schema. No duplicate creation
- **CYC-010**: Guest can browse free content, prompted to sign up when hitting paid features or when data sync needed
- **CYC-011**: Welcome → language picker → route selector (general/fast-track) → auth. Shown only on first launch, preferences saved

---

## Epic 3: Question Bank & Content
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-012 | Firestore question schema & seed data | DBA | done | P0 |
| CYC-013 | Question sync to local storage (Hive) | Backend Dev | pending | P0 |
| CYC-014 | Exam dates collection & seed data | DBA | done | P1 |
| CYC-015 | Keep Learning courses collection & seed data | DBA | done | P2 |

### Acceptance Criteria
- **CYC-012**: Questions collection matches schema in `docs/architecture.md`. Minimum 50 seed questions across all 4 categories, all 3 languages. Indexed by category, difficulty
- **CYC-013**: Questions downloaded to Hive on first launch, incremental sync on subsequent launches. Offline access confirmed — airplane mode test
- **CYC-014**: Exam dates collection with upcoming July 2026 exam data, 4 exam centers with coordinates
- **CYC-015**: Keep Learning courses collection with sample courses, booking URLs

---

## Epic 4: Home Screen & Dashboard
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-016 | Home screen layout & widgets | Frontend Dev | done | P0 |
| CYC-017 | Exam countdown widget | Frontend Dev | done | P1 |
| CYC-018 | Study streak display & logic | Backend Dev | done | P1 |
| CYC-019 | Quick action buttons | Frontend Dev | done | P1 |

### Acceptance Criteria
- **CYC-016**: Home screen matches wireframe — daily question card, streak, average score, quick actions. Pull-to-refresh, skeleton loading
- **CYC-017**: Countdown to next exam date, progress bar, auto-updates. Shows "No upcoming exam" when none scheduled
- **CYC-018**: Streak counter increments on study activity, resets at midnight local time. Persisted in Firestore
- **CYC-019**: 4 quick action buttons (Mock Exam, Flashcard, AI Tutor, Greek Practice) navigate to correct screens

---

## Epic 5: Exam Simulator
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-020 | Exam simulator BLoC & logic | Backend Dev | done | P0 |
| CYC-021 | Exam simulator UI (question screen, timer, progress) | Frontend Dev | done | P0 |
| CYC-022 | Exam results screen with category breakdown | Frontend Dev | done | P0 |
| CYC-023 | Exam history storage & display | Backend Dev | done | P1 |
| CYC-024 | Review wrong answers with explanations | Frontend Dev | done | P1 |

### Acceptance Criteria
- **CYC-020**: Random 25 questions weighted by category (6/7/6/6). 45-min timer, auto-submit on expiry. Pass thresholds: 60% citizenship, 50% LTR
- **CYC-021**: Matches wireframe — one question at a time, 4 options, selected state, progress bar, timer. Smooth transitions
- **CYC-022**: Score display with animated count-up, category breakdown bars, pass/fail indicator, focus recommendation
- **CYC-023**: All mock exams saved to `user_progress/mock_exams/`. History list view with date, score, pass/fail
- **CYC-024**: After results, user can review each question — shows selected answer, correct answer, explanation

---

## Epic 6: Flashcards
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-025 | Flashcard BLoC & spaced repetition logic | Backend Dev | done | P1 |
| CYC-026 | Flashcard UI (swipeable cards, flip animation) | Frontend Dev | done | P1 |
| CYC-027 | Flashcard progress tracking | Backend Dev | done | P1 |

### Acceptance Criteria
- **CYC-025**: Modified Leitner system (5 boxes), cards advance/demote on correct/incorrect. Category and mixed modes
- **CYC-026**: 3D flip animation on tap to reveal. Swipe left (don't know) / right (know it). Buttons as fallback. Card counter
- **CYC-027**: Box assignments persisted locally + synced to Firestore. "Mastered" count visible

---

## Epic 7: AI Features
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-028 | Gemini Flash service layer | Backend Dev | done | P0 |
| CYC-029 | AI Tutor chatbot screen & BLoC | Frontend Dev | done | P0 |
| CYC-030 | AI Tutor system prompt & Cyprus knowledge base | Backend Dev | done | P0 |
| CYC-031 | AI Smart Practice screen & question generation | Frontend Dev | done | P1 |
| CYC-032 | AI Greek Language Practice screen | Frontend Dev | done | P1 |
| CYC-033 | AI rate limiting (free: 3/day, paid: 50/day) | Backend Dev | done | P0 |

### Acceptance Criteria
- **CYC-028**: GeminiService class wrapping `google_generative_ai` package. Handles streaming responses, error handling, retry logic. Configurable system prompts
- **CYC-029**: Chat UI matching wireframe — message bubbles, typing indicator, language selector. Conversation history in-memory
- **CYC-030**: System prompt with Cyprus exam syllabus knowledge. Responds in user's language. Refuses non-exam topics gracefully
- **CYC-031**: Generates exam-format questions targeting weak categories. Shows explanation after answer. Adapts difficulty
- **CYC-032**: Greek conversation partner with A2/B1 modes. Provides transliteration, corrections. Scenario-based (ordering food, directions, etc.)
- **CYC-033**: Message counter per feature per day. Resets at midnight. Shows remaining count. Upgrade prompt at limit

---

## Epic 8: Exam Info & Checklist
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-034 | Exam dates screen with countdown & reminders | Frontend Dev | done | P1 |
| CYC-035 | Exam center map (Google Maps integration) | Frontend Dev | done | P1 |
| CYC-036 | Application checklist screen & document tracker | Frontend Dev | done | P1 |
| CYC-037 | Checklist BLoC & Firestore sync | Backend Dev | done | P1 |

### Acceptance Criteria
- **CYC-034**: List of upcoming/past exams, countdown to next, registration window dates. Tap to set reminder (FCM)
- **CYC-035**: Interactive Google Map showing 4 exam centers (Nicosia, Limassol, Larnaca, Paphos). Tap marker → address, directions link
- **CYC-036**: Two checklist variants (general/fast-track). Tick-off items, progress indicator (X/Y ready). Matches business-logic doc
- **CYC-037**: Checklist state persisted in user Firestore document. Syncs across devices

---

## Epic 9: Weak Area Heatmap & Stats
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-038 | Category stats tracking BLoC | Backend Dev | done | P1 |
| CYC-039 | Heatmap visualization screen | Frontend Dev | done | P1 |

### Acceptance Criteria
- **CYC-038**: Tracks total answered/correct per category in `user_progress/category_stats/`. Updates after every answer
- **CYC-039**: Visual breakdown with category colors from design-style. Percentage bars per category. Trend over time (last 7 days / 30 days)

---

## Epic 10: Profile, Settings & Gamification
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-040 | Profile screen (stats overview, badges, settings) | Frontend Dev | done | P1 |
| CYC-041 | Badge system (milestones & awards) | Backend Dev | done | P2 |
| CYC-042 | Study streak logic with notifications | Backend Dev | done | P1 |
| CYC-043 | Settings (language, notifications, dark mode) | Frontend Dev | done | P1 |

### Acceptance Criteria
- **CYC-040**: Profile shows avatar, name, streak, total questions answered, average score, badge collection, subscription status
- **CYC-041**: Badges: 7-day streak, 30-day streak, first mock exam, first pass, perfect score, 100 questions, 500 questions. Unlock animation
- **CYC-042**: Streak reminder notification at 8pm if not studied. Welcome back notification after 7 days inactive. Cloud Function `updateStreaks`
- **CYC-043**: Language switch (EN/RU/EL), notification toggles (daily question, streak, exam dates), dark mode toggle, exam target date

---

## Epic 11: Payments & Subscription
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-044 | Paywall/upgrade screen | Frontend Dev | done | P0 |
| CYC-045 | Play Store billing integration (Android) | Backend Dev | done | P0 |
| CYC-046 | App Store billing integration (iOS) | Backend Dev | done | P0 |
| CYC-047 | Purchase verification Cloud Function | Backend Dev | done | P0 |
| CYC-048 | Restore purchase flow | Backend Dev | done | P1 |

### Acceptance Criteria
- **CYC-044**: Benefits list, €20 one-time price, platform billing button. Non-intrusive — shown at paywall moments, not forced
- **CYC-045**: `in_app_purchase` package for Android. Product configured in Play Console. Purchase flow → verification → premium unlock
- **CYC-046**: `in_app_purchase` package for iOS. Product configured in App Store Connect. Purchase flow → verification → premium unlock
- **CYC-047**: Cloud Function validates receipt with Play/Apple servers. Updates `isPremium` in user document. Idempotent
- **CYC-048**: "Restore Purchase" button queries store for existing purchases. Restores premium if found

---

## Epic 12: Notifications
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-049 | FCM setup & notification handling | Backend Dev | done | P1 |
| CYC-050 | Daily question Cloud Function | Backend Dev | done | P1 |
| CYC-051 | Exam reminder Cloud Function | Backend Dev | done | P1 |

### Acceptance Criteria
- **CYC-049**: FCM initialized, permission request on onboarding, notification tap opens correct screen (deep link)
- **CYC-050**: Scheduled Cloud Function at 9am, sends daily question notification, avoids recent questions (30 days)
- **CYC-051**: Checks daily for upcoming registration/exam dates. Sends reminders per notification strategy in business-logic doc

---

## Epic 13: Keep Learning Integration
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-052 | Keep Learning section UI | Frontend Dev | done | P2 |
| CYC-053 | Course listing from Firestore | Backend Dev | done | P2 |

### Acceptance Criteria
- **CYC-052**: Dedicated section under Info tab. Course cards with title, description, price, type badge. Tap → booking URL
- **CYC-053**: Reads from `keep_learning/courses/` collection. Supports all 3 languages. Admin-updatable without app release

---

## Epic 14: Offline Support & Performance
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-054 | Offline mode for questions & flashcards | Backend Dev | done | P1 |
| CYC-055 | Progress sync (offline → online) | Backend Dev | done | P1 |

### Acceptance Criteria
- **CYC-054**: Questions and flashcard data cached in Hive. App functional in airplane mode for practice. AI shows "Internet required" message
- **CYC-055**: Answers and progress queued locally when offline. Auto-sync on reconnection. No data loss

---

## Epic 15: Testing & Polish
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-056 | Unit tests for all BLoCs | QA | done | P1 |
| CYC-057 | Widget tests for key screens | QA | done | P1 |
| CYC-058 | Integration tests (auth, purchase, exam flow) | QA | done | P1 |
| CYC-059 | Dark mode verification all screens | QA | done | P2 |
| CYC-060 | Accessibility audit (WCAG 2.1 AA) | QA | done | P2 |
| CYC-061 | Performance optimization & app size | DevOps | done | P2 |

### Acceptance Criteria
- **CYC-056**: 80%+ coverage on BLoC logic. All state transitions tested
- **CYC-057**: Golden tests for home, exam simulator, results, AI tutor, flashcard screens
- **CYC-058**: Full flow tests: onboarding → sign up → take exam → see results. Purchase flow mocked
- **CYC-059**: Every screen verified in dark mode, no contrast violations
- **CYC-060**: Screen reader navigation works, touch targets 48dp+, contrast ratios pass
- **CYC-061**: App size under 30MB, cold start under 3 seconds, no jank in animations

---

---

## Epic 16: Critical Security Fixes
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-062 | AI prompt injection sanitization — sanitize user input before Gemini calls | Security Dev | pending | P0 |
| CYC-063 | Purchase receipt verification Cloud Function — validate receipts server-side | Backend Dev | pending | P0 |
| CYC-066 | Fix Firestore rules operator precedence bug in create rule | Security Dev | pending | P0 |

### Acceptance Criteria
- **CYC-062**: User input sanitized before sending to Gemini (strip injection patterns, enforce max length). Consider Cloud Function proxy.
- **CYC-063**: Cloud Function receives purchase token, validates with Google Play / App Store APIs, sets `isPremium` only on verified receipt. Idempotent.
- **CYC-066**: Firestore create rule uses explicit parentheses so `auth.uid == userId` is always enforced. Tested with security rules unit tests.

---

## Epic 17: High-Priority Security & Architecture Fixes
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-064 | Extract AiPracticeBloc from AiPracticeScreen (setState → BLoC) | Frontend Dev | pending | P0 |
| CYC-065 | Extract GreekPracticeBloc from GreekPracticeScreen (setState → BLoC) | Frontend Dev | pending | P0 |
| CYC-067 | Persist AI rate limits + enforce server-side | Backend Dev | pending | P0 |
| CYC-068 | Move Gemini calls behind Cloud Function (protect API key) | Backend Dev | pending | P0 |
| CYC-069 | Add auth/paywall route guards for premium features | Security Dev | pending | P0 |
| CYC-070 | Add Firestore schema validation on user_progress subcollections | DBA | pending | P0 |
| CYC-071 | Fix service disposal — convert app root or add dispose lifecycle | Backend Dev | pending | P1 |
| CYC-072 | Extract shared chat UI widgets (MessageBubble, TypingIndicator, ChatInput) | Frontend Dev | pending | P1 |
| CYC-073 | Extract shared CategoryUtils (name/color mapping) | Frontend Dev | pending | P1 |
| CYC-074 | Fix QuestionModel Equatable props — include all fields | Backend Dev | pending | P1 |
| CYC-075 | Fix UserModel Equatable props — include all mutable fields | Backend Dev | pending | P1 |
| CYC-076 | Add error logging to all silent catch blocks | Backend Dev | pending | P1 |
| CYC-077 | Scope ExamSimulatorScreen BlocBuilder — timer-only rebuild via BlocSelector | Frontend Dev | pending | P1 |

### Acceptance Criteria
- **CYC-064**: AiPracticeScreen uses AiPracticeBloc with proper events/states. No setState for business logic. Testable.
- **CYC-065**: GreekPracticeScreen uses GreekPracticeBloc. Reuses existing ChatMessage model from ai_tutor_state.dart.
- **CYC-067**: Daily AI limit persisted in Hive/SharedPreferences. Cloud Function proxy enforces server-side limits. Uses AppConstants for limit values.
- **CYC-068**: Gemini API key lives only in Cloud Function environment. Client calls Cloud Function with auth token. Key not in APK/IPA.
- **CYC-069**: Premium routes (/ai-practice, /greek-practice, /flashcards full) check isPremium. Guest users redirected to auth for protected features.
- **CYC-070**: Firestore rules validate field names, types, and sizes on answers/mock_exams subcollections. Tested with rules unit tests.
- **CYC-071**: Services with active subscriptions have dispose() called on app teardown. Convert CyCitizenshipApp to StatefulWidget or use teardown wrapper.
- **CYC-072**: Shared ChatMessageBubble, TypingIndicator, ChatInputField in lib/shared/widgets/. Both AI screens use them.
- **CYC-073**: CategoryUtils in lib/core/utils/ with getCategoryColor() and getCategoryDisplayName(). All 4+ locations use it.
- **CYC-074**: QuestionModel.props includes all fields (id, textEn, textRu, textEl, category, difficulty, options, correctIndex, explanation, source, updatedAt).
- **CYC-075**: UserModel.props includes all mutable fields (displayName, language, badges, examTarget, checklist, lastStudyDate, etc.).
- **CYC-076**: All catch blocks log errors via debugPrint at minimum. No silent swallowing. Consider Crashlytics for production.
- **CYC-077**: Timer chip uses BlocSelector scoped to remainingSeconds. Question/answer UI only rebuilds on question/answer changes.

---

## Epic 18: Medium Security Fixes
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-080 | Validate push notification route data against whitelist | Security Dev | pending | P1 |
| CYC-081 | Remove google-services.json from git + enable App Check | Security Dev | pending | P1 |
| CYC-082 | Add input validation layer for Firestore writes | Backend Dev | pending | P1 |
| CYC-083 | Exclude isPremium/purchaseDate from toFirestore() | Backend Dev | pending | P1 |

### Acceptance Criteria
- **CYC-080**: NotificationService validates route against known app routes before navigating. Unknown routes ignored.
- **CYC-081**: google-services.json and GoogleService-Info.plist in .gitignore. Removed from git history. App Check enabled. Firebase keys restricted in Google Cloud Console.
- **CYC-082**: FirestoreService validates expected field names/types before writes. Rejects unexpected fields.
- **CYC-083**: UserModel has separate toCreateMap()/toUpdateMap() that exclude server-managed fields. Or toFirestore() omits isPremium/purchaseDate.

---

## Epic 19: Performance & Optimization
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-084 | Use QuestionRepository in ExamSimulator + Flashcards BLoCs (batch queries) | Backend Dev | pending | P1 |
| CYC-085 | Add in-memory cache to QuestionRepository | Backend Dev | pending | P1 |
| CYC-086 | Batch Hive writes in QuestionRepository sync (putAll) | Backend Dev | pending | P1 |
| CYC-087 | Debounce flashcard box level saves | Backend Dev | pending | P2 |
| CYC-088 | Move HomeBloc to ShellRoute level (persist across tab switches) | Frontend Dev | pending | P1 |
| CYC-089 | Move AiTutorBloc to ShellRoute level (preserve conversation) | Frontend Dev | pending | P1 |
| CYC-090 | Lazy-init services in app.dart (remove eager ..initialize()) | Backend Dev | pending | P2 |

### Acceptance Criteria
- **CYC-084**: Both BLoCs use QuestionRepository.getQuestions(). Exam start = 1 cached read + client-side sampling. Flashcards same.
- **CYC-085**: QuestionRepository caches List<QuestionModel> in memory. Invalidated only on sync. Subsequent calls return cache.
- **CYC-086**: _syncFromFirestore uses box.putAll() for bulk inserts instead of sequential box.put().
- **CYC-087**: _saveBoxLevels debounced (5s inactivity or on bloc close). Not fired on every swipe.
- **CYC-088**: HomeBloc created at ShellRoute level. No loading spinner on tab switch. Pull-to-refresh triggers reload.
- **CYC-089**: AiTutorBloc at ShellRoute level. Conversation persists during session. Daily limit counter preserved.
- **CYC-090**: Services use lazy initialization. ..initialize() moved to first-use or triggered by specific screens.

---

## Epic 20: Memory Leak Fixes
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-078 | Fix fire-and-forget Timers in chat screens | Frontend Dev | pending | P1 |
| CYC-079 | Cap unbounded message lists in AI chat screens | Backend Dev | pending | P2 |

### Acceptance Criteria
- **CYC-078**: Timers stored in fields and cancelled in dispose(). Mounted/hasClients guard in callbacks.
- **CYC-079**: _messages capped at 100 entries. Oldest dropped. Gemini history uses sliding window.

---

## Epic 21: Data Wiring (Placeholder → Real Data)
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-091 | Wire HeatmapScreen to real category stats with BLoC | Frontend Dev | pending | P1 |
| CYC-092 | Wire ProfileScreen stats + settings to real data | Frontend Dev | pending | P1 |
| CYC-093 | Wire ExamInfoScreen to Firestore exam dates | Frontend Dev | pending | P1 |
| CYC-094 | Create abstract service interfaces for testability | Backend Dev | pending | P2 |
| CYC-095 | Add TODO markers to all unmarked placeholder data | Frontend Dev | pending | P2 |

### Acceptance Criteria
- **CYC-091**: HeatmapBloc fetches from FirestoreService.getCategoryStats(). Real percentages, trends. No hardcoded data.
- **CYC-092**: ProfileBloc or direct Firestore read for real streak, totalAnswered, averageScore, badges. Settings persisted in Hive.
- **CYC-093**: ExamInfoBloc fetches from FirestoreService.getExamDates(). Countdown from real data.
- **CYC-094**: Abstract IAuthService, IFirestoreService, IGeminiService, IBillingService. Concrete classes implement them. Registered via DI.
- **CYC-095**: All hardcoded placeholder values have explicit // TODO: markers for IDE discoverability.

---

## Epic 22: Code Quality & Polish
| ID | Title | Agent | Status | Priority |
|----|-------|-------|--------|----------|
| CYC-096 | Wire all navigation TODOs (paywall, notifications, answer review, date picker) | Frontend Dev | pending | P1 |
| CYC-097 | Fix DI bypass in FlashcardsBloc and ExamSimulatorBloc | Backend Dev | pending | P1 |
| CYC-098 | Add orElse guard to BillingService.buyPremium() | Backend Dev | pending | P1 |
| CYC-099 | Fix hardcoded locale 'en' — read user's selected language | Frontend Dev | pending | P1 |
| CYC-100 | Widget optimizations (const constructors, narrow BlocBuilders, cached SharedPreferences) | Frontend Dev | pending | P2 |
| CYC-101 | Use Gemini systemInstruction parameter + cache ChatSession | Backend Dev | pending | P2 |
| CYC-102 | Code quality cleanup (extract Hive helper, deduplicate checklist, fix magic numbers, add comments) | Backend Dev | pending | P2 |
| CYC-103 | Production hardening (gate debug prints, sanitize error messages, fix email validation, gitignore) | Backend Dev | pending | P2 |

### Acceptance Criteria
- **CYC-096**: All 6 navigation TODOs wired to real screens. Paywall → PaywallScreen. Notifications → NotificationsScreen. Answer review → ReviewScreen. Date picker → DatePickerDialog.
- **CYC-097**: Both BLoCs receive FirestoreService via context.read<FirestoreService>(). No fallback instantiation.
- **CYC-098**: buyPremium uses firstWhere with orElse, handles missing product gracefully.
- **CYC-099**: getText() receives user's language from context/preferences. All exam/flashcard screens use it.
- **CYC-100**: Const constructors added. BlocBuilder scoped narrowly in ProfileScreen, FlashcardsScreen, AiTutorScreen. SharedPreferences cached in ChecklistScreen.
- **CYC-101**: GeminiService uses GenerativeModel(systemInstruction:). ChatSession cached and reused per conversation.
- **CYC-102**: Extract _getPendingList helper in ProgressSyncService. Deduplicate checklist base items. Use AppConstants for AI limits. Add comments to BillingService. Remove redundant Hive box open.
- **CYC-103**: Debug prints gated with kDebugMode. Error messages show generic text to user, log details separately. Email validation uses proper regex. Explicit GoogleService-Info.plist in .gitignore.

---

## Summary

| Priority | Count | Description |
|----------|-------|-------------|
| P0 | 18 + 9 = 27 | Original launch must-haves + critical/high security & architecture fixes |
| P1 | 28 + 22 = 50 | Original important + high/medium review findings |
| P2 | 15 + 11 = 26 | Original nice-to-have + low-priority polish |
| **Total** | **103** | 61 original + 42 review tickets |

## User Stories

### As a citizenship exam candidate, I want to...
- US-01: Take timed mock exams that match the real format, so I know what to expect
- US-02: See which topics I'm weak in, so I can focus my study
- US-03: Practice with flashcards on my commute, so I can study anywhere
- US-04: Ask an AI tutor questions about Cyprus, so I get instant answers without searching
- US-05: Practice Greek conversation with AI, so I improve my language skills
- US-06: Get daily question notifications, so I study consistently
- US-07: Know when exams are scheduled and registration deadlines, so I don't miss them
- US-08: Find exam center locations and directions, so I know where to go
- US-09: Track which documents I've prepared, so I don't miss anything in my application
- US-10: Study in my own language (English/Russian/Greek), so I can understand the material
- US-11: Use the app offline, so I can study without internet
- US-12: Pay once and get lifetime access, so I don't worry about recurring charges
- US-13: See my study streak and badges, so I stay motivated
- US-14: Browse Keep Learning courses, so I can get professional help if needed
- US-15: Get personalized AI-generated questions, so I practice what I need most
