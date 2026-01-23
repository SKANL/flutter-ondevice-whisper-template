import 'dart:async';
import 'dart:isolate';

/// Generic message protocol for isolate communication.
sealed class IsolateCommand {}

/// Response protocol for isolate communication.
sealed class IsolateResponse {}

/// Success response with optional data.
class SuccessResponse extends IsolateResponse {
  SuccessResponse([this.data]);
  final dynamic data;
}

/// Error response with message.
class ErrorResponse extends IsolateResponse {
  ErrorResponse(this.error);
  final String error;
}

/// Dispose command to terminate isolate.
class DisposeCommand extends IsolateCommand {}

/// Manages a long-running background isolate for AI processing.
///
/// This class handles:
/// - Spawning and managing the isolate lifecycle
/// - Bidirectional communication via SendPort/ReceivePort
/// - Request/response matching using Completers
///
/// Usage:
/// ```dart
/// final manager = IsolateManager<MyCommand, MyResponse>();
/// await manager.spawn(MyIsolateWorker.entryPoint);
/// final result = await manager.send(MyCommand(...));
/// manager.dispose();
/// ```
class IsolateManager<C extends IsolateCommand, R extends IsolateResponse> {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  final _pendingResponses = <Completer<R>>[];
  bool _isReady = false;

  /// Whether the isolate is spawned and ready.
  bool get isReady => _isReady;

  /// Spawns the isolate with the given entry point.
  ///
  /// [entryPoint] must be a top-level or static function that accepts
  /// a [SendPort] as its only argument.
  Future<void> spawn(void Function(SendPort) entryPoint) async {
    if (_isolate != null) return;

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(entryPoint, _receivePort!.sendPort);

    final completer = Completer<void>();

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isReady = true;
        completer.complete();
      } else if (message is R) {
        if (_pendingResponses.isNotEmpty) {
          final pending = _pendingResponses.removeAt(0);
          pending.complete(message);
        }
      }
    });

    await completer.future;
  }

  /// Sends a command to the isolate and waits for response.
  Future<R> send(C command) async {
    if (!_isReady || _sendPort == null) {
      throw StateError('IsolateManager not ready. Call spawn() first.');
    }

    final completer = Completer<R>();
    _pendingResponses.add(completer);
    _sendPort!.send(command);
    return completer.future;
  }

  /// Disposes the isolate and cleans up resources.
  void dispose() {
    if (_sendPort != null) {
      _sendPort!.send(DisposeCommand());
    }
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    _isolate = null;
    _sendPort = null;
    _receivePort = null;
    _isReady = false;
    for (final c in _pendingResponses) {
      c.completeError('IsolateManager disposed');
    }
    _pendingResponses.clear();
  }
}
