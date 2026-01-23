import 'package:flutter/material.dart';

/// Panel for displaying transcription results.
class TranscriptionPanel extends StatelessWidget {
  /// Creates a transcription panel.
  const TranscriptionPanel({
    required this.text,
    super.key,
    this.isPartial = false,
  });

  /// The transcription text to display.
  final String text;

  /// Whether this is partial (in-progress) text.
  final bool isPartial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isPartial)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'TRANSCRIBING',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                text.isEmpty ? 'Start speaking...' : text,
                style: TextStyle(
                  color: text.isEmpty
                      ? Colors.white24
                      : isPartial
                      ? Colors.white54
                      : Colors.white,
                  fontSize: text.isEmpty ? 16 : 20,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
