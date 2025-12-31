import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_string.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
// import 'package:sdk_pms/core/utils/dialog_utils/app_snackbar.dart';
// import 'package:sdk_pms/general_import.dart';

class QrCaptureWidget extends StatefulWidget {
  const QrCaptureWidget({super.key, required this.qrData, this.onDone});
  final String qrData;
  final Function? onDone;
  @override
  State<QrCaptureWidget> createState() => _QrCaptureWidgetState();
}

class _QrCaptureWidgetState extends State<QrCaptureWidget> {
  final GlobalKey _globalKey = GlobalKey();
  @protected
  late QrImage qrImage;

  @protected
  late QrCode qrCode;
  // Uint8List? _capturedImageBytes;

  @override
  void initState() {
    qrCode = QrCode(
      8,
      QrErrorCorrectLevel.H,
    )..addData(widget.qrData);

    qrImage = QrImage(qrCode);
    super.initState();
    // _capturedImageBytes = null;
  }

  Future<void> _captureQR() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await _saveImageToGallery(pngBytes);
      widget.onDone?.call();
    } catch (e) {
      // PMSSnackBar.bottomFixedWarning.show(message: e.toString());
    }
  }

  Future<void> _saveImageToGallery(Uint8List imageBytes) async {
    // Yêu cầu quyền
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print('❌ Không có quyền truy cập bộ nhớ.');
      return;
    }
    try {
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: "qr_code_${DateTime.now().millisecondsSinceEpoch}",
      );
      if (result['isSuccess'] == true) {
        print('✅ Đã lưu ảnh vào album.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã lưu ảnh vào thư viện.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Lưu ảnh thất bại.')),
        );
      }
    } catch (e) {
      print('❌ Lỗi khi kiểm tra quyền truy cập bộ nhớ: $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: _globalKey,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PrettyQrView.data(
                data: widget.qrData,
                errorCorrectLevel: QrErrorCorrectLevel.H,
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(color: Colors.black),
                ),
              ),
              Text(
                widget.qrData,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _captureQR,
          child: const Text('Lưu ảnh QR'),
        ),
      ],
    );
  }
}
