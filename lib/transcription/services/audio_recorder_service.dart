import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Service for recording audio from the microphone.
///
/// Records in WAV format at 16kHz sample rate as required by Whisper.
class AudioRecorderService {
  AudioRecorderService();

  AudioRecorder? _recorder;
  String? _currentRecordingPath;

  /// Checks if microphone permission is granted.
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Requests microphone permission.
  ///
  /// Returns true if permission is granted.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Starts recording audio.
  ///
  /// Returns the path where the recording will be saved.
  /// Throws if permission is not granted.
  Future<String> startRecording() async {
    // Check permission
    final hasAccess = await hasPermission();
    if (!hasAccess) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Microphone permission denied');
      }
    }

    // Initialize recorder
    _recorder = AudioRecorder();

    // Get temp directory for recording
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentRecordingPath = '${tempDir.path}/recording_$timestamp.wav';

    // Start recording with Whisper-compatible settings
    // Whisper requires: 16kHz sample rate, mono, 16-bit PCM
    await _recorder!.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: _currentRecordingPath!,
    );

    return _currentRecordingPath!;
  }

  /// Stops recording and returns the path to the recorded file.
  ///
  /// Returns null if no recording is in progress.
  Future<String?> stopRecording() async {
    if (_recorder == null) return null;

    final path = await _recorder!.stop();
    await _recorder!.dispose();
    _recorder = null;

    // Verify file exists
    if (path != null && await File(path).exists()) {
      return path;
    }

    return _currentRecordingPath;
  }

  /// Cancels the current recording without saving.
  Future<void> cancelRecording() async {
    if (_recorder == null) return;

    await _recorder!.cancel();
    await _recorder!.dispose();
    _recorder = null;

    // Delete temp file if exists
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _currentRecordingPath = null;
  }

  /// Checks if currently recording.
  Future<bool> isRecording() async {
    if (_recorder == null) return false;
    return _recorder!.isRecording();
  }

  /// Disposes all resources.
  Future<void> dispose() async {
    await _recorder?.dispose();
    _recorder = null;
  }
}
