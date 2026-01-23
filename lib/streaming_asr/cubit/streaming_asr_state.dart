/// Streaming ASR states using sealed classes.
sealed class StreamingAsrState {
  const StreamingAsrState();
}

/// Initial state before initialization.
final class StreamingAsrInitial extends StreamingAsrState {
  const StreamingAsrInitial();
}

/// Loading model.
final class StreamingAsrLoading extends StreamingAsrState {
  const StreamingAsrLoading();
}

/// Ready to transcribe.
final class StreamingAsrReady extends StreamingAsrState {
  const StreamingAsrReady({this.lastTranscription});
  final String? lastTranscription;
}

/// Actively transcribing.
final class StreamingAsrListening extends StreamingAsrState {
  const StreamingAsrListening({
    required this.partialText,
    required this.finalizedText,
  });

  final String partialText;
  final String finalizedText;
}

/// Error state.
final class StreamingAsrError extends StreamingAsrState {
  const StreamingAsrError({required this.message});
  final String message;
}
