import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_zentyar_app/core_ai/model_registry.dart';
import 'package:w_zentyar_app/model_download/model_download.dart';
import 'package:w_zentyar_app/voice_interface/voice_interface.dart';

/// Demo Hub - Central navigation for all AI features.
///
/// @deprecated The individual feature pages are deprecated.
/// All features now use the unified VoiceOrbPage.
class DemoHubPage extends StatefulWidget {
  const DemoHubPage({super.key});

  @override
  State<DemoHubPage> createState() => _DemoHubPageState();
}

class _DemoHubPageState extends State<DemoHubPage> {
  Map<String, List<AiModelType>>? _downloadedModels;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedModels();
  }

  Future<void> _loadDownloadedModels() async {
    final repo = context.read<ModelRepository>();
    final models = <String, List<AiModelType>>{};

    for (final category in ['ASR', 'TTS', 'VAD', 'Speaker ID']) {
      models[category] = await repo.getDownloadedModelsByCategory(category);
    }

    if (mounted) {
      setState(() {
        _downloadedModels = models;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Template Demo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Manage Models',
            onPressed: () => _navigateToModelManager(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDownloadedModels,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  _buildHeader(context),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Feature cards
                  _FeatureCard(
                    icon: Icons.mic,
                    title: 'Speech to Text',
                    description: _getModelDescription('ASR'),
                    color: Colors.cyan,
                    hasModel: _hasModels('ASR'),
                    onTap: () => _navigateToVoiceOrb(context, 'ASR'),
                  ),
                  _FeatureCard(
                    icon: Icons.volume_up,
                    title: 'Text to Speech',
                    description: _getModelDescription('TTS'),
                    color: Colors.orange,
                    hasModel: _hasModels('TTS'),
                    onTap: () => _navigateToVoiceOrb(context, 'TTS'),
                  ),
                  _FeatureCard(
                    icon: Icons.graphic_eq,
                    title: 'Voice Activity Detection',
                    description: _getModelDescription('VAD'),
                    color: Colors.purple,
                    hasModel: _hasModels('VAD'),
                    onTap: () => _navigateToVoiceOrb(context, 'VAD'),
                  ),
                  _FeatureCard(
                    icon: Icons.person_search,
                    title: 'Speaker Identification',
                    description: _getModelDescription('Speaker ID'),
                    color: Colors.teal,
                    hasModel: _hasModels('Speaker ID'),
                    onTap: () => _navigateToVoiceOrb(context, 'Speaker ID'),
                  ),
                  const SizedBox(height: 24),

                  // Manage models button
                  OutlinedButton.icon(
                    onPressed: () => _navigateToModelManager(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Manage AI Models'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info section
                  _buildInfoSection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Flutter AI Template',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by sherpa-onnx',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'About This Template',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'On-device AI using sherpa-onnx. '
            'All processing happens locally.',
          ),
        ],
      ),
    );
  }

  bool _hasModels(String category) {
    return _downloadedModels?[category]?.isNotEmpty ?? false;
  }

  String _getModelDescription(String category) {
    final models = _downloadedModels?[category] ?? [];
    if (models.isEmpty) {
      return 'No model downloaded';
    }
    final config = ModelRegistry.getConfig(models.first);
    return config?.name ?? 'Model ready';
  }

  void _navigateToVoiceOrb(BuildContext context, String category) {
    final models = _downloadedModels?[category] ?? [];

    if (models.isEmpty) {
      _showModelRequired(context, category);
      return;
    }

    // Use first downloaded model of this category
    final modelType = models.first;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider.value(
          value: context.read<ModelRepository>(),
          child: VoiceOrbPage(modelType: modelType),
        ),
      ),
    );
  }

  void _navigateToModelManager(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => RepositoryProvider.value(
              value: context.read<ModelRepository>(),
              child: const ModelDownloadPage(),
            ),
          ),
        )
        .then((_) => _loadDownloadedModels());
  }

  void _showModelRequired(BuildContext context, String category) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$category Model Required'),
        content: Text(
          'No $category model is downloaded. '
          'Go to Model Manager to download one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _navigateToModelManager(context);
            },
            child: const Text('Manage Models'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.hasModel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool hasModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: hasModel ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: hasModel ? color : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: hasModel ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: hasModel ? null : Colors.grey.shade500,
          ),
        ),
        trailing: hasModel
            ? const Icon(Icons.chevron_right)
            : Icon(Icons.download, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
