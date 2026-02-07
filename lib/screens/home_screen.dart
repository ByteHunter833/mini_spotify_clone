// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_spotify_clone/components/music_controller.dart';
import 'package:mini_spotify_clone/components/music_list_tile.dart';
import 'package:mini_spotify_clone/components/my_drawer.dart';
import 'package:mini_spotify_clone/models/song.dart';
import 'package:mini_spotify_clone/providers/playlist_provider.dart';
import 'package:mini_spotify_clone/screens/song_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  List<Song> savedSongs = [];
  bool _isScrolled = false;
  bool _isInitialLoading = true;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialMusic();
  }

  Future<void> _loadInitialMusic() async {
    if (!_hasLoadedOnce) {
      final provider = context.read<PlaylistProvider>();
      await provider.loadMusicFromDevice();

      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  Future<void> _retryLoading() async {
    setState(() => _isInitialLoading = true);

    final provider = context.read<PlaylistProvider>();
    await provider.loadMusicFromDevice();

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =============================
  // Navigate to player screen
  // =============================
  void goToSong(int songIndex) {
    final provider = context.read<PlaylistProvider>();
    provider.currentSongIndex = songIndex;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SongScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // =============================
  // Save song
  // =============================
  void saveToSavedSongs(Song song) {
    if (!savedSongs.contains(song)) {
      setState(() => savedSongs.add(song));

      Fluttertoast.showToast(
        msg: "✓ Added to library",
        backgroundColor: const Color(0xFF1DB954), // Spotify green
        textColor: Colors.white,
        fontSize: 14,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Already in your library",
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
        textColor: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 14,
      );
    }

    Navigator.pop(context);
  }

  // =============================
  // Filter search
  // =============================
  List<Song> _filterSongs(List<Song> songs) {
    if (_searchQuery.isEmpty) return songs;

    return songs.where((song) {
      final q = _searchQuery.toLowerCase();
      return song.songName.toLowerCase().contains(q) ||
          song.artistName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      extendBodyBehindAppBar: true,
      drawer: MyDrawer(savedSongs: savedSongs),
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          final playlist = provider.playList;
          final filtered = _filterSongs(playlist);

          // =============================
          // Loading State (3 seconds)
          // =============================
          if (_isInitialLoading) {
            return _buildLoadingState(isDark);
          }

          // =============================
          // Empty State (no music found after loading)
          // =============================
          if (playlist.isEmpty) {
            return _buildEmptyState(isDark);
          }

          // =============================
          // Main Content
          // =============================
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // =============================
              // Modern App Bar
              // =============================
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                elevation: 0,
                backgroundColor: _isScrolled
                    ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                    : Colors.transparent,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isScrolled
                            ? Colors.transparent
                            : Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu,
                        color: _isScrolled
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isScrolled
                            ? Colors.transparent
                            : Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: _isScrolled
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                    onPressed: _retryLoading,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: AnimatedOpacity(
                    opacity: _isScrolled ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      'My Playlist',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1DB954), // Spotify green
                                const Color(0xFF121212),
                              ]
                            : [
                                const Color(0xFF1DB954),
                                const Color(0xFF1ED760),
                              ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          right: -40,
                          top: 60,
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 180,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        Positioned(
                          left: -20,
                          bottom: 20,
                          child: Icon(
                            Icons.headphones_rounded,
                            size: 120,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        // Title
                        Positioned(
                          left: 20,
                          bottom: 20,
                          child: AnimatedOpacity(
                            opacity: _isScrolled ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Playlist',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${playlist.length} songs',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =============================
              // Search Bar Section
              // =============================
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(isDark),
                    const SizedBox(height: 8),

                    // Results header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchQuery.isEmpty
                                ? 'All Songs'
                                : 'Results (${filtered.length})',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (_searchQuery.isEmpty && filtered.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                // Shuffle play functionality
                                final randomIndex = (playlist.length * 0.5)
                                    .toInt();
                                goToSong(randomIndex);
                              },
                              icon: const Icon(Icons.shuffle_rounded, size: 20),
                              label: const Text('Shuffle'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1DB954),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =============================
              // Search Empty state
              // =============================
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // =============================
              // Song list
              // =============================
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = filtered[index];
                      final originalIndex = playlist.indexOf(song);

                      return MusicListTile(
                        song: song,
                        goToSong: () => goToSong(originalIndex),
                        saveToSavedSongs: () => saveToSavedSongs(song),
                      );
                    }, childCount: filtered.length),
                  ),
                ),

              // Bottom padding for control bar
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          );
        },
      ),

      bottomNavigationBar: const SafeArea(child: MusicControlBar()),
    );
  }

  // =============================
  // Loading State Widget
  // =============================
  Widget _buildLoadingState(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1DB954).withOpacity(0.2),
                  const Color(0xFF121212),
                ]
              : [const Color(0xFF1DB954).withOpacity(0.1), Colors.grey[50]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated music icon
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 80,
                    color: const Color(0xFF1DB954).withOpacity(value),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your music...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // Empty State Widget (with Retry)
  // =============================
  Widget _buildEmptyState(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1DB954).withOpacity(0.2),
                  const Color(0xFF121212),
                ]
              : [const Color(0xFF1DB954).withOpacity(0.1), Colors.grey[50]!],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.music_off_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No music found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We couldn\'t find any music on your device',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make sure you have audio files in your storage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _retryLoading,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================
  // Modern SearchBar widget
  // =============================
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: "Search songs or artists...",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF242424) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF1DB954), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
