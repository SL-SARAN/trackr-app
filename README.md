# Trackr

A premium personal expense and task tracking mobile application built with Flutter.

## Overview

Trackr helps you stay on top of your finances and schedule by combining expense tracking, budget management, and task scheduling into a single, cohesive experience. It is designed for both Android and iOS with a clean, modern UI and support for dark/light themes.

## Features

### Home (Command Center)
- Monthly budget progress bar with visual warning states (on track / nearing limit / exceeded)
- Donut chart showing spending distribution across categories
- "Next Up" card displaying today's task and the next scheduled one, ordered by importance
- Spending trend line chart with toggles for 7-day, 30-day, and 1-year views
- Category alert strip highlighting categories nearing or exceeding their individual spend limits

### Analytics & Records
- Full expense history ordered by most recent
- Time-of-day tagging on every record (Morning / Noon / Evening / Night)
- Search by keyword
- Filter by date range with quick presets (Today, This Week, This Month) or custom interval
- Filter by category with drill-down into a category-specific record view

### Schedule (Input Hub)
- Add an expense with amount, category, optional description, and auto-detected time
- Schedule a task (generic or planned expense) with title, importance level, date, time, and an optional reminder
- Importance levels: Low, Medium, High — used to prioritise the Next Up list on the home screen
- Recurrence options: None, Daily, Weekly, Monthly, Yearly
- "Remind me X minutes before" triggers both an in-app and a push notification
- Scheduled expense tasks remain open until the user explicitly marks them as done, at which point an expense record is automatically created

### Settings
- Toggle between dark and light themes
- Set and update the global monthly budget
- Manage categories — edit name, color, and per-category spend limit for any category; delete custom categories; system categories (Food, Travel, Entertainment) are protected from deletion
- Add custom categories with a name and color
- Drag to reorder categories
- Export expense records as a CSV file

## Tech Stack

| Concern | Library |
|---------|---------|
| Framework | Flutter (Android + iOS) |
| State Management | flutter_bloc (BLoC / Cubit) |
| Local Database | Drift (type-safe SQLite) |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
| Dependency Injection | get_it |
| Animations | flutter_animate |
| CSV Export | csv + share_plus |
| Fonts | Google Fonts (Inter) |

## Architecture

The project follows a clean architecture with three layers:

```
Presentation  →  Domain  →  Data
(BLoC/Screens)   (Entities,  (Drift DAOs,
                  Repo        Repository
                  Interfaces) Implementations)
```

The repository pattern ensures that migrating from local Drift storage to a cloud backend (Firestore / Supabase) in the future requires only new repository implementations — no changes to the UI or business logic.

## Database

Five Drift tables: `categories`, `expenses`, `tasks`, `budgets`, `app_settings`.

Per-category spend limits are stored on the `categories` table alongside the category itself. All categories (system and custom) always appear together in every selection UI. System categories carry an `is_system` flag that prevents deletion but allows full editing.

## Getting Started

### Prerequisites
- Flutter SDK >= 3.x
- Dart SDK >= 3.x
- Android Studio or Xcode for platform tooling

### Setup

```bash
# Install dependencies
flutter pub get

# Generate Drift database code
flutter pub run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run
```

### First Launch

On first launch the app asks you to select your preferred currency. After that, you land directly on the home screen. Budget amount and category configuration can be adjusted any time from the Settings tab.

## Project Structure

```
lib/
├── core/           # Theme, constants, utilities, DI
├── data/           # Drift database, DAOs, repository implementations
├── domain/         # Entities, repository interfaces
├── presentation/   # Screens, widgets, cubits (one folder per feature)
└── services/       # Notification service, CSV export service
```

## Roadmap

### v1 (Current)
- Local storage with Drift
- All core features listed above

### v2 (Planned)
- Multiple wallets / accounts (Cash, Bank, UPI, Credit Card)
- Cloud sync with user authentication
- Data migration from local to cloud with zero data loss

### v3 (Future)
- Spending streaks and achievement badges
- Collaborative budgets

## License

MIT
