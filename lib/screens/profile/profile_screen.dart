import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';
import 'package:hotelapp_flutter/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _saving = false;
  String _themeMode = 'light';
  String _language = 'vi';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = prefs.getString('pref_theme') ?? 'light';
      _language = prefs.getString('pref_language') ?? 'vi';
    });
  }

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
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: user == null
          ? const Center(child: Text('Không có thông tin người dùng'))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
                      const SizedBox(height: 10),
                      Text(
                        user.fullName ?? user.username,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Account'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _editProfileDialog(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/settings'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.palette),
                        title: const Text('Change Theme'),
                        trailing: Text(
                          _themeMode == 'dark'
                              ? 'Dark'
                              : _themeMode == 'light'
                                  ? 'Light'
                                  : 'Auto',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            builder: (context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text('Light'),
                                      trailing: _themeMode == 'light' ? const Icon(Icons.check) : null,
                                      onTap: () => Navigator.pop(context, 'light'),
                                    ),
                                    ListTile(
                                      title: const Text('Dark'),
                                      trailing: _themeMode == 'dark' ? const Icon(Icons.check) : null,
                                      onTap: () => Navigator.pop(context, 'dark'),
                                    ),
                                    ListTile(
                                      title: const Text('Auto'),
                                      trailing: _themeMode == 'auto' ? const Icon(Icons.check) : null,
                                      onTap: () => Navigator.pop(context, 'auto'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          if (selected != null) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('pref_theme', selected);
                            setState(() => _themeMode = selected);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Change Language'),
                        trailing: Text(
                          _language == 'vi' ? 'Tiếng Việt' : 'English',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            builder: (context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text('Tiếng Việt'),
                                      trailing: _language == 'vi' ? const Icon(Icons.check) : null,
                                      onTap: () => Navigator.pop(context, 'vi'),
                                    ),
                                    ListTile(
                                      title: const Text('English'),
                                      trailing: _language == 'en' ? const Icon(Icons.check) : null,
                                      onTap: () => Navigator.pop(context, 'en'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          if (selected != null) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('pref_language', selected);
                            setState(() => _language = selected);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: const Text('Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (context) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('Liên hệ hỗ trợ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 12),
                                      Text('Email: support@phhotel.com'),
                                      SizedBox(height: 8),
                                      Text('Hotline: +84 123 456 789'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.call_outlined),
                        title: const Text('Contact'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (context) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('Email: contact@phhotel.com'),
                                      SizedBox(height: 8),
                                      Text('Phone: +84 123 456 789'),
                                      SizedBox(height: 8),
                                      Text('Website: https://phhotel.com'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
                ),
              ],
            ),
    );
  }
}

