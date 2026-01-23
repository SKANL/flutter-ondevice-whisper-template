import 'dart:developer' as developer;
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:w_zentyar_app/core_ai/model_registry.dart';

void _log(String message) {
  developer.log(message, name: 'ModelRepository');
  debugPrint('[ModelRepository] $message');
}

///
/// Supports multiple model types from [AiModelType] registry.
class ModelRepository {
  ModelRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Gets the base directory for all AI models.
  Future<Directory> get _modelsBaseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/ai_models');
  }

  /// Gets the directory for a specific model type.
  Future<Directory> _getModelDir(AiModelType type) async {
    final baseDir = await _modelsBaseDir;
    final config = ModelRegistry.getConfig(type);
    if (config == null) throw ArgumentError('Unknown model type: $type');

    final dirName = config.extractedDirName.isNotEmpty
        ? config.extractedDirName
        : config.archiveName.replaceAll('.onnx', '');
    return Directory('${baseDir.path}/$dirName');
  }

  /// Checks if a specific model is downloaded.
  Future<bool> isModelDownloaded(AiModelType type) async {
    final config = ModelRegistry.getConfig(type);
    if (config == null) return false;

    final modelDir = await _getModelDir(type);
    if (!modelDir.existsSync()) return false;

    for (final fileName in config.requiredFiles) {
      // Handle both files and directories
      final filePath = '${modelDir.path}/$fileName';
      if (!File(filePath).existsSync() && !Directory(filePath).existsSync()) {
        return false;
      }
    }
    return true;
  }

  /// Gets download status for all models.
  Future<Map<AiModelType, bool>> getAllModelStatuses() async {
    final statuses = <AiModelType, bool>{};
    for (final type in AiModelType.values) {
      statuses[type] = await isModelDownloaded(type);
    }
    return statuses;
  }

  /// Gets paths for a specific model type.
  Future<ModelPaths?> getModelPaths([
    AiModelType type = AiModelType.whisperTinyEn,
  ]) async {
    if (!await isModelDownloaded(type)) return null;

    final modelDir = await _getModelDir(type);
    final config = ModelRegistry.getConfig(type);
    if (config == null) return null;

    // Dynamically find required files
    final encoderFile = config.requiredFiles.firstWhere(
      (f) => f.contains('encoder'),
      orElse: () => '',
    );
    final decoderFile = config.requiredFiles.firstWhere(
      (f) => f.contains('decoder'),
      orElse: () => '',
    );
    final tokensFile = config.requiredFiles.firstWhere(
      (f) => f.contains('tokens'),
      orElse: () => '',
    );

    // If we can't find core files, return generic path (might still fail but better than empty)
    // For Whisper, we need all three.
    if (encoderFile.isEmpty) {
      return ModelPaths(
        encoder: modelDir.path,
        decoder: '',
        tokens: '',
      );
    }

    return ModelPaths(
      encoder: '${modelDir.path}/$encoderFile',
      decoder: decoderFile.isNotEmpty ? '${modelDir.path}/$decoderFile' : '',
      tokens: tokensFile.isNotEmpty ? '${modelDir.path}/$tokensFile' : '',
    );
  }

  /// Gets paths for a specific model type as a map.
  ///
  /// This method supports all model categories (ASR, TTS, VAD, Speaker ID)
  /// and returns the appropriate paths for each.
  Future<Map<String, String>?> getModelPathsMap(AiModelType type) async {
    _log('getModelPathsMap called for type: $type');

    if (!await isModelDownloaded(type)) {
      _log('Model not downloaded: $type');
      return null;
    }

    final modelDir = await _getModelDir(type);
    final config = ModelRegistry.getConfig(type);
    if (config == null) {
      _log('Config not found for type: $type');
      return null;
    }

    _log('Model name: ${config.name}');
    _log('Model category: ${config.category}');
    _log('Model dir: ${modelDir.path}');

    // List all files in model directory
    if (modelDir.existsSync()) {
      _log('--- Files in model directory ---');
      for (final entity in modelDir.listSync(recursive: true)) {
        final relativePath = entity.path.replaceFirst(modelDir.path, '');
        final type = entity is Directory ? '[DIR]' : '[FILE]';
        _log('  $type $relativePath');
      }
      _log('--- End of file listing ---');
    }

    final category = config.category;
    final dirPath = modelDir.path;

    // Build paths based on model category
    final paths = switch (category) {
      'ASR' => _buildAsrPaths(dirPath, config),
      'TTS' => _buildTtsPaths(dirPath, config),
      'VAD' => _buildVadPaths(dirPath, config),
      'Speaker ID' => _buildSpeakerIdPaths(dirPath, config),
      _ => {'modelDir': dirPath},
    };

    _log('Built paths: $paths');
    return paths;
  }

  Map<String, String> _buildAsrPaths(String dirPath, AiModelConfig config) {
    // Find encoder, decoder, and tokens files from required files
    final encoder = config.requiredFiles.firstWhere(
      (f) => f.contains('encoder'),
      orElse: () => '',
    );
    final decoder = config.requiredFiles.firstWhere(
      (f) => f.contains('decoder'),
      orElse: () => '',
    );
    final tokens = config.requiredFiles.firstWhere(
      (f) => f.contains('tokens'),
      orElse: () => '',
    );

    return {
      'encoder': encoder.isNotEmpty ? '$dirPath/$encoder' : '',
      'decoder': decoder.isNotEmpty ? '$dirPath/$decoder' : '',
      'tokens': tokens.isNotEmpty ? '$dirPath/$tokens' : '',
      'modelDir': dirPath,
    };
  }

  Map<String, String> _buildTtsPaths(String dirPath, AiModelConfig config) {
    _log('_buildTtsPaths for: ${config.name}');

    // TTS models have model.onnx and tokens.txt
    // Some models (Piper, Coqui, MMS) also need espeak-ng-data
    final model = config.requiredFiles.firstWhere(
      (f) => f.endsWith('.onnx'),
      orElse: () => '',
    );
    final tokens = config.requiredFiles.firstWhere(
      (f) => f.contains('tokens'),
      orElse: () => '',
    );

    _log('  requiredFiles: ${config.requiredFiles}');
    _log('  Found model: $model');
    _log('  Found tokens: $tokens');

    // Determine if model is espeak-based (needs espeak-ng-data directory)
    // Piper, Coqui, and MMS models require espeak-ng-data
    // Kokoro, Kitten, Matcha, Melo do NOT need it
    final name = config.name.toLowerCase();
    final isEspeakBased =
        name.contains('piper') ||
        name.contains('coqui') ||
        name.contains('mms');

    _log('  isEspeakBased: $isEspeakBased');

    // For espeak-based models, use espeak-ng-data; for others, empty string
    final dataDir = isEspeakBased ? 'espeak-ng-data' : '';

    final paths = {
      'model': model.isNotEmpty ? '$dirPath/$model' : '',
      'tokens': tokens.isNotEmpty ? '$dirPath/$tokens' : '',
      'dataDir': dataDir.isNotEmpty ? '$dirPath/$dataDir' : '',
      'modelDir': dirPath,
    };

    _log('  TTS paths: $paths');

    // Verify files exist
    for (final entry in paths.entries) {
      if (entry.value.isNotEmpty && entry.key != 'modelDir') {
        final exists =
            File(entry.value).existsSync() ||
            Directory(entry.value).existsSync();
        _log('  Verify ${entry.key}: ${entry.value} -> exists: $exists');
      }
    }

    return paths;
  }

  Map<String, String> _buildVadPaths(String dirPath, AiModelConfig config) {
    final model = config.requiredFiles.firstWhere(
      (f) => f.endsWith('.onnx'),
      orElse: () => '',
    );

    return {
      'model': model.isNotEmpty ? '$dirPath/$model' : '',
      'modelDir': dirPath,
    };
  }

  Map<String, String> _buildSpeakerIdPaths(
    String dirPath,
    AiModelConfig config,
  ) {
    final model = config.requiredFiles.firstWhere(
      (f) => f.endsWith('.onnx'),
      orElse: () => '',
    );

    return {
      'model': model.isNotEmpty ? '$dirPath/$model' : '',
      'modelDir': dirPath,
    };
  }

  /// Gets downloaded models by category.
  Future<List<AiModelType>> getDownloadedModelsByCategory(
    String category,
  ) async {
    final downloaded = <AiModelType>[];
    for (final type in AiModelType.values) {
      final config = ModelRegistry.getConfig(type);
      if (config?.category == category && await isModelDownloaded(type)) {
        downloaded.add(type);
      }
    }
    return downloaded;
  }

  /// Downloads a specific model with progress callback.
  Future<void> downloadModel(
    AiModelType type, {
    required void Function(int received, int total) onProgress,
    void Function()? onExtractionStart,
  }) async {
    if (await isModelDownloaded(type)) return;

    final config = ModelRegistry.getConfig(type);
    if (config == null) throw ArgumentError('Unknown model type: $type');

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${config.archiveName}');
    final modelDir = await _getModelDir(type);

    // Clean up existing temp file
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    // Download
    await _dio.download(
      config.downloadUrl,
      tempFile.path,
      onReceiveProgress: onProgress,
    );

    onExtractionStart?.call();

    // Extract based on archive type
    try {
      if (config.archiveName.endsWith('.tar.bz2')) {
        await _extractTarBz2(
          archivePath: tempFile.path,
          outputDir: modelDir.path,
          requiredFiles: config.requiredFiles,
        );
      } else if (config.archiveName.endsWith('.onnx')) {
        // Single file model, just copy
        await modelDir.create(recursive: true);
        await tempFile.copy('${modelDir.path}/${config.archiveName}');
      }
    } finally {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    }
  }

  /// Deletes a specific model.
  Future<void> deleteModel(AiModelType type) async {
    final modelDir = await _getModelDir(type);
    if (modelDir.existsSync()) {
      await modelDir.delete(recursive: true);
    }
  }

  /// Extracts tar.bz2 archive in background.
  Future<void> _extractTarBz2({
    required String archivePath,
    required String outputDir,
    required List<String> requiredFiles,
  }) async {
    final params = _ExtractionParams(
      archivePath: archivePath,
      outputDir: outputDir,
      requiredFiles: requiredFiles,
    );
    await compute(_extractArchiveIsolate, params);
  }
}

/// Parameters for archive extraction.
class _ExtractionParams {
  const _ExtractionParams({
    required this.archivePath,
    required this.outputDir,
    required this.requiredFiles,
  });

  final String archivePath;
  final String outputDir;
  final List<String> requiredFiles;
}

/// Top-level function for extraction in isolate.
void _extractArchiveIsolate(_ExtractionParams params) {
  final tarPath = params.archivePath.replaceAll('.tar.bz2', '.tar');

  try {
    // Step 1: Decompress BZ2
    final bz2InputStream = InputFileStream(params.archivePath);
    final tarOutputStream = OutputFileStream(tarPath);

    try {
      BZip2Decoder().decodeStream(bz2InputStream, tarOutputStream);
    } finally {
      bz2InputStream.closeSync();
      tarOutputStream.closeSync();
    }

    // Step 2: Extract TAR
    final tarInputStream = InputFileStream(tarPath);

    try {
      final archive = TarDecoder().decodeStream(tarInputStream);
      final modelDir = Directory(params.outputDir);
      modelDir.createSync(recursive: true);

      for (final entry in archive) {
        // Find if this entry matches any required file or directory
        String? matchingReq;
        var isDirectoryMatch = false;

        for (final req in params.requiredFiles) {
          // Case A: Exact file match or file at end of path (e.g. "model.onnx")
          if (entry.name == req || entry.name.endsWith('/$req')) {
            matchingReq = req;
            isDirectoryMatch = false;
            break;
          }
          // Case B: Directory match (e.g. "espeak-ng-data" in ".../espeak-ng-data/file")
          if (entry.name.contains('$req/')) {
            matchingReq = req;
            isDirectoryMatch = true;
            break;
          }
        }

        if (matchingReq != null) {
          String outputPath;
          if (isDirectoryMatch) {
            // Preserve structure starting from the required directory
            // e.g. ".../espeak-ng-data/subdir/file" -> "espeak-ng-data/subdir/file"
            final index = entry.name.indexOf(matchingReq);
            final relativePath = entry.name.substring(index);
            outputPath = '${params.outputDir}/$relativePath';
          } else {
            // Flatten file (old behavior for individual files)
            final fileName = entry.name.split('/').last;
            outputPath = '${params.outputDir}/$fileName';
          }

          if (entry.isDirectory) {
            Directory(outputPath).createSync(recursive: true);
          } else {
            // Ensure parent directory exists for the file
            final parentDir = Directory(outputPath).parent;
            if (!parentDir.existsSync()) {
              parentDir.createSync(recursive: true);
            }

            final outputStream = OutputFileStream(outputPath);
            entry.writeContent(outputStream);
            outputStream.closeSync();
          }
        }
      }
    } finally {
      tarInputStream.closeSync();
    }
  } finally {
    final tarFile = File(tarPath);
    if (tarFile.existsSync()) {
      tarFile.deleteSync();
    }
  }
}

/// Paths to model files.
class ModelPaths {
  const ModelPaths({
    required this.encoder,
    required this.decoder,
    required this.tokens,
  });

  final String encoder;
  final String decoder;
  final String tokens;
}
