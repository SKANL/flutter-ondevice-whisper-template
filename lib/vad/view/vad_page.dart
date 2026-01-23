// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:w_zentyar_app/vad/cubit/vad_cubit.dart';
// import 'package:w_zentyar_app/vad/cubit/vad_state.dart';
// import 'package:w_zentyar_app/vad/services/vad_service.dart';

// /// VAD page following Very Good Page/View pattern.
// class VadPage extends StatelessWidget {
//   const VadPage({required this.modelPath, super.key});

//   final String modelPath;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => VadCubit(vadService: VadService())..initialize(modelPath),
//       child: const VadView(),
//     );
//   }
// }

// /// VAD view with voice activity visualization.
// class VadView extends StatelessWidget {
//   const VadView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Voice Activity Detection'),
//         centerTitle: true,
//       ),
//       body: BlocBuilder<VadCubit, VadState>(
//         builder: (context, state) {
//           return switch (state) {
//             VadInitial() || VadLoading() => const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading VAD model...'),
//                 ],
//               ),
//             ),
//             VadError(:final message) => Center(
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
//             VadReady() => _buildReadyView(context, false, 0),
//             VadListening(:final isSpeaking, :final speechDurationMs) =>
//               _buildReadyView(context, isSpeaking, speechDurationMs),
//           };
//         },
//       ),
//     );
//   }

//   Widget _buildReadyView(
//     BuildContext context,
//     bool isSpeaking,
//     int speechDurationMs,
//   ) {
//     final isListening = context.select<VadCubit, bool>(
//       (cubit) => cubit.state is VadListening,
//     );

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Voice activity indicator
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               width: isSpeaking ? 200 : 150,
//               height: isSpeaking ? 200 : 150,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isSpeaking
//                     ? Colors.green.withOpacity(0.8)
//                     : Colors.grey.withOpacity(0.3),
//                 boxShadow: isSpeaking
//                     ? [
//                         BoxShadow(
//                           color: Colors.green.withOpacity(0.5),
//                           blurRadius: 30,
//                           spreadRadius: 10,
//                         ),
//                       ]
//                     : null,
//               ),
//               child: Icon(
//                 isSpeaking ? Icons.mic : Icons.mic_off,
//                 size: 80,
//                 color: isSpeaking ? Colors.white : Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 32),

//             // Status text
//             Text(
//               isSpeaking
//                   ? 'Speaking...'
//                   : (isListening ? 'Listening...' : 'Ready'),
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),

//             // Speech duration
//             if (isListening)
//               Text(
//                 'Speech: ${(speechDurationMs / 1000).toStringAsFixed(1)}s',
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             const SizedBox(height: 48),

//             // Control button
//             ElevatedButton.icon(
//               onPressed: () {
//                 if (isListening) {
//                   context.read<VadCubit>().stopListening();
//                 } else {
//                   context.read<VadCubit>().startListening();
//                 }
//               },
//               icon: Icon(isListening ? Icons.stop : Icons.play_arrow),
//               label: Text(isListening ? 'Stop' : 'Start Listening'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 16,
//                 ),
//                 backgroundColor: isListening ? Colors.red : null,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
