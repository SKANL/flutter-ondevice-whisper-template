import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:record/record.dart';
import 'package:w_zentyar_app/vad/cubit/vad_state.dart';
import 'package:w_zentyar_app/vad/services/vad_service.dart';

/// Cubit for managing VAD state.
class VadCubit extends Cubit<VadState> {
  VadCubit({
    required VadService vadService,
  }) : _vadService = vadService,
       super(const VadInitial());

  final VadService _vadService;
  final _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;
  int _speechDurationMs = 0;
  bool _isListening = false;

  /// Initialize the VAD service.
  Future<void> initialize(String modelPath) async {
    emit(const VadLoading());

    try {
      await _vadService.initialize(modelPath);
      emit(const VadReady());
    } catch (e) {
      emit(VadError(message: 'Failed to initialize VAD: $e'));
    }
  }

  /// Start listening for voice activity.
  Future<void> startListening() async {
    if (_isListening) return;

    try {
      _isListening = true;
      _speechDurationMs = 0;

      // Start recording audio stream
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      emit(const VadListening(isSpeaking: false, speechDurationMs: 0));

      _audioSubscription = stream.listen((data) async {
        // Convert Uint8List to Float32List
        final samples = _convertToFloat32(data);

        try {
          final result = await _vadService.process(samples);

          if (result.isSpeech) {
            _speechDurationMs += (samples.length / 16)
                .round(); // ~1ms per 16 samples
          }

          if (_isListening) {
            emit(
              VadListening(
                isSpeaking: result.isSpeech,
                speechDurationMs: _speechDurationMs,
              ),
            );
          }
        } catch (e) {
          // Ignore processing errors during streaming
        }
      });
    } catch (e) {
      _isListening = false;
      emit(VadError(message: 'Failed to start listening: $e'));
    }
  }

  /// Stop listening.
  Future<void> stopListening() async {
    _isListening = false;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _recorder.stop();
    _vadService.reset();
    emit(const VadReady());
  }

  /// Converts PCM16 bytes to Float32List.
  Float32List _convertToFloat32(Uint8List bytes) {
    final int16Data = bytes.buffer.asInt16List();
    final float32Data = Float32List(int16Data.length);

    for (var i = 0; i < int16Data.length; i++) {
      float32Data[i] = int16Data[i] / 32768.0;
    }

    return float32Data;
  }

  @override
  Future<void> close() async {
    await stopListening();
    _vadService.dispose();
    return super.close();
  }
}
