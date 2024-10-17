import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_and_generator/provider/qr_generator_provider.dart';
import 'package:screenshot/screenshot.dart';

class PrettyQrAnimatedView extends StatelessWidget {
  const PrettyQrAnimatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QRGeneratorProvider>(
      builder: (context, qrGeneratorProvider, _) {
        return Screenshot(
          controller: qrGeneratorProvider.screenshotController,
          child: Container(
            color: qrGeneratorProvider.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TweenAnimationBuilder<PrettyQrDecoration>(
                tween: PrettyQrDecorationTween(
                  begin: qrGeneratorProvider.previousDecoration,
                  end: qrGeneratorProvider.decoration,
                ),
                curve: Curves.ease,
                duration: const Duration(milliseconds: 240),
                builder: (context, decoration, child) {
                  return PrettyQrView(
                    qrImage: qrGeneratorProvider.qrImage,
                    decoration: decoration,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}