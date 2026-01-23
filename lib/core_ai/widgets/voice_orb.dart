import 'package:flutter/material.dart';
import 'package:w_zentyar_app/core_ai/widgets/energy_orb_painter.dart';

/// Color schemes for different AI model types.
class OrbColorScheme {
  const OrbColorScheme({
    required this.primary,
    required this.secondary,
  });

  /// ASR (Speech-to-Text) color scheme.
  static const asr = OrbColorScheme(
    primary: Color(0xFF00FFFF),
    secondary: Color(0xFF9D00FF),
  );

  /// TTS (Text-to-Speech) color scheme.
  static const tts = OrbColorScheme(
    primary: Color(0xFFFF6B00),
    secondary: Color(0xFFFF00FF),
  );

  /// VAD (Voice Activity Detection) color scheme.
  static const vad = OrbColorScheme(
    primary: Color(0xFF9D00FF),
    secondary: Color(0xFF00FFFF),
  );

  /// Speaker ID color scheme.
  static const speakerId = OrbColorScheme(
    primary: Color(0xFF00FF88),
    secondary: Color(0xFF00FFFF),
  );

  /// Primary color for the orb.
  final Color primary;

  /// Secondary color for the orb.
  final Color secondary;
}

/// A holographic voice orb widget that responds to audio input.
///
/// This widget creates a pulsating, reactive energy orb that can be used
/// as the central interaction point for voice-based AI features.
class VoiceOrb extends StatefulWidget {
  /// Creates a voice orb widget.
  const VoiceOrb({
    required this.isActive,
    super.key,
    this.volume = 0.0,
    this.colorScheme = OrbColorScheme.asr,
    this.size = 250,
    this.onTap,
  });

  /// Whether the orb is actively listening/generating.
  final bool isActive;

  /// Current volume level (0.0 to 1.0).
  final double volume;

  /// Color scheme for the orb.
  final OrbColorScheme colorScheme;

  /// Size of the orb in logical pixels.
  final double size;

  /// Callback when the orb is tapped.
  final VoidCallback? onTap;

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _currentVolume = 0;
  double _targetVolume = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _startVolumeInterpolation();
  }

  @override
  void didUpdateWidget(VoiceOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _targetVolume = widget.volume;
  }

  void _startVolumeInterpolation() {
    _controller.addListener(_interpolateVolume);
  }

  void _interpolateVolume() {
    if (mounted) {
      setState(() {
        // Smooth spring-like interpolation
        _currentVolume += (_targetVolume - _currentVolume) * 0.15;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_interpolateVolume);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The animated orb
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: EnergyOrbPainter(
                animation: _controller,
                volume: widget.isActive ? _currentVolume : 0.0,
                primaryColor: widget.colorScheme.primary,
                secondaryColor: widget.colorScheme.secondary,
              ),
            ),
            // Center icon indicator
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: widget.isActive ? 0.0 : 0.5,
              child: Icon(
                Icons.mic,
                size: widget.size * 0.2,
                color: widget.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
