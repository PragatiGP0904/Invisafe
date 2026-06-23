# Invisafe — Integration Report

Unified **Flutter** application that integrates the six modules previously spread
across three separate **native Android (Kotlin)** projects.

| Source project | Stack | Modules contributed |
|---|---|---|
| `InviSafeP` (`com.example.democity`) | Android Views + Activities | Structural, Food, Skin |
| `InvisafeK` (`com.example.invisafe`) | Jetpack Compose | Air Quality / Ventilation |
| `InvisafeU` (`com.example.invisafe`) | Fragments + ARCore/OpenGL | Road, Pipeline |

The integration target is the pre-existing Flutter app in this folder, whose
`lib/` layout and home screen already matched the requested architecture.

---

## 1. Integration Summary

- All **six modules** are wired into one Flutter app with a single launcher,
  unified dark-glassmorphism theme and one navigation table.
- The home grid is data-driven from a central **module registry**
  (`lib/core/navigation/app_router.dart`); the previous
  `// TODO: Implement actual routing` stub now routes to real module screens.
- Cross-cutting concerns were **standardized** into shared layers:
  - **Navigation** — `AppRouter` + `ModuleScaffold` (consistent app bar/back).
  - **Theme** — `AppTheme` + `AppColors` (one Material 3 dark theme; replaces
    the three separate `Theme.InviSafe/Theme.Invisafe` themes).
  - **Camera** — `CameraService` + `CameraPreviewWidget` (one CameraX-equivalent
    pipeline with graceful fallback when no camera/permission).
  - **AI inference** — `InferenceEngine` / `SimulatedInferenceEngine` contract;
    every module plugs in its analyzer.
  - **Reports** — unified `ScanReport` model + `ReportService` (real PDF export
    via `pdf`/`printing` + text share via `share_plus`) + `ReportView`/`ReportPage`.
  - **AR rendering** — `ArService` standardizes 3D/AR via `model_viewer_plus`
    with an animated holographic fallback when the `.glb` asset is absent.
- Behavior fidelity matches the originals (mostly **heuristic/scripted demo**
  flows), since the native "AI/AR" was itself heuristic and several binary
  assets were already missing from the source checkouts.

---

## 2. Folder Structure

```
lib/
├── main.dart                     # App entry (theme + router + splash)
├── core/
│   ├── constants/app_constants.dart
│   ├── navigation/app_router.dart # Module registry + routes (standardized nav)
│   └── theme/                     # app_colors.dart, app_theme.dart (standardized theme)
├── models/
│   ├── detection_result.dart      # Unified finding type
│   ├── scan_report.dart           # Unified report + RiskLevel
│   ├── nutrition_info.dart
│   ├── user_health_profile.dart
│   └── module_info.dart
├── services/
│   ├── camera_service.dart        # Standardized camera
│   ├── inference_service.dart     # Standardized AI inference pipeline
│   ├── report_service.dart        # Standardized report/PDF generation
│   └── ar_service.dart            # Standardized AR/3D rendering
├── screens/
│   ├── splash_screen.dart
│   └── home_screen.dart           # Unified hub (registry-driven)
├── modules/
│   ├── structural/                # Wall crack & dampness (from InviSafeP)
│   ├── food/                      # Food & nutrition (from InviSafeP)
│   ├── skin/                      # Skin health (from InviSafeP)
│   ├── air_quality/               # Air quality & ventilation (from InvisafeK)
│   ├── road_monitoring/           # Road crack/pothole (from InvisafeU)
│   └── pipeline_monitoring/       # Pipeline leak/damage + AR (from InvisafeU)
├── widgets/                       # glass_card, module_scaffold, camera_preview,
│                                  # scan_overlay, detection_overlay, scan_screen,
│                                  # report_view, report_page, progression_chart,
│                                  # scenario_card
└── utils/format_utils.dart
```

---

## 3. Dependency Report

Added to `pubspec.yaml`:

| Package | Purpose | Replaces (native) |
|---|---|---|
| `camera` | Live preview + still capture | CameraX |
| `permission_handler` | Runtime camera permission | Android permission APIs |
| `fl_chart` | Report charts | MPAndroidChart (InvisafeU) |
| `pdf` + `printing` | PDF report generation/share | `PdfDocument` (InviSafeP) |
| `share_plus` + `path_provider` | Share / file paths | `FileProvider` intents |
| `model_viewer_plus` | 3D/AR model rendering | ARCore + OpenGL GLB (InvisafeU) |
| `video_player` | Demo media (optional) | `VideoView` |
| `image` | On-device pixel heuristics (future) | TFLite/heuristics |
| `google_fonts` (existing) | Inter / Syncopate fonts | Compose Google Fonts |

> Native-only libraries that were intentionally **not** carried over: TFLite
> Task-Vision, Gemini generative AI, ML Kit Face Detection. These powered demo
> flows that were scripted/heuristic in practice; see Future Improvements.

---

## 4. Issues Found (during analysis)

1. **Wrong-stack assumption risk** — source projects are native Android; the
   integration target is Flutter. (Resolved by porting, not literal merging.)
2. **Package collision** — `InvisafeK` and `InvisafeU` both used
   `com.example.invisafe` with duplicate `MainActivity` and `ui.theme.*`.
3. **AGP/Gradle conflict** — `InvisafeU` on AGP 9.0.0 / Gradle 9.1 vs 8.13.2/8.13.
4. **`minSdk` mismatch** — 26 (P) vs 24 (K, U).
5. **Three UI paradigms** — Views vs Compose vs Fragments.
6. **Duplicate project copy** — `InviSafeP/InviSafeGit/` (full second copy).
7. **Dead code / unused assets** — Compose theme scaffold unused in U, legacy
   Sceneform layouts, `model_viewer.html` never loaded in K, TFLite/Gemini
   constructed but never invoked in P.
8. **Missing binary assets** — `model.tflite`, `pipe.glb`, demo videos,
   `logo.jpeg`, several drawables absent from the checkouts.
9. **Inconsistent reports** — only P generated a real PDF; K and U used Toast
   stubs only.
10. **"AI/AR" mostly simulated** — structural/skin = pixel heuristics, food =
    scripted sequence, air quality = random AQI, road/pipeline = video/AR demo.
11. **Two stray placeholder screens** (`*_monitoring_screen.dart`) in the Flutter
    scaffold.

---

## 5. Issues Fixed (during integration)

- Unified everything under one Flutter app, one theme, one navigation table —
  eliminating the package/AGP/minSdk/UI-paradigm conflicts (they no longer
  apply in a single Flutter target).
- Replaced the home-screen routing TODO with a real registry-driven router.
- Standardized **camera, inference, report (now real PDF for every module), and
  AR** behind shared services/widgets.
- Removed duplicate/dead placeholder screens and empty folders from the scaffold.
- Implemented **graceful fallbacks** so missing assets / no-camera devices still
  run (placeholder preview, holographic AR fallback, deterministic nutrition
  fallback).
- Brought all six modules to feature parity with their originals (scan flow →
  findings → unified report with charts where applicable).

---

## 6. Future Improvements

- Restore **real on-device ML**: `tflite_flutter` for food classification &
  structural crack segmentation; `google_mlkit_face_detection` for skin regions.
- Real **AR**: `ar_flutter_plugin` / ARCore depth for pipeline & road, and ship
  `assets/models/pipe.glb`.
- Live **air quality API** (e.g. OpenWeather/IQAir) + device sensors instead of
  simulated AQI.
- Persist health profile & report history (`shared_preferences` / local DB).
- Add unit/widget tests and CI; wire the `Quick Scan` and `Settings` actions.
- Provide the missing binary assets (logos, demo videos, models).

---

## Build & Run Checklist

This `lib/` package is complete, but the Flutter project has **no platform
folders yet** and Flutter is not installed on the analysis machine. To run:

1. Install Flutter (`flutter --version`) — Dart SDK ≥ 3.1.
2. From this folder, generate platform scaffolding **without overwriting `lib/`**:
   ```
   flutter create .
   ```
3. Fetch dependencies:
   ```
   flutter pub get
   ```
4. Add permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
   and set `minSdkVersion 24+` in `android/app/build.gradle`.
   (For iOS, add `NSCameraUsageDescription` to `ios/Runner/Info.plist`.)
5. (Optional) Drop real assets into `assets/images/`, `assets/icons/`,
   `assets/models/pipe.glb` — the app runs with fallbacks if they are absent.
6. Run:
   ```
   flutter run
   ```
7. Verify each module from the home grid:
   - ✓ Structural ✓ Food (Bio-Safety) ✓ Skin (Derma-Tech)
   - ✓ Air Quality (Air Sentinel) ✓ Road Vision ✓ Pipeline Guard
