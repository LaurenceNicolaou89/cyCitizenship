# CyCitizenship — Project Specification

## Overview
A cross-platform mobile app (iOS + Android) that helps foreigners in Cyprus prepare for the citizenship naturalization exams. The app covers both the Culture & Politics exam (25 MCQs) and Greek Language proficiency (B1/A2).

## Target Users
- Foreign residents in Cyprus seeking naturalization
- Primary demographics: Russian-speaking, English-speaking, Greek-learning communities
- ~600+ exam candidates per session (twice yearly: February & July), growing due to fast-track routes

## Business Model
- **Free tier**: 5 practice questions/day, exam dates & reminders, exam center locations
- **Paid tier (€20 one-time)**: Unlimited practice, AI tutor, smart practice, Greek language AI, mock exams, flashcards, study streaks, application checklist, Keep Learning content

## Partnership
- **Keep Learning** (private institute): In-app course booking, exclusive content, cross-promotion

## Supported Languages
- English, Russian, Greek
- All UI, questions, and AI responses available in all 3 languages

---

## Core Features

### 1. Exam Simulator
- Timed 25-question mock exams matching real exam format
- 4 answer options per question, 45-minute timer
- Score tracking with history
- Pass/fail indicator (60% = 15/25 for citizenship, 50% = 13/25 for LTR)
- Questions sourced from 4 categories: Geography, Politics, Culture/Traditions, Daily Life

### 2. Weak Area Heatmap
- Visual breakdown by category (Geography, Politics, Culture, Daily Life)
- Percentage correct per category over time
- Identifies weakest areas for focused study

### 3. Daily Question (Push Notification)
- One question delivered daily via push notification
- Tappable — opens directly to the question
- Tracks daily engagement streak

### 4. Flashcard Mode
- Swipeable cards (know it / don't know it)
- Covers all exam topics
- Spaced repetition algorithm — shows cards you struggle with more often
- Available per category or mixed

### 5. AI Tutor Chatbot
- Powered by Gemini Flash
- Ask any question about Cyprus history, politics, culture, geography
- Context-aware — knows the exam syllabus
- Responds in user's selected language
- Rate-limited for free tier (3 messages/day), unlimited for paid

### 6. AI Smart Practice
- Generates personalized questions based on weak areas
- Adapts difficulty based on performance
- Explains correct answers with context
- Powered by Gemini Flash

### 7. AI Greek Language Practice
- Conversational AI partner for Greek practice
- Scenarios: ordering food, asking directions, government office interactions
- Corrections with explanations
- Difficulty levels: A2 (elementary) and B1 (intermediate)
- Powered by Gemini Flash

### 8. Exam Dates & Countdown
- Next exam date with countdown timer
- Registration window dates with reminders
- Push notification alerts: registration opens, 1 week before deadline, exam day
- Historical exam dates

### 9. Exam Center Map
- Interactive map showing all exam centers (Nicosia, Limassol, Larnaca, Paphos)
- Address, directions (Google Maps integration)
- Center details and capacity info where available

### 10. Application Checklist & Document Tracker
- Step-by-step naturalization process guide
- Document checklist with tick-off:
  - Valid passport
  - Residence permit
  - Criminal record certificate
  - Proof of address
  - Financial self-sufficiency evidence
  - Language certificate (B1/A2)
  - Culture exam pass certificate
  - Application fee (€500 + €17.08 stamps)
  - Passport photos
- Progress indicator (X/Y documents ready)
- Different checklists for general route vs fast-track

### 11. Study Streaks & Badges
- Daily study streak counter
- Badges for milestones: 7-day streak, 30-day streak, first mock exam, first perfect score, etc.
- Profile page showing all achievements

### 12. Keep Learning Integration
- Browse available courses from Keep Learning
- In-app booking / link to booking
- Exclusive study materials from Keep Learning tutors
- Keep Learning branding section in app

### 13. User Profile & Settings
- Language selection (EN/RU/EL)
- Notification preferences
- Study statistics overview
- Subscription status
- Exam target date setting

---

## Authentication
- Firebase Authentication
- Sign-in methods: Email/password, Google Sign-In, Apple Sign-In (required for iOS)
- Guest mode for browsing free content (prompt to sign up for tracking)

## Payments
- Google Play Billing (Android)
- Apple In-App Purchase (iOS)
- One-time payment of €20 for lifetime access
- Free tier always available

## Content Management
- Question bank stored in Firestore
- Admin capability to add/update questions without app update
- Questions tagged by: category, difficulty, language, source
- Content versioning for freshness (political info changes)

## Notifications
- Firebase Cloud Messaging (FCM)
- Notification types: daily question, exam date reminders, registration deadlines, streak reminders

## Offline Support
- Downloaded question bank available offline
- Flashcards work offline
- AI features require internet connection
- Sync progress when back online

## Analytics
- Firebase Analytics
- Track: daily active users, question completion rates, mock exam scores, subscription conversions, feature usage
