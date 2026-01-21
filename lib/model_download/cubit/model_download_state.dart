/// State classes for model download feature using sealed classes.
///
/// Uses Dart 3 sealed classes for type-safe state management with
/// exhaustive switch pattern matching.
library;

/// Base sealed class for model download states.
sealed class ModelDownloadState {
  const ModelDownloadState();
}

/// Initial state before any action.
final class ModelDownloadInitial extends ModelDownloadState {
  const ModelDownloadInitial();
}

/// Checking if the model is already downloaded.
final class ModelDownloadChecking extends ModelDownloadState {
  const ModelDownloadChecking();
}

/// Model is not downloaded, user needs to download it.
final class ModelDownloadRequired extends ModelDownloadState {
  const ModelDownloadRequired();
}

/// Model download is in progress.
final class ModelDownloadInProgress extends ModelDownloadState {
  const ModelDownloadInProgress({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
  });

  /// Progress from 0.0 to 1.0.
  final double progress;

  /// Bytes downloaded so far.
  final int downloadedBytes;

  /// Total bytes to download.
  final int totalBytes;
}

/// Extracting the downloaded archive.
final class ModelDownloadExtracting extends ModelDownloadState {
  const ModelDownloadExtracting();
}

/// Model downloaded and ready.
final class ModelDownloadSuccess extends ModelDownloadState {
  const ModelDownloadSuccess();
}

/// Download or extraction failed.
final class ModelDownloadFailure extends ModelDownloadState {
  const ModelDownloadFailure({required this.message});

  final String message;
}
