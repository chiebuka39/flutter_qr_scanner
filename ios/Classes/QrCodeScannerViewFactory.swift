//
//  QrCodeScannerViewFactor.swift
//  Runner
//
//  Created by Wilberforce Uwadiegwu on 20/06/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import UIKit
import MTBBarcodeScanner

class QrCodeScannerViewFactory: NSObject, FlutterPlatformViewFactory {
    
    var registrar: FlutterPluginRegistrar?
    
    public init(withRegistrar registrar: FlutterPluginRegistrar){
        super.init()
        self.registrar = registrar
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        var dictionary = args as! Dictionary<String, Double>
    
        return QrCodeScannerView(withFrame: CGRect(x: 0, y: 0, width: dictionary["width"] ?? 0, height: dictionary["height"] ?? 0), withRegistrar: registrar!, withId: viewId)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec(readerWriter: FlutterStandardReaderWriter())
    }
    
}

public class QrCodeScannerView: NSObject, FlutterPlatformView {
    @IBOutlet var previewView: UIView!
    var scanner: MTBBarcodeScanner?
    var channel: FlutterMethodChannel
    var registrar: FlutterPluginRegistrar
    
    public init(withFrame frame: CGRect, withRegistrar registrar: FlutterPluginRegistrar, withId id: Int64) {
        self.registrar = registrar
        channel = FlutterMethodChannel.init(name: "com.ncktech.flutter_qr_scanner/qrview_\(id)", binaryMessenger: registrar.messenger())
        previewView = UIView(frame: frame)
    }
    
    func isCameraAvailable(success: Bool) -> Void {
        if success {
            do {
                try scanner?.startScanning(resultBlock: {codes in
                    if let codes = codes {
                        let stringValue = codes[0].stringValue! // Get the first result
                        self.channel.invokeMethod("onScanned", arguments: stringValue)
                        self.scanner!.stopScanning()
                    }
                })
            } catch {
                self.channel.invokeMethod("onScanError", arguments: nil)
            }
        } else {
            self.channel.invokeMethod("onPermissionDenied", arguments: nil)
        }
    }
    
    
    
    public func view() -> UIView {
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch(call.method) {
            case "setDimensions":
                var arguments = call.arguments as! Dictionary<String, Double>
                self?.setDimensions(width: arguments["width"] ?? 0, height: arguments["height"] ?? 0)
            case "flipCamera":
                self?.flipCamera()
            case "flipFlash":
                self?.flipFlash()
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        return previewView
    }
    
    
    func setDimensions(width: Double, height: Double) -> Void {
        previewView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        scanner = MTBBarcodeScanner(previewView: previewView)
        MTBBarcodeScanner.requestCameraPermission(success: isCameraAvailable)
    }
    
    func flipCamera(){
        if let sc: MTBBarcodeScanner = scanner {
            if sc.hasOppositeCamera() {
                sc.flipCamera()
            }
        }
    }
    
    func flipFlash() {
        if let sc: MTBBarcodeScanner = scanner {
            if sc.hasTorch() {
                sc.toggleTorch()
            }
        }
    }
    
}
