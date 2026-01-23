import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:w_zentyar_app/tts/cubit/tts_state.dart';
import 'package:w_zentyar_app/tts/services/tts_service.dart';

/// Cubit for managing TTS state.
class TtsCubit extends Cubit<TtsState> {
  TtsCubit({
    required TtsService ttsService,
  }) : _ttsService = ttsService,
       super(const TtsInitial());

  final TtsService _ttsService;

  /// Initialize the TTS service.
  Future<void> initialize(TtsPaths paths) async {
    emit(const TtsLoading());

    try {
      await _ttsService.initialize(paths);
      emit(TtsReady(numSpeakers: _ttsService.numSpeakers));
    } catch (e) {
      emit(TtsError(message: 'Failed to initialize TTS: $e'));
    }
  }

  /// Generate speech from text.
  Future<void> speak({
    required String text,
    int speakerId = 0,
    double speed = 1.0,
  }) async {
    if (text.trim().isEmpty) return;

    emit(TtsGenerating(text: text));

    try {
      final (samples, sampleRate) = await _ttsService.generate(
        text: text,
        speakerId: speakerId,
        speed: speed,
      );

      // Save to WAV file
      final audioPath = await _saveToWav(samples, sampleRate);

      emit(TtsGenerated(text: text, audioPath: audioPath));
    } catch (e) {
      emit(TtsError(message: 'Failed to generate speech: $e'));
    }
  }

  /// Saves audio samples to a WAV file.
  Future<String> _saveToWav(Float32List samples, int sampleRate) async {
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav';

    // Convert Float32 to Int16
    final int16Samples = Int16List(samples.length);
    for (var i = 0; i < samples.length; i++) {
      final sample = (samples[i] * 32767).clamp(-32768, 32767).toInt();
      int16Samples[i] = sample;
    }

    // Write WAV file
    final file = File(filePath);
    final sink = file.openSync(mode: FileMode.write);

    // WAV header
    final header = _buildWavHeader(int16Samples.length * 2, sampleRate);
    sink.writeFromSync(header);

    // Audio data
    sink.writeFromSync(int16Samples.buffer.asUint8List());
    sink.closeSync();

    return filePath;
  }

  /// Builds WAV file header.
  Uint8List _buildWavHeader(int dataSize, int sampleRate) {
    final header = ByteData(44);
    const channels = 1;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    const blockAlign = channels * bitsPerSample ~/ 8;

    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, 36 + dataSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // PCM format
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    return header.buffer.asUint8List();
  }

  /// Reset to ready state.
  void reset() {
    if (_ttsService.isInitialized) {
      emit(TtsReady(numSpeakers: _ttsService.numSpeakers));
    }
  }

  @override
  Future<void> close() async {
    _ttsService.dispose();
    return super.close();
  }
}
