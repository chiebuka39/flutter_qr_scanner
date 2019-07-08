package com.ncktech.flutter_qr_scanner

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.hardware.Camera
import android.os.Build
import android.view.View
import com.google.zxing.BarcodeFormat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import me.dm7.barcodescanner.zxing.ZXingScannerView

/**
 * Created by Wilberforce on 2019-06-21 at 13:57.
 */
class QrCodeScannerViewFactory(private val registrar: PluginRegistry.Registrar) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, id: Int, obj: Any?): PlatformView {
        return QrCodeScannerView(registrar, id)
    }

}

class QrCodeScannerView(private val registrar: PluginRegistry.Registrar, id: Int) : PlatformView, MethodChannel.MethodCallHandler {
    override fun onMethodCall(p0: MethodCall, p1: MethodChannel.Result) {
        when (p0.method) {
            "flipCamera" -> {
                flipCamera()
            }
            "flipFlash" -> {
                flipFlash()
            }
        }
    }

    var barcodeView: ZXingScannerView? = null
    private val activity = registrar.activity()
    private var cameraPermissionContinuation: Runnable? = null
    private var requestingPermission = false
    private val channel: MethodChannel
    private var cameraId = Camera.CameraInfo.CAMERA_FACING_BACK

    companion object {
        const val CAMERA_REQUEST_ID = 987654
    }

    init {
        registrar.addRequestPermissionsResultListener(CameraRequestPermissionsListener())
        channel = MethodChannel(registrar.messenger(), "com.ncktech.flutter_qr_scanner/qrview_$id")
        channel.setMethodCallHandler(this)
        checkAndRequestPermission()
        registrar.activity().application.registerActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
            override fun onActivityPaused(activity: Activity?) {
                if (activity == registrar.activity()) {
                    barcodeView?.stopCamera()
                }
            }

            override fun onActivityResumed(activity: Activity?) {
                super.onActivityResumed(activity)
                if (activity == registrar.activity()) {
                    restartScanner()
                }
            }
        })
    }

    private fun flipCamera() {
        barcodeView?.stopCamera()

        cameraId = if (cameraId == Camera.CameraInfo.CAMERA_FACING_FRONT)
            Camera.CameraInfo.CAMERA_FACING_BACK
        else
            Camera.CameraInfo.CAMERA_FACING_FRONT

        restartScanner()
    }

    private fun flipFlash() {
        barcodeView?.flash = !barcodeView!!.flash
    }

    private fun initBarCodeView(): ZXingScannerView {
        if (barcodeView == null) {
            barcodeView = createBarCodeView()
        }
        return barcodeView!!
    }

    private fun createBarCodeView(): ZXingScannerView? {
        val scannerView = ZXingScannerView(registrar.activity())
        scannerView.setAutoFocus(true)
        scannerView.setFormats(mutableListOf(BarcodeFormat.QR_CODE))
        // this parameter will make your HUAWEI phone works great!
        scannerView.setAspectTolerance(0.5f)
        return scannerView
    }

    val resultHandler = ZXingScannerView.ResultHandler {
        channel.invokeMethod("onScanned", it.text)
    }

    override fun getView(): View {
        return initBarCodeView().apply {
            restartScanner()
        }
    }

    override fun dispose() {
        barcodeView?.stopCamera()
        barcodeView = null
    }

//    override fun onMethodCall(call: MethodCall?, result: MethodChannel.Result?) {
//
//    }


    private fun hasCameraPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                activity.checkSelfPermission(Manifest.permission.CAMERA) == PERMISSION_GRANTED
    }

    private  fun restartScanner() {
        barcodeView?.setResultHandler(resultHandler)
        barcodeView?.startCamera(cameraId)
    }


    private fun checkAndRequestPermission() {
        if (cameraPermissionContinuation != null) {
            channel.invokeMethod("onPermissionDenied", null)
        }

        cameraPermissionContinuation = Runnable {
            cameraPermissionContinuation = null
            if (!hasCameraPermission()) {
                channel.invokeMethod("onPermissionDenied", null)
                return@Runnable
            }
        }

        requestingPermission = false
        if (hasCameraPermission()) {
            cameraPermissionContinuation?.run()
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                requestingPermission = true
                registrar
                        .activity()
                        .requestPermissions(
                                arrayOf(Manifest.permission.CAMERA),
                                CAMERA_REQUEST_ID)
            }
        }
    }

    private inner class CameraRequestPermissionsListener : PluginRegistry.RequestPermissionsResultListener {
        override fun onRequestPermissionsResult(id: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
            if (id == CAMERA_REQUEST_ID && grantResults[0] == PERMISSION_GRANTED) {
                cameraPermissionContinuation?.run()
                return true
            }
            channel.invokeMethod("onPermissionDenied", null)
            return false
        }
    }


}