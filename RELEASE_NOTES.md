# Scholor AI v1.0.0 Release Notes

Welcome to the initial production release of **Scholor AI** (v1.0.0) — an offline-first personalized AI tutor and curriculum textbook reader built with Flutter.

---

## Highlights & Implemented Features

- **Offline AI Tutor**: Local doubt answering powered by an on-device quantized TinyStories-33M neural model executed via ONNX Runtime Mobile, grounded by textbook knowledge stored in SQLite.
- **Curriculum Textbook Reader**: Preloaded with Tamil Nadu State Board Class 1 (Terms 1–3) textbooks across English, Mathematics, Environmental Science, and Tamil, featuring formatted Markdown view and Text-to-Speech (TTS) narration.
- **Syllabus & Chapter Explorer**: Structured navigation by grade, term, and subject directly from digitized EPUBs.
- **Offline Multimedia Lessons**: Integrated download manager and local video player for offline video learning modules.
- **Gamified Learning Metrics**: Daily streak counters, XP progress, study goal tracking, and on-device storage space analytics.
- **Authentication**: Firebase Authentication and Google Sign-In with full offline guest mode fallback.

---

## Installation Instructions

### Android (APK)
1. Download `app-release.apk` from the release assets below.
2. If prompted on your Android device, enable **Install unknown apps** for your browser/file manager in device settings.
3. Tap the downloaded APK file and follow the on-screen prompts to complete installation.
4. Launch **Scholor AI** from your app drawer. You can begin learning immediately as a Guest without internet access.

---

## Checksums

```
SHA-256: 7a3c55c4e7c7c42715fd4a2c25f9d1426a2461e5f7f5d39f6967a8e85bea185d  app-release.apk
SHA-256: 8701e020d44208a67e6f8f66e0d91d3d66874c785ba6662458005a3d81669a6d  model_quantized.onnx
```

---

## Known Issues & Limitations

- Local model inference is optimized for low-resource hardware (33M parameters, <80 MB ONNX model footprint); answers reflect the grounded textbook context chunks retrieved from local storage.
- Cloud progress synchronization and Google Sign-In require active network connectivity. Standalone guest mode is fully functional offline.
