import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';
import 'package:hotelapp_flutter/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _saving = false;

  Future<void> _editProfileDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;
    final fullNameController = TextEditingController(text: user.fullName ?? '');
    final phoneController = TextEditingController(text: user.phone ?? '');
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa hồ sơ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Họ tên'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () async {
                if (_saving) return;
                setState(() => _saving = true);
                try {
                  final data = {
                    'fullName': fullNameController.text.trim(),
                    'phone': phoneController.text.trim(),
                  };
                  final res = await _authService.updateProfile(data);
                  if (res['user'] != null) {
                    authProvider.updateUser(authProvider.user?.copyWith(
                      fullName: res['user']['fullName'],
                      phone: res['user']['phone'],
                    ));
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _saving = false);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        actions: [
          if (user != null)
            IconButton(
              onPressed: () => _editProfileDialog(context),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
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
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Họ tên'),
                  trailing: Text(user.fullName ?? '-'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Số điện thoại'),
                  trailing: Text(user.phone ?? '-'),
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

