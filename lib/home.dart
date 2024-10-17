import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'provider/qr_generator_provider.dart';
import 'provider/scans_history_provider.dart';
import 'screens/settings_screen.dart';
import 'provider/home_provider.dart';
import 'screens/qr_generator_screen.dart';
import 'provider/qr_scanner_provider.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/scans_history_screen.dart';
import 'utils/qr_scanner_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final screens = [
    const QRGeneratorScreen(),
    const QRScannerScreen(),
    const ScansHistoryScreen(),
    const SettingsScreen(),
  ];
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    // Listen to media sharing coming from outside the app while the app is in memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);

      // Process the shared files and scan the QR code
      _processSharedFiles(_sharedFiles);
    }, onError: (err) {});

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);

      // Process the shared files and scan the QR code
      _processSharedFiles(_sharedFiles);

      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
    });
  }

  Future<void> _processSharedFiles(List<SharedMediaFile> sharedFiles) async {
    if (sharedFiles.isNotEmpty) {
      final scannedCode =
          await QRScannerUtils.analyzeImage(sharedFiles.first.path);

      if (scannedCode != null) {
        QRScannerUtils.showScannedDialog(context, scannedCode, () async {});
      } else {
        QRScannerUtils.showErrorDialog(context, 'No QR Code Detected.');
      }
    }
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QRGeneratorProvider()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (_) => QRScannerProvider()),
        ChangeNotifierProvider(create: (_) => ScansHistoryProvider()),
      ],
      child: Builder(
        builder: (context) {
          final homeScreenProvider = Provider.of<HomeScreenProvider>(context);

          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.white,
            body: screens[homeScreenProvider.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: homeScreenProvider.currentIndex,
              onTap: (index) {
                homeScreenProvider.updateIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code),
                  label: 'Generate',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
