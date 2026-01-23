import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_zentyar_app/core_ai/model_registry.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';
import 'package:w_zentyar_app/voice_interface/cubit/voice_interface_cubit.dart';
import 'package:w_zentyar_app/voice_interface/view/voice_orb_view.dart';

/// Page for the unified voice interface.
///
/// Follows the Very Good Page/View pattern.
class VoiceOrbPage extends StatelessWidget {
  /// Creates a voice orb page.
  const VoiceOrbPage({
    required this.modelType,
    super.key,
  });

  /// The AI model type to use.
  final AiModelType modelType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceInterfaceCubit(
        modelRepository: context.read<ModelRepository>(),
      )..initialize(modelType),
      child: const VoiceOrbView(),
    );
  }
}
