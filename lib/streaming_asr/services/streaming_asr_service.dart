import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:w_zentyar_app/streaming_asr/services/streaming_asr_isolate.dart';

/// Paths to Streaming ASR model files.
class StreamingAsrPaths {
  const StreamingAsrPaths({
    required this.encoder,
    required this.decoder,
    required this.joiner,
    required this.tokens,
  });

  final String encoder;
  final String decoder;
  final String joiner;
  final String tokens;
}

/// Service for Streaming ASR using a background isolate.
class StreamingAsrService {
  StreamingAsrService();

  Isolate? _isolate;
  SendPort? _sendPort;
  bool _isInitialized = false;

  final _responseQueue = Queue<Completer<dynamic>>();

  bool get isInitialized => _isInitialized;

  /// Initializes the streaming ASR model.
  Future<void> initialize(StreamingAsrPaths paths) async {
    if (_isolate != null && _sendPort != null) {
      await _sendInit(paths);
      return;
    }

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      StreamingAsrIsolate.entryPoint,
      receivePort.sendPort,
    );

    final completer = Completer<void>();

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
      } else if (message is StreamingAsrResponse) {
        if (_responseQueue.isNotEmpty) {
          final pending = _responseQueue.removeFirst();
          if (message is StreamingAsrInitSuccess) {
            pending.complete();
          } else if (message is StreamingAsrInitFailure) {
            pending.completeError(message.error);
          } else if (message is StreamingAsrResult) {
            pending.complete(message);
          } else if (message is StreamingAsrProcessFailure) {
            pending.completeError(message.error);
          }
        }
      }
    });

    await completer.future;
    await _sendInit(paths);
    _isInitialized = true;
  }

  Future<void> _sendInit(StreamingAsrPaths paths) async {
    final completer = Completer<void>();
    _responseQueue.add(completer);
    _sendPort?.send(
      StreamingAsrInitCommand(
        encoderPath: paths.encoder,
        decoderPath: paths.decoder,
        joinerPath: paths.joiner,
        tokensPath: paths.tokens,
      ),
    );
    await completer.future;
  }

  /// Processes audio samples and returns partial result.
  Future<StreamingAsrResult> process(Float32List samples) async {
    if (!_isInitialized || _sendPort == null) {
      throw StateError('StreamingAsrService not initialized');
    }

    final completer = Completer<StreamingAsrResult>();
    _responseQueue.add(completer);
    _sendPort?.send(StreamingAsrProcessCommand(samples: samples));
    return completer.future;
  }

  /// Resets the recognizer stream.
  void reset() {
    _sendPort?.send(StreamingAsrResetCommand());
  }

  /// Disposes the isolate.
  void dispose() {
    _sendPort?.send(StreamingAsrDisposeCommand());
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
    _responseQueue.clear();
  }
}
