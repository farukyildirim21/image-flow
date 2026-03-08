# ImageFlow

An intelligent image processing app built with Flutter that supports face anonymization and document scanning.

## Features

- **Home Screen** — History of processed images with thumbnail, type, and date
- **Image Capture** — Camera or gallery selection via bottom sheet
- **Processing Screen** — Real-time progress with step descriptions
- **Result Screen** — Before/after comparison; Done saves to history
- **History Detail** — Full result view with metadata and PDF viewer

## Tech Stack

- **Flutter** + **GetX** — state management and navigation
- **ML Kit** — face detection and text recognition
- **OpenCV** — document edge detection and perspective correction
- **Hive** — local storage
- **PDF** — document generation

## Architecture

Clean Architecture with three layers:

```
lib/
├── core/         # constants, errors
├── domain/       # entities, repositories (abstract), use cases
├── data/         # models, local datasources, ML services, repository implementations
└── presentation/ # GetX controllers, views, bindings
```

## Dependencies

| Package | Purpose |
|---|---|
| get | State management & navigation |
| google_mlkit_face_detection | Face detection |
| google_mlkit_text_recognition | OCR / text recognition |
| opencv_dart | Document edge detection |
| hive / hive_flutter | Local storage |
| image_picker / camera | Image capture |
| pdf / printing | PDF generation |
| open_filex | Open PDF externally |

## Getting Started

```bash
flutter pub get
flutter run
```

> Requires iOS 14+ or Android API 21+. Camera and photo library permissions needed at runtime.
