import 'package:bloc/bloc.dart';
import 'package:w_zentyar_app/model_download/cubit/model_download_state.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';

/// Cubit for managing the model download process.
///
/// Handles checking model status, downloading, and error handling.
class ModelDownloadCubit extends Cubit<ModelDownloadState> {
  ModelDownloadCubit({
    required ModelRepository modelRepository,
  }) : _modelRepository = modelRepository,
       super(const ModelDownloadInitial());

  final ModelRepository _modelRepository;

  /// Checks if the model is already downloaded.
  Future<void> checkModelStatus() async {
    emit(const ModelDownloadChecking());

    try {
      final isDownloaded = await _modelRepository.isModelDownloaded();

      if (isDownloaded) {
        emit(const ModelDownloadSuccess());
      } else {
        emit(const ModelDownloadRequired());
      }
    } catch (e) {
      emit(ModelDownloadFailure(message: e.toString()));
    }
  }

  /// Downloads the model from the remote server.
  Future<void> downloadModel() async {
    emit(
      const ModelDownloadInProgress(
        progress: 0,
        downloadedBytes: 0,
        totalBytes: 0,
      ),
    );

    try {
      await _modelRepository.downloadModel(
        onProgress: (received, total) {
          if (total > 0) {
            emit(
              ModelDownloadInProgress(
                progress: received / total,
                downloadedBytes: received,
                totalBytes: total,
              ),
            );
          }
        },
        onExtractionStart: () {
          emit(const ModelDownloadExtracting());
        },
      );

      // Verify the model was extracted correctly
      final isDownloaded = await _modelRepository.isModelDownloaded();

      if (isDownloaded) {
        emit(const ModelDownloadSuccess());
      } else {
        emit(
          const ModelDownloadFailure(
            message: 'Model extraction failed. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(ModelDownloadFailure(message: e.toString()));
    }
  }

  /// Retries the download after a failure.
  Future<void> retry() async {
    await checkModelStatus();
  }
}
