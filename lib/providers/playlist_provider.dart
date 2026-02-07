import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/models/song.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [];

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  int? _currentSongIndex;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoadingMusic = false;

  PlaylistProvider() {
    listenToDuration();
  }

  // =============================
  // Load music from device
  // =============================
  Future<void> loadMusicFromDevice() async {
    if (_isLoadingMusic) return; // Prevent multiple simultaneous loads

    _isLoadingMusic = true;

    try {
      // Request permission using permission_handler (more reliable)
      final status = await Permission.audio.request();

      if (status.isGranted) {
        // Query songs from device
        final List<SongModel> songs = await _audioQuery.querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        _playlist.clear();

        // Convert to our Song model
        for (var song in songs) {
          // Skip songs without valid data
          if (song.data.isEmpty || song.duration == null) continue;

          _playlist.add(
            Song(
              songName: song.title,
              artistName: song.artist ?? 'Unknown Artist',
              albumArtImagePath: '', // Will be handled separately if needed
              audioPath: song.data, // This is the file path
            ),
          );
        }

        debugPrint('✅ Loaded ${_playlist.length} songs from device');
      } else {
        debugPrint('❌ Audio permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error loading music: $e');
    } finally {
      _isLoadingMusic = false;
      notifyListeners();
    }
  }

  // =============================
  // Playback controls
  // =============================
  Future<void> playCurrentSong() async {
    if (_currentSongIndex == null || _playlist.isEmpty) return;

    final String path = _playlist[_currentSongIndex!].audioPath;

    try {
      await _audioPlayer.stop();

      // Check if path is asset or file
      if (path.startsWith('audios/')) {
        // Asset source
        await _audioPlayer.play(AssetSource(path));
      } else {
        // Device file source
        await _audioPlayer.play(DeviceFileSource(path));
      }

      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error playing song: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void pauseOrResume() {
    _isPlaying ? pause() : resume();
  }

  void playNextSong() {
    if (_currentSongIndex == null || _playlist.isEmpty) return;

    if (_currentSongIndex! < _playlist.length - 1) {
      currentSongIndex = _currentSongIndex! + 1;
    } else {
      currentSongIndex = 0;
    }
  }

  void playPreviousSong() {
    if (_currentSongIndex == null || _playlist.isEmpty) return;

    if (_currentDuration.inSeconds > 2) {
      playCurrentSong();
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _playlist.length - 1;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  // =============================
  // Getters
  // =============================
  List<Song> get playList => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  bool get isLoadingMusic => _isLoadingMusic;

  Song? get currentSong {
    if (_currentSongIndex != null &&
        _currentSongIndex! >= 0 &&
        _currentSongIndex! < _playlist.length) {
      return _playlist[_currentSongIndex!];
    }
    return null;
  }

  // =============================
  // Setters
  // =============================
  set currentSongIndex(int? newIndex) {
    if (newIndex != null && newIndex >= 0 && newIndex < _playlist.length) {
      _currentSongIndex = newIndex;
      playCurrentSong();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void setRepeatMode(bool isRepeatOn) {
    _audioPlayer.setReleaseMode(
      isRepeatOn ? ReleaseMode.loop : ReleaseMode.stop,
    );
  }

  void setShuffleMode(bool isShuffleOn) {}
}
