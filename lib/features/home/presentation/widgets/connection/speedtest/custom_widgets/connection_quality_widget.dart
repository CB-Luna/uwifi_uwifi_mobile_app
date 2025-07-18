// ignore_for_file: file_names

import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ConnectionQualityWidget extends StatefulWidget {
  final double downloadSpeed;
  final double uploadSpeed;
  final double latency;
  final Color primaryColor;
  final Color textColor;
  final Color backgroundColor;

  const ConnectionQualityWidget({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.latency,
    required this.primaryColor,
    required this.textColor,
    required this.backgroundColor,
    super.key,
  });

  @override
  State<ConnectionQualityWidget> createState() => _ConnectionQualityWidgetState();
}

class _ConnectionQualityWidgetState extends State<ConnectionQualityWidget> {
  late Map<String, int> _activityRatings;

  @override
  void initState() {
    super.initState();
    _activityRatings = _calculateRatings();
  }

  @override
  void didUpdateWidget(ConnectionQualityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.downloadSpeed != widget.downloadSpeed ||
        oldWidget.uploadSpeed != widget.uploadSpeed ||
        oldWidget.latency != widget.latency) {
      setState(() {
        _activityRatings = _calculateRatings();
      });
    }
  }

  Map<String, int> _calculateRatings() {
    final ratings = <String, int>{};

    // 1. Browsing (Navegación)
    if (widget.downloadSpeed > 20) {
      ratings['Browsing'] = 5;
    } else if (widget.downloadSpeed > 10) {
      ratings['Browsing'] = 4;
    } else if (widget.downloadSpeed > 5) {
      ratings['Browsing'] = 3;
    } else if (widget.downloadSpeed > 2) {
      ratings['Browsing'] = 2;
    } else if (widget.downloadSpeed > 1) {
      ratings['Browsing'] = 1;
    } else {
      ratings['Browsing'] = 0;
    }

    // 2. Gaming
    final gamingSpeed = widget.downloadSpeed < widget.uploadSpeed
        ? widget.downloadSpeed
        : widget.uploadSpeed;
    if (gamingSpeed > 25) {
      ratings['Gaming'] = 5;
    } else if (gamingSpeed > 15) {
      ratings['Gaming'] = 4;
    } else if (gamingSpeed > 8) {
      ratings['Gaming'] = 3;
    } else if (gamingSpeed > 4) {
      ratings['Gaming'] = 2;
    } else if (gamingSpeed > 2) {
      ratings['Gaming'] = 1;
    } else {
      ratings['Gaming'] = 0;
    }

    // 3. Streaming
    if (widget.downloadSpeed > 30) {
      ratings['Streaming'] = 5; // 4K
    } else if (widget.downloadSpeed > 15) {
      ratings['Streaming'] = 4; // 1080p
    } else if (widget.downloadSpeed > 8) {
      ratings['Streaming'] = 3; // 720p
    } else if (widget.downloadSpeed > 3) {
      ratings['Streaming'] = 2; // SD
    } else if (widget.downloadSpeed > 1.5) {
      ratings['Streaming'] = 1; // Baja calidad
    } else {
      ratings['Streaming'] = 0;
    }

    // 4. Video Call (Videollamada)
    if (widget.uploadSpeed > 10 && widget.downloadSpeed > 10) {
      ratings['Video Call'] = 5;
    } else if (widget.uploadSpeed > 5 && widget.downloadSpeed > 5) {
      ratings['Video Call'] = 4;
    } else if (widget.uploadSpeed > 3 && widget.downloadSpeed > 3) {
      ratings['Video Call'] = 3;
    } else if (widget.uploadSpeed > 1.5 && widget.downloadSpeed > 1.5) {
      ratings['Video Call'] = 2;
    } else if (widget.uploadSpeed > 0.8 && widget.downloadSpeed > 0.8) {
      ratings['Video Call'] = 1;
    } else {
      ratings['Video Call'] = 0;
    }

    return ratings;
  }

  String _getEmojiForRating(int rating) {
    switch (rating) {
      case 5:
        return '😍';
      case 4:
        return '😊';
      case 3:
        return '🙂';
      case 2:
        return '😐';
      case 1:
        return '😕';
      case 0:
      default:
        return '😢';
    }
  }

  Color _getColorForRating(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.deepOrange;
      case 0:
      default:
        return Colors.red;
    }
  }

  Widget _buildRatingItem(String activity, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              activity,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(
                5,
                (index) => Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index < rating
                        ? _getColorForRating(rating)
                        : Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getEmojiForRating(rating),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Quality',
            style: TextStyle(
              color: widget.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your speed test results:',
            style: TextStyle(
              color: widget.textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ..._activityRatings.entries
              .map((entry) => _buildRatingItem(entry.key, entry.value))
              .toList(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Download: ${widget.downloadSpeed.toStringAsFixed(1)} Mbps',
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Upload: ${widget.uploadSpeed.toStringAsFixed(1)} Mbps',
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (widget.latency > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Latency: ${widget.latency.toStringAsFixed(1)} ms',
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
