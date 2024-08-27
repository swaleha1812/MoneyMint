import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class QRCodePage extends StatelessWidget {
  final String data;

  const QRCodePage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: data,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20.0),
            Text(
              'Data: $data',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
     // home: QRCodePage(data: 'ABC1234'), // Provide your data here
    );
  }
}
