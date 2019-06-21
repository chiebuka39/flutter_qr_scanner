import 'package:flutter/material.dart';
import 'package:flutter_qr_scanner/flutter_qr_scanner.dart';

class QrCodeWidget extends StatefulWidget {
  @override
  _QrCodeWidgetState createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _qrViewKey = GlobalKey();
  QRViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.flash_on), onPressed: () => _controller.flipFlash()),
          IconButton(
              icon: Icon(Icons.switch_camera), onPressed: () => _controller.flipCamera())
        ],
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: QrScannerWidget(
                key: _qrViewKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey[800],
              padding: EdgeInsets.all(30),
              child: Column(
                children: <Widget>[
                  Text(
                    "Scan QR Code",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'It will scan automatically',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Powered by NCK',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final channel = controller.channel;
    controller.init(_qrViewKey);
    this._controller = controller;
    channel.setMethodCallHandler((call) async {
      print('Result______________________: ${call.method}');
      switch (call.method) {
        case "onScanned":
          var arguments = call.arguments;
          Navigator.of(context)
              .pop(QrResult(arguments.toString(), true, "Scan successful"));
          break;
        case "onPermissionDenied":
          Navigator.of(context).pop(QrResult(null, false, "Permission denied"));
          break;
        case "onScanError":
          Navigator.of(context)
              .pop(QrResult(null, false, "An error occured while scanning"));
      }
    });
  }
}