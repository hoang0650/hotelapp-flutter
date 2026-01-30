import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_ManagementItem>[
      _ManagementItem(
        title: 'Service Management',
        description: 'Quản lý dịch vụ khách sạn',
        icon: Icons.build,
        route: '/admin/services',
      ),
      _ManagementItem(
        title: 'Staff Management',
        description: 'Quản lý nhân viên và ca làm việc',
        icon: Icons.people,
        route: '/admin/staff',
      ),
      _ManagementItem(
        title: 'Room Management',
        description: 'Quản lý phòng và giá phòng',
        icon: Icons.home,
        route: '/admin/rooms',
      ),
      _ManagementItem(
        title: 'Guest Management',
        description: 'Quản lý thông tin khách hàng',
        icon: Icons.person,
        route: '/admin/guests',
      ),
      _ManagementItem(
        title: 'Debt Management',
        description: 'Quản lý công nợ khách hàng',
        icon: Icons.receipt_long,
        route: '/admin/debt',
      ),
      _ManagementItem(
        title: 'Electric Setting',
        description: 'Điều khiển công tắc Tuya',
        icon: Icons.bolt,
        route: '/admin/electric',
      ),
      _ManagementItem(
        title: 'Reports',
        description: 'Báo cáo hóa đơn, doanh thu, thanh toán',
        icon: Icons.bar_chart,
        route: '/admin/reports',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFf0f9ff),
                child: Icon(item.icon, color: const Color(0xFF1890ff)),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item.description),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => context.push(item.route),
            ),
          );
        },
      ),
    );
  }
}

class _ManagementItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  _ManagementItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}
