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
