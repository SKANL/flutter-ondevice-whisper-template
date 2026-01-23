import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_zentyar_app/core_ai/model_registry.dart';

import 'package:w_zentyar_app/demo_hub/demo_hub.dart';
import 'package:w_zentyar_app/model_download/cubit/model_download_cubit.dart';
import 'package:w_zentyar_app/model_download/cubit/model_download_state.dart';
import 'package:w_zentyar_app/model_download/data/model_repository.dart';

/// Page for managing AI models.
class ModelDownloadPage extends StatelessWidget {
  const ModelDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModelManagerCubit(
        modelRepository: context.read<ModelRepository>(),
      )..loadModelStatuses(),
      child: const ModelManagerView(),
    );
  }
}

/// Alias for backward compatibility.
typedef ModelManagerPage = ModelDownloadPage;

/// View for the model manager.
class ModelManagerView extends StatefulWidget {
  const ModelManagerView({super.key});

  @override
  State<ModelManagerView> createState() => _ModelManagerViewState();
}

class _ModelManagerViewState extends State<ModelManagerView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    // Get unique categories and sort them
    _categories = ModelRegistry.categories..sort();
    // Add 'All' as the first option if not present (logic handled in build)
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total tabs = All + specific categories
    final tabs = ['All', ..._categories];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: _buildSearchBar(),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: tabs.map((c) => Tab(text: c)).toList(),
          ),
        ),
        body: BlocBuilder<ModelManagerCubit, ModelManagerState>(
          builder: (context, state) {
            return switch (state) {
              ModelManagerInitial() || ModelManagerLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ModelManagerError(:final message) => _ErrorView(message: message),
              ModelManagerReady() => TabBarView(
                children: tabs.map((category) {
                  return _ModelList(
                    state: state,
                    category: category,
                    searchQuery: _searchQuery,
                  );
                }).toList(),
              ),
            };
          },
        ),
        floatingActionButton: BlocBuilder<ModelManagerCubit, ModelManagerState>(
          builder: (context, state) {
            final isReady = state is ModelManagerReady;
            final isDownloading = isReady && state.downloadingModel != null;

            return FloatingActionButton.extended(
              onPressed: isDownloading
                  ? null
                  : () => _navigateToDemoHub(context),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue to App'),
              backgroundColor: isDownloading ? Colors.grey : null,
            );
          },
        ),
      ),
    );
  }

  void _navigateToDemoHub(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider.value(
          value: context.read<ModelRepository>(),
          child: const DemoHubPage(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search models...',
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class _ModelList extends StatelessWidget {
  const _ModelList({
    required this.state,
    required this.category,
    required this.searchQuery,
  });

  final ModelManagerReady state;
  final String category;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    // Filter models
    final allModels = ModelRegistry.allModels;
    final filteredModels = allModels.where((model) {
      // 1. Category filter
      if (category != 'All' && model.category != category) {
        return false;
      }
      // 2. Search filter
      if (searchQuery.isNotEmpty &&
          !model.name.toLowerCase().contains(searchQuery)) {
        return false;
      }
      return true;
    }).toList();

    if (filteredModels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No models found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredModels.length,
            itemBuilder: (context, index) {
              final model = filteredModels[index];
              final isDownloaded = state.modelStatuses[model.type] ?? false;
              final isDownloading = state.downloadingModel == model.type;

              return _ModelCard(
                model: model,
                isDownloaded: isDownloaded,
                isDownloading: isDownloading,
                progress: isDownloading ? state.downloadProgress : null,
                isExtracting: isDownloading && state.isExtracting,
                onDownload: () {
                  context.read<ModelManagerCubit>().downloadModel(model.type);
                },
                onDelete: () {
                  _confirmDelete(context, model);
                },
              );
            },
          ),
        ),
        // Show "Continue" only on "All" tab or if we want it global
        // It's safer to have it accessible. Since this is inside TabBarView,
        // we might want to put FloatingActionButton or BottomSheet instead.
        // For now, let's keep it simple: if the user downloaded something,
        // they can navigate back via back button or we add a FAB.
        // The original code had a big button at bottom.
        // Let's us a FAB for "Go to Demo Hub" if we are not downloading.
      ],
    );
  }

  void _confirmDelete(BuildContext context, AiModelConfig model) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Model?'),
        content: Text('Are you sure you want to delete ${model.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ModelManagerCubit>().deleteModel(model.type);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    required this.isDownloaded,
    required this.isDownloading,
    required this.progress,
    required this.isExtracting,
    required this.onDownload,
    required this.onDelete,
  });

  final AiModelConfig model;
  final bool isDownloaded;
  final bool isDownloading;
  final double? progress;
  final bool isExtracting;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDownloaded
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDownloaded ? Icons.check_circle : Icons.cloud_download,
                    color: isDownloaded ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                // Model info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '~${model.sizeEstimateMb} MB',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                if (isDownloading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (isDownloaded)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  )
                else
                  FilledButton.tonal(
                    onPressed: onDownload,
                    child: const Text('Download'),
                  ),
              ],
            ),
            // Download progress
            if (isDownloading && !isExtracting && progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 4),
              Text(
                '${(progress! * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (isExtracting) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 4),
              Text(
                'Extracting...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<ModelManagerCubit>().retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
