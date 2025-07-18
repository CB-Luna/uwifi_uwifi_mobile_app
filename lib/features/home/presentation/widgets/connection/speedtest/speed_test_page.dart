import 'package:flutter/material.dart';

import 'custom_widgets/connection_quality_widget.dart';
import 'custom_widgets/speed_test_custom_widget_emoji.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SpeedTestCustomWidgetEmoji(
        primaryColor: Colors.green,
        secondaryColor: Colors.purple,
        textColor: Colors.black87,
        cardBackgroundColor: Colors.white,
        onTestCompleted:
            (
              downloadSpeedMbps,
              uploadSpeedMbps,
              ipAddress,
              ispName,
              asnName,
            ) async {
              // Aquí podríamos guardar los resultados o realizar alguna acción
              debugPrint('Test completado: $downloadSpeedMbps Mbps download, $uploadSpeedMbps Mbps upload');
            },
        onTestError: (errorMessage) async {
          debugPrint('Error en el test: $errorMessage');
        },
        // URLs de emojis para los diferentes niveles de velocidad
        redFaceUrl: 'https://em-content.zobj.net/source/google/387/crying-face_1f622.png',
        yellowFaceUrl: 'https://em-content.zobj.net/source/google/387/slightly-frowning-face_1f641.png',
        greenSmileFaceUrl: 'https://em-content.zobj.net/source/google/387/slightly-smiling-face_1f642.png',
        greenSmileFace2Url: 'https://em-content.zobj.net/source/google/387/grinning-face-with-smiling-eyes_1f604.png',
        greenSunglassesFaceUrl: 'https://em-content.zobj.net/source/google/387/star-struck_1f929.png',
        downloadGaugeMax: 100,
        uploadGaugeMax: 50,
      ),
    );
  }

  // Variables para almacenar los resultados del test de velocidad
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  double _latency = 0.0;
  bool _isAdvancedTesting = false;

  Widget _advancedTestView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Card para mostrar la IP y otros datos de red
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(Icons.language, 'IP Address', '--'),
                  _infoItem(Icons.router, 'ISP', '--'),
                  _infoItem(Icons.dns, 'ASN', '--'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Widget de calidad de conexión que muestra ratings para diferentes actividades
          ConnectionQualityWidget(
            downloadSpeed: _downloadSpeed,
            uploadSpeed: _uploadSpeed,
            latency: _latency,
            primaryColor: Colors.blue,
            textColor: Colors.black87,
            backgroundColor: Colors.white,
          ),
          const Spacer(),
          // Botón para iniciar el test avanzado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: ElevatedButton(
              onPressed: _isAdvancedTesting ? null : () {
                setState(() {
                  _isAdvancedTesting = true;
                });
                
                // Simulamos un test con un delay para mostrar progreso
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _downloadSpeed = 25.5; // Mbps
                    _uploadSpeed = 10.2; // Mbps
                    _latency = 15.0; // ms
                  });
                  
                  // Simulamos el fin del test
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _isAdvancedTesting = false;
                    });
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(_isAdvancedTesting ? 'Testing...' : 'Start Advanced Testing'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _infoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
