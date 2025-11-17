import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'alprsdk_plugin_method_channel.dart';

abstract class AlprsdkPluginPlatform extends PlatformInterface {
  /// Constructs a AlprsdkPluginPlatform.
  AlprsdkPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AlprsdkPluginPlatform _instance = MethodChannelAlprsdkPlugin();

  /// The default instance of [AlprsdkPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAlprsdkPlugin].
  static AlprsdkPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AlprsdkPluginPlatform] when
  /// they register themselves.
  static set instance(AlprsdkPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int?> setActivation(String license) {
    throw UnimplementedError('setActivation() has not been implemented.');
  }

  Future<int?> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> setParam(Map<String, Object> params) {
    throw UnimplementedError('extractFaces() has not been implemented.');
  }

  Future<dynamic> extractFaces(String imagePath) {
    throw UnimplementedError('extractFaces() has not been implemented.');
  }
}
