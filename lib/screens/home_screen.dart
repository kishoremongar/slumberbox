// lib/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Map<String, String>> sounds = [
    {
      'label': 'Sleeping Music',
      'iconPath': 'assets/icons/sleep.svg',
      'file': 'sounds/sleeping.m4a',
    },
    {
      'label': 'Thunder',
      'iconPath': 'assets/icons/thunder.svg',
      'file': 'sounds/thunder.m4a',
    },
    {
      'label': 'Bowl',
      'iconPath': 'assets/icons/bowl.svg',
      'file': 'sounds/singing-bowl.aac',
    },
    {
      'label': 'Wave & Seagulls',
      'iconPath': 'assets/icons/wave.svg',
      'file': 'sounds/wave.m4a',
    },
    {
      'label': 'Bonfire',
      'iconPath': 'assets/icons/bonfire.svg',
      'file': 'sounds/firecracker.aac',
    },
    {
      'label': 'Creek',
      'iconPath': 'assets/icons/tree.svg',
      'file': 'sounds/creek.m4a',
    },
    {
      'label': 'Frog',
      'iconPath': 'assets/icons/frog-1.svg',
      'file': 'sounds/frog.aac',
    },
    {
      'label': 'Bird',
      'iconPath': 'assets/icons/bird.svg',
      'file': 'sounds/birds.m4a',
    },
    {
      'label': 'Wind',
      'iconPath': 'assets/icons/wind.svg',
      'file': 'sounds/wind.m4a',
    },
    {
      'label': 'Forest',
      'iconPath': 'assets/icons/forest.svg',
      'file': 'sounds/forest.m4a',
    },
  ];

  // UI palette
  static const bg = Color(0xFF1A1B26);
  static const surface = Color(0xFF2A2B36);
  static const textC = Color(0xFFCDCFD9);
  static const accent = Color(0xFF3B82F6);
  static const trackBg = Color(0xFF1F2937);
  static const iconColor = Color(0xFF4D5878);

  late final List<bool> _enabled;
  late final List<double> _volumes;
  late final List<AudioPlayer> _players;

  Timer? _sleepTimer; // one-shot stop
  Timer? _countdownTimer; // periodic for UI
  Duration? _remainingTime; // for display

  @override
  void initState() {
    super.initState();
    final count = sounds.length;
    _enabled = List<bool>.filled(count, false);
    _volumes = List<double>.filled(count, 0.5);
    _players = List.generate(count, (i) {
      final player =
          AudioPlayer(playerId: 'player_$i')
            ..setPlayerMode(PlayerMode.lowLatency)
            ..setReleaseMode(ReleaseMode.loop)
            ..setAudioContext(
              AudioContext(
                android: AudioContextAndroid(
                  isSpeakerphoneOn: true,
                  stayAwake: true,
                  contentType: AndroidContentType.music,
                  usageType: AndroidUsageType.media,
                  audioFocus: AndroidAudioFocus.none,
                ),
                iOS: AudioContextIOS(
                  category: AVAudioSessionCategory.playback,
                  options: <AVAudioSessionOptions>{
                    AVAudioSessionOptions.mixWithOthers,
                  },
                ),
              ),
            );
      return player;
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    for (final p in _players) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleSound(int i) async {
    if (_enabled[i]) {
      await _players[i].stop();
      setState(() => _enabled[i] = false);
    } else {
      await _players[i].setVolume(_volumes[i]);
      await _players[i].play(AssetSource(sounds[i]['file']!));
      setState(() => _enabled[i] = true);
    }
  }

  void _stopAllSounds() {
    if (!mounted) return;

    _sleepTimer?.cancel();
    _countdownTimer?.cancel();

    setState(() {
      _remainingTime = null;
      for (var i = 0; i < _players.length; i++) {
        _players[i].stop();
        _enabled[i] = false;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All sounds & timer stopped')));
  }

  void _saveMix() {
    if (!mounted) return;
    // TODO: persist _enabled & _volumes
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mix saved!')));
  }

  String _formatDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _showTimerPicker() async {
    final minutes = await showModalBottomSheet<int>(
      context: context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children:
                [15, 30, 45, 60].map((m) {
                  return ListTile(
                    title: Text('$m minutes'),
                    onTap: () => Navigator.pop(ctx, m),
                  );
                }).toList(),
          ),
    );

    if (!mounted) return;
    if (minutes != null) {
      // cancel any existing
      _sleepTimer?.cancel();
      _countdownTimer?.cancel();

      // set remaining and start UI countdown
      setState(() => _remainingTime = Duration(minutes: minutes));
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return t.cancel();
        setState(() {
          final r = _remainingTime! - const Duration(seconds: 1);
          if (r.inSeconds <= 0) {
            t.cancel();
            _remainingTime = null;
          } else {
            _remainingTime = r;
          }
        });
      });

      // schedule actual stop
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        if (!mounted) return;
        _stopAllSounds();
        setState(() => _remainingTime = null);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Timer set for $minutes minutes')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: const Text('Slumber Box', style: TextStyle(color: textC)),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer, color: textC),
            onPressed: _showTimerPicker,
          ),
          if (_remainingTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  _formatDur(_remainingTime!),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sounds.length,
        itemBuilder: (ctx, i) {
          final e = sounds[i];
          return Card(
            color: surface,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: ListTile(
              leading: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _toggleSound(i),
                child: SvgPicture.asset(
                  e['iconPath']!,
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    _enabled[i] ? accent : iconColor,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder:
                      (_) => const Icon(Icons.error, color: Colors.red),
                ),
              ),
              title: Text(e['label']!, style: const TextStyle(color: textC)),
              subtitle: Slider(
                min: 0,
                max: 1,
                value: _volumes[i],
                onChanged:
                    _enabled[i]
                        ? (v) async {
                          await _players[i].setVolume(v);
                          setState(() => _volumes[i] = v);
                        }
                        : null,
                activeColor: accent,
                inactiveColor: trackBg,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.save, color: textC),
                onPressed: _saveMix,
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: textC),
                onPressed: _stopAllSounds,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
