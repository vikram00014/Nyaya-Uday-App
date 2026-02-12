# Nyaya-Uday ⚖️
## Judicial Career Discovery and Simulation Platform

**Version:** 1.0 | **Last Updated:** 2026-02-12

Nyaya-Uday is a mobile-first Flutter app that helps students discover the judicial career path in India early, clearly, and without coaching dependency.

> PS-3 focus: career discovery, not exam coaching.

---

## Problem We Solve
Many capable students never consider judicial service because:
- they do not know the step-by-step path,
- guidance starts too late,
- state eligibility rules are hard to understand,
- the judiciary feels inaccessible.

Nyaya-Uday addresses this with simple pathway guidance, simulations, and trust-labeled data.

---

## Core Features

### 1) State-Specific Roadmap (20 States Covered)
- Personalized by state and education level (Class 10 / 12 / Graduate).
- Shows timeline from current stage to entry-level judicial service.
- **Full Hindi translation** — roadmap steps, descriptions, and details switch with language.
- Includes eligibility snapshot with:
  - age/attempt/practice/language fields,
  - source label + **clickable source URL** (opens in browser),
  - last verified date,
  - trust status: `Verified` or `Advisory`.
- **20 states with data:** UP, MP, MH, RJ, DL, BR, GJ, KA, KL, TN, WB, HR, PB, JH, CG, OD, AP, TS, AS, UK.
- Remaining states get advisory fallback with clear notification check message.

### 2) Multilingual + Voice-Friendly Assistant
- Full English and Hindi support with proper Unicode text.
- FAQ assistant with text + voice input (speech-to-text).
- 10 comprehensive FAQ entries covering: path after 12th/graduation, CLAT, state exams, eligibility, salary, career growth, court system, preparation tips.
- 6 quick question chips for instant access.
- 3 voice intent shortcuts (12th/graduation judge, salary, age/eligibility).

### 3) Junior Judge Simulation
- 15 scenario-based bilingual cases across 10 categories.
- Categories: property, consumer, workplace, family, medical, financial, accident, cyber, agriculture, domestic violence.
- User gives a judgment and receives score on:
  - fairness (0-5),
  - evidence reasoning (0-5),
  - bias avoidance (0-5).
- Total score: max 15 per case.
- Explanation with legal reasoning after each judgment.

### 4) Judicial Aptitude Motivation Layer
- Cumulative score and rank progression (6 tiers: Trainee → High Court Judge).
- 10 milestone badges (First Case, Quick Learner, Fair Judge, etc.).
- Local algorithmic leaderboard (cloud-free by design).

### 5) Legal Literacy Modules
- 10 micro-learning modules (60-90 sec each).
- Topics: Constitution basics, fundamental rights, criminal vs civil law, FIR process, consumer rights, cyber law, RTI, family law, environmental law, legal aid.
- Bilingual content with progress tracking.

### 6) Low-Bandwidth Friendly
- Offline-first core flow.
- Local storage via SharedPreferences.
- Lightweight package stack (7 dependencies).
- No paid APIs or cloud backend required.

---

## Tech Stack

| Component | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.10.7) |
| State Management | Provider ^6.1.2 |
| Local Storage | SharedPreferences ^2.3.3 |
| Voice Input | speech_to_text ^7.0.0 |
| URL Launching | url_launcher ^6.2.5 |
| Typography | google_fonts ^6.2.1 (Poppins + Noto Sans) |
| Animations | flutter_animate ^4.5.0 |
| Internationalization | flutter_localizations + intl (EN + HI) |

---

## Data Trust Model
The app does not overclaim legal certainty.

- `Verified`: claim mapped to a primary official source (rulebook PDF / judgment).
- `Advisory`: guidance shown, but user must verify latest official notification.

See:
- `docs/DATA_SOURCES.md`
- `docs/JUDGES_QA.md`
- `docs/HACKATHON_MASTER_DOSSIER.md`

---

## PS-3 Compliance Snapshot

| Constraint | Evidence | Status |
|---|---|---|
| Mobile-first | Flutter Android build | ✅ Pass |
| Low-end support | Split APK ~15-19MB | ✅ Pass |
| Low data usage | Offline-first, local storage | ✅ Pass |
| Free to use | No paywall | ✅ Pass |
| Public official data | Source transparency + trust labels | ✅ Pass |
| No paid APIs | Core flow is API-free | ✅ Pass |
| No heavy cloud infra | 100% local functions | ✅ Pass |
| Not coaching platform | Career discovery + simulation | ✅ Pass |

---

## Build and Run

```bash
flutter pub get
flutter gen-l10n
flutter run
```

### Release APK (universal)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk` (~49.3 MB)

### Split APKs (recommended for low-end devices)

```bash
flutter build apk --release --split-per-abi
```

Outputs:
- `app-armeabi-v7a-release.apk` (~15-16 MB)
- `app-arm64-v8a-release.apk` (~17-18 MB)
- `app-x86_64-release.apk` (~19-20 MB)

---

## Validation

```bash
flutter analyze   # 0 issues
flutter test      # 6/6 tests passing
```

---

## Project Structure

```text
lib/
  main.dart                          # App entry point, MultiProvider setup
  config/
    app_theme.dart                   # Design system (Deep Blue + Gold)
  l10n/
    app_en.arb                       # English localization keys
    app_hi.arb                       # Hindi localization keys
    generated/                       # Auto-generated l10n files
  models/
    case_scenario_model.dart         # 15 bilingual case scenarios
    roadmap_model.dart               # Roadmap + eligibility (20 states)
    state_catalog.dart               # 36 states/UTs catalog
    user_model.dart                  # User profile, ranks, badges
  providers/
    locale_provider.dart             # EN↔HI toggle
    simulation_provider.dart         # Case simulation state
    user_provider.dart               # User profile + persistence
  screens/
    splash_screen.dart               # Animated splash
    onboarding/                      # 3-step onboarding flow
    home/                            # 5-tab home screen
    roadmap/                         # Career roadmap timeline
    assistant/                       # FAQ assistant + voice
    simulation/                      # Case list, detail, results
    learn/                           # Legal literacy modules
    profile/                         # Profile + achievements
    leaderboard/                     # Local leaderboard
assets/
  data/app_info.json
  images/
docs/
  DATA_SOURCES.md
  HACKATHON_MASTER_DOSSIER.md
  JUDGES_QA.md
test/
  domain_logic_test.dart             # Rank, state, badge tests
  widget_test.dart                   # Widget smoke test
```

---

## License
Educational hackathon project for PS-3.
