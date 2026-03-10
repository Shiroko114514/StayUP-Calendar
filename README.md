# StayUP 课程表

StayUP 课程表是一个使用 Flutter 编写的简单课程表应用。

做这个软件的最初原因其实很简单：  
我一直在使用的 WakeUp 课程表在被收购之后，逐渐加入了很多复杂甚至有些“用不到”的功能，用起来反而没有以前那么清爽了。于是某天突然产生了一个想法——既然如此，不如自己写一个简单一点的课程表。

作为一个编程经验并不多的新手，本项目的开发过程中大量借助了 AI 工具的帮助，包括 ChatGPT 和 Claude 等。可以说，这是一次一边学习一边完成的小项目。

之所以取名 **StayUP 课程表**，一方面是对 WakeUp 课程表的一点致敬——它曾经是一款非常优秀的课程表应用；另一方面，这个名字也来自开发这个项目时连续一周熬夜写代码的真实经历（笑）。  
“Stay up” 本身也有“保持清醒”的意思，某种程度上也算是对写代码状态的真实写照。

由于作者仍然是编程新手，项目中难免会存在各种不足甚至 Bug。如果你在使用过程中遇到问题，还请多多包涵，也欢迎提出 Issue 或建议。

如果这个项目对你有所帮助，也欢迎点一个 ⭐ Star 支持一下。

## Developer Guide

本项目是标准 Flutter 多平台工程（Android / iOS / macOS / Windows / Linux / Web），下面是基于当前仓库结构整理的开发指南。

### 1. 开发环境

- Flutter SDK：建议使用最新 stable 版本（需兼容 `Dart >=3.11`，见 `pubspec.yaml`）。
- Xcode：用于 iOS/macOS 调试与打包（macOS 开发必需）。
- Android Studio 或 Android SDK Command-line Tools：用于 Android 调试与打包。
- 可选：Chrome（Web 调试）、Visual Studio Build Tools（Windows 构建）。

首次拉取后建议执行：

```bash
flutter doctor
flutter pub get
```

### 2. 目录结构说明

- `lib/main.dart`：当前主要业务与 UI 入口（核心逻辑集中在此文件）。
- `assets/`：静态资源目录。
- `assets/icon/icon.png`：应用图标源文件（由 `flutter_launcher_icons` 使用）。
- `test/widget_test.dart`：Flutter 测试示例。
- `android/`：Android 原生工程与 Gradle 配置。
- `ios/`：iOS 原生工程（含 `Podfile`、Xcode project）。
- `macos/`：macOS 原生工程。
- `windows/`、`linux/`：桌面端原生工程。
- `web/`：Web 入口与静态资源。
- `pubspec.yaml`：依赖、资源、版本和构建配置。
- `analysis_options.yaml`：Dart/Flutter 静态检查规则。

### 3. 常用开发命令

安装依赖：

```bash
flutter pub get
```

查看可用设备：

```bash
flutter devices
```

本地调试运行：

```bash
# 自动选择设备
flutter run

# 指定设备（示例）
flutter run -d ios
flutter run -d android
flutter run -d macos
flutter run -d chrome
```

代码检查与测试：

```bash
flutter analyze
flutter test
```

### 4. 图标与资源维护

项目已配置 `flutter_launcher_icons`。当你替换 `assets/icon/icon.png` 后，执行：

```bash
dart run flutter_launcher_icons
```

如果修改了资源目录或文件，记得同步更新 `pubspec.yaml` 中的 `flutter` 配置并重新执行 `flutter pub get`。

### 5. 多平台打包命令

Android：

```bash
# 构建优化的 APK（推荐用于测试）
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=build/symbols --tree-shake-icons

# 构建 App Bundle（推荐用于发布到 Google Play）
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --tree-shake-icons
```

iOS（需在 macOS + Xcode 环境）：

```bash
flutter build ios
```

macOS：

```bash
flutter build macos
```

Web：

```bash
flutter build web
```

Windows / Linux：

```bash
flutter build windows
flutter build linux
```

### 6. 开发建议

- 提交前至少执行一次 `flutter analyze` 和 `flutter test`。
- 变更平台配置时，优先在对应目录中修改：Android 在 `android/`，Apple 平台在 `ios/` 与 `macos/`。
- 当前业务代码主要集中在 `lib/main.dart`，后续可以按模块拆分到 `lib/` 下独立文件（如 `models/`、`pages/`、`widgets/`），降低维护成本。
