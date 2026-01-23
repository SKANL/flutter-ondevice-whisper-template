import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:w_zentyar_app/speaker_id/services/speaker_id_isolate.dart';

/// Service for Speaker Identification using a background isolate.
class SpeakerIdService {
  SpeakerIdService();

  Isolate? _isolate;
  SendPort? _sendPort;
  bool _isInitialized = false;

  final _responseQueue = Queue<Completer<dynamic>>();

  bool get isInitialized => _isInitialized;

  /// Initializes the speaker ID model.
  Future<void> initialize(String modelPath) async {
    if (_isolate != null && _sendPort != null) {
      await _sendInit(modelPath);
      return;
    }

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      SpeakerIdIsolate.entryPoint,
      receivePort.sendPort,
    );

    final completer = Completer<void>();

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
      } else if (message is SpeakerIdResponse) {
        if (_responseQueue.isNotEmpty) {
          final pending = _responseQueue.removeFirst();
          if (message is SpeakerIdInitSuccess) {
            pending.complete();
          } else if (message is SpeakerIdInitFailure) {
            pending.completeError(message.error);
          } else if (message is SpeakerIdExtractSuccess) {
            pending.complete(message.embedding);
          } else if (message is SpeakerIdExtractFailure) {
            pending.completeError(message.error);
          } else if (message is SpeakerIdRegisterSuccess) {
            pending.complete(true);
          } else if (message is SpeakerIdRegisterFailure) {
            pending.completeError(message.error);
          } else if (message is SpeakerIdVerifySuccess) {
            pending.complete(message.speakerName);
          } else if (message is SpeakerIdVerifyFailure) {
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
    _sendPort?.send(SpeakerIdInitCommand(modelPath: modelPath));
    await completer.future;
  }

  /// Extracts speaker embedding from audio samples.
  Future<Float32List> extractEmbedding(Float32List samples) async {
    if (!_isInitialized || _sendPort == null) {
      throw StateError('SpeakerIdService not initialized');
    }

    final completer = Completer<Float32List>();
    _responseQueue.add(completer);
    _sendPort?.send(SpeakerIdExtractCommand(samples: samples));
    return completer.future;
  }

  /// Registers a speaker with the given name and embedding.
  Future<bool> registerSpeaker({
    required String name,
    required Float32List embedding,
  }) async {
    if (!_isInitialized || _sendPort == null) {
      throw StateError('SpeakerIdService not initialized');
    }

    final completer = Completer<bool>();
    _responseQueue.add(completer);
    _sendPort?.send(SpeakerIdRegisterCommand(name: name, embedding: embedding));
    return completer.future;
  }

  /// Verifies a speaker against registered speakers.
  /// Returns speaker name if found, empty string otherwise.
  Future<String> verifySpeaker({
    required Float32List embedding,
    double threshold = 0.5,
  }) async {
    if (!_isInitialized || _sendPort == null) {
      throw StateError('SpeakerIdService not initialized');
    }

    final completer = Completer<String>();
    _responseQueue.add(completer);
    _sendPort?.send(
      SpeakerIdVerifyCommand(
        embedding: embedding,
        threshold: threshold,
      ),
    );
    return completer.future;
  }

  /// Disposes the isolate.
  void dispose() {
    _sendPort?.send(SpeakerIdDisposeCommand());
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
    _responseQueue.clear();
  }
}
