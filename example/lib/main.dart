import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_qr_scanner/flutter_qr_scanner.dart';
import 'package:flutter_qr_scanner_example/qr_code_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeWidget(),);
  }
}


class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  QrResult qrResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton(
              onPressed: scanQR,
              child: Text("Scan QR"),
              color: Colors.blueAccent,
              textColor: Colors.white,
            ),
            SizedBox(height: 20),
            qrResult == null ? SizedBox() : Text(qrResult.toString())
          ],
        ),
      ),
    );
  }

  void scanQR() async {
    try {
      QrResult result = await Navigator.of(context).push<QrResult>(
          MaterialPageRoute(builder: (_) => QrCodeWidget(), fullscreenDialog: true));
      this.qrResult = result;
    } on PlatformException catch (e) {}
  }
}
