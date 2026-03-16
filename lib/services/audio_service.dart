import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  double _masterVolume = 1.0;
  double _musicVolume = 0.5;
  bool _masterMuted = false;
  bool _musicMuted = false;

  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  bool get masterMuted => _masterMuted;
  bool get musicMuted => _musicMuted;

  // ── Load Settings ─────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _masterVolume = prefs.getDouble('masterVolume') ?? 1.0;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _masterMuted = prefs.getBool('masterMuted') ?? false;
    _musicMuted = prefs.getBool('musicMuted') ?? false;

    _sfxPlayer.setVolume(_sfxVolume);
    _musicPlayer.setVolume(_bgmVolume);

    await startBgm();
  }

  double get _sfxVolume => _masterMuted ? 0 : _masterVolume;
  double get _bgmVolume =>
      (_masterMuted || _musicMuted) ? 0 : _masterVolume * _musicVolume;

  // ── SFX ───────────────────────────────────────────
  Future<void> playBtnClick() => _playSfx('btn_click.mp3');
  Future<void> playCardFlip() => _playSfx('card_flip.mp3');
  Future<void> playCorrect() => _playSfx('correct.mp3');
  Future<void> playWrong() => _playSfx('wrong.mp3');
  Future<void> playLevelUp() => _playSfx('level_up.mp3');
  Future<void> playPurchase() => _playSfx('purchase.mp3');

  Future<void> _playSfx(String file) async {
    if (_masterMuted) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource('sounds/$file'));
  }

  // ── BGM ───────────────────────────────────────────
  Future<void> playBgm(String file) async {
    if (_masterMuted || _musicMuted) return;
    await _musicPlayer.setVolume(_bgmVolume);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('sounds/$file'));
  }

  Future<void> stopBgm() => _musicPlayer.stop();
  Future<void> pauseBgm() => _musicPlayer.pause();
  Future<void> resumeBgm() async {
    if (_masterMuted || _musicMuted) return;
    await _musicPlayer.resume();
  }

  Future<void> startBgm() async {
    await _musicPlayer.setVolume(_bgmVolume);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('sounds/bgm_music.mp3'));
  }

  // ── Volume Control ────────────────────────────────
  Future<void> setMasterVolume(double v) async {
    _masterVolume = v;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _musicPlayer.setVolume(_bgmVolume);
    _save();
  }

  Future<void> setMusicVolume(double v) async {
    _musicVolume = v;
    await _musicPlayer.setVolume(_bgmVolume);
    _save();
  }

  Future<void> toggleMasterMute() async {
    _masterMuted = !_masterMuted;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _musicPlayer.setVolume(_bgmVolume);
    if (_masterMuted) {
      await _musicPlayer.pause();
    } else {
      await _musicPlayer.resume();
    }
    _save();
  }

  Future<void> toggleMusicMute() async {
    _musicMuted = !_musicMuted;
    await _musicPlayer.setVolume(_bgmVolume);
    if (_musicMuted) {
      await _musicPlayer.pause();
    } else {
      await _musicPlayer.resume();
    }
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
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
