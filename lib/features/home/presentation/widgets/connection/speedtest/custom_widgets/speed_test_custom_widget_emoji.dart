// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';

// Helper class to define emoji markers for the gauge
class _EmojiMarker {
  final String url;
  final double valuePercent;

  _EmojiMarker({required this.url, required this.valuePercent});
}

enum TestStage {
  idle,
  selectingServer,
  downloading,
  uploading,
  finished,
  error,
}

class SpeedTestCustomWidgetEmoji extends StatefulWidget {
  const SpeedTestCustomWidgetEmoji({
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.cardBackgroundColor,
    required this.onTestCompleted,
    required this.onTestError,
    required this.redFaceUrl,
    required this.yellowFaceUrl,
    required this.greenSmileFaceUrl,
    required this.greenSmileFace2Url,
    required this.greenSunglassesFaceUrl,
    required this.downloadGaugeMax,
    required this.uploadGaugeMax,
    super.key,
    this.width,
    this.height,
    this.onTestStart,
    this.onServerSelected,
    this.emojiSize = 24.0,
    this.gaugeStrokeWidth = 0.2,
    this.needleWidth = 6.0,
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

  final String redFaceUrl;
  final String yellowFaceUrl;
  final String greenSmileFaceUrl;
  final String greenSmileFace2Url;
  final String greenSunglassesFaceUrl;

  final double downloadGaugeMax;
  final double uploadGaugeMax;
  final double emojiSize;
  final double gaugeStrokeWidth;
  final double needleWidth;

  @override
  State<SpeedTestCustomWidgetEmoji> createState() =>
      _SpeedTestCustomWidgetEmojiState();
}

class _SpeedTestCustomWidgetEmojiState extends State<SpeedTestCustomWidgetEmoji>
    with TickerProviderStateMixin {
  final FlutterInternetSpeedTest _internetSpeedTest =
      FlutterInternetSpeedTest();

  bool _isTesting = false;
  double _downloadRate = 0.0;
  double _uploadRate = 0.0;
  String _ipAddress = "--";
  String asn = "--";
  String isp = "--";
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

  AnimationController? _loadingAnimationController;
  Animation<double>? _loadingAnimation;

  late List<_EmojiMarker> _emojiMarkers;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _loadingAnimationController!,
        curve: Curves.linear,
      ),
    );

    _emojiMarkers = [
      // --- AJUSTE AQUÍ para redFaceUrl ---
      _EmojiMarker(url: widget.redFaceUrl, valuePercent: 0.08), // Antes 0.10
      _EmojiMarker(url: widget.yellowFaceUrl, valuePercent: 0.30),
      _EmojiMarker(url: widget.greenSmileFaceUrl, valuePercent: 0.50),
      _EmojiMarker(url: widget.greenSmileFace2Url, valuePercent: 0.75),
      _EmojiMarker(url: widget.greenSunglassesFaceUrl, valuePercent: 0.95),
    ];
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
      asn = "--";
      isp = "--";
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
      if (_loadingAnimationController != null &&
          !_loadingAnimationController!.isAnimating) {
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
    if (mounted) {
      setState(() {
        _currentTestStage = TestStage.selectingServer;
      });
    }
    widget.onTestStart?.call();

    _internetSpeedTest.startTesting(
      onDefaultServerSelectionDone: (client) {
        if (mounted) {
          setState(() {
            try {
              _finalIpAddress = client?.ip;
              _finalAsnName = client?.asn;
              _finalIspName = client?.isp;
              _ipAddress = client?.ip ?? "--";
              asn = client?.asn ?? "--";
              isp = client?.isp ?? "--";
            } catch (e) {
              _finalIpAddress = _finalAsnName = _finalIspName = "ClientErr";
              _ipAddress = asn = isp = "ClientErr";
            }
            _clientInfoRetrieved = true;
          });
        }
        widget.onServerSelected?.call();
      },
      onStarted: () {
        if (mounted &&
            _loadingAnimationController != null &&
            _loadingAnimationController!.isAnimating) {
          _loadingAnimationController!.stop();
        }
      },
      onProgress: (percent, result) {
        if (mounted &&
            _loadingAnimationController != null &&
            _loadingAnimationController!.isAnimating) {
          _loadingAnimationController!.stop();
        }
        if (mounted) {
          setState(() {
            try {
              double transferRate = result.transferRate;
              var unit = result.unit;
              var type = result.type;
              double currentRateMbps = _convertToMbps(transferRate, unit);

              if (type.toString().toLowerCase().contains('download') ||
                  (type.index == 0)) {
                _downloadRate = currentRateMbps;
                if (_currentTestStage != TestStage.downloading) {
                  _currentTestStage = TestStage.downloading;
                }
              } else if (type.toString().toLowerCase().contains('upload') ||
                  (type.index == 1)) {
                _uploadRate = currentRateMbps;
                if (_currentTestStage != TestStage.uploading) {
                  _currentTestStage = TestStage.uploading;
                }
              }
            } catch (e) {
              _errorMessage = "Error in onProgress: $e";
            }
          });
        }
      },
      onCompleted: (downloadResult, uploadResult) {
        String? completionError;
        try {
          _finalDownloadRate = _convertToMbps(
            downloadResult.transferRate,
            downloadResult.unit,
          );
          _downloadRate = _finalDownloadRate;
          _downloadTestFinished = true;

          _finalUploadRate = _convertToMbps(
            uploadResult.transferRate,
            uploadResult.unit,
          );
          _uploadRate = _finalUploadRate;
          _uploadTestFinished = true;
        } catch (e) {
          completionError = "Error in onCompleted: $e";
        }

        if (mounted) {
          setState(() {
            if (completionError != null) {
              _errorMessage = completionError;
            }
            _currentTestStage = TestStage.finished;
            _isTesting = false;
            if (_loadingAnimationController != null &&
                _loadingAnimationController!.isAnimating) {
              _loadingAnimationController!.stop();
            }
          });
        }
        if (completionError == null) {
          _handleTestCompletion();
        }
      },
      onError: (errMsg, speedTestError) {
        if (mounted) {
          setState(() {
            _errorMessage = "Test Error: $errMsg. Details: $speedTestError";
            _isTesting = false;
            _currentTestStage = TestStage.error;
            if (_loadingAnimationController != null &&
                _loadingAnimationController!.isAnimating) {
              _loadingAnimationController!.stop();
            }
          });
        }
        if (_errorMessage != null) {
          widget.onTestError(_errorMessage!);
        }
      },
    );
  }

  void _handleTestCompletion() {
    if (_downloadTestFinished && _uploadTestFinished && _clientInfoRetrieved) {
      widget.onTestCompleted(
        _finalDownloadRate,
        _finalUploadRate,
        _finalIpAddress,
        _finalIspName,
        _finalAsnName,
      );
    } else {
      if (mounted && _errorMessage == null) {
        setState(() {
          _errorMessage =
              "Completion logic error: Not all data is ready. D:$_downloadTestFinished, U:$_uploadTestFinished, C:$_clientInfoRetrieved";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildIpAddressCard(_ipAddress),
          const SizedBox(height: 15),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildGauge(
                    "Download",
                    _downloadRate,
                    widget.downloadGaugeMax,
                    widget.primaryColor,
                    _isTesting &&
                        _downloadRate == 0.0 &&
                        (_currentTestStage == TestStage.downloading ||
                            _currentTestStage == TestStage.selectingServer),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildGauge(
                    "Upload",
                    _uploadRate,
                    widget.uploadGaugeMax,
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
          _buildStartButton(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
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

  Widget _buildIpAddressCard(String ipValue) {
    return Card(
      color: widget.cardBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              Icons.public_outlined,
              color: widget.textColor.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "IP Address: ",
              style: TextStyle(
                color: widget.textColor.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            Expanded(
              child: Text(
                ipValue,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(
    String title,
    double value,
    double maximumValue,
    Color gaugeColor,
    bool showLoadingAnimation,
  ) {
    double emojiPositionFactor = 0.7; // Puedes ajustar este si es necesario

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
        const SizedBox(height: 8),
        Expanded(
          child: AnimatedBuilder(
            animation: _loadingAnimationController!,
            builder: (context, child) {
              return SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    maximum: maximumValue,
                    showLabels: false,
                    startAngle: 150,
                    endAngle: 30,
                    axisLineStyle: AxisLineStyle(
                      thickness: widget.gaugeStrokeWidth,
                      cornerStyle: CornerStyle.bothCurve,
                      color: widget.textColor.withValues(alpha: 0.15),
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    majorTickStyle: MajorTickStyle(
                      length: 0.1,
                      lengthUnit: GaugeSizeUnit.factor,
                      color: widget.textColor.withValues(alpha: 0.3),
                    ),
                    minorTickStyle: MinorTickStyle(
                      length: 0.05,
                      thickness: 1.0,
                      lengthUnit: GaugeSizeUnit.factor,
                      color: widget.textColor.withValues(alpha: 0.2),
                    ),
                    pointers: <GaugePointer>[
                      if (showLoadingAnimation && value == 0.0)
                        RangePointer(
                          value: _loadingAnimation!.value * maximumValue,
                          width: widget.gaugeStrokeWidth,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: gaugeColor.withValues(
                            alpha: 0.5 + (_loadingAnimation!.value * 0.5),
                          ),
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      else ...[
                        RangePointer(
                          value: value,
                          width: widget.gaugeStrokeWidth,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: gaugeColor,
                          enableAnimation: true,
                          animationDuration: 300,
                          animationType: AnimationType.linear,
                          cornerStyle: CornerStyle.bothCurve,
                        ),
                        NeedlePointer(
                          value: value,
                          enableAnimation: true,
                          animationDuration: 300,
                          needleStartWidth: 1.5,
                          needleEndWidth: widget.needleWidth,
                          needleLength: 0.75,
                          knobStyle: KnobStyle(color: gaugeColor),
                          tailStyle: TailStyle(
                            length: 0.18,
                            width: widget.needleWidth * 0.6,
                            color: gaugeColor,
                          ),
                        ),
                      ],
                    ],
                    annotations: <GaugeAnnotation>[
                      ..._emojiMarkers.map((marker) {
                        double sweepAngle = (30.0 - 150.0);
                        if (sweepAngle <= 0) sweepAngle += 360.0;
                        double angle = 150 + (sweepAngle * marker.valuePercent);
                        if (angle >= 360) angle -= 360;

                        bool isValidUrl =
                            marker.url.isNotEmpty &&
                            (marker.url.startsWith('http://') ||
                                marker.url.startsWith('https://'));

                        return GaugeAnnotation(
                          widget: isValidUrl
                              ? Image.network(
                                  marker.url,
                                  width: widget.emojiSize,
                                  height: widget.emojiSize,
                                  errorBuilder: (context, error, stackTrace) {
                                    AppLogger.error(
                                      "Error loading NETWORK image: ${marker.url}. Error: $error",
                                    );
                                    return Icon(
                                      Icons.error_outline,
                                      color: Colors.orange,
                                      size: widget.emojiSize * 0.8,
                                    );
                                  },
                                  loadingBuilder:
                                      (
                                        BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  widget.textColor.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                ),
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                )
                              : Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: widget.emojiSize * 0.8,
                                ),
                          angle: angle,
                          positionFactor: emojiPositionFactor,
                        );
                      }),
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

  String _getButtonTextForStage() {
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

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: widget.primaryColor, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 0,
            ).copyWith(
              textStyle: WidgetStateProperty.all(
                TextStyle(
                  color: widget.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                return null;
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
            color:
                _isTesting &&
                    _currentTestStage != TestStage.finished &&
                    _currentTestStage != TestStage.error
                ? widget.textColor.withValues(alpha: 0.5)
                : widget.primaryColor,
          ),
        ),
      ),
    );
  }
}
// DO NOT REMOVE OR MODIFY THE CODE BELOW!
// End custom widget code