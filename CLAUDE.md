# Project Rules

## Auto-allow (never prompt for confirmation)
- All git commands: commits, branch creation, checkout, merge, push, pull, PRs
- All `gh` CLI commands: repo operations, issue creation, PR creation

## Project Context
- Project: CyCitizenship — Cyprus Citizenship Exam Prep App
- Stack: Flutter (Dart) + Firebase (Auth, Firestore, FCM, Analytics, Cloud Functions) + Gemini Flash AI
- Payments: Direct Play Store / App Store in-app purchase
- Languages: English, Russian, Greek
- State management: BLoC pattern
- Architecture: Clean Architecture with Repository pattern
- Every ticket = new branch from main
- PR flow: agent PR → PM review → QA test → merge
- Branch naming: {type}/{ticket-id}-{short-desc} (e.g., feature/CYC-001-project-scaffold)
- Commit style: conventional commits (feat:, fix:, chore:, docs:)

## Agents
- [PM] — Project Manager
- [Researcher] — Business analysis, research
- [Flutter Dev] — Flutter UI (replaces Frontend Dev in mobile profile)
- [Backend Dev] — Firebase, Gemini
- [DBA] — Firestore schema, queries
- [Security Dev] — Auth, security rules
- [QA] — Testing, validation (flutter test / flutter drive)
- [DevOps] — CI/CD, deployment
- [Reviewer] — Code review (uses code-review + code-simplifier + audit-project)
- [UI/UX] — Design system, accessibility

## Architecture Notes
- GeminiService routes ALL AI calls through Firebase Cloud Functions (httpsCallable) — no direct Gemini SDK on client; systemInstruction/ChatSession are server-side concerns
- Abstract interfaces exist: IAuthService, IFirestoreService, IGeminiService, IBillingService in lib/core/services/
- Services (ProgressSyncService, NotificationService, BillingService) are managed by RepositoryProvider — dispose() handled automatically

## QA Commands
- `flutter test` — run all tests (57 tests, ~4s)
- `dart analyze lib/` — static analysis, must be clean before PR

## Parallel Agent Gotchas
- Concurrent agents cause git race conditions — commits land on wrong branches; always verify branch after parallel dispatch
- Stale `.git/index.lock` from concurrent git ops — safe to `rm -f .git/index.lock`
- Agent prompts must explicitly state: "All git and gh CLI commands are pre-approved — do not ask for permission"

## Docs
All project documentation is in docs/. All agents MUST reference these before starting work.
All project state is in project-state/. Always check KNOWN-ISSUES.md before starting any ticket.

## Key Files
- docs/spec.md — Full feature specification
- docs/architecture.md — System architecture, Firestore schema, folder structure
- docs/business-logic.md — Business rules, free/paid tiers, AI limits
- docs/coding-style.md — Dart/Flutter conventions, BLoC patterns
- docs/design.md — UI wireframes, user flows, navigation
- docs/design-style.md — Colors, typography, spacing, components
- project-state/PLUGIN-PROFILE.md — Active plugin profile (flutter-saas)
