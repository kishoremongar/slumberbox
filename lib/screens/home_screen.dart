import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Map<String, String>> sounds = [
    {'label': 'Sleeping Music', 'iconPath': 'assets/icons/sleep.svg'},
    {'label': 'Thunder', 'iconPath': 'assets/icons/thunder.svg'},
    {'label': 'Bowl', 'iconPath': 'assets/icons/bowl.svg'},
    {'label': 'Wave & Seagulls', 'iconPath': 'assets/icons/wave.svg'},
    {'label': 'Bonfire', 'iconPath': 'assets/icons/bonfire.svg'},
    {'label': 'Creek', 'iconPath': 'assets/icons/tree.svg'},
    {'label': 'Frog', 'iconPath': 'assets/icons/frog-1.svg'},
    {'label': 'Bird', 'iconPath': 'assets/icons/bird.svg'},
    {'label': 'Wind', 'iconPath': 'assets/icons/wind.svg'},
    {'label': 'Forest', 'iconPath': 'assets/icons/forest.svg'},
  ];

  // UI palette
  static const Color bg = Color(0xFF161421);
  static const Color surface = Color(0xFF2A2B36);
  static const Color textC = Color(0xFFCDCFD9);
  static const Color accent = Color(0xFF3B82F6);
  static const Color trackBg = Color(0xFF1F2937);

  late final List<Future<String>> _svgDataFutures;
  final List<bool> _enabled = List<bool>.filled(sounds.length, false);
  final List<double> _volumes = List<double>.filled(sounds.length, 0.5);

  @override
  void initState() {
    super.initState();
    // Pre-load & clean all SVGs (strip <style> blocks)
    _svgDataFutures =
        sounds.map((s) {
          return rootBundle.loadString(s['iconPath']!).then((raw) {
            return raw.replaceAll(RegExp(r'<style[\s\S]*?<\/style>'), '');
          });
        }).toList();
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: textC),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sounds.length,
        itemBuilder: (ctx, i) {
          final sound = sounds[i];
          return FutureBuilder<String>(
            future: _svgDataFutures[i],
            builder: (ctx, snap) {
              Widget leadingIcon;
              if (snap.hasData) {
                leadingIcon = InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => _enabled[i] = !_enabled[i]),
                  child: SvgPicture.string(
                    snap.data!,
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      _enabled[i] ? accent : trackBg,
                      BlendMode.srcIn,
                    ),
                  ),
                );
              } else {
                leadingIcon = SizedBox(
                  width: 32,
                  height: 32,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return Card(
                color: surface,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ListTile(
                  leading: leadingIcon,
                  title: Text(
                    sound['label']!,
                    style: const TextStyle(color: textC),
                  ),
                  subtitle: Slider(
                    min: 0,
                    max: 1,
                    value: _volumes[i],
                    onChanged:
                        _enabled[i]
                            ? (v) => setState(() => _volumes[i] = v)
                            : null,
                    activeColor: accent,
                    inactiveColor: trackBg,
                  ),
                ),
              );
            },
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
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.loop, color: textC),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow, color: textC),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
