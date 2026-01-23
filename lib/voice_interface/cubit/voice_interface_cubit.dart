import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:w_zentyar_app/core_ai/model_registry.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';
import 'package:w_zentyar_app/speaker_id/services/speaker_id_service.dart';
import 'package:w_zentyar_app/transcription/services/audio_recorder_service.dart';
import 'package:w_zentyar_app/transcription/services/whisper_service.dart';
import 'package:w_zentyar_app/tts/services/tts_service.dart';
import 'package:w_zentyar_app/vad/services/vad_service.dart';
import 'package:w_zentyar_app/voice_interface/cubit/voice_interface_state.dart';

/// Cubit for the unified Voice Interface.
///
/// Manages state for all AI features (ASR, TTS, VAD, Speaker ID)
/// through a single unified interface.
class VoiceInterfaceCubit extends Cubit<VoiceInterfaceState> {
  VoiceInterfaceCubit({
    required ModelRepository modelRepository,
  }) : _modelRepository = modelRepository,
       super(const VoiceInterfaceInitial());

  final ModelRepository _modelRepository;

  // Services (lazily initialized per model type)
  WhisperService? _whisperService;
  TtsService? _ttsService;
  VadService? _vadService;
  SpeakerIdService? _speakerIdService;

  // Recording
  final _audioRecorder = AudioRecorderService();
  final _streamRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;

  // State tracking
  bool _isListening = false;

  /// Initializes the interface with a specific model.
  Future<void> initialize(AiModelType modelType) async {
    emit(VoiceInterfaceLoading(modelType: modelType));

    try {
      final config = ModelRegistry.getConfig(modelType);
      if (config == null) {
        emit(
          VoiceInterfaceError(
            message: 'Unknown model type',
            modelType: modelType,
          ),
        );
        return;
      }

      // Check if model is downloaded
      final isDownloaded = await _modelRepository.isModelDownloaded(modelType);
      if (!isDownloaded) {
        emit(
          VoiceInterfaceError(
            message: 'Model not downloaded. Please download it first.',
            modelType: modelType,
          ),
        );
        return;
      }

      // Initialize the appropriate service
      await _initializeService(modelType, config);

      emit(
        VoiceInterfaceReady(
          modelType: modelType,
          modelName: config.name,
        ),
      );
    } catch (e) {
      emit(
        VoiceInterfaceError(
          message: 'Failed to initialize: $e',
          modelType: modelType,
        ),
      );
    }
  }

  Future<void> _initializeService(
    AiModelType modelType,
    AiModelConfig config,
  ) async {
    final category = config.category;

    switch (category) {
      case 'ASR':
        await _initializeAsr(modelType);
      case 'TTS':
        await _initializeTts(modelType);
      case 'VAD':
        await _initializeVad(modelType);
      case 'Speaker ID':
        await _initializeSpeakerId(modelType);
      default:
        throw UnsupportedError('Unsupported model category: $category');
    }
  }

  Future<void> _initializeAsr(AiModelType modelType) async {
    _whisperService?.dispose();
    _whisperService = WhisperService();

    final paths = await _modelRepository.getModelPaths(modelType);
    if (paths == null) throw StateError('Model paths not found');

    await _whisperService!.initialize(paths);
  }

  Future<void> _initializeTts(AiModelType modelType) async {
    debugPrint('[VoiceInterfaceCubit] _initializeTts for $modelType');
    _ttsService?.dispose();
    _ttsService = TtsService();

    final pathsMap = await _modelRepository.getModelPathsMap(modelType);
    if (pathsMap == null) throw StateError('Model paths not found');

    debugPrint('[VoiceInterfaceCubit] TTS pathsMap: $pathsMap');

    final ttsPaths = TtsPaths(
      model: pathsMap['model'] ?? '',
      dataDir: pathsMap['dataDir'] ?? '',
      tokens: pathsMap['tokens'] ?? '',
    );

    debugPrint('[VoiceInterfaceCubit] TtsPaths object:');
    debugPrint('  model: ${ttsPaths.model}');
    debugPrint('  dataDir: ${ttsPaths.dataDir}');
    debugPrint('  tokens: ${ttsPaths.tokens}');

    await _ttsService!.initialize(ttsPaths);
    debugPrint('[VoiceInterfaceCubit] TTS initialized successfully');
  }

  Future<void> _initializeVad(AiModelType modelType) async {
    _vadService?.dispose();
    _vadService = VadService();

    final pathsMap = await _modelRepository.getModelPathsMap(modelType);
    if (pathsMap == null) throw StateError('Model paths not found');

    await _vadService!.initialize(pathsMap['model'] ?? '');
  }

  Future<void> _initializeSpeakerId(AiModelType modelType) async {
    _speakerIdService?.dispose();
    _speakerIdService = SpeakerIdService();

    final pathsMap = await _modelRepository.getModelPathsMap(modelType);
    if (pathsMap == null) throw StateError('Model paths not found');

    await _speakerIdService!.initialize(pathsMap['model'] ?? '');
  }

  /// Starts listening/recording based on model type.
  Future<void> startListening() async {
    final currentState = state;
    if (currentState is! VoiceInterfaceReady) return;
    if (_isListening) return;

    _isListening = true;
    final modelType = currentState.modelType;
    final category = ModelRegistry.getConfig(modelType)?.category;

    emit(VoiceInterfaceListening(modelType: modelType));

    try {
      switch (category) {
        case 'ASR':
          await _startAsrRecording(modelType);
        case 'VAD':
          await _startVadListening(modelType);
        case 'Speaker ID':
          await _startSpeakerIdRecording(modelType);
        default:
          throw UnsupportedError('Cannot listen with category: $category');
      }
    } catch (e) {
      _isListening = false;
      emit(
        VoiceInterfaceError(
          message: 'Failed to start listening: $e',
          modelType: modelType,
        ),
      );
    }
  }

  Future<void> _startAsrRecording(AiModelType modelType) async {
    await _audioRecorder.startRecording();
  }

  Future<void> _startVadListening(AiModelType modelType) async {
    final stream = await _streamRecorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    _audioSubscription = stream.listen((data) async {
      final samples = _convertToFloat32(data);

      try {
        final result = await _vadService!.process(samples);
        final volume = result.isSpeech ? 0.8 : 0.1;

        if (_isListening) {
          emit(
            VoiceInterfaceListening(
              modelType: modelType,
              volume: volume,
              isSpeaking: result.isSpeech,
            ),
          );
        }
      } catch (_) {
        // Ignore processing errors during streaming
      }
    });
  }

  Future<void> _startSpeakerIdRecording(AiModelType modelType) async {
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/speaker_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _streamRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  /// Stops listening and processes the result.
  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;

    final currentState = state;
    if (currentState is! VoiceInterfaceListening) return;

    final modelType = currentState.modelType;
    final category = ModelRegistry.getConfig(modelType)?.category;

    emit(VoiceInterfaceProcessing(modelType: modelType));

    try {
      switch (category) {
        case 'ASR':
          await _processAsrRecording(modelType);
        case 'VAD':
          await _stopVadListening(modelType);
        case 'Speaker ID':
          await _processSpeakerIdRecording(modelType);
        default:
          throw UnsupportedError('Cannot process category: $category');
      }
    } catch (e) {
      emit(
        VoiceInterfaceError(
          message: 'Processing failed: $e',
          modelType: modelType,
        ),
      );
    }
  }

  Future<void> _processAsrRecording(AiModelType modelType) async {
    final audioPath = await _audioRecorder.stopRecording();
    if (audioPath == null) {
      emit(VoiceInterfaceReady(modelType: modelType));
      return;
    }

    final transcription = await _whisperService!.transcribe(audioPath);

    // Clean up audio file
    final file = File(audioPath);
    if (await file.exists()) await file.delete();

    emit(
      VoiceInterfaceResult(
        modelType: modelType,
        transcription: transcription,
      ),
    );
  }

  Future<void> _stopVadListening(AiModelType modelType) async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _streamRecorder.stop();
    _vadService?.reset();

    emit(VoiceInterfaceReady(modelType: modelType));
  }

  Future<void> _processSpeakerIdRecording(AiModelType modelType) async {
    final path = await _streamRecorder.stop();
    if (path == null) {
      emit(VoiceInterfaceReady(modelType: modelType));
      return;
    }

    final waveData = sherpa.readWave(path);
    final embedding = await _speakerIdService!.extractEmbedding(
      waveData.samples,
    );
    final speakerName = await _speakerIdService!.verifySpeaker(
      embedding: embedding,
    );

    await File(path).delete();

    emit(
      VoiceInterfaceResult(
        modelType: modelType,
        speakerName: speakerName.isEmpty ? 'Unknown' : speakerName,
      ),
    );
  }

  /// Synthesizes speech from text (TTS only).
  Future<void> synthesize(String text, {double speed = 1.0}) async {
    final currentState = state;
    if (currentState is! VoiceInterfaceReady) return;

    final modelType = currentState.modelType;
    final category = ModelRegistry.getConfig(modelType)?.category;
    if (category != 'TTS') return;

    if (text.trim().isEmpty) return;

    emit(
      VoiceInterfaceProcessing(
        modelType: modelType,
        message: 'Generating speech...',
      ),
    );

    try {
      final (samples, sampleRate) = await _ttsService!.generate(
        text: text,
        speed: speed,
      );

      final audioPath = await _saveToWav(samples, sampleRate);

      emit(
        VoiceInterfaceResult(
          modelType: modelType,
          audioPath: audioPath,
        ),
      );
    } catch (e) {
      emit(
        VoiceInterfaceError(
          message: 'Speech synthesis failed: $e',
          modelType: modelType,
        ),
      );
    }
  }

  /// Registers a speaker (Speaker ID only).
  Future<void> registerSpeaker(String name) async {
    final currentState = state;
    if (currentState is! VoiceInterfaceReady) return;

    final modelType = currentState.modelType;

    emit(VoiceInterfaceListening(modelType: modelType));
    await _startSpeakerIdRecording(modelType);
  }

  Future<String> _saveToWav(Float32List samples, int sampleRate) async {
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav';

    final int16Samples = Int16List(samples.length);
    for (var i = 0; i < samples.length; i++) {
      final sample = (samples[i] * 32767).clamp(-32768, 32767).toInt();
      int16Samples[i] = sample;
    }

    final file = File(filePath);
    final sink = file.openSync(mode: FileMode.write);

    final header = _buildWavHeader(int16Samples.length * 2, sampleRate);
    sink.writeFromSync(header);
    sink.writeFromSync(int16Samples.buffer.asUint8List());
    sink.closeSync();

    return filePath;
  }

  Uint8List _buildWavHeader(int dataSize, int sampleRate) {
    final header = ByteData(44);
    const channels = 1;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    const blockAlign = channels * bitsPerSample ~/ 8;

    // RIFF header
    header
      ..setUint8(0, 0x52) // R
      ..setUint8(1, 0x49) // I
      ..setUint8(2, 0x46) // F
      ..setUint8(3, 0x46) // F
      ..setUint32(4, 36 + dataSize, Endian.little)
      ..setUint8(8, 0x57) // W
      ..setUint8(9, 0x41) // A
      ..setUint8(10, 0x56) // V
      ..setUint8(11, 0x45) // E
      // fmt chunk
      ..setUint8(12, 0x66) // f
      ..setUint8(13, 0x6D) // m
      ..setUint8(14, 0x74) // t
      ..setUint8(15, 0x20) // space
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, channels, Endian.little)
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, byteRate, Endian.little)
      ..setUint16(32, blockAlign, Endian.little)
      ..setUint16(34, bitsPerSample, Endian.little)
      // data chunk
      ..setUint8(36, 0x64) // d
      ..setUint8(37, 0x61) // a
      ..setUint8(38, 0x74) // t
      ..setUint8(39, 0x61) // a
      ..setUint32(40, dataSize, Endian.little);

    return header.buffer.asUint8List();
  }

  Float32List _convertToFloat32(Uint8List bytes) {
    final int16Data = bytes.buffer.asInt16List();
    final float32Data = Float32List(int16Data.length);

    for (var i = 0; i < int16Data.length; i++) {
      float32Data[i] = int16Data[i] / 32768.0;
    }

    return float32Data;
  }

  /// Returns to ready state from result.
  void reset() {
    final currentState = state;
    final modelType = currentState.modelType;
    if (modelType != null) {
      emit(VoiceInterfaceReady(modelType: modelType));
    }
  }

  /// Cancels current operation.
  Future<void> cancel() async {
    _isListening = false;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _audioRecorder.cancelRecording();
    await _streamRecorder.stop();

    final currentState = state;
    final modelType = currentState.modelType;
    if (modelType != null) {
      emit(VoiceInterfaceReady(modelType: modelType));
    }
  }

  @override
  Future<void> close() async {
    await cancel();
    _whisperService?.dispose();
    _ttsService?.dispose();
    _vadService?.dispose();
    _speakerIdService?.dispose();
    await _audioRecorder.dispose();
    await _streamRecorder.dispose();
    return super.close();
  }
}
