// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:alprsdk_plugin/alprsdk_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'alprdetectionview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ALPR Demo',
        theme: ThemeData(
          // Define the default brightness and colors.
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false, // Disable DEBUG banner
        home: MyHomePage(title: 'ALPR Demo'));
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _warningState = "";
  bool _visibleWarning = false;
  var _galleryImage;
  String _numbers = "";

  final _alprsdkPlugin = AlprsdkPlugin();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    int facepluginState = -1;
    String warningState = "";
    bool visibleWarning = false;

    try {
      if (Platform.isAndroid) {
        await _alprsdkPlugin
            .setActivation(
                "o3AfDW+0LAb55qW354xp9ef/Twg1WumIcKaBQLydx+o7+8nuZSo4aL4vVGro3mNCLvo8C2OPNDjZ"
                "/8k+bvgbf8+QszGqG5ubjZOaREXO0Iw8pSepERy4HrWrS6I9ObjuttMUIRHBFNjIsT3RKH57mNv6"
                "1IXxewXlIA2oe5Vak/zaddoKKKcSW+iWJWqIa1MxGn8PpUD1riQS9RrO/cwZsiAJU+5+ekkkyP3C"
                "7eNZGzFfpmkLM55p2F98IMqWHjaMmX0klsNlxE/bdSJD8c2cS/+9DGLqiWb2FHz8FpR6sXjc+eGM"
                "bNtBd0YxqfAy+oeTVdPyw0E17lj+Hilw4L4C6Q==")
            .then((value) => facepluginState = value ?? -1);
      }

      if (facepluginState == 0) {
        await _alprsdkPlugin
            .init()
            .then((value) => facepluginState = value ?? -1);
      }
    } catch (e) {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (facepluginState == -1) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -2) {
      warningState = "License expired!";
      visibleWarning = true;
    } else if (facepluginState == -3) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -4) {
      warningState = "No activated!";
      visibleWarning = true;
    } else if (facepluginState == -5) {
      warningState = "Init error!";
      visibleWarning = true;
    }

    setState(() {
      _warningState = warningState;
      _visibleWarning = visibleWarning;
    });
  }

  Future alprFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      var rotatedImage =
          await FlutterExifRotation.rotateImage(path: image.path);

      final plates = await _alprsdkPlugin.extractFaces(rotatedImage.path);
      var numbers = "";
      for (var plate in plates) {
        numbers = plate['number'] + ", ";
      }

      setState(() {
        _galleryImage = rotatedImage;
        _numbers = numbers;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALPR Demo'),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: <Widget>[
            const Card(
                color: Color.fromARGB(255, 0x49, 0x45, 0x4F),
                child: ListTile(
                  leading: Icon(Icons.tips_and_updates),
                  subtitle: Text(
                    'KBY-AI offers SDKs for face recognition, liveness detection, and id document recognition.',
                    style: TextStyle(fontSize: 13),
                  ),
                )),
            const SizedBox(
              height: 6,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: const Text('Gallery'),
                      icon: const Icon(
                        Icons.browse_gallery,
                        // color: Colors.white70,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          // foregroundColor: Colors.white70,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: alprFromGallery),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: const Text('Camera'),
                      icon: const Icon(
                        Icons.camera,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AlprRecognitionView()),
                        );
                      }),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
                child: Stack(
              children: [
                Column(children: <Widget>[
                  _galleryImage != null
                      ? Image.file(File(_galleryImage!.path))
                      : SizedBox(),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(_numbers)
                ]),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                        visible: _visibleWarning,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          color: Colors.redAccent,
                          child: Center(
                            child: Text(
                              _warningState,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ))
                  ],
                )
              ],
            )),
            const SizedBox(
              height: 4,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/ic_kby.png'),
                  width: 48,
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
