import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';

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
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMenuCard(
          context,
          'Quản lý phòng',
          Icons.bed,
          '/admin/rooms',
        ),
        _buildMenuCard(
          context,
          'Quản lý khách sạn',
          Icons.hotel,
          '/admin/hotels',
        ),
        _buildMenuCard(
          context,
          'Quản lý doanh nghiệp',
          Icons.business,
          '/admin/business',
        ),
        _buildMenuCard(
          context,
          'Quản lý nhân viên',
          Icons.people,
          '/admin/staff',
        ),
        _buildMenuCard(
          context,
          'Quản lý khách hàng',
          Icons.person,
          '/admin/guests',
        ),
        _buildMenuCard(
          context,
          'Quản lý dịch vụ',
          Icons.room_service,
          '/admin/services',
        ),
        _buildMenuCard(
          context,
          'Quản lý công nợ',
          Icons.money_off,
          '/admin/debt',
        ),
        _buildMenuCard(
          context,
          'Giao ca',
          Icons.swap_horiz,
          '/admin/shift-handover',
        ),
        _buildMenuCard(
          context,
          'Lịch',
          Icons.calendar_today,
          '/admin/calendar',
        ),
        _buildMenuCard(
          context,
          'Báo cáo tài chính',
          Icons.assessment,
          '/admin/financial-summary',
        ),
        _buildMenuCard(
          context,
          'Hồ sơ',
          Icons.person,
          '/profile',
        ),
        _buildMenuCard(
          context,
          'Cài đặt',
          Icons.settings,
          '/settings',
        ),
      ],
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
            'Chào mừng đến với Hotel App',
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

