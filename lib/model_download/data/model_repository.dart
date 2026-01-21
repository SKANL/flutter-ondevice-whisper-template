import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Repository for downloading and managing the Whisper AI model.
///
/// Handles downloading from GitHub releases, extracting tar.bz2 archive,
/// and providing model file paths for sherpa_onnx.
class ModelRepository {
  ModelRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Model download URL from sherpa-onnx releases.
  static const String modelUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/'
      'asr-models/sherpa-onnx-whisper-small.tar.bz2';

  /// Model directory name.
  static const String modelDirName = 'sherpa-onnx-whisper-small';

  /// Temp file name for downloaded archive.
  static const String tempFileName = 'whisper-model.tar.bz2';

  /// Required model files.
  static const List<String> requiredFiles = [
    'small-encoder.int8.onnx',
    'small-decoder.int8.onnx',
    'small-tokens.txt',
  ];

  /// Gets the base directory for storing the model.
  Future<Directory> get _modelBaseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$modelDirName');
  }

  /// Gets the temp file path for the download.
  Future<File> get _tempArchiveFile async {
    final tempDir = await getTemporaryDirectory();
    return File('${tempDir.path}/$tempFileName');
  }

  /// Checks if the model is already downloaded and complete.
  Future<bool> isModelDownloaded() async {
    final modelDir = await _modelBaseDir;
    if (!modelDir.existsSync()) return false;

    for (final fileName in requiredFiles) {
      final file = File('${modelDir.path}/$fileName');
      if (!file.existsSync()) return false;
    }
    return true;
  }

  /// Gets the paths to the model files.
  ///
  /// Returns null if the model is not downloaded.
  Future<ModelPaths?> getModelPaths() async {
    if (!await isModelDownloaded()) return null;

    final modelDir = await _modelBaseDir;
    return ModelPaths(
      encoder: '${modelDir.path}/small-encoder.int8.onnx',
      decoder: '${modelDir.path}/small-decoder.int8.onnx',
      tokens: '${modelDir.path}/small-tokens.txt',
    );
  }

  /// Downloads the model with progress callback.
  ///
  /// [onProgress] is called with (received, total) bytes during download.
  /// [onExtractionStart] is called when extraction begins.
  Future<void> downloadModel({
    required void Function(int received, int total) onProgress,
    void Function()? onExtractionStart,
  }) async {
    // Check if already extracted
    if (await isModelDownloaded()) {
      return;
    }

    final tempFile = await _tempArchiveFile;
    final modelDir = await _modelBaseDir;

    // Always clean up any existing temp file to avoid corrupt files
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    // Download the archive
    await _dio.download(
      modelUrl,
      tempFile.path,
      onReceiveProgress: onProgress,
    );

    // Notify that extraction is starting
    onExtractionStart?.call();

    // Extract the archive in a separate isolate to avoid UI freeze
    try {
      await _extractInBackground(
        archivePath: tempFile.path,
        outputDir: modelDir.path,
      );
    } finally {
      // Always clean up temp file
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    }
  }

  /// Extracts the archive in a background isolate.
  Future<void> _extractInBackground({
    required String archivePath,
    required String outputDir,
  }) async {
    final params = _ExtractionParams(
      archivePath: archivePath,
      outputDir: outputDir,
      requiredFiles: requiredFiles,
    );

    await compute(_extractArchiveIsolate, params);
  }

  /// Deletes the downloaded model.
  Future<void> deleteModel() async {
    final modelDir = await _modelBaseDir;
    if (modelDir.existsSync()) {
      await modelDir.delete(recursive: true);
    }
  }
}

/// Parameters for archive extraction (must be serializable for isolate).
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
///
/// Uses TRUE streaming approach to minimize memory usage:
/// 1. Decompress BZ2 using InputFileStream → OutputFileStream (NO RAM load)
/// 2. Extract TAR using InputFileStream (streaming)
/// 3. Clean up .tar temp file
///
/// Must be top-level or static for compute() to work.
void _extractArchiveIsolate(_ExtractionParams params) {
  final tarPath = params.archivePath.replaceAll('.tar.bz2', '.tar');

  try {
    // Step 1: Decompress BZ2 using STREAMING (no full RAM load)
    // InputFileStream reads in chunks, OutputFileStream writes in chunks
    final bz2InputStream = InputFileStream(params.archivePath);
    final tarOutputStream = OutputFileStream(tarPath);

    try {
      // decodeStream reads from input stream and writes to output stream
      // This is TRUE streaming - never loads entire file into RAM
      BZip2Decoder().decodeStream(bz2InputStream, tarOutputStream);
    } finally {
      bz2InputStream.closeSync();
      tarOutputStream.closeSync();
    }

    // Step 2: Extract TAR using InputFileStream (streaming)
    final tarInputStream = InputFileStream(tarPath);

    try {
      final archive = TarDecoder().decodeStream(tarInputStream);

      // Create output directory
      final modelDir = Directory(params.outputDir);
      modelDir.createSync(recursive: true);

      // Extract only required files using streaming write
      for (final entry in archive) {
        final fileName = entry.name.split('/').last;

        if (params.requiredFiles.contains(fileName)) {
          final outputPath = '${params.outputDir}/$fileName';

          // Use OutputFileStream for memory-efficient writing
          final outputStream = OutputFileStream(outputPath);
          entry.writeContent(outputStream);
          outputStream.closeSync();
        }
      }
    } finally {
      tarInputStream.closeSync();
    }
  } finally {
    // Step 3: Clean up .tar temp file
    final tarFile = File(tarPath);
    if (tarFile.existsSync()) {
      tarFile.deleteSync();
    }
  }
}

/// Paths to the Whisper model files.
class ModelPaths {
  const ModelPaths({
    required this.encoder,
    required this.decoder,
    required this.tokens,
  });

  /// Path to the encoder ONNX file.
  final String encoder;

  /// Path to the decoder ONNX file.
  final String decoder;

  /// Path to the tokens file.
  final String tokens;
}
