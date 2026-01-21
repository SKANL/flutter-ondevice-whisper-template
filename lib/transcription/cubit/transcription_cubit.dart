import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';
import 'package:w_zentyar_app/transcription/cubit/transcription_state.dart';
import 'package:w_zentyar_app/transcription/services/audio_recorder_service.dart';
import 'package:w_zentyar_app/transcription/services/whisper_service.dart';

/// Cubit for managing the transcription process.
///
/// Handles recording audio, transcribing with Whisper, and managing state.
class TranscriptionCubit extends Cubit<TranscriptionState> {
  TranscriptionCubit({
    required AudioRecorderService audioRecorder,
    required WhisperService whisperService,
    required ModelRepository modelRepository,
  }) : _audioRecorder = audioRecorder,
       _whisperService = whisperService,
       _modelRepository = modelRepository,
       super(const TranscriptionInitializing());

  final AudioRecorderService _audioRecorder;
  final WhisperService _whisperService;
  final ModelRepository _modelRepository;

  /// Initializes the Whisper model.
  Future<void> initialize() async {
    try {
      if (!_whisperService.isInitialized) {
        final modelPaths = await _modelRepository.getModelPaths();
        if (modelPaths == null) {
          emit(
            TranscriptionFailure(
              message: 'Model not found. Please download it first.',
              language: state.language,
            ),
          );
          return;
        }
        await _whisperService.initialize(modelPaths, language: state.language);
      }
      emit(TranscriptionIdle(language: state.language));
    } catch (e) {
      emit(
        TranscriptionFailure(
          message: 'Failed to initialize: $e',
          language: state.language,
        ),
      );
    }
  }

  /// Changes the transcription language.
  Future<void> changeLanguage(String language) async {
    if (state.language == language) return;

    final lastTranscription = _getLastTranscription();

    try {
      emit(TranscriptionInitializing(language: language));

      final modelPaths = await _modelRepository.getModelPaths();
      if (modelPaths == null) {
        emit(
          TranscriptionFailure(
            message: 'Model not found',
            language: state.language,
            lastTranscription: lastTranscription,
          ),
        );
        return;
      }

      await _whisperService.setLanguage(language, modelPaths);
      emit(
        TranscriptionIdle(
          lastTranscription: lastTranscription,
          language: language,
        ),
      );
    } catch (e) {
      emit(
        TranscriptionFailure(
          message: 'Failed to change language: $e',
          lastTranscription: lastTranscription,
          language: state.language, // Revert to previous language?
        ),
      );
    }
  }

  /// Starts recording audio.
  Future<void> startRecording() async {
    final lastTranscription = _getLastTranscription();

    try {
      await _audioRecorder.startRecording();
      emit(
        TranscriptionRecording(
          lastTranscription: lastTranscription,
          language: state.language,
        ),
      );
    } catch (e) {
      emit(
        TranscriptionFailure(
          message: 'Failed to start recording: $e',
          lastTranscription: lastTranscription,
          language: state.language,
        ),
      );
    }
  }

  /// Stops recording and transcribes the audio.
  Future<void> stopRecordingAndTranscribe() async {
    final lastTranscription = _getLastTranscription();

    try {
      // Stop recording
      final audioPath = await _audioRecorder.stopRecording();
      if (audioPath == null) {
        emit(
          TranscriptionFailure(
            message: 'No recording found',
            lastTranscription: lastTranscription,
            language: state.language,
          ),
        );
        return;
      }

      emit(
        TranscriptionProcessing(
          lastTranscription: lastTranscription,
          language: state.language,
        ),
      );

      // Transcribe
      final transcription = await _whisperService.transcribe(audioPath);

      // Clean up audio file
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }

      emit(
        TranscriptionIdle(
          lastTranscription: transcription,
          language: state.language,
        ),
      );
    } catch (e) {
      emit(
        TranscriptionFailure(
          message: 'Transcription failed: $e',
          lastTranscription: lastTranscription,
          language: state.language,
        ),
      );
    }
  }

  /// Cancels the current recording.
  Future<void> cancelRecording() async {
    final lastTranscription = _getLastTranscription();

    try {
      await _audioRecorder.cancelRecording();
      emit(
        TranscriptionIdle(
          lastTranscription: lastTranscription,
          language: state.language,
        ),
      );
    } catch (e) {
      emit(
        TranscriptionFailure(
          message: 'Failed to cancel: $e',
          lastTranscription: lastTranscription,
          language: state.language,
        ),
      );
    }
  }

  /// Clears the last transcription.
  void clearTranscription() {
    emit(TranscriptionIdle(language: state.language));
  }

  /// Gets the last transcription from the current state.
  String? _getLastTranscription() {
    return switch (state) {
      TranscriptionIdle(:final lastTranscription) => lastTranscription,
      TranscriptionRecording(:final lastTranscription) => lastTranscription,
      TranscriptionProcessing(:final lastTranscription) => lastTranscription,
      TranscriptionFailure(:final lastTranscription) => lastTranscription,
      TranscriptionInitializing() => null,
    };
  }

  @override
  Future<void> close() async {
    await _audioRecorder.dispose();
    _whisperService.dispose();
    return super.close();
  }
}
