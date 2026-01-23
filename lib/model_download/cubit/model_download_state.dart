/// State classes for model manager feature.
library;

import 'package:w_zentyar_app/core_ai/model_registry.dart';

/// Base sealed class for model manager states.
sealed class ModelManagerState {
  const ModelManagerState();
}

/// Initial state before loading.
final class ModelManagerInitial extends ModelManagerState {
  const ModelManagerInitial();
}

/// Loading model statuses.
final class ModelManagerLoading extends ModelManagerState {
  const ModelManagerLoading();
}

/// Ready state showing all models.
final class ModelManagerReady extends ModelManagerState {
  const ModelManagerReady({
    required this.modelStatuses,
    this.downloadingModel,
    this.downloadProgress,
    this.isExtracting = false,
  });

  /// Map of model type to downloaded status.
  final Map<AiModelType, bool> modelStatuses;

  /// Currently downloading model, if any.
  final AiModelType? downloadingModel;

  /// Download progress (0.0 to 1.0) for current download.
  final double? downloadProgress;

  /// Whether currently extracting an archive.
  final bool isExtracting;

  /// Copy with updated values.
  ModelManagerReady copyWith({
    Map<AiModelType, bool>? modelStatuses,
    AiModelType? downloadingModel,
    double? downloadProgress,
    bool? isExtracting,
    bool clearDownloading = false,
  }) {
    return ModelManagerReady(
      modelStatuses: modelStatuses ?? this.modelStatuses,
      downloadingModel: clearDownloading
          ? null
          : (downloadingModel ?? this.downloadingModel),
      downloadProgress: clearDownloading
          ? null
          : (downloadProgress ?? this.downloadProgress),
      isExtracting: isExtracting ?? this.isExtracting,
    );
  }
}

/// Error state.
final class ModelManagerError extends ModelManagerState {
  const ModelManagerError({required this.message});
  final String message;
}
