import 'package:flutter/material.dart';
import '/utils/reg_exp.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchURL(String? url) async {
  try {
    if (url != null && url.isNotEmpty) {
      bool matched = linkPattern.hasMatch(url);
      debugPrint("$matched");
      if (matched &&
          (!url.startsWith('http://') && !url.startsWith('https://'))) {
        url = 'http://$url';
        debugPrint(url);
      }
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
    }
    return true;
  } catch (e) {
    debugPrint('Error launching URL: $e');
    return false;
  }
}
