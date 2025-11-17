import 'dart:typed_data';

import 'alprsdk_plugin_platform_interface.dart';

class AlprsdkPlugin {
  Future<String?> getPlatformVersion() {
    return AlprsdkPluginPlatform.instance.getPlatformVersion();
  }

  Future<int?> setActivation(String license) {
    return AlprsdkPluginPlatform.instance.setActivation(license);
  }

  Future<int?> init() {
    return AlprsdkPluginPlatform.instance.init();
  }

  Future<void> setParam(Map<String, Object> params) async {
    await AlprsdkPluginPlatform.instance.setParam(params);
  }

  Future<dynamic> extractFaces(String imagePath) {
    return AlprsdkPluginPlatform.instance.extractFaces(imagePath);
  }
}
