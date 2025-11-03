import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/screens/settings_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Icon(
              Icons.music_note,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text("H O M E"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text("S E T T I N G S"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
