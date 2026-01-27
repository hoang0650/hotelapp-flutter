import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel App'),
        actions: [
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
        ],
      ),
      body: authProvider.isAuthenticated
          ? _buildAuthenticatedView(context)
          : _buildUnauthenticatedView(context),
    );
  }

  Widget _buildAuthenticatedView(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = authProvider.user?.role;
    final isAdmin = role == AppConstants.roleAdmin || role == AppConstants.roleSuperadmin;
    final isBusiness = role == AppConstants.roleBusiness;
    final isHotel = role == AppConstants.roleHotel;
    final isStaff = role == AppConstants.roleStaff;
    final items = <Map<String, dynamic>>[];
    if (isAdmin || isHotel || isStaff) {
      items.add({'title': 'Quản lý phòng', 'icon': Icons.bed, 'route': '/admin/rooms'});
    }
    if (isAdmin || isBusiness) {
      items.add({'title': 'Quản lý doanh nghiệp', 'icon': Icons.business, 'route': '/admin/business'});
    }
    if (isAdmin || isBusiness || isHotel) {
      items.add({'title': 'Quản lý khách sạn', 'icon': Icons.hotel, 'route': '/admin/hotels'});
    }
    if (isAdmin || isBusiness || isHotel) {
      items.add({'title': 'Quản lý nhân viên', 'icon': Icons.people, 'route': '/admin/staff'});
    }
    items.add({'title': 'Quản lý khách hàng', 'icon': Icons.person, 'route': '/admin/guests'});
    items.add({'title': 'Quản lý dịch vụ', 'icon': Icons.room_service, 'route': '/admin/services'});
    items.add({'title': 'Quản lý công nợ', 'icon': Icons.money_off, 'route': '/admin/debt'});
    if (isAdmin || isHotel || isStaff) {
      items.add({'title': 'Giao ca', 'icon': Icons.swap_horiz, 'route': '/admin/shift-handover'});
    }
    items.add({'title': 'Lịch', 'icon': Icons.calendar_today, 'route': '/admin/calendar'});
    items.add({'title': 'Báo cáo tài chính', 'icon': Icons.assessment, 'route': '/admin/financial-summary'});
    items.add({'title': 'Hồ sơ', 'icon': Icons.person, 'route': '/profile'});
    items.add({'title': 'Cài đặt', 'icon': Icons.settings, 'route': '/settings'});
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: items
          .map((e) => _buildMenuCard(context, e['title'] as String, e['icon'] as IconData, e['route'] as String))
          .toList(),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hotel, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Chào mừng đến với PHHotel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.push('/auth/login'),
            child: const Text('Đăng nhập'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/auth/signup'),
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.push(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

