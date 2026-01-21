/// State classes for transcription feature using sealed classes.
library;

/// Base sealed class for transcription states.
sealed class TranscriptionState {
  const TranscriptionState();
}

/// Initial/idle state, optionally with last transcription.
final class TranscriptionIdle extends TranscriptionState {
  const TranscriptionIdle({this.lastTranscription});

  /// The last transcription result, if any.
  final String? lastTranscription;
}

/// Model is being initialized.
final class TranscriptionInitializing extends TranscriptionState {
  const TranscriptionInitializing();
}

/// Recording audio from microphone.
final class TranscriptionRecording extends TranscriptionState {
  const TranscriptionRecording({this.lastTranscription});

  /// Preserve last transcription while recording.
  final String? lastTranscription;
}

/// Processing the recorded audio through Whisper.
final class TranscriptionProcessing extends TranscriptionState {
  const TranscriptionProcessing({this.lastTranscription});

  /// Preserve last transcription while processing.
  final String? lastTranscription;
}

/// Transcription failed.
final class TranscriptionFailure extends TranscriptionState {
  const TranscriptionFailure({
    required this.message,
    this.lastTranscription,
  });

  final String message;
  final String? lastTranscription;
}
