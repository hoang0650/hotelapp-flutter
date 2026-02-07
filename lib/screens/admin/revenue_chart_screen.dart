import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hotelapp_flutter/services/invoice_service.dart';
import 'package:provider/provider.dart';
import 'package:hotelapp_flutter/providers/hotel_provider.dart';

class RevenueChartScreen extends StatefulWidget {
  const RevenueChartScreen({super.key});

  @override
  State<RevenueChartScreen> createState() => _RevenueChartScreenState();
}

class _RevenueChartScreenState extends State<RevenueChartScreen> {
  final _invoiceService = InvoiceService();
  bool _loading = true;
  List<FlSpot> _spots = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final hp = Provider.of<HotelProvider>(context, listen: false);
      final hotelId = hp.selectedHotelId;
      if (hotelId == null) {
        setState(() {
          _spots = [];
          _loading = false;
        });
        return;
      }
      
      // Load stats for current month
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1).toIso8601String();
      final end = DateTime(now.year, now.month + 1, 0).toIso8601String();
      
      final stats = await _invoiceService.getInvoiceStats(
        hotelId: hotelId,
        startDate: start,
        endDate: end,
      );
      
      // Assume stats is a list of { date: 'YYYY-MM-DD', total: 1000 }
      // Or similar. This is a best guess integration.
      // If stats structure is different, this will need adjustment.
      // For now, if stats is not a list, we leave spots empty.
      
      List<FlSpot> newSpots = [];
      if (stats is List) {
        for (int i = 0; i < stats.length; i++) {
          final item = stats[i];
          if (item is Map && item.containsKey('total')) {
             // Simple mapping: index as x, total as y
             // Ideally we parse date.
             newSpots.add(FlSpot(i.toDouble(), (item['total'] as num).toDouble()));
          }
        }
      }
      _spots = newSpots;
      
    } catch (_) {
      _spots = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biểu đồ doanh thu'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: _spots.isEmpty
                  ? const Center(child: Text('Không có dữ liệu doanh thu'))
                  : LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            spots: _spots,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}

