// import 'package:flutter_test/flutter_test.dart';
// import 'package:alprsdk_plugin/alprsdk_plugin.dart';
// import 'package:alprsdk_plugin/alprsdk_plugin_platform_interface.dart';
// import 'package:alprsdk_plugin/alprsdk_plugin_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockAlprsdkPluginPlatform
//     with MockPlatformInterfaceMixin
//     implements AlprsdkPluginPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final AlprsdkPluginPlatform initialPlatform = AlprsdkPluginPlatform.instance;

//   test('$MethodChannelAlprsdkPlugin is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelAlprsdkPlugin>());
//   });

//   test('getPlatformVersion', () async {
//     AlprsdkPlugin AlprsdkPlugin = AlprsdkPlugin();
//     MockAlprsdkPluginPlatform fakePlatform = MockAlprsdkPluginPlatform();
//     AlprsdkPluginPlatform.instance = fakePlatform;

//     expect(await alprsdkPlugin.getPlatformVersion(), '42');
//   });
// }
