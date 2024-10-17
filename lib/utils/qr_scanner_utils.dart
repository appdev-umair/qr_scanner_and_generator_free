import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_and_generator/utils/reg_exp.dart';
import 'package:qr_scanner_and_generator/utils/save_qr_code.dart';

import 'launch_url.dart';

class QRScannerUtils {
  static Future<String?> analyzeImage(String imagePath) async {
    final MobileScannerController controller = MobileScannerController();
    final result = await controller.analyzeImage(imagePath);
    return result?.barcodes.isNotEmpty ?? false
        ? result?.barcodes.first.rawValue
        : null;
  }

  static void showScannedDialog(
      BuildContext context, String? scannedCode, Function onClick) {
    TextEditingController controller = TextEditingController(text: scannedCode);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        surfaceTintColor: Colors.white,
        title: const Text("Scanned"),
        content: TextField(
          controller: controller,
          readOnly: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await saveQRCode(scannedCode);
              onClick();
              Navigator.of(ctx).pop();
            },
            child: const Text("Cancel"),
          ),
          if (linkPattern.hasMatch("$scannedCode"))
            TextButton(
              onPressed: () async {
                await saveQRCode(scannedCode);
                onClick();
                launchURL(scannedCode);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white),
              child: const Text("Launch"),
            ),
        ],
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        surfaceTintColor: Colors.white,
        title: const Text("Not Scanned!"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
