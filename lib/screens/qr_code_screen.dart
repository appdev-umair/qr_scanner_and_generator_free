import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/qr_generator_provider.dart';
import '../widget/pretty_qr_animated_view.dart';
import '../widget/pretty_qr_settings.dart';

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final qrGeneratorProvider = Provider.of<QRGeneratorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_outlined)),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  surfaceTintColor: Colors.white,
                  title: const Text("Save QR Code"),
                  content: const Text('Do you want to save QR Code?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        qrGeneratorProvider.saveQrImage(context);
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white),
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () => qrGeneratorProvider.shareQrCode(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final safePadding = MediaQuery.of(context).padding;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (constraints.maxWidth >= 720)
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: safePadding.left + 24,
                          right: safePadding.right + 24,
                          bottom: 24,
                        ),
                        child: const PrettyQrAnimatedView(),
                      ),
                    ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        if (constraints.maxWidth < 720)
                          Padding(
                            padding: safePadding.copyWith(
                              top: 0,
                              bottom: 0,
                            ),
                            child: const PrettyQrAnimatedView(),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: safePadding.copyWith(top: 0),
                            child: const Column(
                              children: [
                                PrettyQrSettings(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
