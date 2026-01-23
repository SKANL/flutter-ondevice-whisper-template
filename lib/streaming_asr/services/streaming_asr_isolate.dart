import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Commands for Streaming ASR isolate.
sealed class StreamingAsrCommand {}

class StreamingAsrInitCommand extends StreamingAsrCommand {
  StreamingAsrInitCommand({
    required this.encoderPath,
    required this.decoderPath,
    required this.joinerPath,
    required this.tokensPath,
  });

  final String encoderPath;
  final String decoderPath;
  final String joinerPath;
  final String tokensPath;
}

class StreamingAsrProcessCommand extends StreamingAsrCommand {
  StreamingAsrProcessCommand({required this.samples});
  final Float32List samples;
}

class StreamingAsrResetCommand extends StreamingAsrCommand {}

class StreamingAsrDisposeCommand extends StreamingAsrCommand {}

/// Responses from Streaming ASR isolate.
sealed class StreamingAsrResponse {}

class StreamingAsrInitSuccess extends StreamingAsrResponse {}

class StreamingAsrInitFailure extends StreamingAsrResponse {
  StreamingAsrInitFailure(this.error);
  final String error;
}

class StreamingAsrResult extends StreamingAsrResponse {
  StreamingAsrResult({
    required this.text,
    required this.isEndpoint,
  });

  final String text;
  final bool isEndpoint;
}

class StreamingAsrProcessFailure extends StreamingAsrResponse {
  StreamingAsrProcessFailure(this.error);
  final String error;
}

/// Streaming ASR isolate worker.
class StreamingAsrIsolate {
  static Future<void> entryPoint(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    sherpa.OnlineRecognizer? recognizer;
    sherpa.OnlineStream? stream;

    await for (final message in receivePort) {
      if (message is StreamingAsrInitCommand) {
        try {
          sherpa.initBindings();

          stream?.free();
          recognizer?.free();

          final transducerConfig = sherpa.OnlineTransducerModelConfig(
            encoder: message.encoderPath,
            decoder: message.decoderPath,
            joiner: message.joinerPath,
          );

          final modelConfig = sherpa.OnlineModelConfig(
            transducer: transducerConfig,
            tokens: message.tokensPath,
            modelType: 'zipformer2',
          );

          final config = sherpa.OnlineRecognizerConfig(
            model: modelConfig,
          );

          recognizer = sherpa.OnlineRecognizer(config);
          stream = recognizer.createStream();

          sendPort.send(StreamingAsrInitSuccess());
        } catch (e) {
          sendPort.send(StreamingAsrInitFailure(e.toString()));
        }
      } else if (message is StreamingAsrProcessCommand) {
        if (recognizer == null || stream == null) {
          sendPort.send(
            StreamingAsrProcessFailure('Recognizer not initialized'),
          );
          continue;
        }

        try {
          stream.acceptWaveform(
            samples: message.samples,
            sampleRate: 16000,
          );

          while (recognizer.isReady(stream)) {
            recognizer.decode(stream);
          }

          final isEndpoint = recognizer.isEndpoint(stream);
          final result = recognizer.getResult(stream);

          if (isEndpoint) {
            recognizer.reset(stream);
          }

          sendPort.send(
            StreamingAsrResult(
              text: result.text,
              isEndpoint: isEndpoint,
            ),
          );
        } catch (e) {
          sendPort.send(StreamingAsrProcessFailure(e.toString()));
        }
      } else if (message is StreamingAsrResetCommand) {
        if (stream != null && recognizer != null) {
          recognizer.reset(stream);
        }
      } else if (message is StreamingAsrDisposeCommand) {
        stream?.free();
        recognizer?.free();
        Isolate.exit();
      }
    }
  }
}
