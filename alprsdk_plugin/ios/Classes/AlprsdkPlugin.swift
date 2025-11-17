import Flutter
import UIKit

public class AlprsdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "alprsdk_plugin", binaryMessenger: registrar.messenger())
    let instance = AlprsdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    registrar.register(FaceDetectionViewFactory(registrar: registrar), withId: "facedetectionview")
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments
    let myArgs = args as? [String: Any]
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "setActivation":
      let license = myArgs?["license"] as! String
      print("args: ", license)
      var ret = ALPRSDK.setActivation(license)
      result(ret)
    case "init":
      var ret = ALPRSDK.initSDK()
      result(ret)
    case "setParam":
      result(0)
    case "extractFaces":
      let imagePath = myArgs?["imagePath"] as! String
      var faceBoxesMap = NSMutableArray()
      guard let image = UIImage(contentsOfFile: imagePath)?.fixOrientation() as? UIImage else {
        result(faceBoxesMap)
        return
      }

      let faceBoxes = ALPRSDK.processImage(image)
      for face in (faceBoxes as NSArray as! [ALPRBox]) {
          
          var faceDic = Dictionary<String, Any>()
          faceDic["x1"] = face.x1
          faceDic["y1"] = face.y1
          faceDic["x2"] = face.x2
          faceDic["y2"] = face.y2
          faceDic["number"] = face.number
          faceDic["score"] = face.score
          faceDic["frameWidth"] = Int(image.size.width)
          faceDic["frameHeight"] = Int(image.size.height)

          faceBoxesMap.add(faceDic)
      }

      var faceBoxesArray = faceBoxesMap as Array
      result(faceBoxesArray)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

