import 'package:w_zentyar_app/core_ai/model_registry.dart';

/// Sealed state classes for the Voice Interface feature.
sealed class VoiceInterfaceState {
  const VoiceInterfaceState();

  /// The current model type, if any.
  AiModelType? get modelType => null;

  /// The model category (ASR, TTS, VAD, etc.).
  String? get category => null;
}

/// Initial state before any model is loaded.
final class VoiceInterfaceInitial extends VoiceInterfaceState {
  const VoiceInterfaceInitial();
}

/// Loading state while initializing a model.
final class VoiceInterfaceLoading extends VoiceInterfaceState {
  const VoiceInterfaceLoading({
    required this.modelType,
    this.message = 'Loading model...',
  });

  @override
  final AiModelType modelType;

  /// Loading message to display.
  final String message;

  @override
  String? get category => ModelRegistry.getConfig(modelType)?.category;
}

/// Ready state when model is loaded and ready to use.
final class VoiceInterfaceReady extends VoiceInterfaceState {
  const VoiceInterfaceReady({
    required this.modelType,
    this.modelName,
    this.lastResult,
  });

  @override
  final AiModelType modelType;

  /// Human-readable model name.
  final String? modelName;

  /// Last result from a previous operation.
  final String? lastResult;

  @override
  String? get category => ModelRegistry.getConfig(modelType)?.category;

  /// Creates a copy with updated fields.
  VoiceInterfaceReady copyWith({
    AiModelType? modelType,
    String? modelName,
    String? lastResult,
  }) {
    return VoiceInterfaceReady(
      modelType: modelType ?? this.modelType,
      modelName: modelName ?? this.modelName,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

/// Listening state when actively recording audio.
final class VoiceInterfaceListening extends VoiceInterfaceState {
  const VoiceInterfaceListening({
    required this.modelType,
    this.volume = 0.0,
    this.partialText,
    this.isSpeaking = false,
  });

  @override
  final AiModelType modelType;

  /// Current audio volume (0.0 to 1.0).
  final double volume;

  /// Partial transcription text (for ASR).
  final String? partialText;

  /// Whether voice activity is detected (for VAD).
  final bool isSpeaking;

  @override
  String? get category => ModelRegistry.getConfig(modelType)?.category;

  /// Creates a copy with updated fields.
  VoiceInterfaceListening copyWith({
    AiModelType? modelType,
    double? volume,
    String? partialText,
    bool? isSpeaking,
  }) {
    return VoiceInterfaceListening(
      modelType: modelType ?? this.modelType,
      volume: volume ?? this.volume,
      partialText: partialText ?? this.partialText,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

/// Processing state when running inference.
final class VoiceInterfaceProcessing extends VoiceInterfaceState {
  const VoiceInterfaceProcessing({
    required this.modelType,
    this.message = 'Processing...',
  });

  @override
  final AiModelType modelType;

  /// Processing message to display.
  final String message;

  @override
  String? get category => ModelRegistry.getConfig(modelType)?.category;
}

/// Result state after processing completes.
final class VoiceInterfaceResult extends VoiceInterfaceState {
  const VoiceInterfaceResult({
    required this.modelType,
    this.transcription,
    this.audioPath,
    this.speakerName,
    this.isSpeaking,
  });

  @override
  final AiModelType modelType;

  /// Transcription result (for ASR).
  final String? transcription;

  /// Generated audio path (for TTS).
  final String? audioPath;

  /// Identified speaker name (for Speaker ID).
  final String? speakerName;

  /// Voice activity detected (for VAD).
  final bool? isSpeaking;

  @override
  String? get category => ModelRegistry.getConfig(modelType)?.category;
}

/// Error state when something fails.
final class VoiceInterfaceError extends VoiceInterfaceState {
  const VoiceInterfaceError({
    required this.message,
    this.modelType,
  });

  /// Error message to display.
  final String message;

  @override
  final AiModelType? modelType;

  @override
  String? get category =>
      modelType != null ? ModelRegistry.getConfig(modelType!)?.category : null;
}
