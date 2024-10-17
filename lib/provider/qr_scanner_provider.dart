import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/qr_scanner_utils.dart';



class QRScannerProvider with ChangeNotifier {
  final MobileScannerController mobileScannerController =
      MobileScannerController();
  bool isFlashOff = true;
  File? _image;
  String galleryResult = '';
  double zoomLevel = 0.0;

  Future<void> pickImageFromGallery(
      BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      galleryResult = '';
      await scanQR(context);
    }
  }

  Future<void> scanSharedQRImage(String path, BuildContext context,
      ) async {
    _image = File(path);
    await scanQR(context);
  }

  Future<void> scanQR(
      BuildContext context, ) async {
    if (_image == null) return;
    final scannedCode = await QRScannerUtils.analyzeImage(_image!.path);

    if (scannedCode != null) {
      galleryResult = scannedCode;
      QRScannerUtils.showScannedDialog(context, scannedCode, () async {
        mobileScannerController.start();
      });
    } else {
      QRScannerUtils.showErrorDialog(context, 'No QR Code Detected.');
    }
    notifyListeners();
  }

  void onBarcodeDetected(String? scannedCode,
       BuildContext context) {
    if (scannedCode != null) {
      mobileScannerController.stop();
      QRScannerUtils.showScannedDialog(context, scannedCode, () async {

        mobileScannerController.start();
      });
    }
  }

  void onZoom(double value) {
    zoomLevel = value;
    mobileScannerController.setZoomScale(zoomLevel);
    notifyListeners();
  }

  void onFlipCamera() {
    onZoom(0);
    mobileScannerController.switchCamera();
  }

  void onToggleFlash() {
    mobileScannerController.toggleTorch();
    isFlashOff = !isFlashOff;
    notifyListeners();
  }

  @override
  void dispose() {
    mobileScannerController.dispose();
    super.dispose();
  }
}
