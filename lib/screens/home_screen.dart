import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/components/my_drawer.dart';
import 'package:mini_spotify_clone/models/playlist_provider.dart';
import 'package:mini_spotify_clone/models/song.dart';
import 'package:mini_spotify_clone/screens/song_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final dynamic playListProvider;

  @override
  void initState() {
    super.initState();

    playListProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goToSong(int songIndex) {
    playListProvider.currentSongIndex = songIndex;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('P L A Y L I S T'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      drawer: MyDrawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          List<Song> playlist = value.playList;
          return ListView.builder(
            itemBuilder: (context, index) {
              final Song song = playlist[index];
              return ListTile(
                leading: Image.asset(song.albumArtImagePath),
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                onTap: () => goToSong(index),
              );
            },
            itemCount: playlist.length,
          );
        },
      ),
    );
  }
}
