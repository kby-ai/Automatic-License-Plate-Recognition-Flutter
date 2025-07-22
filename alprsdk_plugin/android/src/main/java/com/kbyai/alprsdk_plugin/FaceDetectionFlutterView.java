package com.kbyai.alprsdk_plugin;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.view.View;
import android.util.Log;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import android.os.Handler;
import android.os.Message;
import java.nio.ByteBuffer;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;



import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;
import android.graphics.Bitmap;
import org.buyun.alpr.sdk.SDK_IMAGE_TYPE;
import org.buyun.alpr.sdk.AlprSdk;
import org.buyun.alpr.sdk.AlprCallback;
import org.buyun.alpr.sdk.AlprResult;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FaceDetectionFlutterView implements PlatformView, MethodCallHandler, CameraViewInterface {

    public static int livenessDetectionLevel = 0;

    private final MethodChannel channel;
    private final ActivityPluginBinding activityPluginBinding;
    private CameraBaseView cameraView;

    private Handler channelHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if(msg.what == 1) {
                ArrayList<HashMap<String, Object>> faceBoxesMap = (ArrayList<HashMap<String, Object>>)msg.obj;
                channel.invokeMethod("onAlprDetected", faceBoxesMap);
            }
        }
    };


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
        if (call.method.equals("startCamera")) {
            int cameraLens = call.argument("cameraLens");
            getCameraView().startCamera(cameraLens);
        } else if (call.method.equals("stopCamera")) {
            getCameraView().stopCamera();
        } else {
            result.notImplemented();
        }
    }

    private CameraBaseView getCameraView() {
        return cameraView;
    }

    public FaceDetectionFlutterView(ActivityPluginBinding activityPluginBinding, DartExecutor dartExecutor, int viewId) {
        this.channel = new MethodChannel(dartExecutor, "facedetectionview_" + viewId);
        this.activityPluginBinding = activityPluginBinding;
        this.channel.setMethodCallHandler(this);
        if (getCameraView() == null) {
            cameraView = new CameraBaseView(activityPluginBinding.getActivity());
            cameraView.setCameraViewInterface(this);

            activityPluginBinding.addRequestPermissionsResultListener(cameraView);
        }
    }

    @Override
    public View getView() {
        return getCameraView().getView();
    }

    @Override
    public void dispose() {
        if (getCameraView() != null) {
            getCameraView().dispose();
        }
    }

    @Override
    public void onFrame(Bitmap bitmap) {

        ArrayList<HashMap<String, Object>> platesMap = new ArrayList<HashMap<String, Object>>();

        int widthInBytes = bitmap.getRowBytes();
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        ByteBuffer nativeBuffer = ByteBuffer.allocateDirect(widthInBytes * height);
        bitmap.copyPixelsToBuffer(nativeBuffer);
        nativeBuffer.rewind();

        AlprResult alprResult = AlprSdk.process(
            SDK_IMAGE_TYPE.ULTALPR_SDK_IMAGE_TYPE_RGBA32,
            nativeBuffer, width, height
        );

        List<AlprUtils.Plate> plates = AlprUtils.extractPlates(alprResult);
        if(plates != null) {
          for(int i = 0; i < plates.size(); i ++) {
                AlprUtils.Plate plate = plates.get(i);
                HashMap<String, Object> e = new HashMap<String, Object>();
  
                float x1 = 65536.0f;
                float y1 = 65536.0f;
                float x2 = 0.0f;
                float y2 = 0.0f;
                float[] wrapper = plate.getWarpedBox();
                if(wrapper[0] < x1) {
                    x1 = wrapper[0];
                }
                if(wrapper[1 * 2] < x1) {
                    x1 = wrapper[1 * 2];
                }
                if(wrapper[2 * 2] < x1) {
                    x1 = wrapper[2 * 2];
                }
                if(wrapper[3 * 2] < x1) {
                    x1 = wrapper[3 * 2];
                }

                if(wrapper[0 * 2 + 1] < y1) {
                    y1 = wrapper[0 * 2 + 1];
                }
                if(wrapper[1 * 2 + 1] < y1) {
                    y1 = wrapper[1 * 2 + 1];
                }
                if(wrapper[2 * 2 + 1] < y1) {
                    y1 = wrapper[2 * 2 + 1];
                }
                if(wrapper[3 * 2 + 1] < y1) {
                    y1 = wrapper[3 * 2 + 1];
                }

                if(wrapper[0 * 2] > x2) {
                    x2 = wrapper[0 * 2];
                }
                if(wrapper[1 * 2] > x2) {
                    x2 = wrapper[1 * 2];
                }
                if(wrapper[2 * 2] > x2) {
                    x2 = wrapper[2 * 2];
                }
                if(wrapper[3 * 2] > x2) {
                    x2 = wrapper[3 * 2];
                }

                if(wrapper[0 * 2 + 1] > y2) {
                    y2 = wrapper[0 * 2 + 1];
                }
                if(wrapper[1 * 2 + 1] > y2) {
                    y2 = wrapper[1 * 2 + 1];
                }
                if(wrapper[2 * 2 + 1] > y2) {
                    y2 = wrapper[2 * 2 + 1];
                }
                if(wrapper[3 * 2 + 1] > y2) {
                    y2 = wrapper[3 * 2 + 1];
                }

                e.put("x1", x1);
                e.put("y1", y1);
                e.put("x2", x2);
                e.put("y2", y2);
                e.put("frameWidth", bitmap.getWidth());
                e.put("frameHeight", bitmap.getHeight());
                e.put("number", plate.getNumber());
                e.put("score", String.valueOf(plate.getRecognitionConfidence()));
                platesMap.add(e);
          }
        }

        Message message = new Message();
        message.what = 1;
        message.obj = platesMap;
        channelHandler.sendMessage(message);
    }
}
