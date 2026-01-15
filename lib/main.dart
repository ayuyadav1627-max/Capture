import 'package:flutter/material.dart';

void main() {
  runApp(const CaptureApp());
}

enum Mood { calm, happy, focused, stressed, sad }

class Moment {
  final String text;
  final Mood mood;

  Moment(this.text, this.mood);
}

class CaptureApp extends StatefulWidget {
  const CaptureApp({super.key});

  @override
  State<CaptureApp> createState() => _CaptureAppState();
}

class _CaptureAppState extends State<CaptureApp> {
  Mood _currentMood = Mood.calm;
  bool _isDarkMode = false;
  final List<Moment> _moments = [];

  ThemeData _getTheme(Mood mood, bool isDark) {
    Color seed;
    switch (mood) {
      case Mood.calm:
        seed = Colors.teal;
        break;
      case Mood.happy:
        seed = Colors.orange;
        break;
      case Mood.focused:
        seed = Colors.indigo;
        break;
      case Mood.stressed:
        seed = Colors.grey;
        break;
      case Mood.sad:
        seed = Colors.deepPurple;
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  void _addMoment(String text, Mood mood) {
    setState(() {
      _moments.add(Moment(text, mood));
      _currentMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capture',
      theme: _getTheme(_currentMood, _isDarkMode),
      home: HomeScreen(
        moments: _moments,
        isDark: _isDarkMode,
        onAddMoment: _addMoment,
        onToggleMode: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Moment> moments;
  final bool isDark;
  final void Function(String, Mood) onAddMoment;
  final VoidCallback onToggleMode;

  const HomeScreen({
    super.key,
    required this.moments,
    required this.isDark,
    required this.onAddMoment,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleMode,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '${moments.length} moment${moments.length == 1 ? '' : 's'} captured',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: moments.isEmpty
                  ? Center(
                      child: Text(
                        'Nothing yet.\nSomething will be worth remembering.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.hintColor),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: moments.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading:
                                Icon(_iconForMood(moments[index].mood)),
                            title: Text(
                              moments[index].text,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CaptureMomentScreen(onSave: onAddMoment),
                        ),
                      );
                    },
                    child: const Text('Capture Moment'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: moments.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReflectionScreen(moments: moments),
                            ),
                          );
                        },
                  child: const Text('Reflect'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CaptureMomentScreen extends StatefulWidget {
  final void Function(String, Mood) onSave;

  const CaptureMomentScreen({super.key, required this.onSave});

  @override
  State<CaptureMomentScreen> createState() => _CaptureMomentScreenState();
}

class _CaptureMomentScreenState extends State<CaptureMomentScreen> {
  final TextEditingController _controller = TextEditingController();
  Mood _selectedMood = Mood.calm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Moment'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What happened?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Mood>(
              value: _selectedMood,
              decoration: const InputDecoration(
                labelText: 'Mood',
                border: OutlineInputBorder(),
              ),
              items: Mood.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.name.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (m) => setState(() => _selectedMood = m!),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onSave(_controller.text, _selectedMood);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}

class ReflectionScreen extends StatelessWidget {
  final List<Moment> moments;

  const ReflectionScreen({super.key, required this.moments});

  String _opening(int count) {
    if (count == 1) return 'You paused once today.';
    if (count <= 3) return 'You captured a few moments today.';
    return 'You paid attention to your day more than usual.';
  }

  String _observation(Map<Mood, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final dominant = entries.first;
    final mixed =
        entries.length > 1 && entries[1].value >= dominant.value - 1;

    if (mixed) {
      return 'Your day didn’t settle into one emotion. It shifted as it went.';
    }

    switch (dominant.key) {
      case Mood.calm:
        return 'Most moments carried a quiet, steady tone.';
      case Mood.happy:
        return 'There was lightness in how the day unfolded.';
      case Mood.focused:
        return 'You spent much of today mentally present and engaged.';
      case Mood.stressed:
        return 'Today demanded attention and effort.';
      case Mood.sad:
        return 'Some moments felt heavier than others.';
    }
  }

  String? _closing(int count, Mood dominant) {
    if (count == 1) return null;

    switch (dominant) {
      case Mood.calm:
        return 'Stillness found space today.';
      case Mood.happy:
        return 'Hold onto what felt good.';
      case Mood.focused:
        return 'That focus came from somewhere.';
      case Mood.stressed:
        return 'Not every demanding day needs resolution.';
      case Mood.sad:
        return 'You don’t need to make sense of it tonight.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final counts = <Mood, int>{};
    for (var m in moments) {
      counts[m.mood] = (counts[m.mood] ?? 0) + 1;
    }

    final dominant =
        counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final opening = _opening(moments.length);
    final observation = _observation(counts);
    final closing = _closing(moments.length, dominant);

    return Scaffold(
      appBar: AppBar(title: const Text('Reflection'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(opening,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              Text(observation,
                  textAlign: TextAlign.center,
                  style:
                      theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
              if (closing != null) ...[
                const SizedBox(height: 24),
                Text(closing,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.hintColor)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForMood(Mood mood) {
  switch (mood) {
    case Mood.calm:
      return Icons.spa;
    case Mood.happy:
      return Icons.sentiment_very_satisfied;
    case Mood.focused:
      return Icons.center_focus_strong;
    case Mood.stressed:
      return Icons.warning_amber_rounded;
    case Mood.sad:
      return Icons.sentiment_dissatisfied;
  }
}
