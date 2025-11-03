import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S E T T I N G S'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),

          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DarkMode',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  // color: Colors.white,
                ),
              ),
              CupertinoSwitch(
                value: Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).isDarkMode,
                onChanged: (v) => Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
