import 'package:flutter/material.dart';

class ApiConfig {
  static String _root = "http://192.168.1.116:3000/";

  static String get root => _root;
  static String get apiURL => "${_root}driver";
  static String get apiURL2 => "${_root}assistant";

  static void updateRoot(String ipAddress) {
    _root = "http://$ipAddress/";
  }
}

Future<void> showIpConfigDialog(BuildContext context) async {
  final TextEditingController ipController = TextEditingController();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Server Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter IP address and port (e.g., 192.168.1.116:3000)'),
            const SizedBox(height: 10),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                hintText: 'x.x.x.x:xxxx',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              String ip = ipController.text.trim();
              if (ip.isNotEmpty) {
                ApiConfig.updateRoot(ip);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}