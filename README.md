# Athena
A survey and data collection app for gathering user feedback.

---

## Features

**Survey form** — Three question types: text input, multiple choice, and checkboxes. Form validation with required field support.

**Responses viewer** — Real-time streaming of all submissions from Firestore. Expandable cards showing only answered questions. Delete with confirmation dialog.

**Clean data** — Blank optional fields are filtered out before submission, keeping the database clean.

**Offline support** — Platform-aware persistence for both web and mobile. Writes queue offline and sync when connectivity returns.

**Theming** — Material 3 with Indigo color scheme.

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Flutter |
| Backend | Firebase Firestore |
| Offline | Firestore persistence |
| Design system | Material 3 |

---

## Getting Started

```bash
git clone https://github.com/TheJeffreyKuo/Athena.git
cd Athena
flutter pub get
flutterfire configure
flutter run
```
