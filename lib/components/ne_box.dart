import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class NeBox extends StatelessWidget {
  final Widget? child;
  const NeBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkmode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: EdgeInsets.all(12),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,

        boxShadow: [
          BoxShadow(
            color: isDarkmode ? Colors.black : Colors.grey.shade500,
            blurRadius: 15,
            offset: Offset(4, 4),
          ),
          BoxShadow(
            color: isDarkmode
                ? const Color.fromARGB(255, 47, 47, 47)
                : Colors.white,
            blurRadius: 15,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: child,
    );
  }
}
