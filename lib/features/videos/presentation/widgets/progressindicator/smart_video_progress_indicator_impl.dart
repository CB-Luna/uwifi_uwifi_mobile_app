import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'progress_style_selector.dart';
import 'video_progress_indicator.dart';
import 'video_progress_indicator_neumorphism.dart';
import 'video_progress_indicator_minimal.dart';
import 'video_progress_indicator_gaming.dart';

/// Smart progress indicator that can dynamically switch between different styles
class SmartVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController? controller;
  final double size;
  final double strokeWidth;
  final ProgressIndicatorStyle initialStyle;

  const SmartVideoProgressIndicator({
    required this.controller, super.key,
    this.size = 120,
    this.strokeWidth = 6,
    this.initialStyle = ProgressIndicatorStyle.glassmorphism,
  });

  @override
  State<SmartVideoProgressIndicator> createState() =>
      _SmartVideoProgressIndicatorState();
}

class _SmartVideoProgressIndicatorState
    extends State<SmartVideoProgressIndicator> {
  late ProgressIndicatorStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.initialStyle;
  }

  @override
  void didUpdateWidget(SmartVideoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStyle != widget.initialStyle) {
      _currentStyle = widget.initialStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    switch (_currentStyle) {
      case ProgressIndicatorStyle.glassmorphism:
        return CustomVideoProgressIndicator(
          controller: widget.controller,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          progressColor: Colors.red,
        );

      case ProgressIndicatorStyle.neumorphism:
        return VideoProgressIndicatorNeumorphism(
          controller: widget.controller,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
        );

      case ProgressIndicatorStyle.minimal:
        return VideoProgressIndicatorMinimal(
          controller: widget.controller,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
        );

      case ProgressIndicatorStyle.gaming:
        return VideoProgressIndicatorGaming(
          controller: widget.controller,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
        );
    }
  }
}
