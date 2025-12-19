import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: user == null
          ? const Center(child: Text('Không có thông tin người dùng'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Vai trò'),
                  trailing: Text(user.role),
                ),
                if (user.fullName != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Họ tên'),
                    trailing: Text(user.fullName!),
                  ),
                if (user.phone != null)
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Số điện thoại'),
                    trailing: Text(user.phone!),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Cài đặt'),
                  onTap: () => context.push('/settings'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/');
                    }
                  },
                ),
              ],
            ),
    );
  }
}

