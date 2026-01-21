import 'dart:isolate';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:w_zentyar_app/model_download/data/model_repository.dart';

/// Messages sent to the isolate.
sealed class IsolateMessage {}

class InitMessage extends IsolateMessage {
  InitMessage(this.modelPaths, this.language);
  final ModelPaths modelPaths;
  final String language;
}

class TranscribeMessage extends IsolateMessage {
  TranscribeMessage(this.audioPath);
  final String audioPath;
}

class DisposeMessage extends IsolateMessage {}

/// Responses received from the isolate.
sealed class IsolateResponse {}

class InitSuccessResponse extends IsolateResponse {}

class InitFailureResponse extends IsolateResponse {
  InitFailureResponse(this.error);
  final String error;
}

class TranscribeSuccessResponse extends IsolateResponse {
  TranscribeSuccessResponse(this.text);
  final String text;
}

class TranscribeFailureResponse extends IsolateResponse {
  TranscribeFailureResponse(this.error);
  final String error;
}

/// Runs the Whisper recognition in a separate isolate.
class WhisperIsolate {
  static Future<void> entryPoint(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    sherpa.OfflineRecognizer? recognizer;

    await for (final message in receivePort) {
      if (message is InitMessage) {
        try {
          // Initialize bindings in the isolate
          sherpa.initBindings();

          recognizer?.free();

          final whisperConfig = sherpa.OfflineWhisperModelConfig(
            encoder: message.modelPaths.encoder,
            decoder: message.modelPaths.decoder,
            language: message.language,
          );

          final modelConfig = sherpa.OfflineModelConfig(
            whisper: whisperConfig,
            tokens: message.modelPaths.tokens,
            modelType: 'whisper',
          );

          final config = sherpa.OfflineRecognizerConfig(model: modelConfig);

          recognizer = sherpa.OfflineRecognizer(config);
          sendPort.send(InitSuccessResponse());
        } catch (e) {
          sendPort.send(InitFailureResponse(e.toString()));
        }
      } else if (message is TranscribeMessage) {
        if (recognizer == null) {
          sendPort.send(
            TranscribeFailureResponse('Recognizer not initialized'),
          );
          continue;
        }

        try {
          final waveData = sherpa.readWave(message.audioPath);
          final stream = recognizer.createStream();
          stream.acceptWaveform(
            samples: waveData.samples,
            sampleRate: waveData.sampleRate,
          );
          recognizer.decode(stream);
          final result = recognizer.getResult(stream);
          stream.free();

          sendPort.send(TranscribeSuccessResponse(result.text.trim()));
        } catch (e) {
          sendPort.send(TranscribeFailureResponse(e.toString()));
        }
      } else if (message is DisposeMessage) {
        recognizer?.free();
        Isolate.exit();
      }
    }
  }
}
