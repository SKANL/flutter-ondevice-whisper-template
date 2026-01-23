import 'package:bloc/bloc.dart';
import 'package:w_zentyar_app/core_ai/model_registry.dart';
import 'package:w_zentyar_app/model_download/cubit/model_download_state.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';

/// Cubit for managing multiple AI models.
///
/// Handles downloading, deleting, and checking status of all AI models.
class ModelManagerCubit extends Cubit<ModelManagerState> {
  ModelManagerCubit({
    required ModelRepository modelRepository,
  }) : _modelRepository = modelRepository,
       super(const ModelManagerInitial());

  final ModelRepository _modelRepository;

  /// Loads status of all models.
  Future<void> loadModelStatuses() async {
    emit(const ModelManagerLoading());

    try {
      final statuses = await _modelRepository.getAllModelStatuses();
      emit(ModelManagerReady(modelStatuses: statuses));
    } catch (e) {
      emit(ModelManagerError(message: e.toString()));
    }
  }

  /// Downloads a specific model.
  Future<void> downloadModel(AiModelType type) async {
    final currentState = state;
    if (currentState is! ModelManagerReady) return;
    if (currentState.downloadingModel != null) return;

    emit(
      currentState.copyWith(
        downloadingModel: type,
        downloadProgress: 0,
      ),
    );

    try {
      await _modelRepository.downloadModel(
        type,
        onProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            final latest = state;
            if (latest is ModelManagerReady) {
              emit(latest.copyWith(downloadProgress: progress));
            }
          }
        },
        onExtractionStart: () {
          final latest = state;
          if (latest is ModelManagerReady) {
            emit(latest.copyWith(isExtracting: true));
          }
        },
      );

      // Refresh statuses
      final statuses = await _modelRepository.getAllModelStatuses();
      emit(ModelManagerReady(modelStatuses: statuses));
    } catch (e) {
      final latest = state;
      if (latest is ModelManagerReady) {
        emit(latest.copyWith(clearDownloading: true));
      }
      emit(ModelManagerError(message: 'Download failed: $e'));
    }
  }

  /// Deletes a specific model.
  Future<void> deleteModel(AiModelType type) async {
    final currentState = state;
    if (currentState is! ModelManagerReady) return;

    try {
      await _modelRepository.deleteModel(type);
      final statuses = await _modelRepository.getAllModelStatuses();
      emit(ModelManagerReady(modelStatuses: statuses));
    } catch (e) {
      emit(ModelManagerError(message: 'Delete failed: $e'));
    }
  }

  /// Retries after error.
  Future<void> retry() async {
    await loadModelStatuses();
  }
}

// Keep old name for backward compatibility
typedef ModelDownloadCubit = ModelManagerCubit;
