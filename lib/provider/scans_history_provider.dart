import 'package:flutter/material.dart';
import '/database/db_helper.dart';
import 'package:share_plus/share_plus.dart';

class ScansHistoryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _selectedQrCodes = [];
  List<Map<String, dynamic>> _qrCodes = [];
  bool _isSelectionMode = false;

  List<Map<String, dynamic>> get selectedQrCodes => _selectedQrCodes;
  List<Map<String, dynamic>> get qrCodes => _qrCodes;
  bool get isSelectionMode => _isSelectionMode;

  void startSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  void endSelectionMode() {
    _isSelectionMode = false;
    _selectedQrCodes.clear();
    notifyListeners();
  }

    void selectAll() {
    _selectedQrCodes.clear();
    _selectedQrCodes.addAll(_qrCodes);
    notifyListeners();
  }

  void deselectAll() {
    _selectedQrCodes.clear();
    notifyListeners();
  }

  void toggleSelection(Map<String, dynamic> qrCode) {
    bool exists =
        _selectedQrCodes.any((element) => element['id'] == qrCode['id']);

    if (exists) {
      _selectedQrCodes.removeWhere((element) => element['id'] == qrCode['id']);
    } else {
      _selectedQrCodes.add(qrCode);
    }

    debugPrint("$_selectedQrCodes}");
    notifyListeners();
  }

  Future<void> deleteScans(Map<String, dynamic> qrCode) async {
    await DatabaseHelper().deleteQrCode(qrCode['id']);
    _selectedQrCodes.removeWhere((element) => element['id'] == qrCode['id']);
    await fetchQrCodes();
    if(_qrCodes.isEmpty){
      endSelectionMode();
    }
    notifyListeners();
  }

  void shareQR({Map<String, dynamic>? qrCode}) {
    if (qrCode == null) {
      final codesToShare = selectedQrCodes.map((e) => e['qr_code']).join('\n');
      Share.share(codesToShare);
    } else {
      Share.share(qrCode['qr_code']);
    }
  }

  Future<void> fetchQrCodes() async {
    _qrCodes = await DatabaseHelper().getQrCodes();
    notifyListeners();
  }

  void clearSelection() {
    _selectedQrCodes.clear();
    notifyListeners();
  }
}
