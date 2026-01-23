import 'package:flutter/material.dart';

/// Panel for displaying speaker identification result.
class SpeakerResultPanel extends StatelessWidget {
  /// Creates a speaker result panel.
  const SpeakerResultPanel({
    required this.speakerName,
    super.key,
  });

  /// The identified speaker name.
  final String speakerName;

  @override
  Widget build(BuildContext context) {
    final isKnown = speakerName != 'Unknown';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isKnown
                  ? Colors.tealAccent.withValues(alpha: 0.2)
                  : Colors.redAccent.withValues(alpha: 0.2),
              border: Border.all(
                color: isKnown ? Colors.tealAccent : Colors.redAccent,
                width: 2,
              ),
            ),
            child: Icon(
              isKnown ? Icons.person : Icons.person_off,
              size: 40,
              color: isKnown ? Colors.tealAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isKnown ? 'IDENTIFIED' : 'UNKNOWN',
            style: TextStyle(
              color: isKnown ? Colors.tealAccent : Colors.redAccent,
              fontSize: 12,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            speakerName,
            style: TextStyle(
              color: isKnown ? Colors.white : Colors.white54,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
