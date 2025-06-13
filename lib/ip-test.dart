import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IP Info',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const IpInfoPage(),
    );
  }
}

class IpInfoPage extends StatefulWidget {
  const IpInfoPage({super.key});

  @override
  State<IpInfoPage> createState() => _IpInfoPageState();
}

class _IpInfoPageState extends State<IpInfoPage> {
  String ip = '';
  String city = '';
  String country = '';
  String error = '';

  Future<void> fetchIpInfo() async {
    try {
      final ipAddress = await ipDisplay();
      final ipCityValue = await ipCity(ipAddress);
      final ipCountryValue = await ipCountry(ipAddress);

      setState(() {
        ip = ipAddress;
        city = ipCityValue;
        country = ipCountryValue;
        error = '';
      });
    } catch (e) {
      setState(() {
        error = 'Fehler beim Abrufen der Daten: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IP Info App',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: fetchIpInfo,
                child: const Text('IP-Daten abrufen'),
              ),
            ),
            const SizedBox(height: 40),
            if (ip.isNotEmpty) Text('🖥️ --> IP: $ip'),
            if (city.isNotEmpty) Text('🏙️ --> Stadt: $city'),
            if (country.isNotEmpty) Text('🌍 --> Land: $country'),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

Future<String> ipDisplay() async {
  final responseIp = await http.get(
    Uri.parse('https://api.ipify.org/?format=json'),
  );
  final jsonConvertedIp = jsonDecode(responseIp.body);
  return jsonConvertedIp['ip'];
}

Future<String> ipCity(String ip) async {
  final responseIpCity = await http.get(Uri.parse('https://ipinfo.io/$ip/geo'));
  final jsonConvertedIpCity = jsonDecode(responseIpCity.body);
  return jsonConvertedIpCity['city'];
}

Future<String> ipCountry(String ip) async {
  final responseIpCountry = await http.get(
    Uri.parse('https://ipinfo.io/$ip/geo'),
  );
  final jsonConvertedIpCountry = jsonDecode(responseIpCountry.body);
  return jsonConvertedIpCountry['country'];
}
