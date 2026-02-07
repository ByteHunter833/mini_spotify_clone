// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/models/song.dart';
import 'package:mini_spotify_clone/providers/playlist_provider.dart';
import 'package:mini_spotify_clone/screens/song_screen.dart';
import 'package:provider/provider.dart';

class MusicControlBar extends StatelessWidget {
  const MusicControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final Song? currentSong = playlistProvider.currentSong;

        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SongScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
              ),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Song Info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.songName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentSong.artistName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Control Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Previous Button
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 32,
                        color: Theme.of(context).colorScheme.onSurface,
                        onPressed: playlistProvider.playPreviousSong,
                      ),

                      // Play/Pause Button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: IconButton(
                          icon: Icon(
                            playlistProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.onPrimary,
                          onPressed: playlistProvider.pauseOrResume,
                        ),
                      ),

                      // Next Button
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 32,
                        color: Theme.of(context).colorScheme.onSurface,
                        onPressed: playlistProvider.playNextSong,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
