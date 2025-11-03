import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mini_spotify_clone/models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [
    Song(
      albumArtImagePath: 'assets/images/Interlinked.jpg',
      artistName: 'Lonely Lies & GOLDKID\$',
      audioPath: 'audios/interlinked.mp3',
      songName: 'InterLinked',
    ),
    Song(
      albumArtImagePath: 'assets/images/avangard.jpg',
      artistName: 'LONOWN',
      audioPath: 'audios/Avangard.mp3',
      songName: 'AVANGARD',
    ),
    Song(
      albumArtImagePath: 'assets/images/Memory_reboot.jpeg',
      artistName: 'VØJ, Narvent',
      audioPath: 'audios/Memory_Reboot.mp3',
      songName: 'Memory Reboot',
    ),
  ];

  int? _currentSongIndex;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  bool _isPlaying = false;

  PlaylistProvider() {
    listenToDuration();
  }

  Future<void> playCurrentSong() async {
    if (_currentSongIndex == null) return;
    final String path = playList[_currentSongIndex!].audioPath;

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));

    _isPlaying = true;
    notifyListeners();
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
    if (_currentSongIndex == null) return;

    if (_currentSongIndex! < playList.length - 1) {
      currentSongIndex = _currentSongIndex! + 1;
    } else {
      currentSongIndex = 0;
    }
  }

  void playPreviousSong() {
    if (_currentDuration.inSeconds > 2) {
      // если песня уже играла >2 сек, то просто начать её сначала
      playCurrentSong();
    } else {
      // иначе — предыдущая песня
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = playList.length - 1;
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

  List<Song> get playList => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    playCurrentSong();
    notifyListeners();
  }
}
