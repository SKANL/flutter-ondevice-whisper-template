import 'package:flutter/material.dart';

/// Panel for VAD voice activity indicator.
class VadIndicatorPanel extends StatelessWidget {
  /// Creates a VAD indicator panel.
  const VadIndicatorPanel({
    required this.isSpeaking,
    super.key,
  });

  /// Whether voice activity is detected.
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSpeaking
                  ? Colors.purpleAccent.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSpeaking ? Colors.purpleAccent : Colors.white24,
                width: 2,
              ),
              boxShadow: isSpeaking
                  ? [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSpeaking ? Icons.mic : Icons.mic_none,
              size: 40,
              color: isSpeaking ? Colors.purpleAccent : Colors.white38,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSpeaking ? 'VOICE DETECTED' : 'LISTENING...',
            style: TextStyle(
              color: isSpeaking ? Colors.purpleAccent : Colors.white38,
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
