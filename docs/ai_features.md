# AI Features Documentation

This template provides **on-device AI capabilities** using [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx).

## Available Features

| Feature                     | Location             | Description                         |
| --------------------------- | -------------------- | ----------------------------------- |
| **Transcription (Whisper)** | `lib/transcription/` | Offline speech-to-text              |
| **Streaming ASR**           | `lib/streaming_asr/` | Real-time transcription             |
| **TTS**                     | `lib/tts/`           | Text-to-speech synthesis            |
| **VAD**                     | `lib/vad/`           | Voice activity detection            |
| **Speaker ID**              | `lib/speaker_id/`    | Speaker identification/verification |

## Architecture

```
lib/
├── core_ai/              # Shared AI infrastructure
│   ├── isolate_manager.dart   # Generic isolate communication
│   └── model_registry.dart    # Model definitions
├── <feature>/
│   ├── <feature>.dart         # Barrel file
│   ├── cubit/                 # State management
│   ├── services/              # Isolate workers
│   └── view/                  # UI components
```

## Key Patterns

### 1. Isolate Workers

All AI processing runs in background isolates to prevent UI jank:

```dart
// Each feature has an isolate worker
class TtsIsolate {
  static Future<void> entryPoint(SendPort sendPort) async {
    // Heavy processing here
  }
}
```

### 2. Sealed State Classes

All states use Dart 3+ sealed classes:

```dart
sealed class TtsState {}
final class TtsLoading extends TtsState {}
final class TtsReady extends TtsState {}
```

### 3. Page/View Pattern

Following Very Good Architecture:

```dart
class TtsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TtsCubit(...)..initialize(...),
      child: const TtsView(),
    );
  }
}
```

## Models

Models are downloaded on-demand. See `core_ai/model_registry.dart` for available models:

- **Whisper Small**: ~600MB (ASR)
- **VITS Piper**: ~80MB (TTS)
- **Silero VAD**: ~2MB (VAD)
- **Zipformer**: ~170MB (Streaming ASR)
- **3D-Speaker**: ~25MB (Speaker ID)

## Adding New Features

1. Create feature directory: `lib/<feature_name>/`
2. Add barrel file: `<feature_name>.dart`
3. Create isolate worker: `services/<feature>_isolate.dart`
4. Create service: `services/<feature>_service.dart`
5. Create cubit + state: `cubit/`
6. Create page: `view/<feature>_page.dart`
