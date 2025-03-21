import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:js' as js;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_vibration.dart';

// Define VibrationPreset enum to match the library's presets
enum VibrationPreset {
  alarm,
  notification,
  heartbeat,
  singleShortBuzz,
  doubleBuzz,
  tripleBuzz,
  longAlarmBuzz,
  pulseWave,
  progressiveBuzz,
  rhythmicBuzz,
  gentleReminder,
  quickSuccessAlert,
  zigZagAlert,
  softPulse,
  emergencyAlert,
  heartbeatVibration,
  countdownTimerAlert,
  rapidTapFeedback,
  dramaticNotification,
  urgentBuzzWave,
}

// Define VibrationPresetConfig class to store pattern and description
class VibrationPresetConfig {
  final List<int> pattern;
  final String description;
  final int? repeat;
  final int? amplitude;

  const VibrationPresetConfig({
    required this.pattern,
    required this.description,
    this.repeat,
    this.amplitude,
  });
}

void main() {
  // Ensure Flutter is initialized properly
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Vibrations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const VibrationDebugPage(),
    );
  }
}

class VibrationPattern {
  final String name;
  final List<int> pattern;
  final int? repeat;
  final int? amplitude;
  final String description;

  const VibrationPattern({
    required this.name,
    required this.pattern,
    this.repeat,
    this.amplitude,
    this.description = '',
  });
}

class VibrationDebugPage extends StatefulWidget {
  const VibrationDebugPage({Key? key}) : super(key: key);

  @override
  State<VibrationDebugPage> createState() => _VibrationDebugPageState();
}

class _VibrationDebugPageState extends State<VibrationDebugPage> {
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;
  bool _hasCustomDurations = false;
  bool _isVibrating = false;
  bool _isIOS = false;

  // Map of VibrationPreset to VibrationPresetConfig
  final Map<VibrationPreset, VibrationPresetConfig> presets = {
    VibrationPreset.alarm: const VibrationPresetConfig(
      pattern: [500, 200, 500, 200, 500, 200, 500, 200, 500],
      description: 'Continuous alarm pattern',
      repeat: 2,
    ),
    VibrationPreset.notification: const VibrationPresetConfig(
      pattern: [300, 100, 100],
      description: 'Standard notification pattern',
    ),
    VibrationPreset.heartbeat: const VibrationPresetConfig(
      pattern: [100, 100, 100, 400],
      description: 'Simulates a heartbeat rhythm',
      repeat: 3,
    ),
    VibrationPreset.singleShortBuzz: const VibrationPresetConfig(
      pattern: [100],
      description: 'A single short vibration (100ms)',
    ),
    VibrationPreset.doubleBuzz: const VibrationPresetConfig(
      pattern: [100, 50, 100],
      description: 'Two short vibrations in quick succession',
    ),
    VibrationPreset.tripleBuzz: const VibrationPresetConfig(
      pattern: [100, 50, 100, 50, 100],
      description: 'Three short vibrations in quick succession',
    ),
    VibrationPreset.longAlarmBuzz: const VibrationPresetConfig(
      pattern: [800, 200, 800, 200, 800],
      description: 'Long vibrations for important alarms',
      repeat: 1,
    ),
    VibrationPreset.pulseWave: const VibrationPresetConfig(
      pattern: [100, 50, 150, 50, 200, 50, 250, 50, 200, 50, 150, 50, 100],
      description: 'Wave-like pattern with increasing then decreasing durations',
    ),
    VibrationPreset.progressiveBuzz: const VibrationPresetConfig(
      pattern: [50, 50, 100, 50, 150, 50, 200, 50, 250, 50, 300],
      description: 'Gradually increasing intensity',
    ),
    VibrationPreset.rhythmicBuzz: const VibrationPresetConfig(
      pattern: [100, 100, 200, 100, 100, 100, 200, 100],
      description: 'Rhythmic pattern with regular intervals',
      repeat: 1,
    ),
    VibrationPreset.gentleReminder: const VibrationPresetConfig(
      pattern: [50, 100, 50, 100, 50],
      description: 'Gentle triple tap for subtle reminders',
    ),
    VibrationPreset.quickSuccessAlert: const VibrationPresetConfig(
      pattern: [50, 30, 100, 30, 200],
      description: 'Quick pattern indicating success',
    ),
    VibrationPreset.zigZagAlert: const VibrationPresetConfig(
      pattern: [50, 50, 100, 50, 50, 50, 100, 50, 50, 50, 100],
      description: 'Zig-zag pattern for attention-grabbing alerts',
    ),
    VibrationPreset.softPulse: const VibrationPresetConfig(
      pattern: [30, 100, 30, 100, 30],
      description: 'Very soft pulses for subtle feedback',
    ),
    VibrationPreset.emergencyAlert: const VibrationPresetConfig(
      pattern: [1000, 200, 1000, 200, 1000],
      description: 'Very long vibrations for emergency situations',
      amplitude: 255,
    ),
    VibrationPreset.heartbeatVibration: const VibrationPresetConfig(
      pattern: [150, 100, 150, 600],
      description: 'More pronounced heartbeat rhythm',
      repeat: 4,
    ),
    VibrationPreset.countdownTimerAlert: const VibrationPresetConfig(
      pattern: [300, 700, 300, 700, 300, 700, 1000],
      description: '3-2-1 countdown pattern ending with long vibration',
    ),
    VibrationPreset.rapidTapFeedback: const VibrationPresetConfig(
      pattern: [20, 30, 20, 30, 20, 30, 20, 30, 20],
      description: 'Very quick tapping sensation',
    ),
    VibrationPreset.dramaticNotification: const VibrationPresetConfig(
      pattern: [100, 100, 200, 100, 400, 100, 800],
      description: 'Dramatically increasing pattern for important notifications',
    ),
    VibrationPreset.urgentBuzzWave: const VibrationPresetConfig(
      pattern: [100, 50, 100, 50, 300, 100, 300, 100, 500],
      description: 'Urgent pattern with increasing intensity',
    ),
  };

  // Collection of vibration patterns
  final List<VibrationPattern> _vibrationPatterns = [
    // Basic patterns
    const VibrationPattern(
      name: 'Single Short',
      pattern: [100],
      description: 'A single short vibration (100ms)',
    ),
    const VibrationPattern(
      name: 'Single Medium',
      pattern: [300],
      description: 'A single medium vibration (300ms)',
    ),
    const VibrationPattern(
      name: 'Single Long',
      pattern: [500],
      description: 'A single long vibration (500ms)',
    ),
    const VibrationPattern(
      name: 'Extra Long',
      pattern: [1000],
      description: 'A single extra long vibration (1000ms)',
    ),
    
    // Notification patterns
    const VibrationPattern(
      name: 'Notification',
      pattern: [300, 100, 100],
      description: 'Standard notification pattern',
    ),
    const VibrationPattern(
      name: 'Double Notification',
      pattern: [300, 100, 300],
      description: 'Double notification pattern',
    ),
    const VibrationPattern(
      name: 'Triple Notification',
      pattern: [300, 100, 300, 100, 300],
      description: 'Triple notification pattern',
    ),
    const VibrationPattern(
      name: 'Gentle Notification',
      pattern: [200, 100, 100],
      description: 'Gentle notification pattern',
    ),
    const VibrationPattern(
      name: 'Urgent Notification',
      pattern: [400, 100, 400, 100, 400],
      description: 'Urgent notification pattern with stronger vibrations',
    ),
    const VibrationPattern(
      name: 'Message Notification',
      pattern: [100, 50, 100],
      description: 'Short notification pattern for messages',
    ),
    const VibrationPattern(
      name: 'Email Notification',
      pattern: [200, 100, 200, 100, 200],
      description: 'Triple short notification pattern for emails',
    ),
    const VibrationPattern(
      name: 'Calendar Notification',
      pattern: [300, 200, 500],
      description: 'Escalating pattern for calendar events',
    ),
    
    // Alert patterns
    const VibrationPattern(
      name: 'Alert',
      pattern: [500, 100, 500],
      description: 'Alert pattern with longer vibrations',
    ),
    const VibrationPattern(
      name: 'Urgent Alert',
      pattern: [500, 100, 500, 100, 500],
      description: 'Urgent alert pattern with three long vibrations',
    ),
    const VibrationPattern(
      name: 'Warning',
      pattern: [700, 200, 700],
      description: 'Warning pattern with very long vibrations',
    ),
    const VibrationPattern(
      name: 'Critical Alert',
      pattern: [800, 200, 800, 200, 800, 200, 800],
      description: 'Critical alert with four long vibrations',
    ),
    const VibrationPattern(
      name: 'Alarm',
      pattern: [500, 200, 500, 200, 500, 200, 500, 200, 500],
      description: 'Continuous alarm pattern',
      repeat: 2,
    ),
    
    // Rhythmic patterns
    const VibrationPattern(
      name: 'Heartbeat',
      pattern: [100, 100, 100, 400],
      repeat: 3,
      description: 'Simulates a heartbeat rhythm',
    ),
    const VibrationPattern(
      name: 'Quick Pulses',
      pattern: [100, 50, 100, 50, 100, 50, 100],
      description: 'Series of quick pulses',
    ),
    const VibrationPattern(
      name: 'Slow Pulses',
      pattern: [300, 200, 300, 200, 300],
      description: 'Series of slow pulses',
    ),
    const VibrationPattern(
      name: 'Rapid Taps',
      pattern: [50, 50, 50, 50, 50, 50, 50, 50, 50, 50],
      description: 'Very quick tapping sensation',
    ),
    const VibrationPattern(
      name: 'Crescendo',
      pattern: [50, 50, 100, 50, 150, 50, 200, 50, 250, 50, 300],
      description: 'Gradually increasing intensity',
    ),
    const VibrationPattern(
      name: 'Decrescendo',
      pattern: [300, 50, 250, 50, 200, 50, 150, 50, 100, 50, 50],
      description: 'Gradually decreasing intensity',
    ),
    const VibrationPattern(
      name: 'Waltz',
      pattern: [300, 100, 100, 100, 100, 100],
      repeat: 2,
      description: 'Waltz rhythm (ONE-two-three)',
    ),
    const VibrationPattern(
      name: 'Marching',
      pattern: [200, 200, 200, 200],
      repeat: 2,
      description: 'Steady marching rhythm',
    ),
    
    // Communication patterns
    const VibrationPattern(
      name: 'SOS',
      pattern: [
        100, 100, 100, 100, 100, 100,  // ... (3 short)
        300, 100, 300, 100, 300, 100,  // --- (3 long)
        100, 100, 100, 100, 100        // ... (3 short)
      ],
      description: 'SOS pattern in Morse code (... --- ...)',
    ),
    const VibrationPattern(
      name: 'Success',
      pattern: [100, 50, 100, 50, 300],
      description: 'Success feedback pattern',
    ),
    const VibrationPattern(
      name: 'Error',
      pattern: [300, 100, 300],
      description: 'Error feedback pattern',
    ),
    const VibrationPattern(
      name: 'Confirmation',
      pattern: [100, 50, 200],
      description: 'Short confirmation pattern',
    ),
    const VibrationPattern(
      name: 'Completion',
      pattern: [300, 100, 100, 100, 500],
      description: 'Task completion pattern',
    ),
    const VibrationPattern(
      name: 'Attention',
      pattern: [500, 200, 100, 200, 100],
      description: 'Pattern to grab attention',
    ),
    
    // Haptic feedback patterns
    const VibrationPattern(
      name: 'Button Press',
      pattern: [40],
      description: 'Very short feedback for button press',
    ),
    const VibrationPattern(
      name: 'Selection Change',
      pattern: [20, 30, 40],
      description: 'Subtle feedback for selection changes',
    ),
    const VibrationPattern(
      name: 'Slider Change',
      pattern: [30],
      description: 'Minimal feedback for slider adjustments',
    ),
    const VibrationPattern(
      name: 'Toggle',
      pattern: [60],
      description: 'Feedback for toggle switches',
    ),
    const VibrationPattern(
      name: 'Keyboard Tap',
      pattern: [15],
      description: 'Very light feedback for keyboard presses',
    ),
    const VibrationPattern(
      name: 'Heavy Impact',
      pattern: [400],
      description: 'Strong feedback for significant actions',
    ),
    const VibrationPattern(
      name: 'Light Impact',
      pattern: [80],
      description: 'Light feedback for minor actions',
    ),
    
    // Special patterns
    const VibrationPattern(
      name: 'Escalating',
      pattern: [100, 100, 200, 100, 300, 100, 400, 100, 500],
      description: 'Escalating duration pattern',
    ),
    const VibrationPattern(
      name: 'Descending',
      pattern: [500, 100, 400, 100, 300, 100, 200, 100, 100],
      description: 'Descending duration pattern',
    ),
    const VibrationPattern(
      name: 'Wave',
      pattern: [100, 50, 200, 50, 300, 50, 400, 50, 500, 50, 400, 50, 300, 50, 200, 50, 100],
      description: 'Wave-like pattern with increasing then decreasing durations',
    ),
    const VibrationPattern(
      name: 'Ripple',
      pattern: [50, 50, 100, 50, 150, 50, 200, 50, 250, 50, 300, 50, 350, 50, 400],
      description: 'Ripple effect with gradually increasing durations',
    ),
    const VibrationPattern(
      name: 'Heartbeat Intense',
      pattern: [150, 100, 150, 600],
      repeat: 4,
      description: 'More pronounced heartbeat rhythm',
    ),
    const VibrationPattern(
      name: 'Morse A',
      pattern: [100, 100, 300],
      description: 'Letter A in Morse code (.-)',
    ),
    const VibrationPattern(
      name: 'Morse B',
      pattern: [300, 100, 100, 100, 100, 100, 100],
      description: 'Letter B in Morse code (-...)',
    ),
    const VibrationPattern(
      name: 'Morse C',
      pattern: [300, 100, 100, 100, 300, 100, 100],
      description: 'Letter C in Morse code (-.-.)',
    ),
    const VibrationPattern(
      name: 'Morse Hello',
      pattern: [
        100, 100, 100, 100, 100, 100, 100, 100,  // H (.....)
        100, 100,                                // E (.)
        100, 100, 100, 100, 100,                 // L (.-..)
        100, 100, 100, 100, 100,                 // L (.-..)
        300, 100, 300, 100, 300                  // O (---)
      ],
      description: 'Spells "HELLO" in Morse code',
    ),
    const VibrationPattern(
      name: 'Countdown',
      pattern: [300, 700, 300, 700, 300, 700, 1000],
      description: '3-2-1 countdown pattern ending with long vibration',
    ),
    const VibrationPattern(
      name: 'Celebration',
      pattern: [100, 50, 100, 50, 100, 50, 100, 50, 100, 50, 500],
      description: 'Celebration pattern with quick pulses and final long vibration',
    ),
    const VibrationPattern(
      name: 'Drumbeat',
      pattern: [100, 200, 300, 200, 100, 200, 300, 200],
      repeat: 1,
      description: 'Rhythmic drumbeat pattern',
    ),
    const VibrationPattern(
      name: 'Rainfall',
      pattern: [50, 150, 30, 200, 70, 100, 40, 180, 60, 120],
      repeat: 1,
      description: 'Random-feeling pattern like rainfall',
    ),
    const VibrationPattern(
      name: 'Gallop',
      pattern: [100, 100, 100, 300, 100, 100, 100, 300],
      repeat: 1,
      description: 'Horse gallop rhythm',
    ),
  ];

  // iOS-specific vibration patterns
  final List<Map<String, dynamic>> _iOSPatterns = [
    {'name': 'Default', 'description': 'Default iOS vibration'},
    {'name': 'Alert', 'description': 'Alert vibration'},
    {'name': 'Warning', 'description': 'Warning vibration'},
    {'name': 'Success', 'description': 'Success feedback vibration'},
    {'name': 'Error', 'description': 'Error vibration'},
    {'name': 'Heavy', 'description': 'Heavy impact vibration'},
    {'name': 'Medium', 'description': 'Medium impact vibration'},
    {'name': 'Light', 'description': 'Light impact vibration'},
    {'name': 'Rigid', 'description': 'Rigid impact vibration'},
    {'name': 'Soft', 'description': 'Soft impact vibration'},
    {'name': 'Selection', 'description': 'Selection change vibration'},
    {'name': 'Old Phone', 'description': 'Classic phone vibration pattern'},
    {'name': 'Double Tap', 'description': 'Double tap feedback'},
    {'name': 'Triple Tap', 'description': 'Triple tap feedback'},
    {'name': 'Heartbeat', 'description': 'Heartbeat pattern'},
  ];

  // Amplitude presets
  final List<Map<String, dynamic>> _amplitudePresets = [
    {'name': 'Very Low', 'amplitude': 32, 'description': '12.5% intensity'},
    {'name': 'Low', 'amplitude': 64, 'description': '25% intensity'},
    {'name': 'Medium', 'amplitude': 128, 'description': '50% intensity'},
    {'name': 'High', 'amplitude': 192, 'description': '75% intensity'},
    {'name': 'Maximum', 'amplitude': 255, 'description': '100% intensity'},
  ];

  // Sound type presets for web
  final List<Map<String, dynamic>> _soundTypePresets = [
    {'name': 'Default', 'type': 'default', 'description': 'Standard sine wave sound'},
    {'name': 'Heavy', 'type': 'heavy', 'description': 'Low frequency sine wave (120Hz)'},
    {'name': 'Medium', 'type': 'medium', 'description': 'Medium frequency sine wave (220Hz)'},
    {'name': 'Light', 'type': 'light', 'description': 'Higher frequency sine wave (320Hz)'},
    {'name': 'Sharp', 'type': 'sharp', 'description': 'Square wave sound (400Hz)'},
    {'name': 'Soft', 'type': 'soft', 'description': 'Triangle wave sound (250Hz)'},
    {'name': 'Buzz', 'type': 'buzz', 'description': 'Sawtooth wave sound (180Hz)'},
  ];

  @override
  void initState() {
    super.initState();
    _checkPlatform();
    _checkVibrationCapabilities();
  }

  void _checkPlatform() {
    if (!kIsWeb) {
      try {
        _isIOS = Platform.isIOS;
      } catch (e) {
        print('Error checking platform: $e');
      }
    }
  }

  Future<void> _checkVibrationCapabilities() async {
    try {
      bool? hasVibrator;
      
      if (kIsWeb) {
        hasVibrator = await WebVibration.hasVibrator();
      } else {
        hasVibrator = await Vibration.hasVibrator();
      }
      
      if (hasVibrator ?? false) {
        setState(() {
          _hasVibrator = true;
        });
        
        bool? hasAmplitude;
        bool? hasCustom;
        
        if (kIsWeb) {
          hasAmplitude = await WebVibration.hasAmplitudeControl();
          hasCustom = await WebVibration.hasCustomVibrationsSupport();
        } else {
          hasAmplitude = await Vibration.hasAmplitudeControl();
          hasCustom = await Vibration.hasCustomVibrationsSupport();
        }
        
        if (hasAmplitude ?? false) {
          setState(() {
            _hasAmplitudeControl = true;
          });
        }
        
        if (hasCustom ?? false) {
          setState(() {
            _hasCustomDurations = true;
          });
        }
      }
    } catch (e) {
      // On web, the vibration API might throw an exception
      print('Error checking vibration capabilities: $e');
      // For web, we'll just simulate everything with sound
      if (kIsWeb) {
        setState(() {
          _hasVibrator = true;
          _hasAmplitudeControl = true;
          _hasCustomDurations = true;
        });
      }
    }
  }

  // Play a sound with the given duration and amplitude
  void _playSound(int duration, {int amplitude = 255, String soundType = 'default'}) {
    if (!kIsWeb) return;
    
    // Normalize amplitude to a value between 0.0 and 1.0
    final double volume = amplitude / 255.0;
    
    // Call the JavaScript function to generate a sound based on the type
    if (soundType != 'default') {
      js.context.callMethod('generateVibrationSound', [soundType, duration, volume]);
    } else {
      js.context.callMethod('generateBeep', [duration, 250, volume, 'sine']);
    }
  }

  // Simulate a vibration pattern with sound
  Future<void> _playPattern(List<int> pattern, {String soundType = 'default'}) async {
    if (!kIsWeb) return; // Only play sounds on web
    
    setState(() {
      _isVibrating = true;
    });
    
    bool isVibration = true;
    
    for (int i = 0; i < pattern.length; i++) {
      if (_isVibrating) {
        if (isVibration) {
          _playSound(pattern[i], soundType: soundType);
        }
        await Future.delayed(Duration(milliseconds: pattern[i]));
        isVibration = !isVibration;
      } else {
        break;
      }
    }
    
    setState(() {
      _isVibrating = false;
    });
  }

  // Vibrate with a pattern
  void _vibrate(VibrationPattern pattern) {
    try {
      if (_hasVibrator) {
        if (pattern.pattern.length == 1) {
          // Single vibration
          if (kIsWeb) {
            WebVibration.vibrate(
              duration: pattern.pattern[0],
              amplitude: pattern.amplitude,
            );
          } else {
            Vibration.vibrate(
              duration: pattern.pattern[0],
              amplitude: pattern.amplitude ?? -1,
            );
          }
        } else {
          // Pattern vibration
          if (kIsWeb) {
            WebVibration.vibrate(
              pattern: pattern.pattern,
              intensities: pattern.amplitude != null 
                  ? List.filled(pattern.pattern.length ~/ 2 + pattern.pattern.length % 2, pattern.amplitude!) 
                  : null,
              repeat: pattern.repeat,
            );
          } else {
            Vibration.vibrate(
              pattern: pattern.pattern,
              intensities: pattern.amplitude != null 
                  ? List.filled(pattern.pattern.length ~/ 2 + pattern.pattern.length % 2, pattern.amplitude!) 
                  : [],
              repeat: pattern.repeat ?? -1,
            );
          }
        }
      }
      
      // Play sound for web testing
      if (kIsWeb) {
        String soundType = 'default';
        
        // Choose sound type based on pattern name or characteristics
        if (pattern.name.contains('Heavy') || pattern.amplitude != null && pattern.amplitude! > 200) {
          soundType = 'heavy';
        } else if (pattern.name.contains('Light') || pattern.amplitude != null && pattern.amplitude! < 100) {
          soundType = 'light';
        } else if (pattern.name.contains('Sharp') || pattern.name.contains('Alert')) {
          soundType = 'sharp';
        } else if (pattern.name.contains('Soft')) {
          soundType = 'soft';
        } else if (pattern.name.contains('Buzz') || pattern.name.contains('Quick')) {
          soundType = 'buzz';
        } else {
          soundType = 'medium';
        }
        
        if (pattern.repeat != null) {
          // Handle repeating patterns
          _playPattern(pattern.pattern, soundType: soundType);
          for (int i = 0; i < pattern.repeat!; i++) {
            Future.delayed(
              Duration(milliseconds: pattern.pattern.reduce((a, b) => a + b) * i),
              () => _playPattern(pattern.pattern, soundType: soundType),
            );
          }
        } else {
          _playPattern(pattern.pattern, soundType: soundType);
        }
      }
    } catch (e) {
      print('Error vibrating: $e');
      // Fallback to sound only
      if (kIsWeb) {
        _playPattern(pattern.pattern);
      }
    }
  }

  // Vibrate with iOS-specific feedback
  void _vibrateIOS(String patternName) {
    try {
      if (_hasVibrator && _isIOS && !kIsWeb) {
        // For iOS, we'll use different durations and patterns to simulate different feedback types
        switch (patternName) {
          case 'Default':
            Vibration.vibrate(duration: 300);
            break;
          case 'Alert':
            Vibration.vibrate(pattern: [300, 100, 300]);
            break;
          case 'Warning':
            Vibration.vibrate(pattern: [500, 100, 500]);
            break;
          case 'Success':
            Vibration.vibrate(pattern: [100, 50, 100, 50, 300]);
            break;
          case 'Error':
            Vibration.vibrate(pattern: [300, 100, 300, 100, 300]);
            break;
          case 'Heavy':
            Vibration.vibrate(duration: 600);
            break;
          case 'Medium':
            Vibration.vibrate(duration: 400);
            break;
          case 'Light':
            Vibration.vibrate(duration: 200);
            break;
          case 'Rigid':
            Vibration.vibrate(pattern: [100, 50, 100, 50, 100, 50, 100]);
            break;
          case 'Soft':
            Vibration.vibrate(pattern: [200, 100, 200]);
            break;
          case 'Selection':
            Vibration.vibrate(pattern: [20, 30, 40]);
            break;
          case 'Old Phone':
            Vibration.vibrate(pattern: [100, 100, 100, 100, 100, 100, 100, 100, 100, 100]);
            break;
          case 'Double Tap':
            Vibration.vibrate(pattern: [50, 100, 50]);
            break;
          case 'Triple Tap':
            Vibration.vibrate(pattern: [50, 100, 50, 100, 50]);
            break;
          case 'Heartbeat':
            Vibration.vibrate(pattern: [100, 100, 100, 400, 100, 100, 100, 400]);
            break;
          default:
            Vibration.vibrate(duration: 300);
            break;
        }
      }
    } catch (e) {
      print('Error with iOS vibration: $e');
    }
  }

  // Cancel ongoing vibration
  void _cancelVibration() {
    try {
      if (kIsWeb) {
        WebVibration.cancel();
      } else {
        Vibration.cancel();
      }
      
      // Stop all sounds on web
      if (kIsWeb) {
        js.context.callMethod('stopAllSounds');
      }
    } catch (e) {
      print('Error canceling vibration: $e');
    }
    
    setState(() {
      _isVibrating = false;
    });
  }

  // Vibrate with a preset
  void _vibrateWithPreset(VibrationPreset preset) {
    try {
      if (_hasVibrator) {
        final config = presets[preset]!;
        
        // Convert the preset to a VibrationPattern
        final pattern = VibrationPattern(
          name: preset.toString().split('.').last,
          pattern: config.pattern,
          repeat: config.repeat,
          amplitude: config.amplitude,
          description: config.description,
        );
        
        // Use the existing vibrate method
        _vibrate(pattern);
      }
    } catch (e) {
      print('Error vibrating with preset: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Vibrations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Device Capabilities:', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    _buildCapabilityRow('Has Vibrator', _hasVibrator),
                    _buildCapabilityRow('Has Amplitude Control', _hasAmplitudeControl),
                    _buildCapabilityRow('Has Custom Durations', _hasCustomDurations),
                    _buildCapabilityRow('Running on Web', kIsWeb),
                    _buildCapabilityRow('Running on iOS', _isIOS),
                    if (kIsWeb)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Note: On web, vibrations are simulated with sounds',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Text('Basic Vibrations', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildVibrationButton('Vibrate (500ms)', () {
                  _vibrate(const VibrationPattern(name: 'Single', pattern: [500]));
                }),
                _buildVibrationButton('Vibrate (1000ms)', () {
                  _vibrate(const VibrationPattern(name: 'Single Long', pattern: [1000]));
                }),
              ],
            ),
            
            const SizedBox(height: 16),
            Text('Vibration Presets', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._buildPresetCategories(),
            
            if (kIsWeb) ...[
              const SizedBox(height: 16),
              Text('Web Sound Types', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _soundTypePresets.map((preset) {
                  return _buildVibrationButton(preset['name'], () {
                    _playSound(500, soundType: preset['type']);
                  }, tooltip: preset['description']);
                }).toList(),
              ),
            ],
            
            if (_isIOS) ...[
              const SizedBox(height: 16),
              Text('iOS Haptic Feedback', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _iOSPatterns.map((pattern) {
                  return _buildVibrationButton(pattern['name'], () {
                    _vibrateIOS(pattern['name']);
                  }, tooltip: pattern['description']);
                }).toList(),
              ),
            ],
            
            if (_hasAmplitudeControl) ...[
              const SizedBox(height: 16),
              Text('Amplitude Vibrations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _amplitudePresets.map((preset) {
                  return _buildVibrationButton(preset['name'], () {
                    _vibrate(VibrationPattern(
                      name: preset['name'],
                      pattern: [500],
                      amplitude: preset['amplitude'],
                    ));
                  }, tooltip: preset['description']);
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            Text('Vibration Patterns', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            
            // Group patterns by category
            ..._buildPatternCategories(),
            
            const SizedBox(height: 16),
            Text('Cancel Vibration', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildVibrationButton('Cancel', () {
              _cancelVibration();
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPatternCategories() {
    // Group patterns into categories
    final Map<String, List<VibrationPattern>> categories = {
      'Notification': _vibrationPatterns.where((p) => 
          p.name.contains('Notification') || 
          p.name == 'Single Short' || 
          p.name == 'Single Medium' || 
          p.name == 'Single Long').toList(),
      'Alert': _vibrationPatterns.where((p) => 
          p.name.contains('Alert') || 
          p.name == 'Error' || 
          p.name == 'Success').toList(),
      'Rhythmic': _vibrationPatterns.where((p) => 
          p.name == 'Heartbeat' || 
          p.name.contains('Pulses') || 
          p.name == 'Wave').toList(),
      'Special': _vibrationPatterns.where((p) => 
          p.name == 'SOS' || 
          p.name == 'Escalating' || 
          p.name == 'Descending').toList(),
    };
    
    List<Widget> categoryWidgets = [];
    
    categories.forEach((category, patterns) {
      categoryWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                '$category Patterns', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: patterns.map((pattern) {
                return _buildVibrationButton(
                  pattern.name, 
                  () => _vibrate(pattern),
                  tooltip: pattern.description,
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
    
    return categoryWidgets;
  }

  Widget _buildCapabilityRow(String title, bool isSupported) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Icon(
            isSupported ? Icons.check_circle : Icons.cancel,
            color: isSupported ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationButton(String label, VoidCallback onPressed, {Color? color, String? tooltip}) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color != null ? Colors.white : null,
      ),
      child: Text(label),
    );
    
    if (tooltip != null && tooltip.isNotEmpty) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }
    
    return button;
  }

  List<Widget> _buildPresetCategories() {
    // Group presets into categories
    final Map<String, List<VibrationPreset>> presetCategories = {
      'Basic': [
        VibrationPreset.singleShortBuzz,
        VibrationPreset.doubleBuzz,
        VibrationPreset.tripleBuzz,
      ],
      'Notification': [
        VibrationPreset.notification,
        VibrationPreset.dramaticNotification,
        VibrationPreset.gentleReminder,
      ],
      'Alert': [
        VibrationPreset.alarm,
        VibrationPreset.emergencyAlert,
        VibrationPreset.longAlarmBuzz,
        VibrationPreset.urgentBuzzWave,
        VibrationPreset.countdownTimerAlert,
      ],
      'Feedback': [
        VibrationPreset.quickSuccessAlert,
        VibrationPreset.rapidTapFeedback,
        VibrationPreset.softPulse,
      ],
      'Rhythmic': [
        VibrationPreset.heartbeat,
        VibrationPreset.heartbeatVibration,
        VibrationPreset.rhythmicBuzz,
        VibrationPreset.pulseWave,
        VibrationPreset.progressiveBuzz,
        VibrationPreset.zigZagAlert,
      ],
    };
    
    List<Widget> categoryWidgets = [];
    
    presetCategories.forEach((category, presetList) {
      categoryWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                '$category Presets', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: presetList.map((preset) {
                final config = presets[preset]!;
                return _buildVibrationButton(
                  preset.toString().split('.').last, 
                  () => _vibrateWithPreset(preset),
                  tooltip: config.description,
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
    
    return categoryWidgets;
  }
} 