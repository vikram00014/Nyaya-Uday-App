# Nyaya-Uday ⚖️
## Judicial Career Discovery and Simulation Platform

**Version:** 3.1 | **Last Updated:** 2026-02-16

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
- **20 states with data:** UP, MP, **MH (Verified)**, RJ, DL, BR, GJ, KA, KL, TN, WB, HR, PB, JH, CG, OD, AP, TS, AS, UK.
- Remaining states get advisory fallback with clear notification check message.

### 2) Multilingual + Voice-Friendly Assistant (CVI-Enhanced)
- Full English and Hindi support with proper Unicode text.
- **Dual-mode chatbot**: LLM-powered (Groq API) online + rule-based offline fallback.
- 10 comprehensive FAQ entries covering: path after 12th/graduation, CLAT, state exams, eligibility, salary, career growth, court system, preparation tips.
- 6 quick question chips for instant access.
- 3 voice intent shortcuts (12th/graduation judge, salary, age/eligibility).
- **CVI Features (Civic Voice Interface):**
  - **Feature 1 — Interaction History & Reference Recall**: Session memory retains state, education, age, category, gender, and topics discussed. LLM naturally references earlier context.
  - **Feature 2 — Structured Decision Checkpoint**: Before answering, confirms understanding with Yes/No buttons: *"Let me confirm: you are asking about __ in __ state."*
  - **Feature 3 — Alternative Path Suggestion**: When ineligible, suggests 2+ alternative routes (education upgrade, different exam, reservation benefit, legal aid route, etc.).
  - **Feature 4 — Conversation Time Awareness**: Offers summary after 5 interactions; time check after 8 interactions. Never drops user queries.
  - **Feature 5 — Graceful Failure & Safe Exit**: Summarizes what is known, suggests official sources (HC website, PSC portal, Legal Aid Centre, Helpline 15100), ends with encouragement.

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
- Cumulative score and rank progression (6 tiers: Trainee → Legal Intern → Junior Advocate → Civil Judge → District Judge → High Court Judge).
- 10 milestone badges (First Case, Quick Learner, Fair Judge, etc.).
- Local algorithmic leaderboard (cloud-free by design).

### 5) Legal Literacy Modules
- 12 micro-learning modules (60-90 sec each).
- Topics: Constitution basics, fundamental rights, criminal vs civil law, FIR process, consumer rights, cyber law, RTI, family law, environmental law, legal aid, juvenile justice, women's rights.
- **9 Landmark Cases** with full bilingual content:
  - Vishaka vs State of Rajasthan (1997) — Workplace sexual harassment
  - Shayara Bano vs Union of India (2017) — Triple Talaq
  - K.S. Puttaswamy vs Union of India (2017) — Right to Privacy
  - Kesavananda Bharati vs State of Kerala (1973) — Basic Structure Doctrine
  - Maneka Gandhi vs Union of India (1978) — Due Process of Law
  - Nirbhaya Case (2017) — Criminal Law reforms
  - DK Basu vs State of West Bengal (1997) — Arrest guidelines
  - Unnikrishnan vs State of AP (1993) — Right to Education
  - Olga Tellis vs BMC (1985) — Right to Livelihood
- Each landmark case includes: what happened, court decision, why it matters, **clickable indiankanoon.org link**, and **YouTube link**.
- Bilingual content with progress tracking.
- **Text-to-Speech (TTS)**: Listen to any module content with play/pause control via `flutter_tts`.
- **21 bilingual quiz questions**: Each module and landmark case includes a bilingual MCQ with instant feedback.

### 6) User Profiling & Personalization
- Onboarding collects: **name**, state, education level, age, category (General/SC/ST/OBC/EWS), gender (Male/Female/Other), **annual income**, **disability (PwD) status**.
- **Editable Profile**: All fields can be changed anytime from the profile screen via bottom sheets and dialogs.
- Profile data passed to LLM for personalized eligibility guidance including relaxed age limits for reserved categories.
- **Chatbot personalization**: AI assistant addresses user by name, uses all profile data for tailored responses.
- Legal aid eligibility automatically assessed based on state, category, and income.

### 7) Roadmap Progress Tracking
- **Live progress bar** showing completed steps count and percentage.
- **Mark steps complete** with tap-to-toggle on each timeline step.
- **Motivational messages** that change based on progress (🚀 Start → 💪 Great start → 🔥 Amazing → 🏆 All done).
- Visual distinction: completed steps show green checkmarks with glow, green connecting lines, and tinted cards.
- Progress persisted via SharedPreferences.

### 8) Personal Notes
- **Full CRUD notes** with title, body, and category tagging.
- **5 categories**: General, Exam Prep, Legal Concepts, Case Notes, Important Dates.
- Swipe-to-delete with confirmation dialog.
- Notes persisted locally via SharedPreferences.
- Accessible from home screen quick action card.

### 10) Daily Legal Tip
- **30 bilingual legal tips** rotating daily on the home screen (day-of-year based).
- Covers: Articles 21, 39A, BNS 2024, Lok Adalat, CLAT, PIL, writs, court hierarchy, salary, reservations, landmark cases, NALSA, RTI, and more.
- Compact card with 💡 icon, auto-switches EN↔HI.

### 11) Study Streak Tracker
- **Consecutive day tracking** — counts active days automatically via SharedPreferences.
- Motivational messages at milestones: 3 days (🌟), 7 days (⭐), 14 days (🔥), 30+ days (🏆).
- Orange gradient card on home screen with flame icons.
- Resets to 1 if a day is missed, persisted across sessions.

### 12) Legal Glossary
- **Searchable A-Z glossary** with 43 English and 30 Hindi legal terms.
- **8 color-coded categories**: Criminal Law, Civil Law, Constitutional Law, Court System, Procedure, Legal Profession, Exam Related, Legal Institution.
- Alphabetically grouped with letter headers.
- Expandable cards with definitions + real-world examples.
- Category chips for quick visual identification.
- Accessible from home screen quick action card.

### 13) Legal Aid Eligibility Data (NALSA / Article 39A)
- Complete income limits for all 36 states/UTs (₹9,000 to ₹3,00,000).
- Universal eligibility categories (SC, ST, Women, Children, PWD, etc.).
- Application process: where to apply, required documents, online/offline modes.
- NALSA Helpline 15100 integrated into chatbot responses.

### 14) Low-Bandwidth Friendly
- Offline-first core flow (roadmap, simulation, FAQ work without internet).
- Online LLM chatbot with automatic offline fallback.
- Local storage via SharedPreferences.
- Lightweight package stack (10 dependencies).
- No paid APIs required for core features (Groq free tier for LLM).

### 15) Smart LLM Response Sizing
- **Proportional response length** based on query complexity:
  - Greetings → 1-2 sentences
  - Simple factual → 2-4 sentences
  - Medium complexity → 100-200 words
  - Complex multi-part → 200-350 words max
- Prevents verbose answers to simple queries.

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
| Text-to-Speech | flutter_tts ^4.2.0 |
| HTTP Client | http ^1.2.0 (LLM API calls) |
| Connectivity | connectivity_plus ^6.1.0 (network detection) |
| LLM Backend | Groq API (Llama 3.3 70B Versatile) |
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
| Bilingual | Full EN + HI support (UI, roadmap, FAQ, cases) | ✅ Pass |
| Voice-friendly | speech_to_text + CVI chatbot | ✅ Pass |

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

Output: `build/app/outputs/flutter-apk/app-release.apk` (~51.7 MB)

### Split APKs (recommended for low-end devices)

```bash
flutter build apk --release --split-per-abi
```

Outputs:
- `app-armeabi-v7a-release.apk` (~16 MB)
- `app-arm64-v8a-release.apk` (~19 MB)
- `app-x86_64-release.apk` (~20 MB)

---

## Validation

```bash
flutter analyze   # 0 issues
flutter test      # 6/6 tests pass
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
    home/                            # 7-action home + streak + daily tip
    roadmap/                         # Career roadmap with progress tracking
    assistant/                       # FAQ assistant + voice
    simulation/                      # Case list, detail, results
    learn/                           # Legal literacy + landmark cases + glossary
    profile/                         # Editable profile + achievements
    leaderboard/                     # Local leaderboard
    notes/                           # Personal notes (CRUD)
  services/
    groq_service.dart                # Groq LLM API client
    knowledge_base.dart              # System prompt builder + legal aid data
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
