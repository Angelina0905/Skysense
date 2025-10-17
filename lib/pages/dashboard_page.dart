import 'package:flutter/material.dart';
import 'package:flutter_application_skysense/pages/grafik_page.dart';
import 'package:flutter_application_skysense/pages/tabel_page.dart';
import 'package:flutter_application_skysense/pages/prediksi_page.dart'; // tambahkan ini

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isConnected = false;

  // Dummy data
  final Map<String, String> sensorData = {
    "Rainfall": "12 mm",
    "Temperature": "28 °C",
    "Wind Speed": "8 km/h",
    "Wind Direction": "North",
    "Humidity": "70 %",
    "Light Intensity": "500 lx",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          children: [
            const Icon(Icons.cloud, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              "SKYSENSE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Text("Connected", style: TextStyle(color: Colors.white)),
            Switch(
              value: isConnected,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              onChanged: (value) {
                setState(() {
                  isConnected = value;
                });
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        // 👉 ini menu samping
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Grafik Cuaca'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GrafikPage()),
                ); // tutup drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text("Tabel"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TabelPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Prediksi Cuaca'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrediksiPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Indikasi'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: sensorData.keys.map((key) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForKey(key),
                      size: 40,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isConnected ? sensorData[key]! : "--",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case "Rainfall":
        return Icons.water_drop;
      case "Temperature":
        return Icons.thermostat;
      case "Wind Speed":
        return Icons.air;
      case "Wind Direction":
        return Icons.navigation;
      case "Humidity":
        return Icons.opacity;
      case "Light Intensity":
        return Icons.wb_sunny;
      default:
        return Icons.device_unknown;
    }
  }
}
