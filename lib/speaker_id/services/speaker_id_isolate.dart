import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Commands for Speaker ID isolate.
sealed class SpeakerIdCommand {}

class SpeakerIdInitCommand extends SpeakerIdCommand {
  SpeakerIdInitCommand({required this.modelPath});
  final String modelPath;
}

class SpeakerIdExtractCommand extends SpeakerIdCommand {
  SpeakerIdExtractCommand({required this.samples});
  final Float32List samples;
}

class SpeakerIdRegisterCommand extends SpeakerIdCommand {
  SpeakerIdRegisterCommand({
    required this.name,
    required this.embedding,
  });
  final String name;
  final Float32List embedding;
}

class SpeakerIdVerifyCommand extends SpeakerIdCommand {
  SpeakerIdVerifyCommand({
    required this.embedding,
    required this.threshold,
  });
  final Float32List embedding;
  final double threshold;
}

class SpeakerIdDisposeCommand extends SpeakerIdCommand {}

/// Responses from Speaker ID isolate.
sealed class SpeakerIdResponse {}

class SpeakerIdInitSuccess extends SpeakerIdResponse {}

class SpeakerIdInitFailure extends SpeakerIdResponse {
  SpeakerIdInitFailure(this.error);
  final String error;
}

class SpeakerIdExtractSuccess extends SpeakerIdResponse {
  SpeakerIdExtractSuccess({required this.embedding});
  final Float32List embedding;
}

class SpeakerIdExtractFailure extends SpeakerIdResponse {
  SpeakerIdExtractFailure(this.error);
  final String error;
}

class SpeakerIdRegisterSuccess extends SpeakerIdResponse {}

class SpeakerIdRegisterFailure extends SpeakerIdResponse {
  SpeakerIdRegisterFailure(this.error);
  final String error;
}

class SpeakerIdVerifySuccess extends SpeakerIdResponse {
  SpeakerIdVerifySuccess({required this.speakerName});
  final String speakerName;
}

class SpeakerIdVerifyFailure extends SpeakerIdResponse {
  SpeakerIdVerifyFailure(this.error);
  final String error;
}

/// Speaker ID isolate worker.
class SpeakerIdIsolate {
  static Future<void> entryPoint(SendPort sendPort) async {
    // Initialize bindings immediately when isolate starts
    sherpa.initBindings();

    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    sherpa.SpeakerEmbeddingExtractor? extractor;
    sherpa.SpeakerEmbeddingManager? manager;

    await for (final message in receivePort) {
      if (message is SpeakerIdInitCommand) {
        try {
          extractor?.free();
          manager?.free();

          final config = sherpa.SpeakerEmbeddingExtractorConfig(
            model: message.modelPath,
          );

          extractor = sherpa.SpeakerEmbeddingExtractor(config: config);
          manager = sherpa.SpeakerEmbeddingManager(extractor.dim);

          sendPort.send(SpeakerIdInitSuccess());
        } catch (e) {
          sendPort.send(SpeakerIdInitFailure(e.toString()));
        }
      } else if (message is SpeakerIdExtractCommand) {
        if (extractor == null) {
          sendPort.send(SpeakerIdExtractFailure('Extractor not initialized'));
          continue;
        }

        try {
          final stream = extractor.createStream();
          stream.acceptWaveform(
            samples: message.samples,
            sampleRate: 16000,
          );
          stream.inputFinished();

          if (!extractor.isReady(stream)) {
            stream.free();
            sendPort.send(SpeakerIdExtractFailure('Audio too short'));
            continue;
          }

          final embedding = extractor.compute(stream);
          stream.free();

          sendPort.send(SpeakerIdExtractSuccess(embedding: embedding));
        } catch (e) {
          sendPort.send(SpeakerIdExtractFailure(e.toString()));
        }
      } else if (message is SpeakerIdRegisterCommand) {
        if (manager == null) {
          sendPort.send(SpeakerIdRegisterFailure('Manager not initialized'));
          continue;
        }

        try {
          final success = manager.add(
            name: message.name,
            embedding: message.embedding,
          );

          if (success) {
            sendPort.send(SpeakerIdRegisterSuccess());
          } else {
            sendPort.send(SpeakerIdRegisterFailure('Failed to register'));
          }
        } catch (e) {
          sendPort.send(SpeakerIdRegisterFailure(e.toString()));
        }
      } else if (message is SpeakerIdVerifyCommand) {
        if (manager == null) {
          sendPort.send(SpeakerIdVerifyFailure('Manager not initialized'));
          continue;
        }

        try {
          final name = manager.search(
            embedding: message.embedding,
            threshold: message.threshold,
          );

          sendPort.send(SpeakerIdVerifySuccess(speakerName: name));
        } catch (e) {
          sendPort.send(SpeakerIdVerifyFailure(e.toString()));
        }
      } else if (message is SpeakerIdDisposeCommand) {
        manager?.free();
        extractor?.free();
        Isolate.exit();
      }
    }
  }
}
