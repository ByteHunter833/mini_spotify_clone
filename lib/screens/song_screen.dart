import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/components/ne_box.dart';
import 'package:mini_spotify_clone/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final playlistSong = value.playList;
        final song = playlistSong[value.currentSongIndex ?? 0];
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text('P L A Y L I S T', style: TextStyle(fontSize: 18)),
                      IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NeBox(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(song.albumArtImagePath),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.songName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(song.artistName),
                                ],
                              ),
                              Icon(Icons.favorite, color: Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    // время и иконки
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTime(value.currentDuration)),
                          Row(
                            children: const [
                              Icon(Icons.shuffle),
                              SizedBox(width: 16),
                              Icon(Icons.repeat),
                            ],
                          ),
                          Text(formatTime(value.totalDuration)),
                        ],
                      ),
                    ),

                    // слайдер
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.grey,
                      ),
                      child: Slider(
                        value: value.currentDuration.inSeconds.toDouble(),
                        min: 0,
                        max: (value.totalDuration.inSeconds > 0)
                            ? value.totalDuration.inSeconds.toDouble()
                            : 1,
                        onChanged: (double seconds) {
                          // Перематывать лучше только по onChangeEnd, чтобы плеер не
                          // получал тысячу seek'ов в секунду. Но оставляю твою логику.
                          value.seek(Duration(seconds: seconds.toInt()));
                        },
                        onChangeEnd: (double seconds) {
                          value.seek(Duration(seconds: seconds.toInt()));
                        },
                      ),
                    ),

                    // кнопки
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: NeBox(
                              child: IconButton(
                                icon: const Icon(Icons.skip_previous),
                                onPressed: () => value.playPreviousSong(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: NeBox(
                              child: IconButton(
                                iconSize: 32,
                                icon: Icon(
                                  value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: () => value.pauseOrResume(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: NeBox(
                              child: IconButton(
                                icon: const Icon(Icons.skip_next),
                                onPressed: () => value.playNextSong(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
