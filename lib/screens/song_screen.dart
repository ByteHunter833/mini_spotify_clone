import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> with TickerProviderStateMixin {
  late AnimationController _albumRotationController;
  late AnimationController _scaleController;
  bool isLiked = false;
  bool isShuffleOn = false;
  bool isRepeatOn = false;

  @override
  void initState() {
    super.initState();

    // Album rotation animation
    _albumRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Scale animation for like button
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _albumRotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    _scaleController.forward().then((_) => _scaleController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        final playlistSong = provider.playList;
        final song = playlistSong[provider.currentSongIndex ?? 0];

        // Control album rotation based on play state
        if (provider.isPlaying) {
          if (!_albumRotationController.isAnimating) {
            _albumRotationController.repeat();
          }
        } else {
          _albumRotationController.stop();
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'from My Playlist',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  // Show options bottom sheet
                  _showOptionsBottomSheet(context, song);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1DB954).withValues(alpha: 0.3),
                        const Color(0xFF121212),
                        const Color(0xFF000000),
                      ]
                    : [
                        const Color(0xFF1DB954).withValues(alpha: 0.2),
                        Colors.grey[100]!,
                        Colors.white,
                      ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // =============================
                    // Album Art with Rotation
                    // =============================
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'album_art_${provider.currentSongIndex}',
                          child: RotationTransition(
                            turns: _albumRotationController,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 340,
                                maxHeight: 340,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1DB954,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: song.albumArtImagePath.isNotEmpty
                                    ? Image.asset(
                                        song.albumArtImagePath,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        child: Icon(
                                          Icons.music_note_rounded,
                                          size: 120,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // =============================
                    // Song Info
                    // =============================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.songName,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                song.artistName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
                        const SizedBox(width: 16),
                        ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: IconButton(
                            onPressed: toggleLike,
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isLiked
                                  ? const Color(0xFF1DB954)
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // =============================
                    // Progress Bar
                    // =============================
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                            activeTrackColor: const Color(0xFF1DB954),
                            inactiveTrackColor: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.grey[300],
                            thumbColor: const Color(0xFF1DB954),
                            overlayColor: const Color(
                              0xFF1DB954,
                            ).withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: provider.currentDuration.inSeconds
                                .toDouble(),
                            min: 0,
                            max: (provider.totalDuration.inSeconds > 0)
                                ? provider.totalDuration.inSeconds.toDouble()
                                : 1,
                            onChanged: (double seconds) {},
                            onChangeEnd: (double seconds) {
                              provider.seek(Duration(seconds: seconds.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatTime(provider.currentDuration),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                formatTime(provider.totalDuration),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =============================
                    // Control Buttons
                    // =============================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle button
                        IconButton(
                          onPressed: () {
                            setState(() => isShuffleOn = !isShuffleOn);
                          },
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: isShuffleOn
                                ? const Color(0xFF1DB954)
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),

                        // Previous button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey[200],
                          ),
                          child: IconButton(
                            onPressed: provider.playPreviousSong,
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              size: 36,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),

                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1ED760), Color(0xFF1DB954)],
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: IconButton(
                              key: ValueKey(provider.isPlaying),
                              onPressed: provider.pauseOrResume,
                              icon: Icon(
                                provider.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Next button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey[200],
                          ),
                          child: IconButton(
                            onPressed: provider.playNextSong,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              size: 36,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),

                        // Repeat button
                        IconButton(
                          onPressed: () {
                            setState(() => isRepeatOn = !isRepeatOn);
                            provider.setRepeatMode(isRepeatOn);
                          },
                          icon: Icon(
                            Icons.repeat_rounded,
                            color: isRepeatOn
                                ? const Color(0xFF1DB954)
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context, dynamic song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text('Add to playlist'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Song info'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
