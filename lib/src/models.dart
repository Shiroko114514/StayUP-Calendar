import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// 主题颜色扩展
// ─────────────────────────────────────────────

class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color card;
  final Color divider;
  final Color hint;
  final Color primaryText;
  final Color secondaryText;
  final Color inputBg;
  final Color iconBg;

  const AppColors({
    required this.bg,
    required this.card,
    required this.divider,
    required this.hint,
    required this.primaryText,
    required this.secondaryText,
    required this.inputBg,
    required this.iconBg,
  });

  static const light = AppColors(
    bg: Color(0xFFF2F2F7),
    card: Color(0xFFFFFFFF),
    divider: Color(0xFFE5E5EA),
    hint: Color(0xFF6C6C70),
    primaryText: Color(0xFF1C1C1E),
    secondaryText: Color(0xFF3C3C43),
    inputBg: Color(0xFFE5E5EA),
    iconBg: Color(0xFFE5E5EA),
  );

  static const dark = AppColors(
    bg: Color(0xFF1C1C1E),
    card: Color(0xFF2C2C2E),
    divider: Color(0xFF3A3A3C),
    hint: Color(0xFF8E8E93),
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFEBEBF5),
    inputBg: Color(0xFF2C2C2E),
    iconBg: Color(0xFF3A3A3C),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? card,
    Color? divider,
    Color? hint,
    Color? primaryText,
    Color? secondaryText,
    Color? inputBg,
    Color? iconBg,
  }) => AppColors(
    bg: bg ?? this.bg,
    card: card ?? this.card,
    divider: divider ?? this.divider,
    hint: hint ?? this.hint,
    primaryText: primaryText ?? this.primaryText,
    secondaryText: secondaryText ?? this.secondaryText,
    inputBg: inputBg ?? this.inputBg,
    iconBg: iconBg ?? this.iconBg,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      iconBg: Color.lerp(iconBg, other.iconBg, t)!,
    );
  }
}

// ─────────────────────────────────────────────
// 时间表配置（名称 + 20节时间）
// ─────────────────────────────────────────────

class TimeTableConfig {
  final String name;
  final List<List<String>> times;

  TimeTableConfig({required this.name, required this.times});

  Map<String, dynamic> toJson() => {'name': name, 'times': times};

  factory TimeTableConfig.fromJson(Map<String, dynamic> j) => TimeTableConfig(
    name: j['name'] as String? ?? '时间表',
    times: (j['times'] as List).map((r) => (r as List).cast<String>()).toList(),
  );

  TimeTableConfig copyWith({String? name, List<List<String>>? times}) =>
      TimeTableConfig(name: name ?? this.name, times: times ?? this.times);
}

// ─────────────────────────────────────────────
// 全局共享状态
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// 每张课表独立配置
// ─────────────────────────────────────────────
class ScheduleConfig {
  final String name;
  final DateTime firstWeekDay;
  final int sectionsPerDay; // 1–12
  final int totalWeeks; // 1–20

  const ScheduleConfig({
    required this.name,
    required this.firstWeekDay,
    this.sectionsPerDay = 10,
    this.totalWeeks = 20,
  });

  ScheduleConfig copyWith({
    String? name,
    DateTime? firstWeekDay,
    int? sectionsPerDay,
    int? totalWeeks,
  }) => ScheduleConfig(
    name: name ?? this.name,
    firstWeekDay: firstWeekDay ?? this.firstWeekDay,
    sectionsPerDay: sectionsPerDay ?? this.sectionsPerDay,
    totalWeeks: totalWeeks ?? this.totalWeeks,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'firstWeekDay': firstWeekDay.millisecondsSinceEpoch,
    'sectionsPerDay': sectionsPerDay,
    'totalWeeks': totalWeeks,
  };

  factory ScheduleConfig.fromJson(Map<String, dynamic> j) => ScheduleConfig(
    name: j['name'] as String,
    firstWeekDay: DateTime.fromMillisecondsSinceEpoch(j['firstWeekDay'] as int),
    sectionsPerDay: j['sectionsPerDay'] as int,
    totalWeeks: j['totalWeeks'] as int,
  );
}

const String kLocaleModeSystem = 'system';
const String kLocaleModeChineseSimplified = 'zh-Hans';
const String kLocaleModeChineseTraditional = 'zh-Hant';
const String kLocaleModeEnglish = 'en';
const String kLocaleModeJapanese = 'ja';

const String kThemeModeSystem = 'system';
const String kThemeModeLight = 'light';
const String kThemeModeDark = 'dark';

const String kDateFormatYmdSlash = 'yyyy/MM/dd';
const String kDateFormatYmdDash = 'yyyy-MM-dd';
const String kDateFormatMdySlash = 'MM/dd/yyyy';
const String kDateFormatDmySlash = 'dd/MM/yyyy';
const String kDateFormatDMonY = 'd MMM. yyyy';
const String kDateFormatMonDY = 'MMM. d yyyy';
const int kScheduleNameMaxLength = 20;
const int kScheduleNameChineseMaxLength = 5;

class AppState extends ChangeNotifier {
  List<TimeTableConfig> allTimeTables;
  int activeTimeTableIndex;

  // 向后兼容：当前激活时间表的 times
  List<List<String>> get customTimes =>
      allTimeTables[activeTimeTableIndex].times;

  bool showWeekend;
  bool showNonWeek;
  bool showSection;
  String themeMode;
  String localeMode;
  String dateFormatPattern;
  bool useMaterialDynamicColor;

  // 全局主题色（null = 使用 kCourseColors[0] 默认值）
  int? themeColorValue;
  Color get themeColor =>
      themeColorValue != null ? Color(themeColorValue!) : kCourseColors[0];
  Locale? get appLocale {
    switch (localeMode) {
      case kLocaleModeChineseSimplified:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      case kLocaleModeChineseTraditional:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      case kLocaleModeEnglish:
        return const Locale('en');
      case kLocaleModeJapanese:
        return const Locale('ja');
      default:
        return null;
    }
  }

  // ── 多课表：每张课表独立配置 + 课程数据 ──
  List<ScheduleConfig> allConfigs;
  int activeScheduleIndex;
  List<List<Course>> allCourses;

  // ── 快捷 getter ──
  ScheduleConfig get config => allConfigs[activeScheduleIndex];
  List<Course> get courses => allCourses[activeScheduleIndex];
  List<String> get scheduleNames => allConfigs.map((c) => c.name).toList();

  static final _defaultFirstWeekDay = DateTime(DateTime.now().year, 9, 1);
  static final RegExp _chineseCharRegex = RegExp(
    r'[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]',
  );

  static int scheduleNameMaxLengthFor(String name) {
    return _chineseCharRegex.hasMatch(name)
        ? kScheduleNameChineseMaxLength
        : kScheduleNameMaxLength;
  }

  static bool isScheduleNameExceeded(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.length > scheduleNameMaxLengthFor(trimmed);
  }

  static String normalizeScheduleName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    final maxLength = scheduleNameMaxLengthFor(trimmed);
    return trimmed.length > maxLength
        ? trimmed.substring(0, maxLength)
        : trimmed;
  }

  AppState({
    List<TimeTableConfig>? allTimeTables,
    this.activeTimeTableIndex = 0,
    required List<Course> initialCourses,
    this.showWeekend = true,
    this.showNonWeek = true,
    this.showSection = true,
    this.themeMode = kThemeModeSystem,
    this.localeMode = kLocaleModeSystem,
    this.dateFormatPattern = kDateFormatYmdSlash,
    this.useMaterialDynamicColor = false,
    this.themeColorValue,
    this.activeScheduleIndex = 0,
    List<ScheduleConfig>? allConfigs,
  }) : allTimeTables =
           allTimeTables ??
           [
             TimeTableConfig(
               name: '默认',
               times: kTimeSlots.map((s) => [s.start, s.end]).toList(),
             ),
           ],
       allConfigs =
           allConfigs ??
           [
             ScheduleConfig(
               name: '新建课表',
               firstWeekDay: _defaultFirstWeekDay,
               sectionsPerDay: 12,
               totalWeeks: 20,
             ),
           ],
       allCourses = List.generate(
         allConfigs != null ? allConfigs.length : 1,
         (i) => i == (activeScheduleIndex)
             ? List<Course>.from(initialCourses)
             : <Course>[],
       );

  // ── 当前课表配置更新 ──
  void updateActiveConfig({
    DateTime? firstWeekDay,
    int? sectionsPerDay,
    int? totalWeeks,
  }) {
    allConfigs = List.from(allConfigs)
      ..[activeScheduleIndex] = allConfigs[activeScheduleIndex].copyWith(
        firstWeekDay: firstWeekDay,
        sectionsPerDay: sectionsPerDay,
        totalWeeks: totalWeeks,
      );
    notifyListeners();
  }

  // ── 课程操作（作用于当前激活课表）──
  void addCourse(Course c) {
    allCourses = List.from(allCourses)
      ..[activeScheduleIndex] = [...allCourses[activeScheduleIndex], c];
    notifyListeners();
  }

  void deleteCourse(int id) {
    allCourses = List.from(allCourses)
      ..[activeScheduleIndex] = allCourses[activeScheduleIndex]
          .where((c) => c.id != id)
          .toList();
    notifyListeners();
  }

  void replaceCourses(List<Course> newList) {
    allCourses = List.from(allCourses)..[activeScheduleIndex] = newList;
    notifyListeners();
  }

  void editCourse(Course updated) {
    allCourses = List.from(allCourses)
      ..[activeScheduleIndex] = allCourses[activeScheduleIndex]
          .map((c) => c.id == updated.id ? updated : c)
          .toList();
    notifyListeners();
  }

  // ── 课表列表管理 ──
  void addSchedule(ScheduleConfig cfg) {
    allConfigs = [
      ...allConfigs,
      cfg.copyWith(name: normalizeScheduleName(cfg.name)),
    ];
    allCourses = [...allCourses, <Course>[]];
    notifyListeners();
  }

  void removeSchedule(int index) {
    if (allConfigs.length <= 1) return;
    final newConfigs = List<ScheduleConfig>.from(allConfigs)..removeAt(index);
    final newCourses = List<List<Course>>.from(allCourses)..removeAt(index);
    int newActive = activeScheduleIndex;
    if (activeScheduleIndex >= index && activeScheduleIndex > 0) {
      newActive = activeScheduleIndex - 1;
    }
    allConfigs = newConfigs;
    allCourses = newCourses;
    activeScheduleIndex = newActive.clamp(0, newConfigs.length - 1);
    notifyListeners();
  }

  void reorderSchedules(List<int> newOrder) {
    allConfigs = newOrder.map((i) => allConfigs[i]).toList();
    allCourses = newOrder.map((i) => allCourses[i]).toList();
    final prevActive = newOrder.indexOf(activeScheduleIndex);
    activeScheduleIndex = prevActive < 0 ? 0 : prevActive;
    notifyListeners();
  }

  void switchSchedule(int index) {
    activeScheduleIndex = index;
    notifyListeners();
  }

  void renameSchedule(int index, String name) {
    final normalizedName = normalizeScheduleName(name);
    if (normalizedName.isEmpty) return;
    allConfigs = List.from(allConfigs)
      ..[index] = allConfigs[index].copyWith(name: normalizedName);
    notifyListeners();
  }

  // ── 时间表管理 ──
  void updateTimeTable(int index, List<List<String>> times) {
    allTimeTables = List.from(allTimeTables)
      ..[index] = allTimeTables[index].copyWith(times: times);
    notifyListeners();
  }

  void renameTimeTable(int index, String name) {
    allTimeTables = List.from(allTimeTables)
      ..[index] = allTimeTables[index].copyWith(name: name);
    notifyListeners();
  }

  void addTimeTable(String name) {
    allTimeTables = [
      ...allTimeTables,
      TimeTableConfig(
        name: name,
        times: kTimeSlots.map((s) => [s.start, s.end]).toList(),
      ),
    ];
    notifyListeners();
  }

  void deleteTimeTable(int index) {
    if (allTimeTables.length <= 1) return; // 至少保留一个
    allTimeTables = List.from(allTimeTables)..removeAt(index);
    if (activeTimeTableIndex >= allTimeTables.length) {
      activeTimeTableIndex = allTimeTables.length - 1;
    }
    notifyListeners();
  }

  void switchTimeTable(int index) {
    activeTimeTableIndex = index.clamp(0, allTimeTables.length - 1);
    notifyListeners();
  }

  // 向后兼容旧调用
  void updateTimes(List<List<String>> times) =>
      updateTimeTable(activeTimeTableIndex, times);

  void updateSettings({
    bool? showWeekend,
    bool? showNonWeek,
    bool? showSection,
  }) {
    if (showWeekend != null) this.showWeekend = showWeekend;
    if (showNonWeek != null) this.showNonWeek = showNonWeek;
    if (showSection != null) this.showSection = showSection;
    notifyListeners();
  }

  void updateThemeMode(String value) {
    themeMode = value;
    notifyListeners();
  }

  void updateLocaleMode(String value) {
    localeMode = value;
    notifyListeners();
  }

  void updateDateFormatPattern(String value) {
    dateFormatPattern = value;
    notifyListeners();
  }

  void updateUseMaterialDynamicColor(bool value) {
    useMaterialDynamicColor = value;
    notifyListeners();
  }

  void updateThemeColor(Color color) {
    themeColorValue = color.toARGB32();
    notifyListeners();
  }

  // ── 持久化 ──

  static const _kPrefsKey = 'wakeup_app_state_v1';

  /// 每次状态变更后自动触发保存
  @override
  void notifyListeners() {
    super.notifyListeners();
    _scheduleSave();
  }

  bool _savePending = false;
  void _scheduleSave() {
    if (_savePending) return;
    _savePending = true;
    // microtask 延迟，合并同帧内多次变更为一次写入
    Future.microtask(() async {
      _savePending = false;
      await saveToPrefs();
    });
  }

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode({
        'activeScheduleIndex': activeScheduleIndex,
        'activeTimeTableIndex': activeTimeTableIndex,
        'showWeekend': showWeekend,
        'showNonWeek': showNonWeek,
        'showSection': showSection,
        'themeMode': themeMode,
        'localeMode': localeMode,
        'dateFormatPattern': dateFormatPattern,
        'useMaterialDynamicColor': useMaterialDynamicColor,
        'themeColorValue': themeColorValue,
        'allTimeTables': allTimeTables.map((t) => t.toJson()).toList(),
        'allConfigs': allConfigs.map((c) => c.toJson()).toList(),
        'allCourses': allCourses
            .map((list) => list.map((c) => c.toJson()).toList())
            .toList(),
      });
      await prefs.setString(_kPrefsKey, data);
    } catch (e) {
      debugPrint('AppState.saveToPrefs error: $e');
    }
  }

  static Future<AppState> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;

        final allConfigs = (j['allConfigs'] as List)
            .map((e) => ScheduleConfig.fromJson(e as Map<String, dynamic>))
            .toList();

        final allCourses = (j['allCourses'] as List)
            .map(
              (list) => (list as List)
                  .map((e) => Course.fromJson(e as Map<String, dynamic>))
                  .toList(),
            )
            .toList();

        // 兼容旧数据：优先读 allTimeTables，否则从 customTimes 迁移
        List<TimeTableConfig> allTimeTables;
        if (j['allTimeTables'] != null) {
          allTimeTables = (j['allTimeTables'] as List)
              .map((e) => TimeTableConfig.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (j['customTimes'] != null) {
          final rawTimes = j['customTimes'] as List;
          final times = rawTimes
              .map((row) => (row as List).cast<String>())
              .toList();
          allTimeTables = [TimeTableConfig(name: '默认', times: times)];
        } else {
          allTimeTables = [
            TimeTableConfig(
              name: '默认',
              times: kTimeSlots.map((s) => [s.start, s.end]).toList(),
            ),
          ];
        }

        final legacyIsDark = j['isDarkMode'] as bool?;
        final persistedThemeMode = j['themeMode'] as String?;
        final resolvedThemeMode = persistedThemeMode ??
            (legacyIsDark == null
                ? kThemeModeSystem
                : (legacyIsDark ? kThemeModeDark : kThemeModeLight));

        return AppState(
          allTimeTables: allTimeTables,
          activeTimeTableIndex: j['activeTimeTableIndex'] as int? ?? 0,
          initialCourses: [],
          activeScheduleIndex: j['activeScheduleIndex'] as int? ?? 0,
          allConfigs: allConfigs,
          showWeekend: j['showWeekend'] as bool? ?? true,
          showNonWeek: j['showNonWeek'] as bool? ?? true,
          showSection: j['showSection'] as bool? ?? true,
          themeMode: resolvedThemeMode,
          localeMode: j['localeMode'] as String? ?? kLocaleModeSystem,
            dateFormatPattern:
              j['dateFormatPattern'] as String? ?? kDateFormatYmdSlash,
          useMaterialDynamicColor:
              j['useMaterialDynamicColor'] as bool? ?? false,
          themeColorValue: j['themeColorValue'] as int?,
        ).._loadedCourses(allCourses);
      }
    } catch (e) {
      debugPrint('AppState.loadFromPrefs error: $e');
    }
    // 返回默认初始状态
    return AppState(
      initialCourses: [],
      activeScheduleIndex: 0,
      allConfigs: [
        ScheduleConfig(
          name: '新建课表',
          firstWeekDay: DateTime(DateTime.now().year, 9, 1),
          sectionsPerDay: 12,
          totalWeeks: 20,
        ),
      ],
    );
  }

  /// 构造后直接注入已加载的课程列表（绕过 initialCourses 限制）
  AppState _loadedCourses(List<List<Course>> loaded) {
    allCourses = loaded;
    return this;
  }
}

// InheritedWidget 透传 AppState
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}

// ─────────────────────────────────────────────
// 数据模型
// ─────────────────────────────────────────────

class TimeSlot {
  final int section;
  final String start;
  final String end;
  const TimeSlot(this.section, this.start, this.end);
}

// ─────────────────────────────────────────────
// 附加时间段数据类
// ─────────────────────────────────────────────

class CourseSlot {
  int day;
  int startSection;
  int endSection;
  int startWeek;
  int endWeek;

  CourseSlot({
    required this.day,
    required this.startSection,
    required this.endSection,
    required this.startWeek,
    required this.endWeek,
  });

  int get span => (endSection - startSection + 1).clamp(1, 20);
  List<int> get weeks =>
      List.generate(endWeek - startWeek + 1, (i) => startWeek + i);

  CourseSlot copyWith({
    int? day,
    int? startSection,
    int? endSection,
    int? startWeek,
    int? endWeek,
  }) => CourseSlot(
    day: day ?? this.day,
    startSection: startSection ?? this.startSection,
    endSection: endSection ?? this.endSection,
    startWeek: startWeek ?? this.startWeek,
    endWeek: endWeek ?? this.endWeek,
  );

  Map<String, dynamic> toJson() => {
    'day': day,
    'startSection': startSection,
    'endSection': endSection,
    'startWeek': startWeek,
    'endWeek': endWeek,
  };

  factory CourseSlot.fromJson(Map<String, dynamic> j) => CourseSlot(
    day: j['day'] as int,
    startSection: j['startSection'] as int,
    endSection: j['endSection'] as int? ?? j['startSection'] as int,
    startWeek: j['startWeek'] as int? ?? 1,
    endWeek: j['endWeek'] as int? ?? 18,
  );
}

class Course {
  final int id;
  final String name;
  final String location;
  final String teacher;
  final String credit;
  final String note;
  final int day; // 1=周一 … 7=周日
  final int startSection;
  final int span;
  final int colorIdx;
  final Color? customColor;
  final bool isNonWeek;
  final List<int> weeks;
  final int startWeek;
  final int endWeek;
  final List<CourseSlot> extraSlots;

  Color get effectiveColor =>
      customColor ?? kCourseColors[colorIdx % kCourseColors.length];

  /// 所有时间段（主 + 附加），供网格渲染遍历
  List<CourseSlot> get allSlots => [
    CourseSlot(
      day: day,
      startSection: startSection,
      endSection: startSection + span - 1,
      startWeek: startWeek,
      endWeek: endWeek,
    ),
    ...extraSlots,
  ];

  Course({
    required this.id,
    required this.name,
    this.location = '',
    this.teacher = '',
    this.credit = '',
    this.note = '',
    required this.day,
    required this.startSection,
    required this.span,
    required this.colorIdx,
    this.customColor,
    this.isNonWeek = false,
    required this.weeks,
    this.startWeek = 1,
    this.endWeek = 18,
    this.extraSlots = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'teacher': teacher,
    'credit': credit,
    'note': note,
    'day': day,
    'startSection': startSection,
    'span': span,
    'colorIdx': colorIdx,
    'customColor': customColor?.toARGB32(),
    'isNonWeek': isNonWeek,
    'weeks': weeks,
    'startWeek': startWeek,
    'endWeek': endWeek,
    'extraSlots': extraSlots.map((s) => s.toJson()).toList(),
  };

  factory Course.fromJson(Map<String, dynamic> j) => Course(
    id: j['id'] as int,
    name: j['name'] as String,
    location: j['location'] as String? ?? '',
    teacher: j['teacher'] as String? ?? '',
    credit: j['credit'] as String? ?? '',
    note: j['note'] as String? ?? '',
    day: j['day'] as int,
    startSection: j['startSection'] as int,
    span: j['span'] as int,
    colorIdx: j['colorIdx'] as int? ?? 0,
    customColor: j['customColor'] != null
        ? Color(j['customColor'] as int)
        : null,
    isNonWeek: j['isNonWeek'] as bool? ?? false,
    weeks: (j['weeks'] as List).cast<int>(),
    startWeek: j['startWeek'] as int? ?? 1,
    endWeek: j['endWeek'] as int? ?? 18,
    extraSlots: (j['extraSlots'] as List? ?? [])
        .map((e) => CourseSlot.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

// ─────────────────────────────────────────────
// 常量
// ─────────────────────────────────────────────

const double kSlotHeight = 68.0;

const List<TimeSlot> kTimeSlots = [
  TimeSlot(1, '08:00', '08:45'),
  TimeSlot(2, '08:55', '09:40'),
  TimeSlot(3, '10:10', '10:55'),
  TimeSlot(4, '11:05', '11:50'),
  TimeSlot(5, '14:00', '14:45'),
  TimeSlot(6, '14:50', '15:35'),
  TimeSlot(7, '15:55', '16:40'),
  TimeSlot(8, '16:45', '17:30'),
  TimeSlot(9, '18:30', '19:15'),
  TimeSlot(10, '19:20', '20:05'),
  TimeSlot(11, '20:15', '21:00'),
  TimeSlot(12, '21:05', '21:50'),
  TimeSlot(13, '07:00', '07:45'),
  TimeSlot(14, '07:50', '08:35'),
  TimeSlot(15, '12:00', '12:45'),
  TimeSlot(16, '12:50', '13:35'),
  TimeSlot(17, '13:40', '14:25'),
  TimeSlot(18, '17:35', '18:20'),
  TimeSlot(19, '21:55', '22:40'),
  TimeSlot(20, '22:45', '23:30'),
];

// 默认20节时间表（供重置使用）
final List<List<String>> kDefaultTimes = kTimeSlots
    .map((s) => [s.start, s.end])
    .toList();

const List<Color> kCourseColors = [
  Color(0xFF7BB8F0),
  Color(0xFFF07B8A),
  Color(0xFF4ECDC4),
  Color(0xFFA78BFA),
  Color(0xFFF0A87B),
  Color(0xFF82C9A0),
  Color(0xFFF0D07B),
  Color(0xFFC4A882),
];

const List<String> kWeekDays = ['一', '二', '三', '四', '五', '六', '日'];

final List<int> kAllWeeks = List.generate(20, (i) => i + 1);
final List<int> kEvenWeeks = [2, 4, 6, 8, 10, 12, 14, 16];

final List<Course> kInitialCourses = [
  Course(
    id: 1,
    name: '这是课程名称',
    location: '这是上课地点',
    day: 1,
    startSection: 1,
    span: 2,
    colorIdx: 0,
    weeks: kAllWeeks,
  ),
];
