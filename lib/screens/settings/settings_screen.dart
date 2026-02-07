import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotelapp_flutter/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Chế độ tối'),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (v) => settings.toggleTheme(v),
          ),
          ListTile(
            title: const Text('Ngôn ngữ'),
            trailing: DropdownButton<String>(
              value: settings.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) {
                if (v != null) settings.setLanguage(v);
              },
            ),
          ),
          ListTile(
            title: const Text('Tiền tệ'),
            trailing: DropdownButton<String>(
              value: settings.currency,
              items: const [
                DropdownMenuItem(value: 'VND', child: Text('VND')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
              ],
              onChanged: (v) {
                if (v != null) settings.setCurrency(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

