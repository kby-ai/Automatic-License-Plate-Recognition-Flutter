package com.kbyai.alprsdk_plugin

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.util.Log
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import android.os.Handler
import android.os.Message
import android.view.ViewGroup

import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner


import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.fotoapparat.Fotoapparat
import io.fotoapparat.parameter.Resolution
import io.fotoapparat.preview.Frame
import io.fotoapparat.selector.front
import io.fotoapparat.selector.back
import io.fotoapparat.configuration.CameraConfiguration
import io.fotoapparat.view.CameraView
import io.fotoapparat.util.FrameProcessor

import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit
import java.util.concurrent.ExecutorService
import org.buyun.alpr.sdk.SDK_IMAGE_TYPE
import org.buyun.alpr.sdk.AlprSdk
import org.buyun.alpr.sdk.AlprCallback
import org.buyun.alpr.sdk.AlprResult
import java.nio.ByteBuffer

import android.graphics.*
import java.io.FileDescriptor
import java.io.FileOutputStream


class CameraBaseView(activity: Activity): PluginRegistry.RequestPermissionsResultListener {

    private lateinit var activity: Activity
    private var cameraLens = 0
    private var cameraViewInterface: CameraViewInterface? = null
    private lateinit var linearLayout: FrameLayout
    private lateinit var dummyLayout: FrameLayout
    private lateinit var cameraView: CameraView
    private lateinit var frontFotoapparat: Fotoapparat

    init {
        this.activity = activity

        linearLayout = FrameLayout(activity)
        linearLayout.setLayoutParams(
            FrameLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
        )
        linearLayout.setBackgroundColor(Color.parseColor("#000000"))

        cameraView = CameraView(activity)
        cameraView!!.setLayoutParams(
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT))

        linearLayout.addView(cameraView)

        dummyLayout = FrameLayout(activity)
        dummyLayout.setLayoutParams(
            FrameLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
        )
        dummyLayout.setBackgroundColor(Color.parseColor("#000000"))
        linearLayout.addView(dummyLayout)

        frontFotoapparat = Fotoapparat.with(activity)
            .into(cameraView)
            .lensPosition(back())
            .frameProcessor(SampleFrameProcessor())
            .cameraErrorCallback{error -> Log.e("TestEngine", "error: " + error)}
            .build()
            
    }

    fun setCameraViewInterface(cameraViewInterface: CameraViewInterface) {
        this.cameraViewInterface = cameraViewInterface
    }

    fun getContext(): Context? {
        return activity
    }

    fun startCamera(cameraLens: Int) {
        this.cameraLens = cameraLens
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
            === PackageManager.PERMISSION_DENIED
        ) {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf<String>(Manifest.permission.CAMERA),
                1
            )
        } else {
            val configuration = CameraConfiguration()
            /*if(this.cameraLens == 1) {
                frontFotoapparat.switchTo(lensPosition = front(),
                    cameraConfiguration = configuration)
            } else {
                frontFotoapparat.switchTo(lensPosition = back(),
                    cameraConfiguration = configuration)
            }*/
            frontFotoapparat.start()
        }
    }

    fun stopCamera() {
        frontFotoapparat.stop()
        dummyLayout.visibility = View.VISIBLE
    }

    fun getView(): View? {
        return linearLayout
    }

    fun dispose() {
        frontFotoapparat.stop()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == 1) {
            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
                === PackageManager.PERMISSION_GRANTED
            ) {
                val configuration = CameraConfiguration()
                if(this.cameraLens == 1) {
                    frontFotoapparat.switchTo(lensPosition = front(),
                        cameraConfiguration = configuration)
                } else {
                    frontFotoapparat.switchTo(lensPosition = back(),
                        cameraConfiguration = configuration)
                }
                frontFotoapparat.start()
            }
        }
        return true
    }

    inner class SampleFrameProcessor : FrameProcessor {
        override fun invoke(frame: Frame) {
            activity.runOnUiThread{dummyLayout.visibility = View.INVISIBLE}

            val exifOrientation: Int = when (frame.rotation) {
                90 -> ExifInterface.ORIENTATION_ROTATE_270
                180 -> ExifInterface.ORIENTATION_ROTATE_180
                270 -> ExifInterface.ORIENTATION_ROTATE_90
                else -> ExifInterface.ORIENTATION_NORMAL
            }

            val bitmap = AlprSdk.yuv2Bitmap(frame.image, frame.size.width, frame.size.height, exifOrientation)
            cameraViewInterface?.onFrame(bitmap)
        }
    }
}