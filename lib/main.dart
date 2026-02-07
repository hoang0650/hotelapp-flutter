import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';
import 'package:hotelapp_flutter/providers/settings_provider.dart';
import 'package:hotelapp_flutter/providers/hotel_provider.dart';
import 'package:hotelapp_flutter/config/router.dart';
import 'package:hotelapp_flutter/config/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp.router(
            title: 'PHHotel PMS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi'),
              Locale('en'),
            ],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

