import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:w_zentyar_app/model_download/data/model_repository.dart';

/// Service for transcribing audio using Whisper via sherpa_onnx.
///
/// Requires the model to be downloaded first via [ModelRepository].
class WhisperService {
  WhisperService();

  sherpa.OfflineRecognizer? _recognizer;
  bool _isInitialized = false;

  /// Whether the service is initialized and ready for transcription.
  bool get isInitialized => _isInitialized;

  /// Initializes the Whisper model.
  ///
  /// Must be called before [transcribe].
  Future<void> initialize(ModelPaths modelPaths) async {
    if (_isInitialized) return;

    // Initialize native library bindings first
    sherpa.initBindings();

    final whisperConfig = sherpa.OfflineWhisperModelConfig(
      encoder: modelPaths.encoder,
      decoder: modelPaths.decoder,
    );

    final modelConfig = sherpa.OfflineModelConfig(
      whisper: whisperConfig,
      tokens: modelPaths.tokens,
      modelType: 'whisper',
    );

    final config = sherpa.OfflineRecognizerConfig(model: modelConfig);

    _recognizer = sherpa.OfflineRecognizer(config);
    _isInitialized = true;
  }

  /// Transcribes the audio file at the given path.
  ///
  /// [audioPath] must be a WAV file with 16kHz sample rate, mono, 16-bit PCM.
  /// Returns the transcribed text.
  Future<String> transcribe(String audioPath) async {
    if (!_isInitialized || _recognizer == null) {
      throw StateError(
        'WhisperService not initialized. Call initialize first.',
      );
    }

    // Read audio file
    final waveData = sherpa.readWave(audioPath);

    // Create stream and process
    final stream = _recognizer!.createStream();
    stream.acceptWaveform(
      samples: waveData.samples,
      sampleRate: waveData.sampleRate,
    );

    // Decode
    _recognizer!.decode(stream);

    // Get result
    final result = _recognizer!.getResult(stream);

    // Clean up stream
    stream.free();

    return result.text.trim();
  }

  /// Disposes all resources.
  void dispose() {
    _recognizer?.free();
    _recognizer = null;
    _isInitialized = false;
  }
}
