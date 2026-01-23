// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:w_zentyar_app/streaming_asr/cubit/streaming_asr_cubit.dart';
// import 'package:w_zentyar_app/streaming_asr/cubit/streaming_asr_state.dart';
// import 'package:w_zentyar_app/streaming_asr/services/streaming_asr_service.dart';

// /// Streaming ASR page following Very Good Page/View pattern.
// class StreamingAsrPage extends StatelessWidget {
//   const StreamingAsrPage({required this.modelPaths, super.key});

//   final StreamingAsrPaths modelPaths;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => StreamingAsrCubit(
//         streamingAsrService: StreamingAsrService(),
//       )..initialize(modelPaths),
//       child: const StreamingAsrView(),
//     );
//   }
// }

// /// Streaming ASR view with real-time transcription display.
// class StreamingAsrView extends StatelessWidget {
//   const StreamingAsrView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Real-time Transcription'),
//         centerTitle: true,
//       ),
//       body: BlocBuilder<StreamingAsrCubit, StreamingAsrState>(
//         builder: (context, state) {
//           return switch (state) {
//             StreamingAsrInitial() || StreamingAsrLoading() => const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading streaming ASR model...'),
//                 ],
//               ),
//             ),
//             StreamingAsrError(:final message) => Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       size: 64,
//                       color: Colors.red,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(message, textAlign: TextAlign.center),
//                   ],
//                 ),
//               ),
//             ),
//             StreamingAsrReady(:final lastTranscription) => _buildReadyView(
//               context,
//               lastTranscription,
//               '',
//               '',
//               false,
//             ),
//             StreamingAsrListening(:final partialText, :final finalizedText) =>
//               _buildReadyView(context, null, partialText, finalizedText, true),
//           };
//         },
//       ),
//     );
//   }

//   Widget _buildReadyView(
//     BuildContext context,
//     String? lastTranscription,
//     String partialText,
//     String finalizedText,
//     bool isListening,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Transcription display
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surfaceContainerHighest,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (isListening) ...[
//                       // Finalized text
//                       if (finalizedText.isNotEmpty)
//                         Text(
//                           finalizedText,
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                       // Partial text (in progress)
//                       if (partialText.isNotEmpty)
//                         Text(
//                           partialText,
//                           style: Theme.of(context).textTheme.bodyLarge
//                               ?.copyWith(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.primary.withOpacity(0.7),
//                                 fontStyle: FontStyle.italic,
//                               ),
//                         ),
//                       if (finalizedText.isEmpty && partialText.isEmpty)
//                         Text(
//                           'Listening...',
//                           style: Theme.of(context).textTheme.bodyLarge
//                               ?.copyWith(
//                                 color: Colors.grey,
//                                 fontStyle: FontStyle.italic,
//                               ),
//                         ),
//                     ] else if (lastTranscription != null) ...[
//                       Text(
//                         lastTranscription,
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                     ] else ...[
//                       Text(
//                         'Tap the button to start transcribing',
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Listening indicator
//           if (isListening)
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.red),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.fiber_manual_record,
//                       color: Colors.red,
//                       size: 12,
//                     ),
//                     SizedBox(width: 8),
//                     Text('Recording', style: TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               ),
//             ),
//           const SizedBox(height: 16),

//           // Control button
//           ElevatedButton.icon(
//             onPressed: () {
//               if (isListening) {
//                 context.read<StreamingAsrCubit>().stopListening();
//               } else {
//                 context.read<StreamingAsrCubit>().startListening();
//               }
//             },
//             icon: Icon(isListening ? Icons.stop : Icons.mic),
//             label: Text(isListening ? 'Stop' : 'Start Transcription'),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.all(16),
//               backgroundColor: isListening ? Colors.red : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
