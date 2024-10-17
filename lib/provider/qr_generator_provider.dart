import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QRGeneratorProvider with ChangeNotifier {
  TextEditingController controller = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  PrettyQrDecoration _decoration =
      const PrettyQrDecoration(shape: PrettyQrSmoothSymbol(roundFactor: 0));
  late final TextEditingController imageSizeEditingController;
  late QrImage _qrImage;
  late QrCode _qrCode;
  PrettyQrDecoration _previousDecoration = const PrettyQrDecoration();

  PrettyQrDecoration get previousDecoration => _previousDecoration;
  PrettyQrDecoration get decoration => _decoration;
  QrImage get qrImage => _qrImage;
  QrCode get qrCode => _qrCode;

  Color _backgroundColor = Colors.white;

  Color get backgroundColor => _backgroundColor;
  void clearText() {
    controller.text = '';
    notifyListeners();
  }

  void updateBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  QRGeneratorProvider() {
    controller.addListener(_updateQrCode);
    imageSizeEditingController = TextEditingController(text: '512w');
    _updateQrCode(); // Generate initial QR code
  }

  void _updateQrCode() {
    _qrCode = QrCode.fromData(
      data: controller.text.isNotEmpty
          ? controller.text
          : 'Enter text to generate QR code',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    _qrImage = QrImage(_qrCode);
    notifyListeners();
  }

  void reset() {
    _decoration = const PrettyQrDecoration(shape: PrettyQrSmoothSymbol(roundFactor: 0));
    _backgroundColor = Colors.white;
    notifyListeners();
  }

  void updateDecoration(PrettyQrDecoration newDecoration) {
    _previousDecoration = _decoration;
    _decoration = newDecoration;
    notifyListeners();
  }

  void updateBgColor(Color newColor) {
    _previousDecoration = _decoration;
    _decoration = _decoration.copyWith(background: newColor);
    notifyListeners();
  }

Future<void> saveQrImage(BuildContext context) async {
  // Check and request necessary permissions based on Android version
  if (Platform.isAndroid) {
    if (await _requestPermissions()) {
      await _captureAndSaveImage(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to save images.'),
        ),
      );
      await openAppSettings();
    }
  } else {
    // Handle iOS or other platforms here if needed
    await _captureAndSaveImage(context);
  }
}

// Request necessary permissions based on Android version
Future<bool> _requestPermissions() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted || await Permission.mediaLibrary.isGranted) {
      return true;
    } else {
      final storageStatus = await Permission.storage.request();
      final mediaStatus = await Permission.mediaLibrary.request(); // For Android 13+
      return storageStatus.isGranted || mediaStatus.isGranted;
    }
  }
  return false;
}

// Capture the image and save it to the gallery
Future<void> _captureAndSaveImage(BuildContext context) async {
  try {
    final Uint8List? image = await screenshotController.capture();
    if (image != null) {
      final result = await ImageGallerySaver.saveImage(image);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code saved successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving QR Code!'),
          ),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error capturing or saving QR Code!'),
      ),
    );
  }
}

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final image = PrettyQrDecorationImage(
        image: FileImage(File(pickedFile.path)),
        position: PrettyQrDecorationImagePosition.embedded,
      );
      updateDecoration(_decoration.copyWith(image: image));
    }
  }

  void removeImage() {
    _decoration = PrettyQrDecoration(
      shape: _decoration.shape,
      background: _decoration.background,
      image: null,
    );
    notifyListeners();
  }

  int get imageSize {
    final rawValue = imageSizeEditingController.text;
    return int.parse(rawValue.replaceAll('w', '').replaceAll(' ', ''));
  }

  Color get shapeColor {
    var shape = decoration.shape;
    if (shape is PrettyQrSmoothSymbol) return shape.color;
    if (shape is PrettyQrRoundedSymbol) return shape.color;
    return Colors.black;
  }

  bool get isRoundedBorders {
    var shape = decoration.shape;
    if (shape is PrettyQrSmoothSymbol) {
      return shape.roundFactor > 0;
    } else if (shape is PrettyQrRoundedSymbol) {
      return shape.borderRadius != BorderRadius.zero;
    }
    return false;
  }

  Future<void> shareQrCode() async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final image = await screenshotController.capture();
    if (image != null) {
      try {
        String fileName = DateTime.now().microsecondsSinceEpoch.toString();
        final imagePath = await File('$directory/$fileName.png').create();
        imagePath.writeAsBytesSync(image);
        await Share.shareXFiles([XFile(imagePath.path)],
            text: 'Here is the QR code');
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    imageSizeEditingController.dispose();
    super.dispose();
  }
}
