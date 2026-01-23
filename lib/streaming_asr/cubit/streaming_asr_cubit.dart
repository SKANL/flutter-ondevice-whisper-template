import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:record/record.dart';
import 'package:w_zentyar_app/streaming_asr/cubit/streaming_asr_state.dart';
import 'package:w_zentyar_app/streaming_asr/services/streaming_asr_service.dart';

/// Cubit for managing Streaming ASR state.
class StreamingAsrCubit extends Cubit<StreamingAsrState> {
  StreamingAsrCubit({
    required StreamingAsrService streamingAsrService,
  }) : _service = streamingAsrService,
       super(const StreamingAsrInitial());

  final StreamingAsrService _service;
  final _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;
  String _finalizedText = '';
  bool _isListening = false;

  /// Initialize the streaming ASR service.
  Future<void> initialize(StreamingAsrPaths paths) async {
    emit(const StreamingAsrLoading());

    try {
      await _service.initialize(paths);
      emit(const StreamingAsrReady());
    } catch (e) {
      emit(StreamingAsrError(message: 'Failed to initialize: $e'));
    }
  }

  /// Start listening and transcribing.
  Future<void> startListening() async {
    if (_isListening) return;

    try {
      _isListening = true;
      _finalizedText = '';

      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      emit(const StreamingAsrListening(partialText: '', finalizedText: ''));

      _audioSubscription = stream.listen((data) async {
        final samples = _convertToFloat32(data);

        try {
          final result = await _service.process(samples);

          if (result.isEndpoint && result.text.isNotEmpty) {
            _finalizedText += '${result.text} ';
          }

          if (_isListening) {
            emit(
              StreamingAsrListening(
                partialText: result.text,
                finalizedText: _finalizedText,
              ),
            );
          }
        } catch (e) {
          // Ignore processing errors during streaming
        }
      });
    } catch (e) {
      _isListening = false;
      emit(StreamingAsrError(message: 'Failed to start: $e'));
    }
  }

  /// Stop listening.
  Future<void> stopListening() async {
    _isListening = false;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _recorder.stop();
    _service.reset();

    final transcription = _finalizedText.trim();
    emit(
      StreamingAsrReady(
        lastTranscription: transcription.isNotEmpty ? transcription : null,
      ),
    );
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
    _service.dispose();
    return super.close();
  }
}
