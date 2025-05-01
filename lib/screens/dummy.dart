import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      'file': 'assets/sounds/sleeping.m4a',
    },
    {
      'label': 'Thunder',
      'iconPath': 'assets/icons/thunder.svg',
      'file': 'assets/sounds/thunder.m4a',
    },
    {
      'label': 'Bowl',
      'iconPath': 'assets/icons/bowl.svg',
      'file': 'assets/sounds/singing-bowl.m4a',
    },
    {
      'label': 'Wave & Seagulls',
      'iconPath': 'assets/icons/wave.svg',
      'file': 'assets/sounds/wave.m4a',
    },
    {
      'label': 'Bonfire',
      'iconPath': 'assets/icons/bonfire.svg',
      'file': 'assets/sounds/firecracker.m4a',
    },
    {
      'label': 'Creek',
      'iconPath': 'assets/icons/tree.svg',
      'file': 'assets/sounds/creek.m4a',
    },
    {
      'label': 'Frog',
      'iconPath': 'assets/icons/frog-1.svg',
      'file': 'assets/sounds/frog.m4a',
    },
    {
      'label': 'Bird',
      'iconPath': 'assets/icons/bird.svg',
      'file': 'assets/sounds/birds.m4a',
    },
    {
      'label': 'Wind',
      'iconPath': 'assets/icons/wind.svg',
      'file': 'assets/sounds/wind.m4a',
    },
    {
      'label': 'Forest',
      'iconPath': 'assets/icons/forest.svg',
      'file': 'assets/sounds/forest.m4a',
    },
  ];

  // UI palette
  static const bg = Color(0xFF1A1B26);
  static const surface = Color(0xFF2A2B36);
  static const textC = Color(0xFFCDCFD9);
  static const accent = Color(0xFF3B82F6);
  static const trackBg = Color(0xFF1F2937);

  // State: enabled flags, volumes, and AudioPlayers
  late final List<bool> _enabled;
  late final List<double> _volumes;
  late final List<AudioPlayer> _players;

  @override
  void initState() {
    super.initState();
    final count = sounds.length;
    _enabled = List<bool>.filled(count, false);
    _volumes = List<double>.filled(count, 0.5);
    _players = List.generate(count, (_) {
      final p = AudioPlayer();
      p.setReleaseMode(ReleaseMode.loop); // loop the sound
      return p;
    });
  }

  @override
  void dispose() {
    // Dispose all players
    for (final p in _players) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleSound(int i) async {
    if (_enabled[i]) {
      // Was on → turn off
      await _players[i].stop();
      setState(() => _enabled[i] = false);
    } else {
      // Was off → turn on & play
      await _players[i].setVolume(_volumes[i]);
      await _players[i].play(DeviceFileSource(sounds[i]['file']!));
      setState(() => _enabled[i] = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: const Text('SlumberBox', style: TextStyle(color: textC)),
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
                  entry['icon']!,
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    _enabled[i] ? accent : trackBg,
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
                          // adjust volume in real time
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
        child: Container(height: 56),
      ),
    );
  }
}
