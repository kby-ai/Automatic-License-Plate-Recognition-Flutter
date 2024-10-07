import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AlprDetectionInterface {
  AlprDetectionInterface();

  void onAlprDetected(plates) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

class AlprDetectionViewController {
  final MethodChannel _channel;
  final AlprDetectionInterface faceDetectionInterface;

  AlprDetectionViewController(int id, this.faceDetectionInterface)
      : _channel = MethodChannel('facedetectionview_$id');

  Future<void> initHandler() async {
    _channel.setMethodCallHandler(nativeMethodCallHandler);
  }

  Future<bool?> startCamera(int cameraLens) async {
    final ret =
        _channel.invokeMethod<bool>('startCamera', {"cameraLens": cameraLens});
    return ret;
  }

  Future<bool?> stopCamera() async {
    final ret = _channel.invokeMethod<bool>('stopCamera');
    return ret;
  }

  Future<void> nativeMethodCallHandler(MethodCall methodCall) async {
    if (methodCall.method == "onAlprDetected") {
      faceDetectionInterface.onAlprDetected(methodCall.arguments);
    }
  }
}
