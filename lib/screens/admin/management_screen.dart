import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelapp_flutter/services/permission_service.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final _permissionService = PermissionService();
  List<_ManagementItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final allItems = <_ManagementItem>[
      _ManagementItem(
        title: 'Service Management',
        description: 'Quản lý dịch vụ khách sạn',
        icon: Icons.build,
        route: '/admin/services',
        permission: PermissionService.MANAGE_SERVICES,
      ),
      _ManagementItem(
        title: 'Staff Management',
        description: 'Quản lý nhân viên và ca làm việc',
        icon: Icons.people,
        route: '/admin/staff',
        permission: PermissionService.MANAGE_STAFF,
      ),
      _ManagementItem(
        title: 'Room Management',
        description: 'Quản lý phòng và giá phòng',
        icon: Icons.home,
        route: '/admin/rooms',
        permission: PermissionService.MANAGE_ROOMS,
      ),
      _ManagementItem(
        title: 'Guest Management',
        description: 'Quản lý thông tin khách hàng',
        icon: Icons.person,
        route: '/admin/guests',
        permission: PermissionService.MANAGE_GUESTS,
      ),
      _ManagementItem(
        title: 'Debt Management',
        description: 'Quản lý công nợ khách hàng',
        icon: Icons.receipt_long,
        route: '/admin/debt',
        permission: PermissionService.MANAGE_DEBT,
      ),
      _ManagementItem(
        title: 'Electric Setting',
        description: 'Điều khiển công tắc Tuya',
        icon: Icons.bolt,
        route: '/admin/electric',
        permission: PermissionService.ELECTRIC_CONTROL,
      ),
      _ManagementItem(
        title: 'Reports',
        description: 'Báo cáo hóa đơn, doanh thu, thanh toán',
        icon: Icons.bar_chart,
        route: '/admin/reports',
        permission: PermissionService.VIEW_REPORTS,
      ),
    ];

    final allowedItems = <_ManagementItem>[];
    for (final item in allItems) {
      if (item.permission == null || await _permissionService.canAccess(item.permission!)) {
        allowedItems.add(item);
      }
    }

    if (mounted) {
      setState(() {
        _items = allowedItems;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = _items[i];
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
  final String? permission;

  _ManagementItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.permission,
  });
}
