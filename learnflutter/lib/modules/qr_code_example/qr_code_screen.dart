import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/cccd_scan_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_blinking_border_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_border.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_laser_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_rotating_border_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/overlay/qr_scan_zigzag_overlay.dart';
import 'package:learnflutter/modules/qr_code_example/widget/qr_capture_widget.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';
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
  bool isFlashOn = false;

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
    return Stack(
      children: <Widget>[
        Positioned.fill(top: 0, child: _buildQrView(context)),
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: DeviceDimension.defaultSize(36),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: DeviceDimension.defaultSize(36),
              ),
              onPressed: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                });
                controller?.toggleFlash();
              },
            ),
          ],
        ),
        Positioned.fill(
          top: DeviceDimension.statusBarHeight(context) + DeviceDimension.appBar + DeviceDimension.padding * 2,
          child: Text(
            'Di chuyển camera đến mã QR để quét',
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: DeviceDimension.padding / 2),
        ),
        Positioned.fill(
          top: DeviceDimension.statusBarHeight(context) + DeviceDimension.screenHeight / 2,
          child: GestureDetector(
            onTap: pickImageAndScanQRCode,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.photo_rounded,
                    color: Colors.white,
                  ),
                  onPressed: pickImageAndScanQRCode,
                ),
                Text(
                  'Chọn ảnh từ thư viện',
                  style: context.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ).paddingOnly(left: DeviceDimension.padding / 2),
              ],
            ).center(),
          ).paddingSymmetric(vertical: DeviceDimension.padding),
        ),
      ],
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
          // top: DeviceDimension.statusBarHeight(context) + DeviceDimension.appBar,
          // left: DeviceDimension.padding,
          // right: DeviceDimension.padding,
          // bottom: DeviceDimension.screenHeight / 4,
          child: QRBorderOverlay(
            borderColor: Colors.blue,
            borderLength: DeviceDimension.defaultSize(36),
            strokeWidth: DeviceDimension.defaultSize(6),
            scanAreaSize: context.mediaQuery.size.width * 0.7,
            // size: context.mediaQuery.size,
          ),
          // RotatingBorderOverlay(width: context.mediaQuery.size.width * 0.8, height: context.mediaQuery.size.width * 0.8),
        ),
        // Positioned(
        //   child: BlinkingBorderOverlay(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
        // ),
        // Positioned(
        //   child: ZigZagLaserOverlay(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.width * 0.8),
        // ),
        Positioned.fill(
          top: DeviceDimension.statusBarHeight(context) + DeviceDimension.appBar + DeviceDimension.padding * 5,
          left: DeviceDimension.padding * 3,
          right: DeviceDimension.padding * 3,
          child: QRScanLaserOverlay(
            key: laserKey,
            size: Size(context.mediaQuery.size.width * 0.7, context.mediaQuery.size.width * 0.7),
          ).paddingOnly(
            top: DeviceDimension.statusBarHeight(context) + DeviceDimension.appBar,
          ),
        ),
        // CccdScanOverlay()
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
        // controller.pauseCamera();
        // laserKey.currentState?.stop();
      });
      SnackBar(content: Text(result?.code ?? ""));
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
