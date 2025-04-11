import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alprsdk_plugin/alprdetection_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alprsdk_plugin/alprsdk_plugin.dart';

// ignore: must_be_immutable
class AlprRecognitionView extends StatefulWidget {
  AlprDetectionViewController? faceDetectionViewController;

  AlprRecognitionView({super.key});

  @override
  State<StatefulWidget> createState() => AlprRecognitionViewState();
}

class AlprRecognitionViewState extends State<AlprRecognitionView> {
  dynamic _plates;
  final _alprsdkPlugin = AlprsdkPlugin();
  AlprDetectionViewController? faceDetectionViewController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> faceRecognitionStart() async {
    setState(() {
      _plates = null;
    });

    await faceDetectionViewController?.startCamera(0);
  }

  Future<bool> onAlprDetected(plates) async {
    if (!mounted) return false;

    setState(() {
      _plates = plates;
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        faceDetectionViewController?.stopCamera();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ALPR'),
          toolbarHeight: 70,
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            FaceDetectionView(faceRecognitionViewState: this),
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: FacePainter(plates: _plates),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaceDetectionView extends StatefulWidget
    implements AlprDetectionInterface {
  AlprRecognitionViewState faceRecognitionViewState;

  FaceDetectionView({super.key, required this.faceRecognitionViewState});

  @override
  Future<void> onAlprDetected(plates) async {
    await faceRecognitionViewState.onAlprDetected(plates);
  }

  @override
  State<StatefulWidget> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return UiKitView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  void _onPlatformViewCreated(int id) async {
    widget.faceRecognitionViewState.faceDetectionViewController =
        AlprDetectionViewController(id, widget);

    await widget.faceRecognitionViewState.faceDetectionViewController
        ?.initHandler();

    await widget.faceRecognitionViewState.faceDetectionViewController
        ?.startCamera(0);
  }
}

class FacePainter extends CustomPainter {
  dynamic plates;
  FacePainter({required this.plates});

  @override
  void paint(Canvas canvas, Size size) {
    if (plates != null) {
      var paint = Paint()
        ..color = const Color.fromARGB(255, 255, 0, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      for (var plate in plates) {
        // Original frame size from camera
        final frameWidth = plate['frameWidth']?.toDouble() ?? size.width;
        final frameHeight = plate['frameHeight']?.toDouble() ?? size.height;

        // Scale to fit height
        final scale = size.height / frameHeight;

        final scaledFrameWidth = frameWidth * scale;
        final offsetX = (size.width - scaledFrameWidth) / 2;
        final offsetY = 0.0;

        // Plate coordinates
        final x1 = plate['x1']?.toDouble() ?? 0;
        final y1 = plate['y1']?.toDouble() ?? 0;
        final x2 = plate['x2']?.toDouble() ?? 0;
        final y2 = plate['y2']?.toDouble() ?? 0;

        // Apply scale and offset
        final drawX1 = x1 * scale + offsetX;
        final drawY1 = y1 * scale + offsetY;
        final drawX2 = x2 * scale + offsetX;
        final drawY2 = y2 * scale + offsetY;

        final title = plate['number']?.toString() ?? '';
        final color = const Color.fromARGB(255, 0, 255, 0);

        // Draw label
        final span = TextSpan(style: TextStyle(color: color, fontSize: 20), text: title);
        final tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(drawX1 + 10, drawY1 - 30));

        // Draw rectangle
        paint.color = color;
        final rect = Rect.fromPoints(Offset(drawX1, drawY1), Offset(drawX2, drawY2));
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
