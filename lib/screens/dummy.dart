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
  // Define your sounds, icons & file paths
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

  // State: enabled flags, volumes, and AudioPlayers
  late final List<bool> _enabled;
  late final List<double> _volumes;
  late final List<AudioPlayer> _players;

  Timer? _sleepTimer;

  @override
  void initState() {
    super.initState();
    final count = sounds.length;
    _enabled = List<bool>.filled(count, false);
    _volumes = List<double>.filled(count, 0.5);
    _players = List.generate(count, (i) {
      final player = AudioPlayer(playerId: 'player_$i');

      // low-latency looping
      player.setPlayerMode(PlayerMode.lowLatency);
      player.setReleaseMode(ReleaseMode.loop);

      // configure audio focus/session
      player.setAudioContext(
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
    for (var i = 0; i < _players.length; i++) {
      _players[i].stop();
      _enabled[i] = false;
    }
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All sounds stopped')));
  }

  void _saveMix() {
    if (!mounted) return;
    // TODO: persist _enabled & _volumes to local storage
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mix saved!')));
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
      _sleepTimer?.cancel();
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        if (!mounted) return;
        _stopAllSounds();
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
        title: const Text('SlumberBox', style: TextStyle(color: textC)),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer, color: textC),
            onPressed: _showTimerPicker,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sounds.length,
        itemBuilder: (ctx, i) {
          final entry = sounds[i];
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
                  entry['iconPath']!,
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
              title: Text(
                entry['label']!,
                style: const TextStyle(color: textC),
              ),
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
