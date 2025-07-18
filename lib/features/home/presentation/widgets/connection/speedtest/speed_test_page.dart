import 'package:flutter/material.dart';

import 'custom_widgets/speed_test_custom_widget.dart';
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
              debugPrint(
                'Test completado: $downloadSpeedMbps Mbps download, $uploadSpeedMbps Mbps upload',
              );
            },
        onTestError: (errorMessage) async {
          debugPrint('Error en el test: $errorMessage');
        },
        // URLs de emojis para los diferentes niveles de velocidad
        redFaceUrl:
            'https://em-content.zobj.net/source/google/387/crying-face_1f622.png',
        yellowFaceUrl:
            'https://em-content.zobj.net/source/google/387/slightly-frowning-face_1f641.png',
        greenSmileFaceUrl:
            'https://em-content.zobj.net/source/google/387/slightly-smiling-face_1f642.png',
        greenSmileFace2Url:
            'https://em-content.zobj.net/source/google/387/grinning-face-with-smiling-eyes_1f604.png',
        greenSunglassesFaceUrl:
            'https://em-content.zobj.net/source/google/387/star-struck_1f929.png',
        downloadGaugeMax: 100,
        uploadGaugeMax: 50,
      ),
    );
  }

  // Variables para almacenar los resultados del test de velocidad
  // Estas variables se actualizan desde los callbacks y podrían utilizarse
  // para mostrar resultados en otras partes de la aplicación o para análisis
  double downloadSpeed = 0.0;
  double uploadSpeed = 0.0;
  bool isAdvancedTesting = false;
  String? ipAddress;
  String? ispName;
  String? asnName;

  Widget _advancedTestView() {
    return Expanded(
      child: SpeedTestCustomWidget(
        // Configuración de colores para el widget avanzado
        primaryColor: Colors.green, // Color para descarga
        secondaryColor: Colors.purple, // Color para subida
        textColor: Colors.black87, // Color de texto principal
        cardBackgroundColor:
            Colors.grey.shade50, // Color de fondo para tarjetas
        // Callback cuando la prueba se completa exitosamente
        onTestCompleted:
            (downloadSpeed, uploadSpeed, ipAddress, ispName, asnName) async {
              setState(() {
                // Actualizamos las variables de estado con los resultados
                downloadSpeed = downloadSpeed;
                uploadSpeed = uploadSpeed;
                ipAddress = ipAddress;
                ispName = ispName;
                asnName = asnName;
                isAdvancedTesting = false;
              });
              // Registramos los resultados para depuración
              debugPrint(
                'Test completado: $downloadSpeed Mbps download, $uploadSpeed Mbps upload',
              );
              debugPrint('IP: $ipAddress, ISP: $ispName, ASN: $asnName');
              return Future.value();
            },

        // Callback cuando ocurre un error durante la prueba
        onTestError: (errorMessage) async {
          setState(() {
            isAdvancedTesting = false;
          });
          debugPrint('Error en el test: $errorMessage');
          return Future.value();
        },

        // Callback cuando inicia la prueba
        onTestStart: () async {
          setState(() {
            isAdvancedTesting = true;
          });
          debugPrint('Iniciando prueba avanzada de velocidad');
          return Future.value();
        },
      ),
    );
  }

  // Este método ya no es necesario porque el widget SpeedTestCustomWidget maneja su propia UI
}
