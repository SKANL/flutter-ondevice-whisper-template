import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_zentyar_app/l10n/l10n.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';
import 'package:w_zentyar_app/transcription/cubit/transcription_cubit.dart';
import 'package:w_zentyar_app/transcription/cubit/transcription_state.dart';
import 'package:w_zentyar_app/transcription/services/audio_recorder_service.dart';
import 'package:w_zentyar_app/transcription/services/whisper_service.dart';

/// Page for voice recording and transcription.
///
/// Follows the Very Good Page/View pattern.
class TranscriptionPage extends StatelessWidget {
  const TranscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TranscriptionCubit(
        audioRecorder: AudioRecorderService(),
        whisperService: WhisperService(),
        modelRepository: context.read<ModelRepository>(),
      )..initialize(),
      child: const TranscriptionView(),
    );
  }
}

/// View for the transcription page.
class TranscriptionView extends StatelessWidget {
  const TranscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transcriptionTitle),
        centerTitle: true,
        actions: [
          BlocBuilder<TranscriptionCubit, TranscriptionState>(
            builder: (context, state) {
              final hasTranscription = switch (state) {
                TranscriptionIdle(:final lastTranscription) =>
                  lastTranscription != null && lastTranscription.isNotEmpty,
                _ => false,
              };

              if (!hasTranscription) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  context.read<TranscriptionCubit>().clearTranscription();
                },
              );
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(child: _TranscriptionResult()),
            SizedBox(height: 24),
            _RecordButton(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TranscriptionResult extends StatelessWidget {
  const _TranscriptionResult();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranscriptionCubit, TranscriptionState>(
      builder: (context, state) {
        return switch (state) {
          TranscriptionInitializing() => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Inicializando modelo...'),
              ],
            ),
          ),
          TranscriptionIdle(:final lastTranscription) => _buildResult(
            context,
            lastTranscription,
          ),
          TranscriptionRecording(:final lastTranscription) =>
            _buildRecordingView(context, lastTranscription),
          TranscriptionProcessing(:final lastTranscription) =>
            _buildProcessingView(context, lastTranscription),
          TranscriptionFailure(:final message, :final lastTranscription) =>
            _buildErrorView(context, message, lastTranscription),
        };
      },
    );
  }

  Widget _buildResult(BuildContext context, String? transcription) {
    if (transcription == null || transcription.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Mantén presionado el botón para grabar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(
          transcription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildRecordingView(BuildContext context, String? lastTranscription) {
    return Column(
      children: [
        if (lastTranscription != null && lastTranscription.isNotEmpty)
          Expanded(child: _buildResult(context, lastTranscription))
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _PulsingMic(),
                  const SizedBox(height: 24),
                  Text(
                    'Grabando...',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suelta para transcribir',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProcessingView(BuildContext context, String? lastTranscription) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Transcribiendo...',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String message,
    String? lastTranscription,
  ) {
    return Column(
      children: [
        if (lastTranscription != null && lastTranscription.isNotEmpty)
          Expanded(child: _buildResult(context, lastTranscription))
        else
          const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _PulsingMic extends StatefulWidget {
  const _PulsingMic();

  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<_PulsingMic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              size: 50,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranscriptionCubit, TranscriptionState>(
      builder: (context, state) {
        final isRecording = state is TranscriptionRecording;
        final isProcessing = state is TranscriptionProcessing;
        final isInitializing = state is TranscriptionInitializing;
        final isDisabled = isProcessing || isInitializing;

        return GestureDetector(
          onLongPressStart: isDisabled
              ? null
              : (_) {
                  context.read<TranscriptionCubit>().startRecording();
                },
          onLongPressEnd: isDisabled
              ? null
              : (_) {
                  context
                      .read<TranscriptionCubit>()
                      .stopRecordingAndTranscribe();
                },
          onLongPressCancel: isDisabled
              ? null
              : () {
                  context.read<TranscriptionCubit>().cancelRecording();
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? 100 : 80,
            height: isRecording ? 100 : 80,
            decoration: BoxDecoration(
              color: isRecording
                  ? Colors.red
                  : isDisabled
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: isRecording
                  ? [
                      BoxShadow(
                        color: Colors.red.withAlpha(100),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isRecording ? Icons.mic : Icons.mic_none,
              size: isRecording ? 50 : 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
