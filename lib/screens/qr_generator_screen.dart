import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../provider/qr_generator_provider.dart';
import 'qr_code_screen.dart';
import '../utils/svg_constant.dart';

class QRGeneratorScreen extends StatelessWidget {
  const QRGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qrGeneratorProvider = Provider.of<QRGeneratorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Generator'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: qrGeneratorProvider.controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Enter here to generate QR Code',
                      suffixIcon: qrGeneratorProvider.controller.text.isNotEmpty
                          ? IconButton(
                              onPressed: () => qrGeneratorProvider.clearText(),
                              icon: const Icon(Icons.clear))
                          : null),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (qrGeneratorProvider.controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please enter text to generate a QR code.'),
                        ),
                      );
                    } else {
                      qrGeneratorProvider
                          .reset();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: qrGeneratorProvider,
                            child: const QRCodeScreen(),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Generate QR Code'),
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  SvgConstant.qrCodeRafiki,
                  height: 300,
                  width: 300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
