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
                "juw/83/TqWAHba7Zm99020yr7FgQIalodN0Cj/l2wT/W0UtczQmtwncpjXxv1DEcovUGO3JVr0vW"
                "qpBefI3RuzJe+toXMEC8fjH9T4zfLhXkIDDQr2J263hAofQJ+0YeoOZ0KMjzlx7Ls3PNQtaA+ji3"
                "4DDtZCDgTAMbgjajC2OKsgidEqAXtFH+tOdMYZGAFvVSoAnN77ptXboPZSjP4WntJnGOT8D1Eug8"
                "7EkudgO8d46HKJGs9dznovTJZKSQXqrEVyhl3MAEbNV3dvITViF9LuLMKpJeSErEa0pbw+MaK+ww"
                "xR+z68jzNwFLlZvc+8FHo34btlaSz0p1A4SKJw==")
            .then((value) => facepluginState = value ?? -1);
      } else {
        await _alprsdkPlugin
            .setActivation(
                "akxRJanttIzX+ddPyyKIXSYjtmGbrCO+zFn+7kvvIGRVJKaaOjZVWfi15a6Z1CCX5oR0aCGyD664"
                "7KC6xbA4uK2xDw7g9W6M7QjS5LGfJgplEO45XqE3PgepmdqYiRFEl5sw+Xe+SWmfuOu8xyUwBD37"
                "m2RoQ6TgCnBJ9rxYFM9MNxsLUrlBuKP5J8r/aZg5vFbotvLqXHI4enn8Lzva2lF6QYo0wMBhfus6"
                "cY8fWzDnFvCvleLXHHGWCRYs0KLj37eCUAxVWuoO7luagiRoh0sFabCEtQx4GZf11ofcpqr8v7BO"
                "j3PbBeba3PTbGgOoSvE7NKmwZTdv9uBRtK+LdQ==")
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
      print(plates);
      for (var plate in plates) {
        numbers = plate['number'] + ", " + plate['score'] + "%";
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
