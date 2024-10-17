import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_and_generator/utils/svg_constant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme_provider.dart';
// import '../../widget/banner_ad_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri params = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Contact From QRchive&body=Hi!\n');

    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      debugPrint('Could not launch $params');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Contact Us'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Contact Us'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Muhammad Umair Ali'),
                          subtitle: const Text('appdev.umair@gmail.com'),
                          onTap: () => _launchEmail('appdev.umair@gmail.com'),
                        ),
                        ListTile(
                          title: const Text('Zain Iqbal'),
                          subtitle: const Text('appdev.zain@gmail.com'),
                          onTap: () => _launchEmail('appdev.zain@gmail.com'),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'QR Scanner & Generator',
                  applicationVersion: '1.1.7',
                  applicationIcon: const Icon(Icons.qr_code),
                  children: <Widget>[
                    const Text(
                        'This is a QR app that allows you to Scan and Generate QR codes.'),
                  ],
                );
              },
            ),
            const Divider(),
            const SizedBox(
              height: 20,
            ),
            SvgPicture.asset(
              SvgConstant.qrCodeBor,
              height: 300,
              width: 300,
            ),
            const SizedBox(
              height: 80,
            )
          ],
        ),
      ),
    );
  }
}
