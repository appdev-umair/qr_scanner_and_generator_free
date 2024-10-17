import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_and_generator/utils/svg_constant.dart';
import '../utils/launch_url.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/scans_history_provider.dart';

class ScansHistoryScreen extends StatelessWidget {
  const ScansHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Saved QR'),
        actions: [
          Consumer<ScansHistoryProvider>(
            builder: (context, scansProvider, child) {
              final selectedQrCodes = scansProvider.selectedQrCodes;
              final isSelectionMode = scansProvider.isSelectionMode;
              final allSelected =
                  selectedQrCodes.length == scansProvider.qrCodes.length;

              return Row(
                children: [
                  if (isSelectionMode)
                    IconButton(
                      icon:
                          Icon(allSelected ? Icons.deselect : Icons.select_all),
                      onPressed: () {
                        if (allSelected) {
                          scansProvider.deselectAll();
                        } else {
                          scansProvider.selectAll();
                        }
                      },
                    ),
                  if (isSelectionMode && selectedQrCodes.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => scansProvider.shareQR(),
                    ),
                  if (isSelectionMode && selectedQrCodes.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        if (selectedQrCodes.isNotEmpty) {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                  'Are you sure you want to delete the selected QR codes?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white),
                                  child: const Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            final codesToDelete = List.from(selectedQrCodes);
                            for (var qrCode in codesToDelete) {
                              await scansProvider.deleteScans(qrCode);
                            }
                          }
                        }
                      },
                    ),
                  if (isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        scansProvider.endSelectionMode();
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: Provider.of<ScansHistoryProvider>(context, listen: false)
              .fetchQrCodes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Consumer<ScansHistoryProvider>(
                builder: (context, scansProvider, child) {
                  final selectedQrCodes = scansProvider.selectedQrCodes;
                  final isSelectionMode = scansProvider.isSelectionMode;
                  final qrCodes = scansProvider.qrCodes;

                  if (qrCodes.isEmpty) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            SvgConstant.emptyCuate,
                            height: 300,
                            width: 300,
                          ),
                          const Text(
                            'Nothing here!',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 80,
                          )
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: qrCodes.length,
                          itemBuilder: (context, index) {
                            final qrCode = qrCodes[index];
                            final isSelected = selectedQrCodes.any(
                                (element) => element['id'] == qrCode['id']);

                            return Column(
                              children: [
                                ListTile(
                                  tileColor: isSelected
                                      ? Colors.blueGrey.withOpacity(0.2)
                                      : Colors.transparent,
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(qrCode['qr_code']
                                              .toString()
                                              .length >
                                          21
                                      ? "${qrCode['qr_code'].toString().substring(0, 20)} ..."
                                      : qrCode['qr_code']),
                                  subtitle: Text(qrCode['scannedAt']),
                                  trailing: isSelectionMode
                                      ? Checkbox(
                                          value: isSelected,
                                          onChanged: (bool? value) {
                                            scansProvider
                                                .toggleSelection(qrCode);
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.share),
                                          onPressed: () {
                                            Share.share(qrCode['qr_code']);
                                          },
                                        ),
                                  onTap: () async {
                                    if (isSelectionMode) {
                                      scansProvider.toggleSelection(qrCode);
                                    } else {
                                      final url = qrCode['qr_code'];
                                      if (!await launchURL(url)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Could not launch URL'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  onLongPress: () {
                                    scansProvider.startSelectionMode();
                                    scansProvider.toggleSelection(qrCode);
                                  },
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
