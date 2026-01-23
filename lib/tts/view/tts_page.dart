// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:w_zentyar_app/tts/cubit/tts_cubit.dart';
// import 'package:w_zentyar_app/tts/cubit/tts_state.dart';
// import 'package:w_zentyar_app/tts/services/tts_service.dart';

// /// TTS page following Very Good Page/View pattern.
// class TtsPage extends StatelessWidget {
//   const TtsPage({required this.modelPaths, super.key});

//   final TtsPaths modelPaths;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => TtsCubit(ttsService: TtsService())..initialize(modelPaths),
//       child: const TtsView(),
//     );
//   }
// }

// /// TTS view with text input and playback controls.
// class TtsView extends StatefulWidget {
//   const TtsView({super.key});

//   @override
//   State<TtsView> createState() => _TtsViewState();
// }

// class _TtsViewState extends State<TtsView> {
//   final _textController = TextEditingController();
//   final _audioPlayer = AudioPlayer();
//   double _speed = 1;

//   @override
//   void dispose() {
//     _textController.dispose();
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Text to Speech'),
//         centerTitle: true,
//       ),
//       body: BlocConsumer<TtsCubit, TtsState>(
//         listener: (context, state) async {
//           if (state is TtsGenerated) {
//             // Auto-play generated audio
//             await _audioPlayer.play(DeviceFileSource(state.audioPath));
//           } else if (state is TtsError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           return switch (state) {
//             TtsInitial() || TtsLoading() => const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading TTS model...'),
//                 ],
//               ),
//             ),
//             TtsError(:final message) => Center(
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
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: () => context.read<TtsCubit>().reset(),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             _ => _buildReadyView(context, state),
//           };
//         },
//       ),
//     );
//   }

//   Widget _buildReadyView(BuildContext context, TtsState state) {
//     final isGenerating = state is TtsGenerating;

//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Text input
//           TextField(
//             controller: _textController,
//             decoration: const InputDecoration(
//               labelText: 'Enter text to speak',
//               hintText: 'Type something...',
//               border: OutlineInputBorder(),
//             ),
//             maxLines: 5,
//             enabled: !isGenerating,
//           ),
//           const SizedBox(height: 16),

//           // Speed slider
//           Row(
//             children: [
//               const Text('Speed:'),
//               Expanded(
//                 child: Slider(
//                   value: _speed,
//                   min: 0.5,
//                   max: 2,
//                   divisions: 6,
//                   label: '${_speed.toStringAsFixed(1)}x',
//                   onChanged: isGenerating
//                       ? null
//                       : (value) => setState(() => _speed = value),
//                 ),
//               ),
//               Text('${_speed.toStringAsFixed(1)}x'),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Generate button
//           ElevatedButton.icon(
//             onPressed: isGenerating
//                 ? null
//                 : () {
//                     context.read<TtsCubit>().speak(
//                       text: _textController.text,
//                       speed: _speed,
//                     );
//                   },
//             icon: isGenerating
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Icons.volume_up),
//             label: Text(isGenerating ? 'Generating...' : 'Speak'),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.all(16),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Playback controls (shown after generation)
//           if (state is TtsGenerated) ...[
//             const Divider(),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton.filled(
//                   onPressed: () =>
//                       _audioPlayer.play(DeviceFileSource(state.audioPath)),
//                   icon: const Icon(Icons.play_arrow),
//                   iconSize: 32,
//                 ),
//                 const SizedBox(width: 16),
//                 IconButton.outlined(
//                   onPressed: _audioPlayer.stop,
//                   icon: const Icon(Icons.stop),
//                   iconSize: 32,
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
