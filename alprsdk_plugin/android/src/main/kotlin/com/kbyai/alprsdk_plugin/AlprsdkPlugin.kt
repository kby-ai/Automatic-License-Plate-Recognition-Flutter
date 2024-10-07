package com.kbyai.alprsdk_plugin

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformViewRegistry
import android.util.Log
import android.util.Size
import com.kbyai.alprsdk_plugin.*
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import java.io.File
import java.io.ByteArrayOutputStream
import java.util.Base64
import java.io.IOException
import java.nio.ByteBuffer
import org.buyun.alpr.sdk.SDK_IMAGE_TYPE
import org.buyun.alpr.sdk.AlprSdk
import org.buyun.alpr.sdk.AlprCallback
import org.buyun.alpr.sdk.AlprResult
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject


/** AlprsdkPlugin */
class AlprsdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var registery: PlatformViewRegistry
  private lateinit var dartExecuter: DartExecutor
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "alprsdk_plugin")
    channel.setMethodCallHandler(this)

    context = flutterPluginBinding.applicationContext

    registery = flutterPluginBinding.getFlutterEngine().getPlatformViewsController().getRegistry();
    dartExecuter = flutterPluginBinding.getFlutterEngine().getDartExecutor();
    FaceDetectionFlutterView.livenessDetectionLevel = 0
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "setActivation") {
      val license: String? = call.argument("license")
      result.success(0)
      val ret = AlprSdk.setActivation(license);
      result.success(ret)
    } else if (call.method == "init") {
      // Init the engine
      val config = getJsonConfig()
      // Retrieve previously stored key from internal storage
      val alprResult = AlprUtils.assertIsOk(AlprSdk.init(
              context.assets,
              config.toString(),
              null
      ))
      Log.i("TestEngine", "ALPR engine initialized: " + AlprUtils.resultToString(alprResult))

      result.success(0)
    } else if (call.method == "setParam") {
      //val check_liveness_level: Int? = call.argument("check_liveness_level")
      //if(check_liveness_level != null)
      //  FaceDetectionFlutterView.livenessDetectionLevel = check_liveness_level!!
      result.success(0)
    } else if (call.method == "extractFaces") {
      val platesMap: ArrayList<HashMap<String, Any>> = ArrayList<HashMap<String, Any>>()
      val imagePath: String? = call.argument("imagePath")

      val options = BitmapFactory.Options().apply {
          inPreferredConfig = Bitmap.Config.ARGB_8888
      }
      var bitmap: Bitmap? = null
      try {
          bitmap = BitmapFactory.decodeFile(imagePath, options)
      } catch (e: IOException) {
          e.printStackTrace()
          Log.e("TestEngine", e.toString())
          result.success(platesMap)
          return
      }
      if (bitmap!!.rowBytes < bitmap.width shl 2) {
          result.success(platesMap)
          return
      }

      val widthInBytes = bitmap.rowBytes
      val width = bitmap.width
      val height = bitmap.height
      val nativeBuffer = ByteBuffer.allocateDirect(widthInBytes * height)
      bitmap.copyPixelsToBuffer(nativeBuffer)
      nativeBuffer.rewind()

      val alprResult: AlprResult = AlprSdk.process(
          SDK_IMAGE_TYPE.ULTALPR_SDK_IMAGE_TYPE_RGBA32,
          nativeBuffer, width.toLong(), height.toLong()
      )

      val plates = AlprUtils.extractPlates(alprResult);
      if(!plates.isNullOrEmpty()) {
        for(plate in plates!!) {
            Log.i("TestEngine", "number: " + plate.getNumber())
            Log.i("TestEngine", "wrapper: " + plate.getWarpedBox()[0])
            val e: HashMap<String, Any> = HashMap<String, Any>()

            var x1 = 65536.0f
            var y1 = 65536.0f
            var x2 = 0.0f
            var y2 = 0.0f
            val wrapper = plate.getWarpedBox()
            if(wrapper[0] < x1) {
              x1 = wrapper[0]
            }
            if(wrapper[1 * 2] < x1) {
              x1 = wrapper[1 * 2]
            }
            if(wrapper[2 * 2] < x1) {
              x1 = wrapper[2 * 2]
            }
            if(wrapper[3 * 2] < x1) {
              x1 = wrapper[3 * 2]
            }

            if(wrapper[0 * 2 + 1] < y1) {
              y1 = wrapper[0 * 2 + 1]
            }
            if(wrapper[1 * 2 + 1] < y1) {
              y1 = wrapper[1 * 2 + 1]
            }
            if(wrapper[2 * 2 + 1] < y1) {
              y1 = wrapper[2 * 2 + 1]
            }
            if(wrapper[3 * 2 + 1] < y1) {
              y1 = wrapper[3 * 2 + 1]
            }

            if(wrapper[0 * 2] > x2) {
              x2 = wrapper[0 * 2]
            }
            if(wrapper[1 * 2] > x2) {
              x2 = wrapper[1 * 2]
            }
            if(wrapper[2 * 2] > x2) {
              x2 = wrapper[2 * 2]
            }
            if(wrapper[3 * 2] > x2) {
              x2 = wrapper[3 * 2]
            }

            if(wrapper[0 * 2 + 1] > y2) {
              y2 = wrapper[0 * 2 + 1]
            }
            if(wrapper[1 * 2 + 1] > y2) {
              y2 = wrapper[1 * 2 + 1]
            }
            if(wrapper[2 * 2 + 1] > y2) {
              y2 = wrapper[2 * 2 + 1]
            }
            if(wrapper[3 * 2 + 1] > y2) {
              y2 = wrapper[3 * 2 + 1]
            }

            e.put("x1", x1);
            e.put("y1", y1);
            e.put("x2", x2);
            e.put("y2", y2);
            e.put("frameWidth", bitmap!!.width);
            e.put("frameHeight", bitmap!!.height);
            e.put("number", plate.getNumber());
            platesMap.add(e)
        }
      }

      result.success(platesMap)
    } else if (call.method == "similarityCalculation") {
      val templates1: ByteArray? = call.argument("templates1")
      val templates2: ByteArray? = call.argument("templates2")

      result.success(0)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
    if (binding.getActivity() != null) {
      registery
        .registerViewFactory(
          "facedetectionview", FaceDetectionViewFactory(binding, dartExecuter)
        )
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {}

  override fun onDetachedFromActivity() {}

  fun getJsonConfig(): JSONObject {
      val PREFERRED_SIZE = Size(1280, 720)
      val CONFIG_DEBUG_LEVEL = "info"
      val CONFIG_DEBUG_WRITE_INPUT_IMAGE = false // must be false unless you're debugging the code
      val CONFIG_NUM_THREADS = -1
      val CONFIG_GPGPU_ENABLED = true
      val CONFIG_MAX_LATENCY = -1
      val CONFIG_CHARSET = "latin"
      val CONFIG_IENV_ENABLED = false
      val CONFIG_OPENVINO_ENABLED = true
      val CONFIG_OPENVINO_DEVICE = "CPU"
      val CONFIG_DETECT_MINSCORE = 0.1 // 10%
      val CONFIG_CAR_NOPLATE_DETECT_ENABLED = false
      val CONFIG_CAR_NOPLATE_DETECT_MINSCORE = 0.8 // 80%
      val CONFIG_DETECT_ROI = listOf(0f, 0f, 0f, 0f)
      val CONFIG_PYRAMIDAL_SEARCH_ENABLED = true
      val CONFIG_PYRAMIDAL_SEARCH_SENSITIVITY = 0.28 // 28%
      val CONFIG_PYRAMIDAL_SEARCH_MINSCORE = 0.5 // 50%
      val CONFIG_PYRAMIDAL_SEARCH_MIN_IMAGE_SIZE_INPIXELS = 800 // pixels
      val CONFIG_KLASS_LPCI_ENABLED = true
      val CONFIG_KLASS_VCR_ENABLED = true
      val CONFIG_KLASS_VMMR_ENABLED = true
      val CONFIG_KLASS_VBSR_ENABLED = false
      val CONFIG_KLASS_VCR_GAMMA = 1.5
      val CONFIG_RECOGN_MINSCORE = 0.4 // 40%
      val CONFIG_RECOGN_SCORE_TYPE = "min"
      val CONFIG_RECOGN_RECTIFY_ENABLED = false
          
      val config = JSONObject()
      try {
          config.put("debug_level", CONFIG_DEBUG_LEVEL)
          config.put("debug_write_input_image_enabled", CONFIG_DEBUG_WRITE_INPUT_IMAGE)

          config.put("num_threads", CONFIG_NUM_THREADS)
          config.put("gpgpu_enabled", CONFIG_GPGPU_ENABLED)
          config.put("charset", CONFIG_CHARSET)
          config.put("max_latency", CONFIG_MAX_LATENCY)
          config.put("ienv_enabled", CONFIG_IENV_ENABLED)
          config.put("openvino_enabled", CONFIG_OPENVINO_ENABLED)
          config.put("openvino_device", CONFIG_OPENVINO_DEVICE)

          config.put("detect_minscore", CONFIG_DETECT_MINSCORE)
          config.put("detect_roi", JSONArray(CONFIG_DETECT_ROI))

          config.put("car_noplate_detect_enabled", CONFIG_CAR_NOPLATE_DETECT_ENABLED)
          config.put("car_noplate_detect_min_score", CONFIG_CAR_NOPLATE_DETECT_MINSCORE)

          config.put("pyramidal_search_enabled", CONFIG_PYRAMIDAL_SEARCH_ENABLED)
          config.put("pyramidal_search_sensitivity", CONFIG_PYRAMIDAL_SEARCH_SENSITIVITY)
          config.put("pyramidal_search_minscore", CONFIG_PYRAMIDAL_SEARCH_MINSCORE)
          config.put("pyramidal_search_min_image_size_inpixels", CONFIG_PYRAMIDAL_SEARCH_MIN_IMAGE_SIZE_INPIXELS)

          config.put("klass_lpci_enabled", CONFIG_KLASS_LPCI_ENABLED)
          config.put("klass_vcr_enabled", CONFIG_KLASS_VCR_ENABLED)
          config.put("klass_vmmr_enabled", CONFIG_KLASS_VMMR_ENABLED)
          config.put("klass_vbsr_enabled", CONFIG_KLASS_VBSR_ENABLED)
          config.put("klass_vcr_gamma", CONFIG_KLASS_VCR_GAMMA)

          config.put("recogn_minscore", CONFIG_RECOGN_MINSCORE)
          config.put("recogn_score_type", CONFIG_RECOGN_SCORE_TYPE)
          config.put("recogn_rectify_enabled", CONFIG_RECOGN_RECTIFY_ENABLED)
      } catch (e: JSONException) {
          e.printStackTrace()
      }
      return config
  }
}
