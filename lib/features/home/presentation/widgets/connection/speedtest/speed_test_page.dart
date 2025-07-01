import 'package:flutter/material.dart';
import 'dart:math';

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});

  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  bool isAdvanced = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Test'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => isAdvanced = false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isAdvanced ? Colors.black : Colors.green,
                      side: BorderSide(
                        color: isAdvanced ? Colors.grey.shade300 : Colors.green,
                      ),
                      backgroundColor: isAdvanced
                          ? Colors.grey.shade100
                          : Colors.white,
                    ),
                    child: const Text('Speed Test'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => isAdvanced = true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isAdvanced ? Colors.green : Colors.black,
                      side: BorderSide(
                        color: isAdvanced ? Colors.green : Colors.grey.shade300,
                      ),
                      backgroundColor: isAdvanced
                          ? Colors.white
                          : Colors.grey.shade100,
                    ),
                    child: const Text('Advanced Test'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: isAdvanced ? _advancedTestView() : _speedTestView()),
        ],
      ),
    );
  }

  Widget _speedTestView() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.language, color: Colors.grey),
              SizedBox(width: 8),
              Text('IP Address: --', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Download',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _gaugeWidget(color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'Upload',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _gaugeWidget(color: Colors.purple),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Start Testing'),
          ),
        ),
      ],
    );
  }

  Widget _advancedTestView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoBox(Icons.language, 'IP Address', '--'),
              _infoBox(Icons.dns, 'ASN', '--'),
              _infoBox(Icons.router, 'ISP', '--'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Download',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Upload',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _advancedGaugeWidget(color: Colors.green),
              _advancedGaugeWidget(color: Colors.purple),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Start Testing'),
          ),
        ),
      ],
    );
  }

  Widget _gaugeWidget({required Color color}) {
    // Mock de velocímetro con caritas
    return SizedBox(
      height: 120,
      width: 200,
      child: CustomPaint(painter: _GaugePainter(color: color)),
    );
  }

  Widget _advancedGaugeWidget({required Color color}) {
    // Mock de velocímetro avanzado
    return SizedBox(
      height: 100,
      width: 100,
      child: CustomPaint(painter: _GaugePainter(color: color, advanced: true)),
    );
  }

  Widget _infoBox(IconData icon, String label, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final Color color;
  final bool advanced;
  _GaugePainter({required this.color, this.advanced = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 12;
    // Semicírculo
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14,
      3.14,
      false,
      paint,
    );
    // Aguja
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final angle = 3.14 + 3.14 * 0.3; // Mock posición
    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * -1 * cos(angle),
      center.dy + needleLength * -1 * sin(angle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);
    // Caritas (solo en modo normal)
    if (!advanced) {
      final emojiStyle = const TextStyle(fontSize: 18);
      final emojis = ['😡', '😕', '🙂', '😀', '😎'];
      for (int i = 0; i < emojis.length; i++) {
        final emojiAngle = 3.14 + (3.14 / (emojis.length - 1)) * i;
        final emojiOffset = Offset(
          center.dx + (radius - 18) * -1 * cos(emojiAngle),
          center.dy + (radius - 18) * -1 * sin(emojiAngle),
        );
        final tp = TextPainter(
          text: TextSpan(text: emojis[i], style: emojiStyle),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, emojiOffset - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
