/// VAD states using sealed classes.
sealed class VadState {
  const VadState();
}

/// Initial state before initialization.
final class VadInitial extends VadState {
  const VadInitial();
}

/// Loading VAD model.
final class VadLoading extends VadState {
  const VadLoading();
}

/// Ready to detect voice activity.
final class VadReady extends VadState {
  const VadReady();
}

/// Actively listening for voice.
final class VadListening extends VadState {
  const VadListening({
    required this.isSpeaking,
    required this.speechDurationMs,
  });

  final bool isSpeaking;
  final int speechDurationMs;
}

/// Error state.
final class VadError extends VadState {
  const VadError({required this.message});
  final String message;
}
