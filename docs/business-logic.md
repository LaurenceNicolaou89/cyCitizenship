# CyCitizenship — Business Logic

## Free vs Paid Access

| Feature | Free | Paid (€20) |
|---------|------|------------|
| Practice questions | 5/day | Unlimited |
| Exam simulator | No | Yes |
| Flashcards | 10 cards/session | Unlimited |
| AI Tutor | 3 messages/day | Unlimited |
| AI Smart Practice | No | Yes |
| AI Greek Practice | No | Yes |
| Exam dates & reminders | Yes | Yes |
| Exam center map | Yes | Yes |
| Application checklist | View only | Interactive with tracking |
| Study streaks & badges | Basic | Full |
| Keep Learning content | Browse | Full access |
| Weak area heatmap | No | Yes |

## Exam Simulator Rules

1. **Question selection**: Random 25 questions, weighted by category to match real exam distribution:
   - Geography: ~6 questions
   - Politics: ~7 questions
   - Culture/Traditions: ~6 questions
   - Daily Life: ~6 questions
2. **Timer**: 45 minutes, countdown displayed. Warning at 5 minutes remaining.
3. **No going back**: Once answered, cannot change (mirrors real exam behavior — confirm with user if real exam allows review)
4. **Scoring**: Score shown at end with breakdown by category
5. **Pass thresholds**:
   - Citizenship: 60% (15/25) — green indicator
   - Long-term residence: 50% (13/25) — yellow indicator
   - Below 50%: red indicator
6. **History**: All mock exams saved with date, score, duration, category breakdown

## Flashcard Spaced Repetition

- Algorithm: Modified Leitner system
- New cards start in Box 1 (shown daily)
- Correct → move to next box (shown less frequently)
- Incorrect → move back to Box 1
- Box intervals: 1 day, 3 days, 7 days, 14 days, 30 days
- Cards marked "mastered" after Box 5 completion

## Study Streak Logic

- A "study day" = answering at least 1 question OR completing 1 flashcard session
- Streak resets at midnight (user's local timezone)
- Grace period: None (keeps it motivating)
- Push notification at 8pm if user hasn't studied that day: "Don't break your X-day streak!"

## Daily Question

- Sent at 9:00 AM local time via FCM
- Question selected from pool, avoiding recently shown questions (last 30 days)
- Weighted toward user's weak categories (if enough history)
- Tapping notification opens question directly
- Answering counts toward daily streak

## AI Rate Limiting

### Free Tier
- AI Tutor: 3 messages per day (resets at midnight)
- AI Smart Practice: Locked
- AI Greek Practice: Locked
- Show upgrade prompt after limit reached

### Paid Tier
- All AI features: 50 messages per day per feature
- Soft limit — show warning at 45, hard block at 50
- Prevents abuse while being generous for genuine study

## AI System Prompts

### Tutor Chatbot
- Role: Expert on Cyprus history, politics, geography, culture, daily life
- Knowledge base: visitcyprus.com content, exam syllabus, current political info
- Behavior: Concise answers, exam-focused, cite sources when possible
- Language: Respond in user's selected language
- Boundaries: Only answer Cyprus-related questions relevant to the exam

### Smart Practice
- Role: Exam question generator
- Input: User's weak categories and difficulty level
- Output: Single question in exam format (4 options) with explanation
- Adapts difficulty based on recent performance
- Avoids generating questions too similar to existing bank

### Greek Language Practice
- Role: Greek conversation partner and teacher
- Levels: A2 (elementary) and B1 (intermediate) modes
- Scenarios: Daily life situations relevant to living in Cyprus
- Behavior: Speak in Greek, provide transliteration, correct mistakes gently
- Switch to user's language for explanations when asked

## Notification Strategy

| Notification | Time | Condition |
|--------------|------|-----------|
| Daily question | 9:00 AM | Always (can disable) |
| Streak reminder | 8:00 PM | If hasn't studied today |
| Registration opens | Day of | When exam registration announced |
| Registration closing | 3 days before | Upcoming deadline |
| Exam reminder | 1 week + 1 day before | Upcoming exam |
| Welcome back | After 7 days inactive | Re-engagement |

## Content Freshness

- Political questions flagged for review every 6 months
- Admin can mark questions as "outdated" → excluded from rotation
- App checks for content updates on launch (Firestore listener)
- Last update date shown to users for transparency

## Multi-Language

- App UI fully translated: EN, RU, EL
- Questions available in all 3 languages simultaneously
- User selects language at onboarding, changeable in settings
- AI responses match user's selected language
- Fallback: English if translation missing

## Keep Learning Integration

- Courses listed in dedicated section
- Each course: title, description, price, type (online/in-person), booking link
- Deep link to Keep Learning booking system
- Keep Learning can update course listings via Firestore (admin access)
- Analytics: track how many users view/click through to Keep Learning

## Checklist Logic

- Two checklist variants: General Route (7+1 years) and Fast-Track (3-4 years)
- User selects their route at onboarding
- Items can be checked off, with progress saved
- Progress persists across devices (Firestore sync)
- Optional: reminder notifications for incomplete items

## Edge Cases

- **No internet**: App works offline for questions and flashcards. AI features show "Internet required" message. Progress syncs when back online.
- **Concurrent devices**: Last-write-wins for simple fields. Merge for arrays (answers, badges).
- **Content update mid-exam**: Exam simulator uses locally cached questions. Updates apply after exam completion.
- **Payment restore**: "Restore Purchase" button on paywall. Queries Play Store / App Store for existing purchase.
- **Account deletion**: GDPR-compliant. Delete all user data from Firestore + Auth. Confirm with dialog.
