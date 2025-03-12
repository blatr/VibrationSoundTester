# 📱 Debug Vibrations

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)

> A Flutter application specifically designed to test and debug the **Vibration** library (v1.7.7) functionality across different platforms.

## 🔍 Project Overview

Debug Vibrations is a cross-platform testing tool that helps developers verify vibration patterns through both haptic feedback and sound simulation. This project serves as a dedicated testing environment for the [vibration](https://pub.dev/packages/vibration) Flutter package.

## ✨ Features

- 📳 Test various vibration patterns and intensities
- 🔊 Sound simulation for platforms without vibration support
- ⏱️ Custom duration and pattern sequencing
- 📊 Visual feedback of vibration patterns
- 🌐 Cross-platform compatibility testing

## 🛠️ Technical Details

- Built with Flutter
- Primary test subject: `vibration: ^1.7.7` package
- Web implementation uses audio feedback to simulate vibrations
- Native implementations use platform-specific vibration APIs

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/yourusername/DebugVibrations.git

# Navigate to the project directory
cd DebugVibrations

# Install dependencies
flutter pub get

# Run the web version
flutter run -d chrome

# Or run on a physical device for actual vibration testing
flutter run
```

## 📋 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅     | Full vibration support |
| iOS      | ✅     | Requires physical device |
| Web      | ⚠️     | Sound simulation only |
| macOS    | ❌     | No vibration support |
| Windows  | ❌     | No vibration support |
| Linux    | ❌     | No vibration support |

## 🤝 Contributing

Contributions to improve the testing capabilities are welcome! Please feel free to submit a PR.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

<p align="center">
  <i>Created for testing and debugging the vibration library in Flutter applications</i>
</p> 