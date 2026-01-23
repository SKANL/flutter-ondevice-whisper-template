/// State classes for transcription feature using sealed classes.
library;

/// Base sealed class for transcription states.
sealed class TranscriptionState {
  const TranscriptionState();

  /// Current selected language (e.g., 'en', 'es').
  String get language;
}

/// Initial/idle state, optionally with last transcription.
final class TranscriptionIdle extends TranscriptionState {
  const TranscriptionIdle({
    this.lastTranscription,
    this.language = 'en',
  });

  /// The last transcription result, if any.
  final String? lastTranscription;

  @override
  final String language;
}

/// Model is being initialized.
final class TranscriptionInitializing extends TranscriptionState {
  const TranscriptionInitializing({this.language = 'en'});

  @override
  final String language;
}

/// Recording audio from microphone.
final class TranscriptionRecording extends TranscriptionState {
  const TranscriptionRecording({
    required this.language,
    this.lastTranscription,
  });

  /// Preserve last transcription while recording.
  final String? lastTranscription;

  @override
  final String language;
}

/// Processing the recorded audio through Whisper.
final class TranscriptionProcessing extends TranscriptionState {
  const TranscriptionProcessing({
    required this.language,
    this.lastTranscription,
  });

  /// Preserve last transcription while processing.
  final String? lastTranscription;

  @override
  final String language;
}

/// Transcription failed.
final class TranscriptionFailure extends TranscriptionState {
  const TranscriptionFailure({
    required this.message,
    required this.language,
    this.lastTranscription,
  });

  final String message;
  final String? lastTranscription;

  @override
  final String language;
}
