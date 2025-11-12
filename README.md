# Acme Tasks (Flutter)

Offline-first task manager with sync, filters, search, and basic analytics.

## Prerequisites
- Flutter SDK installed
- Node.js (for mock API)

## Quick Start
1) Create missing platform scaffolding (if not present):
```bash
flutter create .
```
2) Install Flutter deps:
```bash
flutter pub get
```
3) Start Mock API:
```bash
cd api
npm install
npm run start
```
This starts the API at `http://localhost:3333`.

4) Run the app:
```bash
flutter run
```

## Features
- Task CRUD: create, read, update, delete
- Status: pending, in-progress, completed
- Offline support: local persistence via SQLite, queue sync when online
- Sync: last-write-wins based on `updatedAt`
- Filtering, sorting, and search
- Pull-to-refresh to fetch from server
- Offline indicator banner
- Analytics screen: totals and breakdowns

## Architecture
- Pattern: Clean-ish modular structure + Riverpod for state
- Data Layer: `sqflite` for local DB, `dio` for API
- Repositories: offline-first with `sync_queue` table
- State: Riverpod providers for filters, tasks, and sync controller

Key folders:
- `lib/src/core`: low-level services (db, network)
- `lib/src/features/tasks`: feature modules (data, presentation)
- `api/`: mock API server (Express)
- `test/`, `integration_test/`

## Testing
Unit:
```bash
flutter test
```
Integration:
```bash
flutter test integration_test
```

## API
Mock API endpoints:
- GET `/api/tasks`
- GET `/api/tasks/:id`
- POST `/api/tasks`
- PUT `/api/tasks/:id`
- DELETE `/api/tasks/:id`
- GET `/api/categories`

## Notes
- App base URL: `http://localhost:3333` (see `ApiClient`)
- If running on a device/emulator, adjust host:
  - iOS Simulator: `localhost` works
  - Android emulator: use `10.0.2.2` in `ApiClient`

## AI Usage Disclosure
If you used AI tools, add details here:

### Tools Used
- ChatGPT (for idea generation/debugging)

### Prompts Used
- Paste your exact prompts/questions here.

### How AI Helped
- Briefly describe how AI influenced your approach/decisions.


