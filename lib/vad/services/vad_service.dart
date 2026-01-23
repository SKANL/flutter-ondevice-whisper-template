import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:w_zentyar_app/vad/services/vad_isolate.dart';

/// Service for Voice Activity Detection using a background isolate.
class VadService {
  VadService();

  Isolate? _isolate;
  SendPort? _sendPort;
  bool _isInitialized = false;

  final _responseQueue = Queue<Completer<dynamic>>();

  bool get isInitialized => _isInitialized;

  /// Initializes the VAD model in a background isolate.
  Future<void> initialize(String modelPath) async {
    if (_isolate != null && _sendPort != null) {
      await _sendInit(modelPath);
      return;
    }

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(VadIsolate.entryPoint, receivePort.sendPort);

    final completer = Completer<void>();

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
      } else if (message is VadResponse) {
        if (_responseQueue.isNotEmpty) {
          final pending = _responseQueue.removeFirst();
          if (message is VadInitSuccess) {
            pending.complete();
          } else if (message is VadInitFailure) {
            pending.completeError(message.error);
          } else if (message is VadProcessResult) {
            pending.complete(message);
          } else if (message is VadProcessFailure) {
            pending.completeError(message.error);
          }
        }
      }
    });

    await completer.future;
    await _sendInit(modelPath);
    _isInitialized = true;
  }

  Future<void> _sendInit(String modelPath) async {
    final completer = Completer<void>();
    _responseQueue.add(completer);
    _sendPort?.send(VadInitCommand(modelPath: modelPath));
    await completer.future;
  }

  /// Processes audio samples and returns VAD result.
  Future<VadProcessResult> process(Float32List samples) async {
    if (!_isInitialized || _sendPort == null) {
      throw StateError('VadService not initialized');
    }

    final completer = Completer<VadProcessResult>();
    _responseQueue.add(completer);
    _sendPort?.send(VadProcessCommand(samples: samples));
    return completer.future;
  }

  /// Resets the VAD state.
  void reset() {
    _sendPort?.send(VadResetCommand());
  }

  /// Disposes the VAD isolate.
  void dispose() {
    _sendPort?.send(VadDisposeCommand());
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
    _responseQueue.clear();
  }
}
