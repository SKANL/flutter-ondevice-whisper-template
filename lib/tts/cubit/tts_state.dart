/// TTS states using sealed classes (Dart 3+).
sealed class TtsState {
  const TtsState();
}

/// Initial state before initialization.
final class TtsInitial extends TtsState {
  const TtsInitial();
}

/// Loading model.
final class TtsLoading extends TtsState {
  const TtsLoading({this.message = 'Loading TTS model...'});
  final String message;
}

/// Ready to generate speech.
final class TtsReady extends TtsState {
  const TtsReady({
    required this.numSpeakers,
    this.lastText,
  });

  final int numSpeakers;
  final String? lastText;
}

/// Generating speech.
final class TtsGenerating extends TtsState {
  const TtsGenerating({required this.text});
  final String text;
}

/// Speech generated successfully.
final class TtsGenerated extends TtsState {
  const TtsGenerated({
    required this.text,
    required this.audioPath,
  });

  final String text;
  final String audioPath;
}

/// Error state.
final class TtsError extends TtsState {
  const TtsError({required this.message});
  final String message;
}
