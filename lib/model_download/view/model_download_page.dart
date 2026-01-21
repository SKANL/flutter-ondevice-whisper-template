import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_zentyar_app/l10n/l10n.dart';
import 'package:w_zentyar_app/model_download/cubit/model_download_cubit.dart';
import 'package:w_zentyar_app/model_download/cubit/model_download_state.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';
import 'package:w_zentyar_app/transcription/transcription.dart';

/// Page for downloading the Whisper AI model.
///
/// Follows the Very Good Page/View pattern:
/// - Page provides the Cubit via BlocProvider
/// - View builds the UI using BlocBuilder
class ModelDownloadPage extends StatelessWidget {
  const ModelDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModelDownloadCubit(
        modelRepository: context.read<ModelRepository>(),
      )..checkModelStatus(),
      child: const ModelDownloadView(),
    );
  }
}

/// View for the model download page.
class ModelDownloadView extends StatelessWidget {
  const ModelDownloadView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modelDownloadTitle),
        centerTitle: true,
      ),
      body: BlocConsumer<ModelDownloadCubit, ModelDownloadState>(
        listener: (context, state) {
          // Navigate to transcription when download is complete
          if (state is ModelDownloadSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => RepositoryProvider.value(
                  value: context.read<ModelRepository>(),
                  child: const TranscriptionPage(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: switch (state) {
                ModelDownloadInitial() => const SizedBox.shrink(),
                ModelDownloadChecking() => const _CheckingView(),
                ModelDownloadRequired() => const _RequiredView(),
                ModelDownloadInProgress(
                  :final progress,
                  :final downloadedBytes,
                  :final totalBytes,
                ) =>
                  _ProgressView(
                    progress: progress,
                    downloadedBytes: downloadedBytes,
                    totalBytes: totalBytes,
                  ),
                ModelDownloadExtracting() => const _ExtractingView(),
                ModelDownloadSuccess() => const _SuccessView(),
                ModelDownloadFailure(:final message) => _FailureView(
                  message: message,
                ),
              },
            ),
          );
        },
      ),
    );
  }
}

class _CheckingView extends StatelessWidget {
  const _CheckingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Verificando modelo...'),
      ],
    );
  }
}

class _RequiredView extends StatelessWidget {
  const _RequiredView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.download_rounded,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        Text(
          'Modelo de IA Requerido',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Para transcribir tu voz, necesitas descargar el modelo Whisper (~600 MB)',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () {
            context.read<ModelDownloadCubit>().downloadModel();
          },
          icon: const Icon(Icons.download),
          label: const Text('Descargar Modelo'),
        ),
      ],
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
  });

  final double progress;
  final int downloadedBytes;
  final int totalBytes;

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatBytes(downloadedBytes)} / ${_formatBytes(totalBytes)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        const Text('Descargando modelo...'),
      ],
    );
  }
}

class _ExtractingView extends StatelessWidget {
  const _ExtractingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Extrayendo modelo...'),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        Text('Modelo listo'),
      ],
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red,
        ),
        const SizedBox(height: 24),
        Text(
          'Error al descargar',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            context.read<ModelDownloadCubit>().retry();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }
}
