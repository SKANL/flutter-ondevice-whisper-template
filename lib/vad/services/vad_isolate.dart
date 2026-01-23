import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Commands for VAD isolate.
sealed class VadCommand {}

class VadInitCommand extends VadCommand {
  VadInitCommand({required this.modelPath});
  final String modelPath;
}

class VadProcessCommand extends VadCommand {
  VadProcessCommand({required this.samples});
  final Float32List samples;
}

class VadResetCommand extends VadCommand {}

class VadDisposeCommand extends VadCommand {}

/// Responses from VAD isolate.
sealed class VadResponse {}

class VadInitSuccess extends VadResponse {}

class VadInitFailure extends VadResponse {
  VadInitFailure(this.error);
  final String error;
}

class VadProcessResult extends VadResponse {
  VadProcessResult({
    required this.isSpeech,
    required this.speechSegments,
  });

  final bool isSpeech;
  final List<VadSpeechSegment> speechSegments;
}

class VadProcessFailure extends VadResponse {
  VadProcessFailure(this.error);
  final String error;
}

/// Represents a detected speech segment.
class VadSpeechSegment {
  VadSpeechSegment({
    required this.start,
    required this.samples,
  });

  final int start;
  final Float32List samples;
}

/// VAD isolate worker.
class VadIsolate {
  static Future<void> entryPoint(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    sherpa.VoiceActivityDetector? vad;

    await for (final message in receivePort) {
      if (message is VadInitCommand) {
        try {
          sherpa.initBindings();

          vad?.free();

          final sileroConfig = sherpa.SileroVadModelConfig(
            model: message.modelPath,
          );

          final vadConfig = sherpa.VadModelConfig(
            sileroVad: sileroConfig,
          );

          vad = sherpa.VoiceActivityDetector(
            config: vadConfig,
            bufferSizeInSeconds: 30,
          );

          sendPort.send(VadInitSuccess());
        } catch (e) {
          sendPort.send(VadInitFailure(e.toString()));
        }
      } else if (message is VadProcessCommand) {
        if (vad == null) {
          sendPort.send(VadProcessFailure('VAD not initialized'));
          continue;
        }

        try {
          vad.acceptWaveform(message.samples);

          final isSpeech = vad.isDetected();
          final segments = <VadSpeechSegment>[];

          while (!vad.isEmpty()) {
            final segment = vad.front();
            segments.add(
              VadSpeechSegment(
                start: segment.start,
                samples: segment.samples,
              ),
            );
            vad.pop();
          }

          sendPort.send(
            VadProcessResult(
              isSpeech: isSpeech,
              speechSegments: segments,
            ),
          );
        } catch (e) {
          sendPort.send(VadProcessFailure(e.toString()));
        }
      } else if (message is VadResetCommand) {
        vad?.reset();
      } else if (message is VadDisposeCommand) {
        vad?.free();
        Isolate.exit();
      }
    }
  }
}
