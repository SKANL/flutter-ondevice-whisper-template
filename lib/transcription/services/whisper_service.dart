import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:w_zentyar_app/model_download/data/model_repository.dart';
import 'package:w_zentyar_app/transcription/services/whisper_isolate.dart';

/// Service for transcribing audio using Whisper via a background isolate.
///
/// Handles communication with [WhisperIsolate] to prevent UI blocking.
class WhisperService {
  WhisperService();

  Isolate? _isolate;
  SendPort? _sendPort;
  bool _isInitialized = false;

  // Queue to match responses to requests
  final _responseQueue = Queue<Completer<dynamic>>();

  /// Whether the service is initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the Whisper isolate and model.
  Future<void> initialize(
    ModelPaths modelPaths, {
    String language = 'en',
  }) async {
    // If re-initializing, just send new InitMessage if isolate exists
    if (_isolate != null && _sendPort != null) {
      await _sendInit(modelPaths, language);
      return;
    }

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      WhisperIsolate.entryPoint,
      receivePort.sendPort,
    );

    final completer = Completer<void>();

    // Listen for messages from the isolate
    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
      } else if (message is IsolateResponse) {
        if (_responseQueue.isNotEmpty) {
          final pendingCompleter = _responseQueue.removeFirst();
          if (message is InitSuccessResponse) {
            pendingCompleter.complete();
          } else if (message is InitFailureResponse) {
            pendingCompleter.completeError(message.error);
          } else if (message is TranscribeSuccessResponse) {
            pendingCompleter.complete(message.text);
          } else if (message is TranscribeFailureResponse) {
            pendingCompleter.completeError(message.error);
          }
        }
      }
    });

    await completer.future; // Wait for handshake

    await _sendInit(modelPaths, language);
    _isInitialized = true;
  }

  Future<void> _sendInit(ModelPaths modelPaths, String language) async {
    final completer = Completer<void>();
    _responseQueue.add(completer);
    _sendPort?.send(InitMessage(modelPaths, language));
    await completer.future;
  }

  Future<void> setLanguage(String language, ModelPaths modelPaths) async {
    await initialize(modelPaths, language: language);
  }

  /// Transcribes the audio file at the given path.
  Future<String> transcribe(String audioPath) async {
    if (!_isInitialized || _sendPort == null) {
      throw StateError('WhisperService not initialized');
    }

    final completer = Completer<String>();
    _responseQueue.add(completer);
    _sendPort?.send(TranscribeMessage(audioPath));
    return completer.future;
  }

  /// Disposes the isolate.
  void dispose() {
    _sendPort?.send(DisposeMessage());
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
    _responseQueue.clear();
  }
}
