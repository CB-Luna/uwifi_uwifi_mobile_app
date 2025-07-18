import 'dart:math' as math; // Para la animación de carga

import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

enum TestStage {
  idle,
  selectingServer,
  downloading,
  uploading,
  finished,
  error,
}

class SpeedTestCustomWidget extends StatefulWidget {
  const SpeedTestCustomWidget({
    required this.primaryColor, // Usado para degradado de descarga, iconos, botón
    required this.secondaryColor, // Usado para degradado de subida
    required this.textColor, // Para la mayoría del texto
    required this.cardBackgroundColor, // Para el fondo de las tarjetas
    required this.onTestCompleted,
    required this.onTestError,
    this.onTestStart,
    this.onServerSelected,
    this.width,
    this.height,
    super.key,
  });

  final double? width;
  final double? height;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color cardBackgroundColor;
  final Future Function(
    double downloadSpeedMbps,
    double uploadSpeedMbps,
    String? ipAddress,
    String? ispName,
    String? asnName,
  )
  onTestCompleted;
  final Future Function(String errorMessage) onTestError;
  final Future Function()? onTestStart;
  final Future Function()? onServerSelected;

  @override
  State<SpeedTestCustomWidget> createState() => _SpeedTestCustomWidgetState();
}

class _SpeedTestCustomWidgetState extends State<SpeedTestCustomWidget>
    with TickerProviderStateMixin {
  final FlutterInternetSpeedTest _internetSpeedTest =
      FlutterInternetSpeedTest();

  final double _gaugeMaxDownloadSpeed =
      150.0; // Max para gauge de descarga (Mbps)
  final double _gaugeMaxUploadSpeed = 50.0; // Max para gauge de subida (Mbps)

  bool _isTesting = false;
  double _downloadRate = 0.0;
  double _uploadRate = 0.0;
  String _ipAddress = "--";
  String _asn = "--";
  String _isp = "--";
  String? _errorMessage;
  TestStage _currentTestStage = TestStage.idle;

  double _finalDownloadRate = 0.0;
  double _finalUploadRate = 0.0;
  String? _finalIpAddress;
  String? _finalIspName;
  String? _finalAsnName;

  bool _downloadTestFinished = false;
  bool _uploadTestFinished = false;
  bool _clientInfoRetrieved = false;

  // Para la animación de carga "initial loading"
  AnimationController? _loadingAnimationController;
  Animation<double>? _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ), // Duración de un ciclo de animación
      vsync: this,
    )..repeat(); // Repetir la animación

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _loadingAnimationController!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _loadingAnimationController?.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _isTesting = true;
      _downloadRate = 0.0;
      _uploadRate = 0.0;
      _ipAddress = "--";
      _asn = "--";
      _isp = "--";
      _errorMessage = null;
      _currentTestStage = TestStage.idle;
      _finalDownloadRate = 0.0;
      _finalUploadRate = 0.0;
      _finalIpAddress = null;
      _finalIspName = null;
      _finalAsnName = null;
      _downloadTestFinished = false;
      _uploadTestFinished = false;
      _clientInfoRetrieved = false;
      if (!_loadingAnimationController!.isAnimating) {
        _loadingAnimationController!.repeat();
      }
    });
  }

  double _convertToMbps(double rate, dynamic unit) {
    String unitString = unit.toString().toLowerCase();
    if (unitString.contains('kbps')) {
      return rate / 1000.0;
    }
    return rate;
  }

  void _startTest() {
    if (_isTesting &&
        _currentTestStage != TestStage.idle &&
        _currentTestStage != TestStage.finished &&
        _currentTestStage != TestStage.error) {
      return;
    }
    _resetState();
    setState(() {
      _currentTestStage = TestStage.selectingServer;
    });
    widget.onTestStart?.call();

    _internetSpeedTest.startTesting(
      onDefaultServerSelectionDone: (dynamic client) {
        /* ... (igual que antes) ... */
        setState(() {
          try {
            _finalIpAddress = client?.ip as String?;
            _finalAsnName = client?.asn as String?;
            _finalIspName = client?.isp as String?;
            _ipAddress = client?.ip as String? ?? "--";
            _asn = client?.asn as String? ?? "--";
            _isp = client?.isp as String? ?? "--";
          } catch (e) {
            _finalIpAddress = _finalAsnName = _finalIspName = "ClientErr";
            _ipAddress = _asn = _isp = "ClientErr";
          }
          _clientInfoRetrieved = true;
        });
        widget.onServerSelected?.call();
      },
      onStarted: () {
        if (_loadingAnimationController!.isAnimating) {
          _loadingAnimationController!.stop();
        }
      },
      onProgress: (double percent, dynamic result) {
        if (_loadingAnimationController!.isAnimating) {
          _loadingAnimationController!.stop();
        }
        setState(() {
          try {
            double transferRate = result.transferRate as double;
            dynamic unit = result.unit;
            dynamic type = result.type;
            double currentRateMbps = _convertToMbps(transferRate, unit);
            if (type.toString().toLowerCase().contains('download') ||
                (type is Enum && type.index == 0)) {
              _downloadRate = currentRateMbps;
              if (_currentTestStage != TestStage.downloading) {
                _currentTestStage = TestStage.downloading;
              }
            } else if (type.toString().toLowerCase().contains('upload') ||
                (type is Enum && type.index == 1)) {
              _uploadRate = currentRateMbps;
              if (_currentTestStage != TestStage.uploading) {
                _currentTestStage = TestStage.uploading;
              }
            }
          } catch (e) {
            _errorMessage = "Error in onProgress: $e";
          }
        });
      },
      onCompleted: (dynamic downloadResult, dynamic uploadResult) {
        /* ... (igual que antes, actualizando _finalDownloadRate, _downloadRate, _finalUploadRate, _uploadRate) ... */
        String? completionError;
        try {
          _finalDownloadRate = _convertToMbps(
            downloadResult.transferRate as double,
            downloadResult.unit,
          );
          _downloadRate = _finalDownloadRate;
          _downloadTestFinished = true;
          _finalUploadRate = _convertToMbps(
            uploadResult.transferRate as double,
            uploadResult.unit,
          );
          _uploadRate = _finalUploadRate;
          _uploadTestFinished = true;
        } catch (e) {
          completionError = "Error in onCompleted: $e";
        }
        setState(() {
          if (completionError != null) {
            _errorMessage = completionError;
          }
          _currentTestStage = TestStage.finished;
          _isTesting = false;
          if (_loadingAnimationController!.isAnimating) {
            _loadingAnimationController!.stop();
          }
        });
        if (completionError == null) {
          _handleTestCompletion();
        }
      },
      onError: (String errMsg, String speedTestError) {
        /* ... (igual que antes) ... */
        setState(() {
          _errorMessage = "Test Error: $errMsg. Details: $speedTestError";
          _isTesting = false;
          _currentTestStage = TestStage.error;
          if (_loadingAnimationController!.isAnimating) {
            _loadingAnimationController!.stop();
          }
        });
        if (_errorMessage != null) {
          widget.onTestError(_errorMessage!);
        }
      },
    );
  }

  void _handleTestCompletion() {
    /* ... (igual que antes) ... */
    if (_downloadTestFinished && _uploadTestFinished && _clientInfoRetrieved) {
      try {
        widget.onTestCompleted.call(
          _finalDownloadRate,
          _finalUploadRate,
          _finalIpAddress,
          _finalIspName,
          _finalAsnName,
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Error in onTestCompleted call: $e";
          });
        }
      }
    } else {
      if (mounted && _errorMessage == null) {
        setState(() {
          _errorMessage = "Completion logic error.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usaremos widget.textColor para la mayoría de los textos
    // widget.primaryColor para descarga (gauge y texto "Download")
    // widget.secondaryColor para subida (gauge y texto "Upload")
    // widget.cardBackgroundColor para el fondo de las tarjetas

    return Container(
      // Fondo general se define en FF
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Sección Superior: Info Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard("IP Address", _ipAddress, Icons.public_outlined),
              _buildInfoCard("ASN", _asn, Icons.dns_outlined),
              _buildInfoCard("ISP", _isp, Icons.router_outlined),
            ],
          ),
          const SizedBox(height: 15),

          // Sección Intermedia: Resumen de Velocidades
          _buildSpeedSummaryCard(),
          const SizedBox(height: 15),

          // Sección de Gauges
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Alinea los gauges si tienen diferentes alturas de título
              children: [
                Expanded(
                  child: _buildGauge(
                    "Download",
                    _downloadRate,
                    _gaugeMaxDownloadSpeed,
                    widget.primaryColor,
                    _isTesting &&
                        _downloadRate == 0.0 &&
                        (_currentTestStage == TestStage.downloading ||
                            _currentTestStage == TestStage.selectingServer),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildGauge(
                    "Upload",
                    _uploadRate,
                    _gaugeMaxUploadSpeed,
                    widget.secondaryColor,
                    _isTesting &&
                        _uploadRate == 0.0 &&
                        _currentTestStage == TestStage.uploading,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Botón de Iniciar Test
          _buildStartButton(),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _getButtonTextForStage() {
    /* ... (igual que antes, con todos los return) ... */
    if (!_isTesting &&
        (_currentTestStage == TestStage.idle ||
            _currentTestStage == TestStage.finished ||
            _currentTestStage == TestStage.error)) {
      return 'Start Testing';
    }
    switch (_currentTestStage) {
      case TestStage.selectingServer:
        return 'Finding Server...';
      case TestStage.downloading:
        return 'Testing Download...';
      case TestStage.uploading:
        return 'Testing Upload...';
      case TestStage.finished:
        return 'Test Finished';
      case TestStage.error:
        return 'Test Failed';
      default:
        return 'Initializing...';
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: widget.cardBackgroundColor,
        elevation: 0, // Diseño plano
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: widget.textColor.withValues(alpha: 0.7),
                size: 24,
              ), // Icono más sutil
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: widget.textColor.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedSummaryCard() {
    return Card(
      color: widget.cardBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSpeedSummaryItem(
              "Download",
              _finalDownloadRate > 0 ? _finalDownloadRate : _downloadRate,
              Icons.arrow_downward,
              widget.primaryColor,
            ),
            Container(
              height: 30,
              width: 1,
              color: widget.textColor.withValues(alpha: 0.2),
            ),
            _buildSpeedSummaryItem(
              "Upload",
              _finalUploadRate > 0 ? _finalUploadRate : _uploadRate,
              Icons.arrow_upward,
              widget.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedSummaryItem(
    String title,
    double speed,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: widget.textColor.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: color, size: 16),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${speed.toStringAsFixed(speed > 0 ? 2 : 0)} ${speed > 0 ? "Mbps" : "--"}",
          style: TextStyle(
            color: widget.textColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGauge(
    String title,
    double value,
    double maximumValue,
    Color gaugeColor,
    bool showLoadingAnimation,
  ) {
    // Definición de los degradados (puedes ajustarlos)
    final List<Color> gaugeGradientColors = gaugeColor == widget.primaryColor
        ? [
            Color.lerp(gaugeColor, Colors.white, 0.4)!,
            gaugeColor,
          ] // Degradado para descarga (ej. verde claro a verde)
        : [
            Color.lerp(gaugeColor, Colors.white, 0.4)!,
            gaugeColor,
          ]; // Degradado para subida (ej. morado claro a morado)

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: gaugeColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: AnimatedBuilder(
            // Para la animación de carga
            animation: _loadingAnimationController!,
            builder: (context, child) {
              return SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    maximum: maximumValue,
                    startAngle:
                        150, // Ajusta para que el arco no sea un círculo completo
                    endAngle: 30,
                    radiusFactor:
                        0.8, // Hacer el gauge un poco más pequeño dentro de su espacio
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.15,
                      cornerStyle: CornerStyle.bothCurve,
                      color: widget.textColor.withValues(alpha: 0.1),
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    majorTickStyle: MajorTickStyle(
                      length: 0.1,
                      lengthUnit: GaugeSizeUnit.factor,
                      color: widget.textColor.withValues(alpha: 0.3),
                    ),
                    minorTickStyle: MinorTickStyle(
                      length: 0.05,
                      thickness: 0.8,
                      lengthUnit: GaugeSizeUnit.factor,
                      color: widget.textColor.withValues(alpha: 0.2),
                    ),
                    axisLabelStyle: GaugeTextStyle(
                      fontSize: 8,
                      color: widget.textColor.withValues(alpha: 0.6),
                    ),
                    pointers: <GaugePointer>[
                      if (showLoadingAnimation &&
                          value == 0.0) // Muestra animación de carga
                        RangePointer(
                          value:
                              _loadingAnimation!.value *
                              maximumValue, // Anima el valor
                          width: 0.15,
                          sizeUnit: GaugeSizeUnit.factor,
                          gradient: SweepGradient(
                            colors: [
                              gaugeColor.withValues(alpha: 0.3),
                              gaugeColor,
                            ],
                            stops: const [0.7, 1.0],
                            transform: GradientRotation(
                              _loadingAnimation!.value * 2 * math.pi,
                            ),
                          ),
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      else ...[
                        // Muestra datos reales
                        RangePointer(
                          value: value,
                          width: 0.15,
                          sizeUnit: GaugeSizeUnit.factor,
                          gradient: SweepGradient(
                            colors: gaugeGradientColors,
                            stops: const [0.0, 1.0],
                          ),
                          enableAnimation: true,
                          animationDuration: 300,
                          animationType: AnimationType.linear,
                          cornerStyle: CornerStyle.bothCurve,
                        ),
                        NeedlePointer(
                          value: value,
                          enableAnimation: true,
                          animationDuration: 300,
                          needleStartWidth: 0.5,
                          needleEndWidth: 4,
                          knobStyle: KnobStyle(
                            knobRadius: 0.06,
                            color: gaugeColor,
                          ),
                          tailStyle: TailStyle(
                            length: 0.1,
                            width: 3,
                            color: gaugeColor,
                          ),
                        ),
                      ],
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              value.toStringAsFixed(value > 0 ? 2 : 0),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: widget.textColor,
                              ),
                            ),
                            if (value > 0 || _isTesting)
                              Text(
                                'Mbps',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.textColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.45, // Ajustar posición del texto
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Fondo transparente
              // foregroundColor: widget.primaryColor, // Color del texto y borde
              side: BorderSide(color: widget.primaryColor, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.primaryColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 0,
            ).copyWith(
              // Estilo para el texto del botón
              textStyle: WidgetStateProperty.all(
                TextStyle(
                  color: widget.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Para asegurar que el splash y overlay usen primaryColor
              overlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.hovered)) {
                  return widget.primaryColor.withValues(alpha: 0.08);
                }
                if (states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.pressed)) {
                  return widget.primaryColor.withValues(alpha: 0.24);
                }
                return null; // Defer to the widget's default.
              }),
            ),
        onPressed:
            (_isTesting &&
                _currentTestStage != TestStage.finished &&
                _currentTestStage != TestStage.error)
            ? null
            : _startTest,
        child: Text(
          _getButtonTextForStage(),
          style: TextStyle(
            color: _isTesting
                ? widget.textColor.withValues(alpha: 0.5)
                : widget.primaryColor,
          ), // Texto del botón cambia color
        ),
      ),
    );
  }
}
