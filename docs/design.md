# CyCitizenship — UI/UX Design

## Design Philosophy
- **Clean & focused** — users are stressed about exams, don't add cognitive load
- **Mobile-first** — every interaction designed for thumb reach
- **Progress-driven** — always show users how far they've come
- **Accessible** — WCAG 2.1 AA minimum, high contrast, readable fonts

## Navigation Structure

### Bottom Navigation Bar (5 tabs)
1. **Home** — dashboard with quick stats, daily question, countdown
2. **Practice** — exam simulator, flashcards, smart practice
3. **AI** — tutor chatbot, Greek practice
4. **Info** — exam dates, centers, checklist, Keep Learning
5. **Profile** — stats, badges, settings, subscription

## Screen Wireframes

### Home Screen
```
┌─────────────────────────────┐
│  CyCitizenship        [🔔]  │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │  Next Exam: July 5      │ │
│ │  ████████░░  45 days     │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │  Daily Question          │ │
│ │  "Which district..."     │ │
│ │  ○ A  ○ B  ○ C  ○ D    │ │
│ └─────────────────────────┘ │
│                             │
│ ┌──────────┐ ┌────────────┐ │
│ │ 🔥 12    │ │ 📊 68%     │ │
│ │ Day      │ │ Average    │ │
│ │ Streak   │ │ Score      │ │
│ └──────────┘ └────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │  Quick Actions           │ │
│ │  [Mock Exam] [Flashcard] │ │
│ │  [AI Tutor]  [Greek]     │ │
│ └─────────────────────────┘ │
│                             │
│ [Home] [Practice] [AI] [Info] [Profile]│
└─────────────────────────────┘
```

### Exam Simulator Screen
```
┌─────────────────────────────┐
│  ← Mock Exam    ⏱ 42:15    │
├─────────────────────────────┤
│  Question 3 of 25           │
│  ████░░░░░░░░░░░░░░░░░░░░  │
│                             │
│  Which is the highest       │
│  mountain in Cyprus?        │
│                             │
│  ┌─────────────────────────┐│
│  │ A. Mount Olympus        ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ B. Mount Troodos        ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ C. Mount Chionistra     ││  ← selected (highlighted)
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ D. Mount Stavrovouni    ││
│  └─────────────────────────┘│
│                             │
│       [Next Question →]     │
│                             │
│ [Home] [Practice] [AI] [Info] [Profile]│
└─────────────────────────────┘
```

### Exam Results Screen
```
┌─────────────────────────────┐
│  ← Results                  │
├─────────────────────────────┤
│                             │
│        ┌──────────┐         │
│        │   18/25  │         │
│        │   72%    │         │
│        │  PASSED  │         │
│        └──────────┘         │
│                             │
│  Category Breakdown:        │
│  Geography    ████████░░ 5/6│
│  Politics     ██████░░░░ 4/7│
│  Culture      ████████░░ 5/6│
│  Daily Life   ████████░░ 4/6│
│                             │
│  ⚠️ Focus on: Politics      │
│                             │
│  [Review Answers]           │
│  [Try Again]                │
│  [Share Score]              │
│                             │
│ [Home] [Practice] [AI] [Info] [Profile]│
└─────────────────────────────┘
```

### AI Tutor Screen
```
┌─────────────────────────────┐
│  ← AI Tutor          [EN ▼]│
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐    │
│  │ Hi! I'm your Cyprus │    │
│  │ exam tutor. Ask me  │    │
│  │ anything about      │    │
│  │ history, politics,  │    │
│  │ or culture.         │    │
│  └─────────────────────┘    │
│                             │
│       ┌─────────────────────┐
│       │ What are the main   │
│       │ political parties   │
│       │ in Cyprus?          │
│       └─────────────────────┘
│                             │
│  ┌─────────────────────┐    │
│  │ The main parties:   │    │
│  │ • DISY (center-right│    │
│  │ • AKEL (left)       │    │
│  │ • DIKO (center)     │    │
│  │ • EDEK (soc-dem)    │    │
│  │ ...                 │    │
│  └─────────────────────┘    │
│                             │
│ ┌─────────────────────┐ [→] │
│ │ Type a question...  │     │
│ └─────────────────────┘     │
│ [Home] [Practice] [AI] [Info] [Profile]│
└─────────────────────────────┘
```

### Flashcard Screen
```
┌─────────────────────────────┐
│  ← Flashcards    12/50     │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │                         ││
│  │                         ││
│  │   What is the capital   ││
│  │     of Cyprus?          ││
│  │                         ││
│  │     (tap to reveal)     ││
│  │                         ││
│  │                         ││
│  └─────────────────────────┘│
│                             │
│  ← Swipe left: Don't know  │
│  → Swipe right: Know it    │
│                             │
│  [Don't Know]   [Know It]  │
│                             │
│ [Home] [Practice] [AI] [Info] [Profile]│
└─────────────────────────────┘
```

## User Flows

### Onboarding Flow
1. Welcome screen (app logo, tagline)
2. Language selection (EN / RU / EL)
3. Route selection (General / Fast-Track) — brief explanation of each
4. Sign up / Sign in / Continue as Guest
5. Home screen with tutorial tooltips on first visit

### Purchase Flow
1. User hits paywall (e.g., 6th question of the day)
2. Upgrade screen: benefits list, €20 one-time, "Pay once, access forever"
3. Platform billing sheet (Google Play / Apple)
4. Success animation → full access unlocked
5. If declined → continue with free tier, no nagging

### Exam Simulator Flow
1. Select exam type (Citizenship 60% / LTR 50%)
2. Confirmation: "25 questions, 45 minutes. Ready?"
3. Questions presented one at a time
4. Timer visible, progress bar
5. Auto-submit at timer expiry
6. Results screen with category breakdown
7. Review wrong answers with explanations

## Interaction Patterns

- **Pull to refresh**: Home screen stats
- **Swipe**: Flashcards (left = don't know, right = know)
- **Long press**: Question in review → see full explanation
- **Haptic feedback**: Correct/incorrect answer
- **Animations**: Score reveal, badge unlock, streak milestone
- **Skeleton loading**: While data loads from Firestore
