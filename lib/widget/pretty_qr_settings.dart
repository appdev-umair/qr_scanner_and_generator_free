import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_and_generator/provider/qr_generator_provider.dart';

class PrettyQrSettings extends StatelessWidget {
  const PrettyQrSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QRGeneratorProvider>(
      builder: (context, qrGeneratorProvider, _) {
        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return PopupMenuButton(
                  onSelected: (Type type) =>
                      _changeShape(qrGeneratorProvider, type),
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  initialValue:
                      qrGeneratorProvider.decoration.shape.runtimeType,
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: PrettyQrSmoothSymbol,
                        child: Text('Smooth'),
                      ),
                      const PopupMenuItem(
                        value: PrettyQrRoundedSymbol,
                        child: Text('Circles'),
                      ),
                    ];
                  },
                  child: ListTile(
                    leading: const Icon(Icons.format_paint_outlined),
                    title: const Text('Style'),
                    trailing: Text(
                      qrGeneratorProvider.decoration.shape
                              is PrettyQrSmoothSymbol
                          ? 'Smooth'
                          : 'Circles',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                );
              },
            ),
            if (qrGeneratorProvider.decoration.shape is PrettyQrSmoothSymbol)
              SwitchListTile.adaptive(
                value: qrGeneratorProvider.isRoundedBorders,
                onChanged: (value) =>
                    _toggleRoundedCorners(qrGeneratorProvider),
                secondary: const Icon(Icons.rounded_corner),
                title: const Text('Rounded corners'),
              ),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('QR Code Color'),
              trailing: CircleAvatar(
                backgroundColor: qrGeneratorProvider.shapeColor,
              ),
              onTap: () => _showColorPicker(context, qrGeneratorProvider),
            ),
            ListTile(
              leading: const Icon(Icons.format_color_fill_outlined),
              title: const Text('Background Color'),
              trailing: CircleAvatar(
                backgroundColor: qrGeneratorProvider.backgroundColor,
              ),
              onTap: () =>
                  _showBackgroundColorPicker(context, qrGeneratorProvider),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(qrGeneratorProvider.decoration.image == null
                  ? 'Select Image'
                  : 'Change Image'),
              trailing: qrGeneratorProvider.decoration.image != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => qrGeneratorProvider.removeImage(),
                    )
                  : null,
              onTap: () => qrGeneratorProvider.pickImage(),
            ),
            if (qrGeneratorProvider.decoration.image != null)
              ListTile(
                leading: const Icon(Icons.layers_outlined),
                title: const Text('Image position'),
                trailing: PopupMenuButton<PrettyQrDecorationImagePosition>(
                  onSelected: (PrettyQrDecorationImagePosition value) {
                    _changeImagePosition(qrGeneratorProvider, value);
                  },
                  initialValue: qrGeneratorProvider.decoration.image!.position,
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: PrettyQrDecorationImagePosition.embedded,
                        child: Text('Embedded'),
                      ),
                      const PopupMenuItem(
                        value: PrettyQrDecorationImagePosition.foreground,
                        child: Text('Foreground'),
                      ),
                      const PopupMenuItem(
                        value: PrettyQrDecorationImagePosition.background,
                        child: Text('Background'),
                      ),
                    ];
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, QRGeneratorProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = provider.shapeColor;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                _changeColor(provider, pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundColorPicker(
      BuildContext context, QRGeneratorProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = provider.backgroundColor;
        return AlertDialog(
          title: const Text('Pick a background color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                provider.updateBackgroundColor(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeColor(QRGeneratorProvider provider, Color color) {
    var shape = provider.decoration.shape;
    if (shape is PrettyQrSmoothSymbol) {
      shape = PrettyQrSmoothSymbol(
        color: color,
        roundFactor: shape.roundFactor,
      );
    } else if (shape is PrettyQrRoundedSymbol) {
      shape = PrettyQrRoundedSymbol(
        color: color,
        borderRadius: shape.borderRadius,
      );
    }

    provider.updateDecoration(provider.decoration.copyWith(shape: shape));
  }

  void _changeShape(QRGeneratorProvider provider, Type type) {
    var shape = provider.decoration.shape;
    if (shape.runtimeType == type) return;

    if (shape is PrettyQrSmoothSymbol) {
      shape = PrettyQrRoundedSymbol(color: provider.shapeColor);
    } else if (shape is PrettyQrRoundedSymbol) {
      shape = PrettyQrSmoothSymbol(color: provider.shapeColor);
    }

    provider.updateDecoration(provider.decoration.copyWith(shape: shape));
  }

  void _toggleRoundedCorners(QRGeneratorProvider provider) {
    var shape = provider.decoration.shape;

    if (shape is PrettyQrSmoothSymbol) {
      shape = PrettyQrSmoothSymbol(
        color: shape.color,
        roundFactor: provider.isRoundedBorders ? 0 : 1,
      );
    } else if (shape is PrettyQrRoundedSymbol) {
      shape = PrettyQrRoundedSymbol(
        color: shape.color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      );
    }

    provider.updateDecoration(provider.decoration.copyWith(shape: shape));
  }

  void _changeImagePosition(
      QRGeneratorProvider provider, PrettyQrDecorationImagePosition value) {
    final image = provider.decoration.image?.copyWith(position: value);
    provider.updateDecoration(provider.decoration.copyWith(image: image));
  }
}
