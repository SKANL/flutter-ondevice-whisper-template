// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:w_zentyar_app/speaker_id/cubit/speaker_id_cubit.dart';
// import 'package:w_zentyar_app/speaker_id/cubit/speaker_id_state.dart';
// import 'package:w_zentyar_app/speaker_id/services/speaker_id_service.dart';

// /// Speaker ID page following Very Good Page/View pattern.
// class SpeakerIdPage extends StatelessWidget {
//   const SpeakerIdPage({required this.modelPath, super.key});

//   final String modelPath;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => SpeakerIdCubit(
//         speakerIdService: SpeakerIdService(),
//       )..initialize(modelPath),
//       child: const SpeakerIdView(),
//     );
//   }
// }

// /// Speaker ID view.
// class SpeakerIdView extends StatefulWidget {
//   const SpeakerIdView({super.key});

//   @override
//   State<SpeakerIdView> createState() => _SpeakerIdViewState();
// }

// class _SpeakerIdViewState extends State<SpeakerIdView> {
//   final _nameController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Speaker Identification'),
//         centerTitle: true,
//       ),
//       body: BlocBuilder<SpeakerIdCubit, SpeakerIdState>(
//         builder: (context, state) {
//           return switch (state) {
//             SpeakerIdInitial() || SpeakerIdLoading() => const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading speaker model...'),
//                 ],
//               ),
//             ),
//             SpeakerIdError(:final message) => Center(
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
//             SpeakerIdReady(:final registeredSpeakers, :final lastResult) =>
//               _buildReadyView(context, registeredSpeakers, lastResult),
//             SpeakerIdRecording(:final mode) => _buildRecordingView(
//               context,
//               mode,
//             ),
//             SpeakerIdProcessing() => const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Processing audio...'),
//                 ],
//               ),
//             ),
//           };
//         },
//       ),
//     );
//   }

//   Widget _buildReadyView(
//     BuildContext context,
//     List<String> registeredSpeakers,
//     String? lastResult,
//   ) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Last result
//           if (lastResult != null) ...[
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primaryContainer,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     lastResult.startsWith('Identified')
//                         ? Icons.check_circle
//                         : lastResult.startsWith('Registered')
//                         ? Icons.person_add
//                         : Icons.help_outline,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       lastResult,
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],

//           // Register section
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Register New Speaker',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Speaker Name',
//                       hintText: 'Enter name...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       if (_nameController.text.trim().isNotEmpty) {
//                         context.read<SpeakerIdCubit>().startRegisterRecording(
//                           _nameController.text.trim(),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.person_add),
//                     label: const Text('Record Voice'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Verify section
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Verify Speaker',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: registeredSpeakers.isEmpty
//                         ? null
//                         : () {
//                             context
//                                 .read<SpeakerIdCubit>()
//                                 .startVerifyRecording();
//                           },
//                     icon: const Icon(Icons.record_voice_over),
//                     label: const Text('Identify Speaker'),
//                   ),
//                   if (registeredSpeakers.isEmpty)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 8),
//                       child: Text(
//                         'Register at least one speaker first',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Registered speakers list
//           if (registeredSpeakers.isNotEmpty) ...[
//             Text(
//               'Registered Speakers',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: registeredSpeakers
//                   .map(
//                     (name) => Chip(
//                       avatar: const Icon(Icons.person, size: 18),
//                       label: Text(name),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildRecordingView(BuildContext context, SpeakerIdMode mode) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Recording indicator
//             Container(
//               width: 150,
//               height: 150,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red.withOpacity(0.2),
//               ),
//               child: const Icon(
//                 Icons.mic,
//                 size: 80,
//                 color: Colors.red,
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text(
//               mode == SpeakerIdMode.register
//                   ? 'Recording for registration...'
//                   : 'Recording for verification...',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),
//             const Text('Speak clearly for 3-5 seconds'),
//             const SizedBox(height: 32),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 OutlinedButton.icon(
//                   onPressed: () =>
//                       context.read<SpeakerIdCubit>().cancelRecording(),
//                   icon: const Icon(Icons.close),
//                   label: const Text('Cancel'),
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton.icon(
//                   onPressed: () =>
//                       context.read<SpeakerIdCubit>().stopRecording(),
//                   icon: const Icon(Icons.stop),
//                   label: const Text('Done'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
