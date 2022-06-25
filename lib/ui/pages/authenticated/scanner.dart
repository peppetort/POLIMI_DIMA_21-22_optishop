import 'dart:io';

import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

Logger _logger = Logger('ScannerPage');

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _flashOn = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _getProduct(BuildContext context, String scannedCode) async {
    String? productId = await Provider.of<DataProvider>(context, listen: false)
        .getProductByEAN(scannedCode);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProductAlert(
          productId: productId,
          onClose: () {
            controller!.resumeCamera();
          },
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        _getProduct(context, scanData.code!);
      }
    });
  }

  List<double> _getBarCodeRectSize(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    double rectWidth = deviceWidth * 0.5;
    double rectHeight = 0;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      rectHeight = deviceHeight / deviceWidth * rectWidth * 0.8;
    } else {
      rectHeight = deviceWidth / deviceHeight * rectWidth * 0.9;
    }

    return [rectWidth, rectHeight];
  }

  @override
  Widget build(BuildContext context) {
    List<double> rectSize = _getBarCodeRectSize(context);

    return Scaffold(
      backgroundColor: OptiShopAppTheme.primaryColor,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                  Center(
                    child: CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: RectPainter(rectSize.first, rectSize.last),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 80.0,
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 20.0,
                      ),
                      InkWell(
                        onTap: () async {
                          await controller?.flipCamera();
                        },
                        child: Icon(
                          Icons.flip_camera_ios_outlined,
                          size: 35.0,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      InkWell(
                        onTap: () async {
                          await controller?.toggleFlash();
                          setState(() {
                            _flashOn = !_flashOn;
                          });
                        },
                        child: Icon(
                          _flashOn
                              ? Icons.flashlight_off_outlined
                              : Icons.flashlight_on_outlined,
                          size: 35.0,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Annulla',
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RectPainter extends CustomPainter {
  double width;
  double height;

  RectPainter(this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            ..addRRect(RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(size.width * 0.5, size.height * 0.5),
                    width: width,
                    height: height),
                const Radius.circular(5)))
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
