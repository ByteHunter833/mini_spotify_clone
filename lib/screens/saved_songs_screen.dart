import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/components/music_list_tile.dart';
import 'package:mini_spotify_clone/models/song.dart';

class LikedSongsScreen extends StatelessWidget {
  final List<Song> savedSongs;

  const LikedSongsScreen({super.key, required this.savedSongs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liked Songs')),
      body: ListView.builder(
        itemCount: savedSongs.length,
        itemBuilder: (context, index) {
          final song = savedSongs[index];
          return MusicListTile(song: song);
        },
      ),
    );
  }
}
