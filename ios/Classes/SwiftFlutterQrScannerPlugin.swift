import Flutter
import UIKit

public class SwiftFlutterQrScannerPlugin: NSObject, FlutterPlugin {
    var factory: QrCodeScannerViewFactory
    
  public init(with registrar: FlutterPluginRegistrar) {
    self.factory = QrCodeScannerViewFactory(withRegistrar: registrar)
   registrar.register(factory, withId: "com.ncktech.flutter_qr_scanner/qrview")
  }

 public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.addApplicationDelegate(SwiftFlutterQrScannerPlugin(with: registrar))
    }
}
