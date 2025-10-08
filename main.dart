import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Halloween Challenge',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B12),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const HomeScreen(),
        '/game': (_) => const GameScreen(),
        '/win': (_) => const WinScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0B12), Color(0xFF1B1530)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Spooky Finder \u{1F383}',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text('Find the right item. Avoid the traps!',
                  style: TextStyle(color: Colors.orangeAccent)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/game'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                  child: Text('Start', style: TextStyle(fontSize: 20)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const _HowToPlayDialog(),
                ),
                child: const Text('How to play'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowToPlayDialog extends StatelessWidget {
  const _HowToPlayDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1B1530),
      title: const Text('How to play'),
      content: const Text(
        'Objects float around. Tap the CORRECT one to win. Tapping a TRAP flashes the screen. Hint: the right one glows brighter.\n\nNo downloads needed; this build has zero assets.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
      ],
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int _itemCount = 8;
  final int _targetIndex = Random().nextInt(_itemCount);
  bool _flash = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find the Correct Item'),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hint: the winner glows more!')),
            ),
            icon: const Icon(Icons.tips_and_updates_outlined),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.0,
                  colors: [Color(0xFF12121C), Color(0xFF090910)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: List.generate(_itemCount, (i) {
                    final isTarget = i == _targetIndex;
                    return FloatingItem(
                      key: ValueKey('float_$i'),
                      speedMs: 2200 + Random().nextInt(1800),
                      child: SpookyToken(isTarget: isTarget, index: i),
                      onTap: () => isTarget ? _onWin() : _onTrap(),
                    );
                  }),
                );
              },
            ),
          ),
          if (_flash)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.red.withOpacity(0.35),
                  child: const Center(
                    child: Text(
                      'BOO!',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onTrap() async {
    setState(() => _flash = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _flash = false);
  }

  void _onWin() => Navigator.pushReplacementNamed(context, '/win');
}

class SpookyToken extends StatefulWidget {
  final bool isTarget;
  final int index;
  const SpookyToken({super.key, required this.isTarget, required this.index});

  @override
  State<SpookyToken> createState() => _SpookyTokenState();
}

class _SpookyTokenState extends State<SpookyToken>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
    lowerBound: 0.95,
    upperBound: 1.05,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(widget.index);
    return ScaleTransition(
      scale: _pulse,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.isTarget
                  ? Colors.orangeAccent.withOpacity(0.75)
                  : Colors.deepPurpleAccent.withOpacity(0.45),
              blurRadius: widget.isTarget ? 24 : 12,
              spreadRadius: widget.isTarget ? 2 : 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            icon,
            size: 44,
            color: widget.isTarget ? Colors.orangeAccent : Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _iconFor(int i) {
    const icons = [
      Icons.dark_mode, // moon
      Icons.pest_control, // spider
      Icons.holiday_village, // house
      Icons.emoji_objects, // candle
      Icons.cruelty_free, // bat-like
      Icons.local_florist, // plant (trap)
      Icons.sick, // skull-ish face
      Icons.sentiment_very_dissatisfied, // ghoul face
    ];
    return icons[i % icons.length];
  }
}

class FloatingItem extends StatefulWidget {
  final Widget child;
  final int speedMs;
  final VoidCallback onTap;
  const FloatingItem({super.key, required this.child, required this.speedMs, required this.onTap});

  @override
  State<FloatingItem> createState() => _FloatingItemState();
}

class _FloatingItemState extends State<FloatingItem> {
  final _rand = Random();
  late Alignment _alignment = _randomAlignment();
  Timer? _timer;

  Alignment _randomAlignment() {
    final x = (_rand.nextDouble() * 1.8) - 0.9; // -0.9..0.9
    final y = (_rand.nextDouble() * 1.8) - 0.9; // -0.9..0.9
    return Alignment(x, y);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(milliseconds: widget.speedMs + 400 + _rand.nextInt(600)),
      (_) => setState(() => _alignment = _randomAlignment()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: Duration(milliseconds: widget.speedMs),
      curve: Curves.easeInOut,
      alignment: _alignment,
      child: GestureDetector(onTap: widget.onTap, child: widget.child),
    );
  }
}

class WinScreen extends StatelessWidget {
  const WinScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1530), Color(0xFF0B0B12)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 96, color: Colors.orangeAccent),
                const SizedBox(height: 12),
                const Text('You Found It! \u{1F389}',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
