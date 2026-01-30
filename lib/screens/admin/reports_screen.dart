import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_ReportItem>[
      _ReportItem(
        title: 'Hóa đơn',
        description: 'Xem và quản lý hóa đơn',
        icon: Icons.receipt_long,
        route: '/admin/invoices',
      ),
      _ReportItem(
        title: 'Doanh thu',
        description: 'Thống kê doanh thu theo thời gian',
        icon: Icons.attach_money,
        route: '/admin/revenue',
      ),
      _ReportItem(
        title: 'Lịch sử thanh toán',
        description: 'SePay, PayPal, Crypto',
        icon: Icons.credit_card,
        route: '/admin/payment-history',
      ),
      _ReportItem(
        title: 'Giao dịch SePay',
        description: 'Lịch sử chuyển khoản ngân hàng',
        icon: Icons.account_balance,
        route: '/admin/bank-transfer-history',
      ),
      _ReportItem(
        title: 'Giao ca',
        description: 'Lịch sử giao ca',
        icon: Icons.swap_horiz,
        route: '/admin/shift-handover-history',
      ),
      _ReportItem(
        title: 'Tài chính tổng hợp',
        description: 'Báo cáo tổng hợp',
        icon: Icons.pie_chart,
        route: '/admin/financial-summary',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => context.push(item.route),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 36, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 10),
                    Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  _ReportItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}
