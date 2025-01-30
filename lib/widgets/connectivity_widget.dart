import 'package:flutter/material.dart';

class NetworkConnectivitySnackbar extends StatelessWidget {
  final bool isConnected;

  NetworkConnectivitySnackbar({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Network Connection'),
          ),
        );
      });
    }
    return Container();
  }
}
