import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this package
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../provider/qr_scanner_provider.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Enforce portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final qrScannerProvider = Provider.of<QRScannerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("QR Scanner"),
        actions: [
          IconButton(
            onPressed: () {
              qrScannerProvider.pickImageFromGallery(context);
            },
            tooltip: 'Pick Image from Gallery',
            icon: const Icon(Icons.image),
          ),
          IconButton(
            onPressed: () {
              qrScannerProvider.onFlipCamera();
            },
            tooltip: 'Switch Camera',
            icon: const Icon(Icons.flip_camera_android),
          ),
          IconButton(
            onPressed: () {
              qrScannerProvider.onToggleFlash();
            },
            tooltip: qrScannerProvider.isFlashOff
                ? "Turn Flashlight On"
                : "Turn Flashlight Off",
            icon: Icon(
              qrScannerProvider.isFlashOff
                  ? Icons.flashlight_off
                  : Icons.flashlight_on,
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: MobileScanner(
        controller: qrScannerProvider.mobileScannerController,
        onDetect: (barcodeCapture) {
          final Barcode barcode = barcodeCapture.barcodes.first;
          qrScannerProvider.onBarcodeDetected(
              barcode.rawValue,context);
        },
        overlayBuilder: (context, constraints) {
          return Stack(
            children: [
              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      width: 400,
                      height: 400,
                      child: Lottie.asset('assets/scanner.json',
                          height: 300, width: 300),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 150.0,
                left: 30.0,
                right: 30.0,
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white),
                        icon: const Icon(Icons.zoom_out),
                        tooltip: 'Zoom out',
                        onPressed: () {
                          double value = qrScannerProvider.zoomLevel - 0.1;
                          if (value > 0) {
                            qrScannerProvider.onZoom(value);
                          }
                        },
                      ),
                      Slider(
                        value: qrScannerProvider.zoomLevel,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          qrScannerProvider.onZoom(value);
                        },
                        activeColor: Colors.teal,
                        inactiveColor: Colors.grey,
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white),
                        tooltip: 'Zoom in',
                        icon: const Icon(Icons.zoom_in),
                        onPressed: () {
                          double value = qrScannerProvider.zoomLevel + 0.1;
                          if (value < 1) {
                            qrScannerProvider.onZoom(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        scanWindow: Rect.fromCenter(
          center: Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height * 0.5,
          ),
          width: 300,
          height: 300,
        ),
        scanWindowUpdateThreshold: 0.0, // Adjust this value as needed
      ),
    );
  }
}
