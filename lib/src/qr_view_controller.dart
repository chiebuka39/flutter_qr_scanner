import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QRViewController {
  QRViewController(int id) : channel = MethodChannel("com.ncktech.flutter_qr_scanner/qrview_$id");

  final MethodChannel channel;

  init(GlobalKey qrKey) {
    if (Platform.isIOS) {
      final RenderBox renderBox = qrKey.currentContext.findRenderObject();
      channel.invokeMethod("setDimensions",
          {"width": renderBox.size.width, "height": renderBox.size.height});
    }
  }

  void flipCamera() {
    channel.invokeMethod("flipCamera");
  }

  void flipFlash() {
    channel.invokeMethod("flipFlash");
  }
}