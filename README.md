# 🚀 HireHub — Intelligent Career Co-Pilot & Job Discovery Platform

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS-blue?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-22%2F22%20Passing-brightgreen?style=for-the-badge&logo=checkmarx)
![License](https://img.shields.io/badge/License-MIT-blueviolet?style=for-the-badge)

**Next-generation cross-platform mobile & web application empowering candidates with deterministic fit scoring, resume parsing, multi-criteria decision matrices, and real-time application health analytics.**

[Key Features](#-key-features) •
[Architecture](#-architecture--design-patterns) •
[Tech Stack](#-tech-stack) •
[Getting Started](#-getting-started) •
[Test Suite](#-deterministic-test-suite) •
[Contributing](#-contributing)

</div>

---

## 📖 Overview

**HireHub** is a production-grade Flutter application engineered to revolutionize the modern job hunting experience. Unlike traditional job boards that act as passive search listings, HireHub serves as a **dynamic career co-pilot**. 

It combines **deterministic rule-based algorithmic matching**, **offline PDF resume byte-stream extraction**, **decision analysis matrices**, and **application pipeline health scoring** to provide transparent, actionable intelligence at every stage of the hiring lifecycle.

HireHub is built with an offline-first resilient architecture: it connects seamlessly to **Firebase Auth** and **Cloud Firestore**, while offering instant, high-fidelity **Seed Mode** out of the box with zero external configuration required.

---

## ✨ Key Features

### 🎯 1. Algorithmic Job Fit & Skill Gap Analyzer
- **5-Factor Weighted Matching**: Evaluates candidates deterministically against open roles:
  - 🛠️ **Core Technical Skills (50%)**: Exact & alias-aware technical stack verification.
  - ⏳ **Experience Match (20%)**: Experience bracket matching with curve-adjusted scoring.
  - 📍 **Location & Flexibility (10%)**: Remote, hybrid, or on-premise alignment.
  - 💼 **Employment Type (10%)**: Full-time, contract, or internship preference matching.
  - 🎓 **Education Credentials (10%)**: Degree verification.
- **Dynamic Skill Boost Simulation**: Projects expected fit score increases (+% ROI) if the candidate acquires missing skills.
- **Actionable Gap Analysis**: Direct deep links from missing skills to recommended courses, certifications, and learning roadmaps.

### ⚖️ 2. Multi-Criteria Job Decision Matrix & Comparison
- **Side-by-Side Role Comparison**: Compare up to 4 offers or target roles across salary, equity, commute, culture, tech stack, and company ratings.
- **Weighted Decision Matrix**:
  - Interactive slider-driven weights across **Compensation**, **Remote Flexibility**, **Company Rating**, **Career Growth**, and **Job Fit**.
  - One-click presets: *Balanced*, *High Compensation*, and *Remote First*.
  - Deterministic ranking engine assigning Rank #1 to the most mathematically aligned role.

### 📊 3. Application Health Score & Pipeline Tracker
- **100-Point Diagnostic Engine**: Evaluates job search momentum across four 25-point dimensions:
  1. **Profile Completeness**: Portfolio links, contact info, credentials.
  2. **Resume Readiness**: Verification of documented skills and parsed keywords.
  3. **Pipeline Velocity**: Active application frequency and target balance.
  4. **Interview Conversion**: Progression rate from submission to interview rounds.
- **Live Sync & Diagnostic Tips**: Real-time feedback engine suggesting immediate high-leverage actions (e.g., adding verified skills or following up on stalled stages).

### 📄 4. Cross-Platform Resume Parser & Document Text Extractor
- **Zero-Cloud Local Byte-Stream Parsing**:
  - Pure Dart PDF text extraction supporting FlateDecode / ZLib decompression, text layout operators (`Tj`, `TJ`), kerning adjustments, and hex string decoding.
  - Custom font glyph mapping using embedded `ToUnicode CMap` translation tables.
- **Curated Technical Dictionary**: Matches hundreds of engineering aliases, frameworks, cloud technologies, databases, and acronyms (e.g., `K8s` ➔ Kubernetes, `GCP` ➔ Google Cloud Platform, `TS` ➔ TypeScript).
- **In-App Resume Builder**: Generates clean, professional PDF resumes with live preview and system printing / PDF export support.

### 🎙️ 5. Interview Prep Hub & Calendar
- **Role-Specific Intel**: Tailored technical questions with in-depth model answers covering Flutter lifecycle, state management architecture, memory leak prevention, and repository patterns.
- **Pre-Interview Readiness Checklist**: Audio/video check, architecture walkthrough preparation, and company notes.
- **Interview Calendar**: Tracks upcoming rounds with direct video meeting links (Google Meet, Zoom) and round status.

### 💰 6. Salary Explorer & Counter-Offer Simulator
- **Market Benchmarking**: Salary curves across major engineering hubs (Mumbai, Bengaluru, Delhi-NCR, Pune, Remote).
- **Counter-Offer Simulator**: Test negotiation strategies, variable increment amounts, and projected total compensation outcomes with data-backed guidance.

### 🛡️ 7. Privacy & Stealth Mode
- **Recruiter Shield**: Hide active search status and profile updates from current employers.
- **Granular Resume Visibility**: Limit sensitive contact details to verified company recruiters.
- **Job Integrity System**: Built-in reporting dialog for flagged or suspicious postings.

---

## 🎨 Design System & Visual Identity

HireHub features a custom Material 3 design system built on **Stitch UX principles**:

| Token | Hex / Value | Semantic Role |
|:---|:---|:---|
| **Primary Navy** | `#12355B` | Primary branding, headers, authoritative CTA elements |
| **Accent Teal** | `#16A085` | Success metrics, high-fit scores, verified indicators |
| **Tertiary Azure** | `#2E86DE` | Interactive elements, links, active tab highlights |
| **Background** | `#F5F7FA` | Canvas background with high contrast |
| **Surface** | `#FFFFFF` | Elevated cards, dialogs, navigation containers |
| **Typography** | `GoogleFonts.inter` | Clean, highly legible typographic scale |

---

## 🏗️ Architecture & Design Patterns

The codebase adheres strictly to **Clean Architecture** principles and the **Provider State Management** pattern:

```
lib/
├── app.dart                        # MaterialApp theme config & splash orchestrator
├── main.dart                       # Entry point, Firebase init & MultiProvider registry
├── firebase_options.dart           # Cross-platform Firebase config
│
├── core/
│   ├── constants/                  # Colors, spacing, radii, typography tokens
│   ├── theme/                      # Material 3 ThemeData with GoogleFonts (Inter)
│   └── utils/                      # Deterministic calculators & parsers
│       ├── application_health_calculator.dart
│       ├── decision_matrix_calculator.dart
│       ├── document_picker.dart     # Multiplatform conditional imports (IO vs Web)
│       ├── document_text_extractor.dart # Low-level PDF stream & CMap parser
│       ├── job_fit_calculator.dart  # 50/20/10/10/10 weighted fit engine
│       ├── resume_parser.dart       # Technical alias normalization engine
│       ├── safe_parsers.dart        # Null-safe Firestore data wrappers
│       └── skill_gap_analyzer.dart  # Missing skill delta analyzer
│
├── data/
│   └── seed_data.dart              # Comprehensive demo dataset (users, jobs, companies)
│
├── models/                         # Strongly-typed data models with copyWith & fromMap
│   ├── application_model.dart
│   ├── company_model.dart
│   ├── interview_model.dart
│   ├── job_alert_model.dart
│   ├── job_model.dart
│   ├── learning_resource_model.dart
│   ├── notification_model.dart
│   ├── review_model.dart
│   ├── skill_model.dart
│   └── user_model.dart
│
├── providers/                      # Reactive ChangeNotifier state controllers
│   ├── application_provider.dart
│   ├── auth_provider.dart
│   ├── interview_provider.dart
│   ├── job_provider.dart
│   ├── notification_provider.dart
│   ├── saved_jobs_provider.dart
│   ├── settings_provider.dart
│   └── skill_provider.dart
│
├── screens/                        # Modular, feature-first UI screens
│   ├── applications/               # Tracker Kanban & application details
│   ├── auth/                       # Clean authentication views
│   ├── home/                       # Dashboard, hero search & recommendations
│   ├── interviews/                 # Prep hub, questions & calendar
│   ├── jobs/                       # Details, apply, fit score, compare, decision matrix
│   ├── notifications/              # Alerts & status updates
│   ├── onboarding/                 # Candidate intro flow
│   ├── profile/                    # Profile manager & PDF resume builder
│   ├── profile_setup/              # Multi-step candidate onboarding
│   ├── salary/                     # Explorer & offer simulator
│   ├── search/                     # Filterable search with chips & salary sliders
│   ├── settings/                   # Privacy, stealth mode & application health
│   ├── skills/                     # Skill progress & learning roadmaps
│   └── splash/                     # Animated splash screen
│
├── services/                       # Data access & cloud abstractions
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
│
└── widgets/                        # Atomic reusable UI components
    ├── application_card.dart
    ├── empty_state_view.dart
    ├── fit_factor_bar.dart
    ├── fit_score_gauge.dart        # Custom circular score indicator
    ├── job_card.dart
    ├── loading_skeleton.dart
    ├── primary_button.dart
    └── skill_chip.dart
```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Channel stable, ^3.13.0)
- **Language**: [Dart](https://dart.dev) (^3.0.0)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `MultiProvider`)
- **Backend & Cloud**:
  - [Firebase Core](https://pub.dev/packages/firebase_core)
  - [Firebase Auth](https://pub.dev/packages/firebase_auth)
  - [Cloud Firestore](https://pub.dev/packages/cloud_firestore)
  - [Firebase Storage](https://pub.dev/packages/firebase_storage)
- **Data Visualization & Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Document & PDF Processing**:
  - [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing)
  - [archive](https://pub.dev/packages/archive) (ZLib stream decompression)
  - [file_picker](https://pub.dev/packages/file_picker)
- **Typography & UI**:
  - [google_fonts](https://pub.dev/packages/google_fonts) (Inter typography)
  - [cupertino_icons](https://pub.dev/packages/cupertino_icons)

---

## 🚦 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.13 or higher)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- An IDE with Flutter plugins ([VS Code](https://code.visualstudio.com/), [Android Studio](https://developer.android.com/studio), or Antigravity)
- Xcode (for iOS / macOS development) or Android Studio / SDK (for Android)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Vrutti88/HireHub.git
   cd HireHub
   ```

2. **Fetch project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # Launch on connected mobile device or emulator
   flutter run

   # Launch on Chrome / Web
   flutter run -d chrome

   # Launch on macOS Desktop
   flutter run -d macos
   ```

> [!TIP]
> **Zero Configuration Required**: HireHub is configured to run out-of-the-box using high-fidelity local seed data. You can explore all features (Job Fit calculations, Resume Parsing, Decision Matrix, Application Health, and Interview Hub) without setting up your own Firebase project.

### Optional: Configuring Your Own Firebase Project

If you wish to link your personal Firebase project:
1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password & Anonymous) and **Cloud Firestore**.
3. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. Replace `lib/firebase_options.dart` with your generated configuration.

---

## 🧪 Deterministic Test Suite

HireHub incorporates comprehensive unit, algorithmic, and widget tests ensuring deterministic math calculations, null-safety resilience, and cross-platform PDF parsing stability:

```bash
flutter test
```

### Test Coverage Highlights:
- **`job_fit_calculator_test.dart`**: Validates 50/20/10/10/10 weighted score formula and ROI skill boost simulations.
- **`skill_gap_analyzer_test.dart`**: Verifies exact missing skill detection and proficiency threshold matching.
- **`decision_matrix_test.dart`**: Tests dynamic role ranking and custom multi-attribute weight adjustments.
- **`application_health_calculator_test.dart`**: Ensures 4-subfactor 100-point calculation and bounds checking.
- **`resume_parser_test.dart`**: Tests text parsing, alias mapping (`K8s`, `GCP`, `TS`), and pure-Dart PDF operator extraction (`ToUnicode CMap`, `FlateDecode`).
- **`safe_parsers_test.dart`**: Validates null-safe Firestore wrappers against corrupted or incomplete JSON/Map documents.
- **`widget_test.dart`**: Tests application launch sequence and initial splash branding.

---

## 🤝 Contributing

Contributions, feature requests, and issue reports are warmly welcomed!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Crafted with ❤️ for engineers and ambitious professionals seeking their next career leap.</sub>
</div>
