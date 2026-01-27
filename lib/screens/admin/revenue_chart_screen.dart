import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueChartScreen extends StatelessWidget {
  const RevenueChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ doanh thu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                spots: const [
                  FlSpot(0, 1),
                  FlSpot(1, 2),
                  FlSpot(2, 1.5),
                  FlSpot(3, 3),
                  FlSpot(4, 2.2),
                  FlSpot(5, 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

