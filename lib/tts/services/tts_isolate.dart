import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Commands for TTS isolate.
sealed class TtsCommand {}

class TtsInitCommand extends TtsCommand {
  TtsInitCommand({
    required this.modelPath,
    required this.dataPath,
    required this.tokensPath,
  });

  final String modelPath;
  final String dataPath;
  final String tokensPath;
}

class TtsGenerateCommand extends TtsCommand {
  TtsGenerateCommand({
    required this.text,
    this.speakerId = 0,
    this.speed = 1.0,
  });

  final String text;
  final int speakerId;
  final double speed;
}

class TtsDisposeCommand extends TtsCommand {}

/// Responses from TTS isolate.
sealed class TtsResponse {}

class TtsInitSuccess extends TtsResponse {
  TtsInitSuccess({required this.numSpeakers, required this.sampleRate});

  final int numSpeakers;
  final int sampleRate;
}

class TtsInitFailure extends TtsResponse {
  TtsInitFailure(this.error);
  final String error;
}

class TtsGenerateSuccess extends TtsResponse {
  TtsGenerateSuccess({required this.samples, required this.sampleRate});

  final Float32List samples;
  final int sampleRate;
}

class TtsGenerateFailure extends TtsResponse {
  TtsGenerateFailure(this.error);
  final String error;
}

/// TTS isolate worker.
class TtsIsolate {
  /// Entry point for the TTS isolate.
  static Future<void> entryPoint(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    sherpa.OfflineTts? tts;

    await for (final message in receivePort) {
      if (message is TtsInitCommand) {
        try {
          sherpa.initBindings();

          tts?.free();

          final vitsConfig = sherpa.OfflineTtsVitsModelConfig(
            model: message.modelPath,
            dataDir: message.dataPath,
            tokens: message.tokensPath,
          );

          final modelConfig = sherpa.OfflineTtsModelConfig(
            vits: vitsConfig,
          );

          final config = sherpa.OfflineTtsConfig(model: modelConfig);
          tts = sherpa.OfflineTts(config);

          sendPort.send(
            TtsInitSuccess(
              numSpeakers: tts.numSpeakers,
              sampleRate: tts.sampleRate,
            ),
          );
        } catch (e) {
          sendPort.send(TtsInitFailure(e.toString()));
        }
      } else if (message is TtsGenerateCommand) {
        if (tts == null) {
          sendPort.send(TtsGenerateFailure('TTS not initialized'));
          continue;
        }

        try {
          final audio = tts.generate(
            text: message.text,
            sid: message.speakerId,
            speed: message.speed,
          );

          sendPort.send(
            TtsGenerateSuccess(
              samples: audio.samples,
              sampleRate: audio.sampleRate,
            ),
          );
        } catch (e) {
          sendPort.send(TtsGenerateFailure(e.toString()));
        }
      } else if (message is TtsDisposeCommand) {
        tts?.free();
        Isolate.exit();
      }
    }
  }
}
