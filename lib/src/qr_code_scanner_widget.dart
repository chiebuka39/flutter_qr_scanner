import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scanner/src/creation_params.dart';
import 'package:flutter_qr_scanner/src/qr_view_controller.dart';
import 'package:flutter_qr_scanner/src/qr_view_created_callback.dart';

class QrScannerWidget extends StatefulWidget {
  final QRViewCreatedCallback onQRViewCreated;

  const QrScannerWidget({Key key, this.onQRViewCreated}) : super(key: key);

  @override
  _QrScannerWidgetState createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  var viewType = "com.ncktech.flutter_qr_scanner/qrview";

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: CreationParams.fromWidget(0, 0).toMap(),
        creationParamsCodec: StandardMessageCodec(),
      );
    }

    return Text("$defaultTargetPlatform is not yet supported");
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onQRViewCreated == null) {
      return;
    }

    widget.onQRViewCreated(QRViewController(id));
  }
}

