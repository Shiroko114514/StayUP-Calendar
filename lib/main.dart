import 'package:flutter/material.dart';

import 'src/models.dart';
import 'src/schedule_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WakeUpApp());
}

// ─────────────────────────────────────────────
// 根 App
// ─────────────────────────────────────────────

class WakeUpApp extends StatefulWidget {
  const WakeUpApp({super.key});
  @override
  State<WakeUpApp> createState() => _WakeUpAppState();
}

class _WakeUpAppState extends State<WakeUpApp> {
  AppState? _appState;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await AppState.loadFromPrefs();
    if (mounted) {
      state.addListener(_onStateChanged);
      setState(() {
        _appState = state;
        _isDarkMode = state.isDarkMode;
      });
    }
  }

  void _onStateChanged() {
    if (mounted && _appState != null && _appState!.isDarkMode != _isDarkMode) {
      setState(() {
        _isDarkMode = _appState!.isDarkMode;
      });
    }
  }

  @override
  void dispose() {
    _appState?.removeListener(_onStateChanged);
    _appState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _appState;
    if (state == null) {
      // 启动加载屏
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF1C1C1E),
          body: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF4ECDC4), strokeWidth: 2),
                SizedBox(height: 20),
                Text('正在加载课表…',
                    style: TextStyle(color: Color(0xFF6C6C70), fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }
    return _AppWithTheme(appState: state, isDarkMode: _isDarkMode);
  }
}

class _AppWithTheme extends StatelessWidget {
  final AppState appState;
  final bool isDarkMode;
  const _AppWithTheme({required this.appState, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WakeUp 课程表',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4ECDC4), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        cardColor: const Color(0xFFFFFFFF),
        dividerColor: const Color(0xFFE5E5EA),
        fontFamily: 'PingFang SC',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF1C1C1E),
          elevation: 0,
          titleTextStyle: TextStyle(color: Color(0xFF1C1C1E), fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'PingFang SC'),
          iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
        ),
        dialogTheme: const DialogThemeData(
          titleTextStyle: TextStyle(color: Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'PingFang SC'),
          contentTextStyle: TextStyle(color: Color(0xFF6C6C70), fontSize: 14, height: 1.5, fontFamily: 'PingFang SC'),
        ),
        extensions: const [AppColors.light],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4ECDC4), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        cardColor: const Color(0xFF2C2C2E),
        dividerColor: const Color(0xFF3A3A3C),
        fontFamily: 'PingFang SC',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2E),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'PingFang SC'),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        dialogTheme: const DialogThemeData(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'PingFang SC'),
          contentTextStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 14, height: 1.5, fontFamily: 'PingFang SC'),
        ),
        extensions: const [AppColors.dark],
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => AppStateScope(
        notifier: appState,
        child: child!,
      ),
      home: const SchedulePage(),
    );
  }
}

// ─────────────────────────────────────────────
// 主页面（有状态）
// ─────────────────────────────────────────────

