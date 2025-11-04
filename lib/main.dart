import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/models/playlist_provider.dart';
import 'package:mini_spotify_clone/screens/home_screen.dart';
import 'package:mini_spotify_clone/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // или !kReleaseMode, если хочешь отключать в релизе
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => PlaylistProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomeScreen(),
    );
  }
}
