# Flutter Whisper On-Device Template 🎙️

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Sherpa ONNX](https://img.shields.io/badge/Sherpa%20ONNX-Enable-green?style=for-the-badge)
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A **production-ready Flutter template** for offline speech recognition using the OpenAI Whisper model powered by `sherpa-onnx`.

This project is designed as a **base template** that any developer can clone and modify to build their own offline-first voice applications.

---

## ✨ Features

- **Offline Speech Recognition**: Runs entirely on-device (Android/iOS) without internet connection.
- **Model Management**:
  - Automatic download of Whisper extraction.
  - **Smart Streaming Extraction**: Uses `InputFileStream` to extract large `tar.bz2` files (~600MB) without crashing memory (fixes OOM issues on low-end devices).
  - Progress tracking and download animations.
- **Very Good Architecture**:
  - Built with [Very Good CLI](https://github.com/VeryGoodOpenSource/very_good_cli).
  - Feature-first directory structure.
  - **Bloc/Cubit** for state management (with sealed classes).
  - Dependency Injection via `RepositoryProvider`.
- **Production Ready**:
  - `dio` for robust HTTP requests.
  - `permission_handler` for microphone permissions.
  - `path_provider` for file system access.
  - Comprehensive localization (en/es).

---

## 🤖 Models Used

This template uses the **Whisper Small** model converted for `sherpa-onnx`.

- **Model Source**: [Hugging Face - csukuangfj/sherpa-onnx-whisper-small](https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small/tree/main)
- **Files Required** (handled automatically by the app):
  - `small-encoder.int8.onnx`
  - `small-decoder.int8.onnx`
  - `small-tokens.txt`

> **Note**: The app downloads the `sherpa-onnx-whisper-small.tar.bz2` archive (~600MB) on first run.

---

## 🚀 Getting Started

### 1. Requirements

- Flutter SDK: `^3.35.0`
- Dart SDK: `^3.9.0`
- Android / iOS device (Simulators may not support microphone input correctly)

### 2. Clone the Repo

```sh
git clone https://github.com/SKANL/flutter-ondevice-whisper-template.git
cd flutter-ondevice-whisper-template
```

### 3. Run the App

```sh
# Development
flutter run --flavor development --target lib/main_development.dart
```

---

## 🏗️ Architecture & AI Agents

This project follows strict architectural rules designed for scalability and collaboration with AI Agents.

👉 **[Read the AI Agent Rules for this Project](docs/agents.md)**

This document (`docs/agents.md`) defines:

- **Project Structure**: Feature-first organization.
- **State Management**: When to use Cubit vs Bloc, Naming conventions.
- **Coding Standards**: Context extensions, Switch expressions, Sealed classes.

**Tip:** If you are using an AI coding assistant (like Cursor, Windsurf, or GitHub Copilot), give it the `docs/agents.md` file as context to ensure it writes code that matches the project style.

---

## 🛠️ Customization

### Changing the Model

To use a different model (e.g., `tiny` or `base`):

1. Find a compatible model on [Hugging Face (k2-fsa)](https://huggingface.co/k2-fsa).
2. Update `lib/model_download/data/model_repository.dart` with the new URL and filenames.

### Adding Features

1. Create a new folder in `lib/<feature_name>`.
2. Create a `cubit`, `view`, and `data` folder inside.
3. Create a barrel file `lib/<feature_name>/<feature_name>.dart`.
4. Follow the **Page/View pattern** defined in `docs/agents.md`.

---

## 🧪 Testing

To run all unit and widget tests:

```sh
very_good test --coverage
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
