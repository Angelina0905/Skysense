import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrafikPage extends StatelessWidget {
  const GrafikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grafik Data Cuaca"),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Grafik Perubahan Suhu per Jam",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 200, child: LineChartSample()),

              const SizedBox(height: 30),

              const Text(
                "Grafik Curah Hujan per Hari",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 200, child: BarChartSample()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Line Chart untuk suhu per jam
class LineChartSample extends StatelessWidget {
  const LineChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 2),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text("${value.toInt()}h",
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: const [
              FlSpot(1, 24),
              FlSpot(2, 25),
              FlSpot(3, 26),
              FlSpot(4, 27),
              FlSpot(5, 26),
              FlSpot(6, 28),
            ],
            barWidth: 3,
            color: Colors.red,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

/// Bar Chart untuk curah hujan per hari
class BarChartSample extends StatelessWidget {
  const BarChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()],
                      style: const TextStyle(fontSize: 10));
                }
                return const Text("");
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 5),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 10, color: Colors.blue)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 15, color: Colors.blue)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 12, color: Colors.blue)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 20, color: Colors.blue)]),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 17, color: Colors.blue)]),
          BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 9, color: Colors.blue)]),
        ],
      ),
    );
  }
}
