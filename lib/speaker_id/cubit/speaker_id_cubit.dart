import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:w_zentyar_app/speaker_id/cubit/speaker_id_state.dart';
import 'package:w_zentyar_app/speaker_id/services/speaker_id_service.dart';

/// Cubit for managing Speaker ID state.
class SpeakerIdCubit extends Cubit<SpeakerIdState> {
  SpeakerIdCubit({
    required SpeakerIdService speakerIdService,
  }) : _service = speakerIdService,
       super(const SpeakerIdInitial());

  final SpeakerIdService _service;
  final _recorder = AudioRecorder();
  final _registeredSpeakers = <String>[];
  String? _pendingName;
  SpeakerIdMode? _currentMode;

  /// Initialize the speaker ID service.
  Future<void> initialize(String modelPath) async {
    emit(const SpeakerIdLoading());

    try {
      await _service.initialize(modelPath);
      emit(SpeakerIdReady(registeredSpeakers: List.from(_registeredSpeakers)));
    } catch (e) {
      emit(SpeakerIdError(message: 'Failed to initialize: $e'));
    }
  }

  /// Start recording for registration.
  Future<void> startRegisterRecording(String name) async {
    _pendingName = name;
    _currentMode = SpeakerIdMode.register;
    await _startRecording();
    emit(const SpeakerIdRecording(mode: SpeakerIdMode.register));
  }

  /// Start recording for verification.
  Future<void> startVerifyRecording() async {
    _currentMode = SpeakerIdMode.verify;
    await _startRecording();
    emit(const SpeakerIdRecording(mode: SpeakerIdMode.verify));
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/speaker_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  /// Stop recording and process.
  Future<void> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) {
      emit(SpeakerIdReady(registeredSpeakers: List.from(_registeredSpeakers)));
      return;
    }

    emit(const SpeakerIdProcessing());

    try {
      // Read audio file
      final waveData = sherpa.readWave(path);

      // Extract embedding
      final embedding = await _service.extractEmbedding(waveData.samples);

      String? result;

      if (_currentMode == SpeakerIdMode.register && _pendingName != null) {
        // Register speaker
        await _service.registerSpeaker(
          name: _pendingName!,
          embedding: embedding,
        );
        _registeredSpeakers.add(_pendingName!);
        result = 'Registered: ${_pendingName!}';
      } else if (_currentMode == SpeakerIdMode.verify) {
        // Verify speaker
        final speakerName = await _service.verifySpeaker(embedding: embedding);
        if (speakerName.isNotEmpty) {
          result = 'Identified: $speakerName';
        } else {
          result = 'Unknown speaker';
        }
      }

      // Clean up temp file
      await File(path).delete();

      emit(
        SpeakerIdReady(
          registeredSpeakers: List.from(_registeredSpeakers),
          lastResult: result,
        ),
      );
    } catch (e) {
      emit(SpeakerIdError(message: 'Processing failed: $e'));
    } finally {
      _pendingName = null;
      _currentMode = null;
    }
  }

  /// Cancel recording.
  Future<void> cancelRecording() async {
    await _recorder.stop();
    _pendingName = null;
    _currentMode = null;
    emit(SpeakerIdReady(registeredSpeakers: List.from(_registeredSpeakers)));
  }

  @override
  Future<void> close() async {
    await _recorder.dispose();
    _service.dispose();
    return super.close();
  }
}
