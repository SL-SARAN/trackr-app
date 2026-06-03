# Trackr

A premium personal expense & task tracker built with Flutter — designed for clean architecture, local-first storage, and future cloud migration.

## Features

### Home (Command Center)
- **Budget Progress** — Visual progress bar comparing total spent vs. monthly budget, with safe/warning/over states
- **Category Donut Chart** — Interactive pie chart showing spending distribution across categories
- **Category Alerts** — Horizontal alert chips for categories nearing or exceeding their individual budget limits
- **Next Up** — Displays the next 2 upcoming tasks with importance levels and time labels
- **Spending Trend** — Line chart of daily spending with toggleable 7-day / 30-day / 1-year views

### Analytics (Historical View)
- Full expense history with infinite scroll pagination
- Category filter chips and date range picker
- Search by description
- Swipe-to-delete expense records
- Time-of-day tags (Morning, Noon, Evening, Night)

### Schedule (Input Hub)
- **Add Expense** tab — Amount, category, description, date/time picker
- **Add Task** tab — Title, description, importance selector, date/time, recurrence options
- Planned expense toggle that links tasks to automatic expense creation
- Category-colored dropdowns for quick identification

### Settings
- **Monthly Budget** — Set or update the global monthly budget
- **Dark Mode** — Toggle between light and dark themes
- **CSV Export** — Export all expenses as a `.csv` file via the system share sheet
- **Category Management** — Add custom categories with color picker and optional per-category budget limits
- System categories (Food, Travel, Entertainment) are protected from deletion

### Onboarding
- Currency selection screen on first launch
- Seeds default system categories automatically

## Architecture

```
lib/
├── core/               # Theme, constants, DI, utilities
├── data/               # Database (Drift), DAOs, repository implementations
├── domain/             # Pure entities and repository interfaces
├── presentation/       # BLoC/Cubit + UI screens
│   ├── home/
│   ├── analytics/
│   ├── schedule/
│   ├── settings/
│   ├── onboarding/
│   ├── navigation/     # AppShell with bottom nav
│   └── shared/         # ThemeCubit
└── services/           # Notifications, CSV export
```

**Design patterns:**
- **Clean Architecture** — `domain/` ↔ `data/` separation via abstract repository interfaces
- **BLoC/Cubit** — Each screen has its own Cubit for state management
- **Repository Pattern** — All data access goes through repositories; swap implementations for cloud migration
- **Drift ORM** — Typed SQL with generated code for local SQLite storage

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter (Material 3) |
| State | flutter_bloc / Cubit |
| Database | Drift (SQLite) |
| Charts | fl_chart |
| Animations | flutter_animate |
| DI | get_it |
| Notifications | flutter_local_notifications |
| CSV | Custom export service |
| Formatting | intl |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build

# Run the app
flutter run
```

## Future Roadmap

- Cloud migration (Firestore) with local-to-cloud data sync
- Authentication layer
- Multiple wallets
- Streaks & badges
- Push notifications for task reminders
