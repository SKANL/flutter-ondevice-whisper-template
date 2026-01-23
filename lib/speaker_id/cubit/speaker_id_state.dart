/// Speaker ID states using sealed classes.
sealed class SpeakerIdState {
  const SpeakerIdState();
}

/// Initial state.
final class SpeakerIdInitial extends SpeakerIdState {
  const SpeakerIdInitial();
}

/// Loading model.
final class SpeakerIdLoading extends SpeakerIdState {
  const SpeakerIdLoading();
}

/// Ready to register or verify.
final class SpeakerIdReady extends SpeakerIdState {
  const SpeakerIdReady({
    required this.registeredSpeakers,
    this.lastResult,
  });

  final List<String> registeredSpeakers;
  final String? lastResult;
}

/// Recording audio for registration/verification.
final class SpeakerIdRecording extends SpeakerIdState {
  const SpeakerIdRecording({required this.mode});
  final SpeakerIdMode mode;
}

/// Processing audio.
final class SpeakerIdProcessing extends SpeakerIdState {
  const SpeakerIdProcessing();
}

/// Error state.
final class SpeakerIdError extends SpeakerIdState {
  const SpeakerIdError({required this.message});
  final String message;
}

/// Mode for speaker ID operation.
enum SpeakerIdMode { register, verify }
