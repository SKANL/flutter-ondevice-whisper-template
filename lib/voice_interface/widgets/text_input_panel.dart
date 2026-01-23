import 'package:flutter/material.dart';

/// Panel for text input (TTS).
class TextInputPanel extends StatelessWidget {
  /// Creates a text input panel.
  const TextInputPanel({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  /// Text controller for the input field.
  final TextEditingController controller;

  /// Callback when text is submitted.
  final void Function(String text) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ENTER TEXT TO SYNTHESIZE',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orangeAccent.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.orangeAccent.withValues(alpha: 0.05),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                hintText: 'Type something...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.orangeAccent,
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      onSubmit(controller.text);
                      controller.clear();
                    }
                  },
                ),
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  onSubmit(text);
                  controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
