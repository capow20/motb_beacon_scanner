import 'package:flutter/material.dart';
import 'package:motb_beacon_scanner/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BeaconScannerApp());
}

class BeaconScannerApp extends StatelessWidget {
  const BeaconScannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const HomePage(),
      },
      initialRoute: '/',
    );
  }
}
