import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;

/// A web implementation of the vibration plugin.
/// This is used to prevent MissingPluginException errors when running on web.
class WebVibration {
  /// Check if the device has vibration capabilities
  static Future<bool?> hasVibrator() async {
    if (!kIsWeb) return null;
    
    // For web, we'll just return true and simulate with sound
    return true;
  }
  
  /// Check if the device has amplitude control
  static Future<bool?> hasAmplitudeControl() async {
    if (!kIsWeb) return null;
    
    // For web, we'll just return true and simulate with sound
    return true;
  }
  
  /// Check if the device has custom vibration support
  static Future<bool?> hasCustomVibrationsSupport() async {
    if (!kIsWeb) return null;
    
    // For web, we'll just return true and simulate with sound
    return true;
  }
  
  /// Vibrate with the given parameters
  static Future<void> vibrate({
    int duration = 500,
    List<int>? pattern,
    int? repeat,
    List<int>? intensities,
    int? amplitude,
  }) async {
    if (!kIsWeb) return;
    
    // For web, we'll simulate vibration with sound
    if (pattern != null && pattern.isNotEmpty) {
      _playPattern(pattern);
    } else {
      _playSound(duration, amplitude: amplitude ?? 255);
    }
  }
  
  /// Cancel ongoing vibration
  static Future<void> cancel() async {
    if (!kIsWeb) return;
    
    // Stop all sounds
    js.context.callMethod('stopAllSounds');
  }
  
  // Private methods for sound simulation
  
  /// Play a sound with the given duration and amplitude
  static void _playSound(int duration, {int amplitude = 255, String soundType = 'default'}) {
    if (!kIsWeb) return;
    
    // Normalize amplitude to a value between 0.0 and 1.0
    final double volume = amplitude / 255.0;
    
    // Call the JavaScript function to generate a sound
    if (soundType != 'default') {
      js.context.callMethod('generateVibrationSound', [soundType, duration, volume]);
    } else {
      js.context.callMethod('generateBeep', [duration, 250, volume, 'sine']);
    }
  }
  
  /// Play a pattern of sounds
  static Future<void> _playPattern(List<int> pattern) async {
    if (!kIsWeb) return;
    
    bool isVibration = true;
    
    for (int i = 0; i < pattern.length; i++) {
      if (isVibration) {
        _playSound(pattern[i]);
      }
      await Future.delayed(Duration(milliseconds: pattern[i]));
      isVibration = !isVibration;
    }
  }
} 