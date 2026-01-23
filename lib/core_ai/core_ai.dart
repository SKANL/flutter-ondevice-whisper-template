/// Core AI module for sherpa-onnx integration.
///
/// Provides shared infrastructure for all AI features including:
/// - [IsolateManager] for background processing
/// - Model registry and download utilities
/// - Voice Orb widgets for unified interface
library;

import 'package:w_zentyar_app/core_ai/core_ai.dart' show IsolateManager;
import 'package:w_zentyar_app/core_ai/isolate_manager.dart' show IsolateManager;

export 'isolate_manager.dart';
export 'model_registry.dart';
export 'widgets/widgets.dart';
