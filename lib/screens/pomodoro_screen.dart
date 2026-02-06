import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

enum PomodoroState { initial, focusing, breakTime, completed }

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Timer State
  PomodoroState _currentState = PomodoroState.initial;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _currentRep = 1;

  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, String> _soundOptions = {
    'Bell': 'bell',
    'Digital': 'digital',
    'Nature': 'nature',
  };

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer(PomodoroProvider provider) {
    if (_currentState == PomodoroState.initial || _currentState == PomodoroState.completed) {
      setState(() {
        _currentState = PomodoroState.focusing;
        _remainingSeconds = provider.focusMinutes * 60;
        _currentRep = 1;
      });
      _playSound(provider.startSound);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _handleTimerComplete(provider);
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      // Just pause, keep state
    });
  }

  void _resetTimer(PomodoroProvider provider) {
    _timer?.cancel();
    setState(() {
      _currentState = PomodoroState.initial;
      _remainingSeconds = provider.focusMinutes * 60;
      _currentRep = 1;
    });
  }

  void _handleTimerComplete(PomodoroProvider provider) {
    _timer?.cancel();
    if (_currentState == PomodoroState.focusing) {
      if (_currentRep < provider.totalReps) {
        _currentState = PomodoroState.breakTime;
        _remainingSeconds = provider.breakMinutes * 60;
        _playSound(provider.breakSound);
        // Auto-start break
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
           if (!mounted) {
            timer.cancel();
            return;
          }
           setState(() {
            if (_remainingSeconds > 0) {
              _remainingSeconds--;
            } else {
              _handleTimerComplete(provider);
            }
          });
        });
      } else {
        _currentState = PomodoroState.completed;
        _playSound(provider.endSound);
      }
    } else if (_currentState == PomodoroState.breakTime) {
      _currentState = PomodoroState.focusing;
      _currentRep++;
      _remainingSeconds = provider.focusMinutes * 60;
      _playSound(provider.startSound);
      // Auto-start focus
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
         if (!mounted) {
            timer.cancel();
            return;
         }
         setState(() {
            if (_remainingSeconds > 0) {
              _remainingSeconds--;
            } else {
              _handleTimerComplete(provider);
            }
          });
      });
    }
  }

  Future<void> _playSound(String soundName) async {
    try {
      // Placeholder for sound playing logic.
      debugPrint('Playing sound: $soundName');
      // await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context);
    final totalSeconds = _currentState == PomodoroState.focusing 
        ? provider.focusMinutes * 60 
        : provider.breakMinutes * 60;
    
    // Avoid division by zero
    final safeTotalSeconds = totalSeconds > 0 ? totalSeconds : 1;
        
    final progress = _currentState == PomodoroState.initial 
        ? 0.0 
        : (_currentState == PomodoroState.completed ? 1.0 : 1.0 - (_remainingSeconds / safeTotalSeconds));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Timer Display
            SizedBox(
              height: 250,
              width: 250,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    color: _currentState == PomodoroState.breakTime ? Colors.green : Theme.of(context).primaryColor,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentState == PomodoroState.initial ? 'Ready' : 
                          _currentState == PomodoroState.completed ? 'Done!' :
                          _currentState == PomodoroState.breakTime ? 'Break' : 'Focus',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(_remainingSeconds > 0 
                              ? _remainingSeconds 
                              : (_currentState == PomodoroState.breakTime ? provider.breakMinutes : provider.focusMinutes) * 60),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (_currentState != PomodoroState.initial && _currentState != PomodoroState.completed)
                          Text('Rep $_currentRep / ${provider.totalReps}', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_timer != null && _timer!.isActive)
                  FilledButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => _startTimer(provider),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _resetTimer(provider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 16),
            
            // Configuration
            Text('Configuration', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: provider.focusMinutes.toString(),
                    decoration: const InputDecoration(labelText: 'Focus (min)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final newVal = int.tryParse(val);
                      if (newVal != null) {
                        provider.updateSettings(focusMinutes: newVal);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: provider.breakMinutes.toString(),
                    decoration: const InputDecoration(labelText: 'Break (min)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final newVal = int.tryParse(val);
                      if (newVal != null) {
                        provider.updateSettings(breakMinutes: newVal);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: provider.totalReps.toString(),
                    decoration: const InputDecoration(labelText: 'Reps', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final newVal = int.tryParse(val);
                      if (newVal != null) {
                        provider.updateSettings(totalReps: newVal);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Sounds', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildSoundDropdown('Start Sound', provider.startSound, (val) => provider.updateSettings(startSound: val)),
            _buildSoundDropdown('Break Sound', provider.breakSound, (val) => provider.updateSettings(breakSound: val)),
            _buildSoundDropdown('End Sound', provider.endSound, (val) => provider.updateSettings(endSound: val)),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundDropdown(String label, String currentValue, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        DropdownButton<String>(
          value: currentValue,
          items: _soundOptions.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

