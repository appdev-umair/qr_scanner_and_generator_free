  import 'package:intl/intl.dart';

import '../database/db_helper.dart';

Future<void> saveQRCode(String? scannedCode) async {
    if (scannedCode == null || scannedCode.isEmpty) return;

    String scannedAt = DateFormat('dd-MM-yyyy – kk:mm').format(DateTime.now());
    Map<String, dynamic> qrCode = {
      'qr_code': scannedCode,
      'scannedAt': scannedAt,
    };

    await DatabaseHelper().insertQrCode(qrCode);
  }