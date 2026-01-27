import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';
import 'package:hotelapp_flutter/config/router.dart';
import 'package:hotelapp_flutter/config/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'PHHotel PMS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

