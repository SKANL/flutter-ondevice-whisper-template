import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_zentyar_app/core_ai/model_registry.dart';
import 'package:w_zentyar_app/core_ai/widgets/voice_orb.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';
import 'package:w_zentyar_app/voice_interface/cubit/voice_interface_cubit.dart';
import 'package:w_zentyar_app/voice_interface/cubit/voice_interface_state.dart';
import 'package:w_zentyar_app/voice_interface/widgets/widgets.dart';

/// View for the unified voice interface.
class VoiceOrbView extends StatefulWidget {
  const VoiceOrbView({super.key});

  @override
  State<VoiceOrbView> createState() => _VoiceOrbViewState();
}

class _VoiceOrbViewState extends State<VoiceOrbView> {
  final _audioPlayer = AudioPlayer();
  final _textController = TextEditingController();

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevent keyboard from pushing up UI
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<VoiceInterfaceCubit, VoiceInterfaceState>(
          buildWhen: (p, c) => p.modelType != c.modelType,
          builder: (context, state) {
            return Text(
              _getTitle(state),
              style: const TextStyle(
                color: Colors.white70,
                letterSpacing: 2,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<VoiceInterfaceCubit, VoiceInterfaceState>(
            builder: (context, state) {
              final modelType = state.modelType;
              if (modelType == null) return const SizedBox.shrink();

              // Get category for current model
              final config = ModelRegistry.getConfig(modelType);
              final category = config?.category;
              if (category == null) return const SizedBox.shrink();

              return FutureBuilder<List<AiModelType>>(
                future: context
                    .read<ModelRepository>()
                    .getDownloadedModelsByCategory(category),
                builder: (context, snapshot) {
                  final models = snapshot.data ?? [];
                  if (models.isEmpty || models.length <= 1) {
                    return const SizedBox.shrink();
                  }

                  return PopupMenuButton<AiModelType>(
                    icon: const Icon(Icons.swap_horiz, color: Colors.white70),
                    tooltip: 'Switch Model',
                    onSelected: (type) {
                      context.read<VoiceInterfaceCubit>().initialize(type);
                    },
                    itemBuilder: (context) {
                      return models.map((type) {
                        final config = ModelRegistry.getConfig(type);
                        return PopupMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              if (type == modelType)
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.green,
                                )
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  config?.name ?? '',
                                  style: TextStyle(
                                    fontWeight: type == modelType
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF0A0015), Colors.black],
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<VoiceInterfaceCubit, VoiceInterfaceState>(
            listener: (context, state) {
              // Play audio when TTS completes
              if (state is VoiceInterfaceResult && state.audioPath != null) {
                unawaited(
                  _audioPlayer.play(DeviceFileSource(state.audioPath!)),
                );
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Determine layout based on height
                  // Use more concise vertical layout for landscape or small screens
                  final isSmallHeight = constraints.maxHeight < 600;

                  return Column(
                    children: [
                      // Top panel (results/input)
                      Expanded(
                        flex: isSmallHeight ? 3 : 2,
                        child: _buildTopPanel(context, state),
                      ),
                      // Voice Orb (Centerpiece)
                      Expanded(
                        flex: isSmallHeight ? 2 : 3,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.8,
                              maxHeight: constraints.maxHeight * 0.4,
                            ),
                            child: FittedBox(
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: _buildOrb(context, state),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom panel (controls)
                      Expanded(
                        flex: isSmallHeight ? 1 : 2,
                        child: _buildBottomPanel(context, state),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _getTitle(VoiceInterfaceState state) {
    return switch (state.category) {
      'ASR' => 'TRANSCRIPTION',
      'TTS' => 'SPEECH SYNTHESIS',
      'VAD' => 'VOICE DETECTION',
      'Speaker ID' => 'SPEAKER ID',
      _ => 'VOICE INTERFACE',
    };
  }

  OrbColorScheme _getColorScheme(VoiceInterfaceState state) {
    return switch (state.category) {
      'ASR' => OrbColorScheme.asr,
      'TTS' => OrbColorScheme.tts,
      'VAD' => OrbColorScheme.vad,
      'Speaker ID' => OrbColorScheme.speakerId,
      _ => OrbColorScheme.asr,
    };
  }

  Widget _buildOrb(BuildContext context, VoiceInterfaceState state) {
    final isActive =
        state is VoiceInterfaceListening || state is VoiceInterfaceProcessing;
    final volume = state is VoiceInterfaceListening ? state.volume : 0.0;

    return VoiceOrb(
      isActive: isActive,
      volume: volume,
      colorScheme: _getColorScheme(state),
      onTap: () => _handleOrbTap(context, state),
    );
  }

  void _handleOrbTap(BuildContext context, VoiceInterfaceState state) {
    final cubit = context.read<VoiceInterfaceCubit>();

    if (state is VoiceInterfaceListening) {
      unawaited(cubit.stopListening());
    } else if (state is VoiceInterfaceReady) {
      if (state.category == 'TTS') {
        // TTS uses text input, not tap
        return;
      }
      unawaited(cubit.startListening());
    } else if (state is VoiceInterfaceResult) {
      cubit.reset();
    }
  }

  Widget _buildTopPanel(BuildContext context, VoiceInterfaceState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (state) {
        VoiceInterfaceInitial() => const SizedBox.shrink(),
        VoiceInterfaceLoading(:final message) => _buildMessage(message),
        VoiceInterfaceReady(:final lastResult) when lastResult != null =>
          TranscriptionPanel(text: lastResult),
        VoiceInterfaceReady(:final category) when category == 'TTS' =>
          TextInputPanel(
            controller: _textController,
            onSubmit: (text) =>
                context.read<VoiceInterfaceCubit>().synthesize(text),
          ),
        VoiceInterfaceListening(:final partialText, :final isSpeaking) =>
          _buildListeningPanel(state.category, partialText, isSpeaking),
        VoiceInterfaceProcessing(:final message) => _buildMessage(message),
        VoiceInterfaceResult(
          :final transcription,
          :final speakerName,
          :final audioPath,
        ) =>
          _buildResultPanel(
            state.category,
            transcription,
            speakerName,
            audioPath,
          ),
        VoiceInterfaceError(:final message) => _buildError(message),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildListeningPanel(
    String? category,
    String? partialText,
    bool isSpeaking,
  ) {
    return switch (category) {
      'ASR' => TranscriptionPanel(
        text: partialText ?? '',
        isPartial: true,
      ),
      'VAD' => VadIndicatorPanel(isSpeaking: isSpeaking),
      'Speaker ID' => const Center(
        child: Text(
          'Recording...',
          style: TextStyle(color: Colors.white54),
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildResultPanel(
    String? category,
    String? transcription,
    String? speakerName,
    String? audioPath,
  ) {
    return switch (category) {
      'ASR' => TranscriptionPanel(text: transcription ?? ''),
      'Speaker ID' => SpeakerResultPanel(speakerName: speakerName ?? 'Unknown'),
      'TTS' when audioPath != null => const Center(
        child: Icon(
          Icons.play_circle_filled,
          size: 48,
          color: Colors.white54,
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, VoiceInterfaceState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status indicator
          _buildStatusIndicator(state),
          const SizedBox(height: 24),
          // Action hint
          Text(
            _getActionHint(state),
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(VoiceInterfaceState state) {
    final color = _getColorScheme(state).primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(24),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        _getStatusText(state),
        style: TextStyle(
          color: color,
          fontSize: 14,
          letterSpacing: 2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusText(VoiceInterfaceState state) {
    return switch (state) {
      VoiceInterfaceInitial() => 'INITIALIZING',
      VoiceInterfaceLoading() => 'LOADING',
      VoiceInterfaceReady() => 'READY',
      VoiceInterfaceListening() => 'LISTENING',
      VoiceInterfaceProcessing() => 'PROCESSING',
      VoiceInterfaceResult() => 'COMPLETE',
      VoiceInterfaceError() => 'ERROR',
    };
  }

  String _getActionHint(VoiceInterfaceState state) {
    return switch (state) {
      VoiceInterfaceReady(:final category) when category == 'TTS' =>
        'ENTER TEXT ABOVE TO SYNTHESIZE',
      VoiceInterfaceReady() => 'TAP ORB TO BEGIN',
      VoiceInterfaceListening() => 'TAP ORB TO STOP',
      VoiceInterfaceResult() => 'TAP ORB TO RESET',
      _ => '',
    };
  }
}
