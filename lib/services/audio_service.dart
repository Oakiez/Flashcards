import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._();

  // ── BGM ──────────────────────────────────
  final AudioPlayer _musicPlayer = AudioPlayer();

  // ── SFX ──────────────────────
  final AudioPlayer _sfxClick = AudioPlayer();
  final AudioPlayer _sfxFlip = AudioPlayer();
  final AudioPlayer _sfxCorrect = AudioPlayer();
  final AudioPlayer _sfxWrong = AudioPlayer();
  final AudioPlayer _sfxLevelUp = AudioPlayer();
  final AudioPlayer _sfxPurchase = AudioPlayer();

  double _masterVolume = 1.0;
  double _musicVolume = 0.5;
  bool _masterMuted = false;
  bool _musicMuted = false;

  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  bool get masterMuted => _masterMuted;
  bool get musicMuted => _musicMuted;

  double get _sfxVol => _masterMuted ? 0.0 : _masterVolume;
  double get _bgmVol =>
      (_masterMuted || _musicMuted) ? 0.0 : _masterVolume * _musicVolume;

  List<AudioPlayer> get _sfxPlayers => [
    _sfxClick,
    _sfxFlip,
    _sfxCorrect,
    _sfxWrong,
    _sfxLevelUp,
    _sfxPurchase,
  ];

  // ── Init ───────────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _masterVolume = prefs.getDouble('masterVolume') ?? 1.0;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _masterMuted = prefs.getBool('masterMuted') ?? false;
    _musicMuted = prefs.getBool('musicMuted') ?? false;

    for (final p in _sfxPlayers) {
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    }

    await _musicPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);

    await startBgm();
  }

  // ── SFX ───────────────────────────────────────────────────────
  Future<void> playBtnClick() => _playSfx(_sfxClick, 'btn_click.mp3');
  Future<void> playCardFlip() => _playSfx(_sfxFlip, 'card_flip.mp3');
  Future<void> playCorrect() => _playSfx(_sfxCorrect, 'correct.mp3');
  Future<void> playWrong() => _playSfx(_sfxWrong, 'wrong.mp3');
  Future<void> playLevelUp() => _playSfx(_sfxLevelUp, 'level_up.mp3');
  Future<void> playPurchase() => _playSfx(_sfxPurchase, 'purchase.mp3');

  Future<void> _playSfx(AudioPlayer player, String file) async {
    if (_masterMuted) return;
    try {
      await player.setVolume(_sfxVol);
      await player.play(AssetSource('sounds/$file'));
    } catch (_) {}
  }

  // ── BGM ───────────────────────────────────────────────────────
  Future<void> startBgm() async {
    try {
      await _musicPlayer.setVolume(_bgmVol);
      await _musicPlayer.play(AssetSource('sounds/bgm_music.mp3'));
    } catch (_) {}
  }

  Future<void> stopBgm() => _musicPlayer.stop();
  Future<void> pauseBgm() => _musicPlayer.pause();

  Future<void> resumeBgm() async {
    try {
      await _musicPlayer.setVolume(_bgmVol);
      // ถ้าหยุดเล่นไปแล้ว ให้เริ่มใหม่
      final state = _musicPlayer.state;
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        await startBgm();
      } else {
        await _musicPlayer.resume();
      }
    } catch (_) {}
  }

  // ── Volume & Mute ─────────────────────────────────────────────
  Future<void> setMasterVolume(double v) async {
    _masterVolume = v;
    await _musicPlayer.setVolume(_bgmVol);
    _save();
  }

  Future<void> setMusicVolume(double v) async {
    _musicVolume = v;
    await _musicPlayer.setVolume(_bgmVol);
    _save();
  }

  Future<void> toggleMasterMute() async {
    _masterMuted = !_masterMuted;
    await _musicPlayer.setVolume(_bgmVol);
    if (!_masterMuted) await resumeBgm();
    _save();
  }

  Future<void> toggleMusicMute() async {
    _musicMuted = !_musicMuted;
    await _musicPlayer.setVolume(_bgmVol);
    if (!_musicMuted) await resumeBgm();
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('masterVolume', _masterVolume);
    prefs.setDouble('musicVolume', _musicVolume);
    prefs.setBool('masterMuted', _masterMuted);
    prefs.setBool('musicMuted', _musicMuted);
  }

  void dispose() {
    _musicPlayer.dispose();
    for (final p in _sfxPlayers) p.dispose();
  }
}
