import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_blinking_border_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_laser_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_rotating_border_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_zigzag_overlay.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final GlobalKey<QRScanLaserOverlayState> laserKey = GlobalKey();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: Column(
        children: <Widget>[
          Expanded(flex: 8, child: _buildQrView(context)),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: pickImageAndScanQRCode,
                    child: Text("Chọn ảnh từ thư viện"),
                  ),
                  if (result != null)
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}',
                        ))
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text('Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text('pause', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: const Text('resume', style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> pickImageAndScanQRCode() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final qrCode = await QrCodeToolsPlugin.decodeFrom(pickedFile.path);
        if (qrCode != null && qrCode.isNotEmpty) {
          print('QR Code found: $qrCode');
          // TODO: xử lý QR thành công, ví dụ:
          // Navigator.pop(context, qrCode);
        } else {
          print('Không tìm thấy mã QR trong ảnh.');
        }
      } catch (e) {
        print('Lỗi khi quét QR từ ảnh: $e');
      }
    } else {
      print('Không chọn ảnh nào.');
    }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return Stack(
      alignment: Alignment.center,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: null,
          // onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        Positioned(
          child: RotatingBorderOverlay(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
        ),
        // Positioned(
        //   child: BlinkingBorderOverlay(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
        // ),
        // Positioned(
        //   child: ZigZagLaserOverlay(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
        // ),
        QRScanLaserOverlay(
          key: laserKey,
          size: MediaQuery.of(context).size.width * 0.8,
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller.pauseCamera();
        laserKey.currentState?.stop();
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
