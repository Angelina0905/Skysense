import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_skysense/services/mqtt_service.dart';
import 'package:http/http.dart' as http;
import 'live_video_page.dart';
import 'data_historis_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double temperature = 0.0;
  double humidity = 0.0;
  double windSpeed = 0.0;
  double rainChance = 0.0;
  double windDirection = 0; // derajat
  double light = 0.0;
  List<FlSpot> temperatureData = []; // Menyimpan data suhu untuk grafik

  int _selectedIndex = 0;
  final MqttService mqttService = MqttService();
  // ================= WIND DIRECTION TEXT =================

  @override
  void initState() {
    super.initState();

    mqttService.onMessage = (data) {
      if (!mounted) return;

      debugPrint("MQTT DATA: $data");

      setState(() {
        // Mengupdate data suhu, kelembapan, dll
        temperature = (data['temperature'] as num?)?.toDouble() ?? temperature;
        humidity = (data['humidity'] as num?)?.toDouble() ?? humidity;
        windSpeed = (data['windSpeed'] as num?)?.toDouble() ?? windSpeed;
        windDirection =
            (data['windDirection'] as num?)?.toDouble() ?? windDirection;
        rainChance = (data['rainRate'] as num?)?.toDouble() ?? rainChance;
        light = (data['light'] as num?)?.toDouble() ?? light;

        // Menambahkan titik data suhu ke dalam temperatureData untuk grafik
        temperatureData.add(
          FlSpot(DateTime.now().millisecondsSinceEpoch.toDouble(), temperature),
        );

        // Hanya menjaga 10 data terakhir untuk grafik agar tidak terlalu banyak
        if (temperatureData.length > 10) {
          temperatureData.removeAt(0);
        }
      });
    };

    mqttService.connect();
  }

  Future<void> fetchRealtimeData() async {
    final url = Uri.parse(
      'https://api.ecowitt.net/api/v3/device/real_time'
      '?application_key=9EFB0615455045456084E4024E4CD911'
      '&api_key=84b31d82-6110-43ab-a3f2-71715e61d2be'
      '&mac=48:E7:29:5F:05:68'
      '&call_back=all',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint("❌ Gagal ambil data Ecowitt");
        return;
      }

      final body = jsonDecode(response.body);
      final data = body['data'];

      if (data == null) return;

      setState(() {
        // ================= TEMPERATURE (F → C) =================
        final tempF =
            double.tryParse(
              data['outdoor']?['temperature']?['value']?.toString() ?? '',
            ) ??
            temperature;

        temperature = (tempF - 32) * 5 / 9;

        // ================= HUMIDITY (%) =================
        humidity =
            double.tryParse(
              data['outdoor']?['humidity']?['value']?.toString() ?? '',
            ) ??
            humidity;

        // ================= WIND SPEED (mph → km/h) =================
        final windMph =
            double.tryParse(
              data['wind']?['wind_speed']?['value']?.toString() ?? '',
            ) ??
            windSpeed;

        windSpeed = windMph * 1.60934;

        // ================= WIND DIRECTION (degree) =================
        windDirection =
            double.tryParse(
              data['wind']?['wind_direction']?['value']?.toString() ?? '',
            ) ??
            windDirection;

        // ================= RAIN RATE (inch/hr → mm/hr) =================
        final rainInch =
            double.tryParse(
              data['rainfall']?['rain_rate']?['value']?.toString() ?? '',
            ) ??
            rainChance;

        rainChance = rainInch * 25.4;

        // ================= LIGHT (W/m²) =================
        light =
            double.tryParse(
              data['solar_and_uvi']?['solar']?['value']?.toString() ?? '',
            ) ??
            light;
      });

      temperatureData.add(
        FlSpot(DateTime.now().millisecondsSinceEpoch.toDouble(), temperature),
      );
    } catch (e) {
      debugPrint("❌ Ecowitt error: $e");
    }
  }

  String getWindDirectionText(double degree) {
    if (degree >= 337.5 || degree < 22.5) return "Utara";
    if (degree >= 22.5 && degree < 67.5) return "Timur Laut";
    if (degree >= 67.5 && degree < 112.5) return "Timur";
    if (degree >= 112.5 && degree < 157.5) return "Tenggara";
    if (degree >= 157.5 && degree < 202.5) return "Selatan";
    if (degree >= 202.5 && degree < 247.5) return "Barat Daya";
    if (degree >= 247.5 && degree < 292.5) return "Barat";
    return "Barat Laut";
  }

  // =================  WEATHER PREDICT =================
  String predictMonthlyWeather({
    required double rain,
    required double temp,
    required double humidity,
  }) {
    if (rain > 100 && humidity > 80) {
      return "Rainy";
    } else if (temp > 30 && rain < 50) {
      return "Sunny";
    } else {
      return "Cloudy";
    }
  }

  // ================= FARMING ACTIVITY =================
  List<String> getFarmingActivities(String weather) {
    switch (weather) {
      case "Rainy":
        return [
          "Perbaikan drainase lahan",
          "Penundaan penanaman sayuran sensitif",
          "Pengendalian penyakit jamur",
          "Penguatan bedengan",
        ];

      case "Cloudy":
        return [
          "Penanaman sayuran daun",
          "Pemupukan organik",
          "Monitoring kelembapan tanah",
          "Penyulaman tanaman",
        ];

      case "Sunny":
        return [
          "Penanaman sayuran umbi",
          "Irigasi terkontrol",
          "Pemupukan bertahap",
          "Pengendalian hama daun",
        ];

      default:
        return ["Monitoring kondisi lahan"];
    }
  }

  // ================= MONTHLY PREDICTION =================
  List<Map<String, dynamic>> getMonthlyPrediction() {
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
    ];

    final rainPattern = [140, 120, 90, 70, 50, 40, 35];
    final tempPattern = [22, 23, 24, 24, 25, 26, 26];

    return List.generate(months.length, (i) {
      final rain = rainPattern[i];
      final temp = tempPattern[i];

      String weather;
      IconData icon;

      if (rain > 110) {
        weather = "Rainy";
        icon = Icons.grain;
      } else if (rain < 60 && temp >= 25) {
        weather = "Sunny";
        icon = Icons.wb_sunny;
      } else {
        weather = "Cloudy";
        icon = Icons.cloud;
      }

      return {
        "month": months[i],
        "weather": weather,
        "temp": "${temp}°",
        "icon": icon,
        "activities": getFarmingActivities(weather),
      };
    });
  }

  // ========================= UI BUILD =========================

  @override
  Widget build(BuildContext context) {
    final monthlyData = getMonthlyPrediction();

    return Scaffold(
      backgroundColor: const Color(0xFFD9ECFF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOCATION
              Container(
                padding: const EdgeInsets.all(
                  12,
                ), // Memberikan padding sekitar elemen
                decoration: BoxDecoration(
                  color: Colors.blue, // Latar belakang khusus untuk lokasi
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Membuat sudut membulat
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ), // Ikon lokasi dengan warna putih
                    SizedBox(width: 6),
                    Text(
                      "Bandung", // Nama kota
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .white, // Teks dengan warna putih agar kontras
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 6,
              ), // Memberikan sedikit jarak antara elemen

              const Text(
                "Realtime Weather Monitoring",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // ============================================================
              // =================== REALTIME SENSOR GRID ===================
              // ============================================================
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _sensorBox(
                    Icons.water_drop,
                    "Rainfall",
                    "${rainChance}%",
                    const Color.fromARGB(
                      255,
                      87,
                      127,
                      167,
                    ), // Latar Belakang: Dark Blue/Navy
                    const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ), // Teks: Putih (Kontras yang baik)
                  ),

                  // Temperature - Bright Red/Terracotta
                  _sensorBox(
                    Icons.thermostat,
                    "Temperature",
                    "${temperature.toStringAsFixed(1)}°C",
                    const Color(
                      0xFFE74C3C,
                    ), // Latar Belakang: Bright Red/Terracotta
                    Colors.white, // Teks: Putih
                  ),

                  // Wind Speed - Turquoise/Mint Green
                  _sensorBox(
                    Icons.air,
                    "Wind Speed",
                    "${windSpeed.toStringAsFixed(1)} km/h",
                    const Color(
                      0xFF1ABC9C,
                    ), // Latar Belakang: Turquoise/Mint Green
                    const Color.fromARGB(
                      255,
                      8,
                      10,
                      12,
                    ), // Teks: Hitam Pekat (Kontras)
                  ),

                  // Wind Direction - Sky Blue
                  _sensorBox(
                    Icons.navigation,
                    "Wind Direction",
                    getWindDirectionText(windDirection),
                    const Color(0xFF3498DB), // Latar Belakang: Sky Blue
                    Colors.white, // Teks: Putih
                  ),

                  // Humidity - Light Gray/Silver
                  _sensorBox(
                    Icons
                        .water, // Di kode Anda sebelumnya menggunakan Icons.water, saya pertahankan
                    "Humidity",
                    "${humidity}%",
                    const Color(
                      0xFFBDC3C7,
                    ), // Latar Belakang: Light Gray/Silver
                    const Color.fromARGB(
                      255,
                      8,
                      10,
                      12,
                    ), // Teks: Hitam Pekat (Kontras)
                  ),

                  // Light Intensity - Vibrant Orange/Gold
                  _sensorBox(
                    Icons.wb_sunny,
                    "Light Intensity",
                    "${light}W/m²",
                    const Color(
                      0xFFF39C12,
                    ), // Latar Belakang: Vibrant Orange/Gold
                    const Color.fromARGB(
                      255,
                      8,
                      10,
                      12,
                    ), // Teks: Hitam Pekat (Kontras)
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================================================================
              // ========================== GRAFIK SUHU ===========================
              // ==================================================================
              const SizedBox(height: 28),
              const Text(
                "Grafik Perubahan Suhu (Today)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                height: 280,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    minY: 20,
                    maxY: 40, // Sesuaikan dengan kisaran suhu Anda
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            temperatureData, // Data yang kita perbarui dengan suhu baru
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================================
              // ======================== HOURLY FORECAST =========================
              // ==================================================================
              const SizedBox(height: 28),
              const Text(
                "Hari Ini",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    HourCard("Now", "22°", Icons.wb_sunny),
                    HourCard("13:00", "23°", Icons.wb_sunny),
                    HourCard("16:00", "21°", Icons.cloud),
                    HourCard("19:00", "19°", Icons.cloud),
                  ],
                ),
              ),

              // ==================================================================
              // ======================== FORECAST 7 HARI =========================
              // ==================================================================
              const SizedBox(height: 24),
              const Text(
                "Perkiraan 7 Hari",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _dayForecast("Senin", "22° / 18°", Icons.wb_sunny),
              _dayForecast("Selasa", "21° / 17°", Icons.cloud),
              _dayForecast("Rabu", "20° / 16°", Icons.cloud_queue),
              _dayForecast("Kamis", "23° / 18°", Icons.wb_sunny),

              // ==================================================================
              // ======================== FORECAST BULANAN ========================
              // ==================================================================
              const SizedBox(height: 28),
              const Text(
                "Perkiraan Bulanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                itemCount: monthlyData.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final data = monthlyData[index];
                  return PredictionCard(
                    data["month"],
                    data["weather"],
                    data["temp"],
                    data["icon"],
                    activities: data["activities"],
                  );
                },
              ),

              // ==================================================================
              // ======================== FORECAST TAHUNAN ========================
              // ==================================================================
              const SizedBox(height: 28),
              const Text(
                "Perkiraan Tahunan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Column(
                  children: const [
                    TrendRow("Average Temperature", "28° C"),
                    TrendRow("Rain Dominance", "High"),
                    TrendRow("Dry Season Peak", "August"),
                    TrendRow("Extreme Weather Risk", "Moderate"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ==================================================================
      // ======================== BOTTOM NAVIGATION ========================
      // ==================================================================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveVideoPage()),
              );
            }

            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DataHistorisPage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam_rounded),
              label: "Live",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: "History",
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // ======================= COMPONENTS ================================
  // ===================================================================

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(height: 6),
        Text(value, style: TextStyle(color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _dayForecast(String day, String temp, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
          Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
          Text(temp),
        ],
      ),
    );
  }

  Widget _sensorBox(
    IconData icon,
    String label,
    String value,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 45, color: iconColor),
          SizedBox(height: 14),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class HourCard extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;

  const HourCard(this.time, this.temp, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time),
          SizedBox(height: 8),
          Icon(icon, color: Colors.orange),
          SizedBox(height: 8),
          Text(temp, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class PredictionCard extends StatelessWidget {
  final String month;
  final String condition;
  final String temp;
  final IconData icon;
  final List<String> activities;

  const PredictionCard(
    this.month,
    this.condition,
    this.temp,
    this.icon, {
    required this.activities,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(month, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Icon(icon, color: Colors.blue, size: 28),
          SizedBox(height: 6),
          Text(condition, style: TextStyle(fontSize: 13)),
          Text(temp, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Divider(),
          Text(
            "Kegiatan:",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),

          ...activities
              .take(2)
              .map((e) => Text("• $e", style: TextStyle(fontSize: 11))),
        ],
      ),
    );
  }
}

class TrendRow extends StatelessWidget {
  final String label;
  final String value;

  const TrendRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
