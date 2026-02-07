// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/models/song.dart';

class MusicListTile extends StatelessWidget {
  final Song song;
  final VoidCallback? goToSong;
  final VoidCallback? saveToSavedSongs;

  const MusicListTile({
    super.key,
    required this.song,
    this.goToSong,
    this.saveToSavedSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: goToSong,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Hero(
                  tag: 'album-${song.songName}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: song.albumArtImagePath.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              song.albumArtImagePath,

                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
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
                  ),
                ),

                const SizedBox(width: 12),

                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        song.songName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artistName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // More options button
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _showOptionsBottomSheet(context);
                  },
                  splashRadius: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Song info header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  song.albumArtImagePath.isEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: Theme.of(context).colorScheme.primary,
                            child: Icon(
                              Icons.music_note,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            song.albumArtImagePath,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.songName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artistName,
                          style: TextStyle(
                            fontSize: 14,
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
                ],
              ),
            ),

            const Divider(),

            // Options
            _buildOption(
              context,
              Icons.bookmark_outline,
              'Save to Your Library',
              saveToSavedSongs,
            ),
            _buildOption(context, Icons.favorite_border, 'Like', () {}),
            _buildOption(context, Icons.share, 'Share', () {}),
            _buildOption(context, Icons.album, 'Go to album', () {}),
            _buildOption(context, Icons.person, 'Go to artist', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(label),
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
