import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataHistorisPage extends StatelessWidget {
  const DataHistorisPage({super.key});

  // ================= FETCH AVG DATA =================
  Future<List<Map<String, String>>> fetchDataHistoris() async {
    final response = await http.get(
      // Uri.parse("http://192.168.131.254:3000/avgdata"),
      Uri.parse("http://192.168.131.254:3000/avgdata"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body); // ✅ LIST

      return data.map<Map<String, String>>((item) {
        // format tanggal (YYYY-MM-DD)
        final date = DateTime.parse(
          item["tanggal"],
        ).toLocal().toString().split(" ")[0];

        return {
          "tanggal": date,
          "suhu": "${item["avg_temperature"]}°C",
          "kelembapan": "${item["avg_humidity"]}%",
          "hujan": "${item["avg_ldr"]}", // sementara pakai ldr
          "kondisi": "Rata-rata",
        };
      }).toList();
    } else {
      throw Exception("Gagal ambil data historis");
    }
  }

  // ================= ICON =================
  IconData getWeatherIcon(String kondisi) {
    switch (kondisi) {
      case "Cerah":
        return Icons.wb_sunny_rounded;
      case "Berawan":
        return Icons.cloud_rounded;
      case "Hujan":
        return Icons.umbrella_rounded;
      case "Rata-rata":
        return Icons.analytics_rounded;
      default:
        return Icons.help_outline;
    }
  }

  // ================= COLOR =================
  Color getWeatherColor(String kondisi) {
    switch (kondisi) {
      case "Cerah":
        return const Color(0xFFFFF3C4);
      case "Berawan":
        return const Color(0xFFE3F2FD);
      case "Hujan":
        return const Color(0xFFE1F5FE);
      case "Rata-rata":
        return const Color(0xFFE8F5E9);
      default:
        return Colors.white;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5BAAF4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SKYSENSE • Data Historis",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: fetchDataHistoris(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          }

          final dataHistoris = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Riwayat Cuaca Harian",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Digunakan sebagai dasar analisis dan prediksi cuaca pertanian.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),

              ...dataHistoris.map((row) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getWeatherColor(row["kondisi"]!),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            row["tanggal"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(getWeatherIcon(row["kondisi"]!), size: 22),
                              const SizedBox(width: 6),
                              Text(
                                row["kondisi"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoItem(Icons.thermostat, "Suhu", row["suhu"]!),
                          _infoItem(
                            Icons.water_drop,
                            "Kelembapan",
                            row["kelembapan"]!,
                          ),
                          _infoItem(Icons.grain, "Hujan", row["hujan"]!),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  // ================= ITEM =================
  static Widget _infoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
