# InviSafe

InviSafe is a unified Flutter application that integrates multiple safety and
vision intelligence modules into one mobile app.

## Modules

- Structural safety and integrity analysis
- Bio-safety food and nutrition checks
- Skin health assessment
- Road crack and pothole monitoring
- Underground pipeline leak and damage simulation
- Air quality and ventilation monitoring

## Included Assets

- Road simulation image: `assets/images/road.png`
- Pipeline 3D model: `assets/models/pipe.glb`
- Module icons under `assets/icons/`

## Getting Started

Install Flutter, then run:

```bash
flutter pub get
flutter run
```

To build an Android APK:

```bash
flutter build apk
```

## Notes

The app uses on-device simulated inference flows for the demo modules. Road and
pipeline screens are wired to match the original Android demo behavior, including
the road simulation view and the pipeline 3D model view.
