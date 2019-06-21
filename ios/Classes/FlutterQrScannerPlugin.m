#import "FlutterQrScannerPlugin.h"
#import <flutter_qr_scanner/flutter_qr_scanner-Swift.h>

@implementation FlutterQrScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterQrScannerPlugin registerWithRegistrar:registrar];
}
@end
