import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:w_zentyar_app/tts/services/tts_isolate.dart';

/// Paths to TTS model files.
class TtsPaths {
  const TtsPaths({
    required this.model,
    required this.dataDir,
    required this.tokens,
  });

  final String model;
  final String dataDir;
  final String tokens;
}

/// Service for Text-to-Speech using a background isolate.
class TtsService {
  TtsService();

  Isolate? _isolate;
  SendPort? _sendPort;
  bool _isInitialized = false;
  int _numSpeakers = 0;
  int _sampleRate = 22050;

  final _responseQueue = Queue<Completer<dynamic>>();

  bool get isInitialized => _isInitialized;
  int get numSpeakers => _numSpeakers;
  int get sampleRate => _sampleRate;

  /// Initializes the TTS model in a background isolate.
  Future<void> initialize(TtsPaths paths) async {
    if (_isolate != null && _sendPort != null) {
      await _sendInit(paths);
      return;
    }

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(TtsIsolate.entryPoint, receivePort.sendPort);

    final completer = Completer<void>();

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
      } else if (message is TtsResponse) {
        if (_responseQueue.isNotEmpty) {
          final pending = _responseQueue.removeFirst();
          if (message is TtsInitSuccess) {
            _numSpeakers = message.numSpeakers;
            _sampleRate = message.sampleRate;
            pending.complete();
          } else if (message is TtsInitFailure) {
            pending.completeError(message.error);
          } else if (message is TtsGenerateSuccess) {
            pending.complete((message.samples, message.sampleRate));
          } else if (message is TtsGenerateFailure) {
            pending.completeError(message.error);
          }
        }
      }
    });

    await completer.future;
    await _sendInit(paths);
    _isInitialized = true;
  }

  Future<void> _sendInit(TtsPaths paths) async {
    final completer = Completer<void>();
    _responseQueue.add(completer);
    _sendPort?.send(
      TtsInitCommand(
        modelPath: paths.model,
        dataPath: paths.dataDir,
        tokensPath: paths.tokens,
      ),
    );
    await completer.future;
  }

  /// Generates speech from text.
  ///
  /// Returns a tuple of (samples, sampleRate).
  Future<(Float32List, int)> generate({
    required String text,
    int speakerId = 0,
    double speed = 1.0,
  }) async {
    if (!_isInitialized || _sendPort == null) {
      throw StateError('TtsService not initialized');
    }

    final completer = Completer<(Float32List, int)>();
    _responseQueue.add(completer);
    _sendPort?.send(
      TtsGenerateCommand(
        text: text,
        speakerId: speakerId,
        speed: speed,
      ),
    );
    return completer.future;
  }

  /// Disposes the TTS isolate.
  void dispose() {
    _sendPort?.send(TtsDisposeCommand());
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
    _responseQueue.clear();
  }
}
