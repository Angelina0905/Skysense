import 'package:flutter/material.dart';

class TabelPage extends StatelessWidget {
  const TabelPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text("Tabel Data Historis"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // tabel putih biar kontras
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 4),
              )
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.lightBlue),
              border: TableBorder.all(
                width: 1.5,
                color: Colors.black54,
              ),
              columnSpacing: 24,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              columns: const [
                DataColumn(label: Text("Tanggal")),
                DataColumn(label: Text("Suhu (°C)")),
                DataColumn(label: Text("Kelembaban (%)")),
                DataColumn(label: Text("Curah Hujan (mm)")),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text("17/09/2025")),
                  DataCell(Text("30")),
                  DataCell(Text("70")),
                  DataCell(Text("12")),
                ]),
                DataRow(cells: [
                  DataCell(Text("18/09/2025")),
                  DataCell(Text("31")),
                  DataCell(Text("68")),
                  DataCell(Text("20")),
                ]),
                DataRow(cells: [
                  DataCell(Text("19/09/2025")),
                  DataCell(Text("29")),
                  DataCell(Text("75")),
                  DataCell(Text("15")),
                ]),
                DataRow(cells: [
                  DataCell(Text("20/09/2025")),
                  DataCell(Text("28")),
                  DataCell(Text("78")),
                  DataCell(Text("8")),
                ]),
                DataRow(cells: [
                  DataCell(Text("21/09/2025")),
                  DataCell(Text("32")),
                  DataCell(Text("65")),
                  DataCell(Text("18")),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
