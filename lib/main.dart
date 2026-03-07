import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────
// 主题色扩展（浅色 / 深色）
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
    bg:            Color(0xFFF2F2F7),
    card:          Color(0xFFFFFFFF),
    divider:       Color(0xFFE5E5EA),
    hint:          Color(0xFF6C6C70),
    primaryText:   Color(0xFF1C1C1E),
    secondaryText: Color(0xFF3C3C43),
    inputBg:       Color(0xFFE5E5EA),
    iconBg:        Color(0xFFE5E5EA),
  );

  static const dark = AppColors(
    bg:            Color(0xFF1C1C1E),
    card:          Color(0xFF2C2C2E),
    divider:       Color(0xFF3A3A3C),
    hint:          Color(0xFF8E8E93),
    primaryText:   Color(0xFFFFFFFF),
    secondaryText: Color(0xFFEBEBF5),
    inputBg:       Color(0xFF2C2C2E),
    iconBg:        Color(0xFF3A3A3C),
  );

  @override
  AppColors copyWith({Color? bg, Color? card, Color? divider, Color? hint,
      Color? primaryText, Color? secondaryText, Color? inputBg, Color? iconBg}) =>
      AppColors(
        bg:            bg            ?? this.bg,
        card:          card          ?? this.card,
        divider:       divider       ?? this.divider,
        hint:          hint          ?? this.hint,
        primaryText:   primaryText   ?? this.primaryText,
        secondaryText: secondaryText ?? this.secondaryText,
        inputBg:       inputBg       ?? this.inputBg,
        iconBg:        iconBg        ?? this.iconBg,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg:            Color.lerp(bg, other.bg, t)!,
      card:          Color.lerp(card, other.card, t)!,
      divider:       Color.lerp(divider, other.divider, t)!,
      hint:          Color.lerp(hint, other.hint, t)!,
      primaryText:   Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      inputBg:       Color.lerp(inputBg, other.inputBg, t)!,
      iconBg:        Color.lerp(iconBg, other.iconBg, t)!,
    );
  }
}

// 便捷访问
AppColors _ac(BuildContext context) =>
    Theme.of(context).extension<AppColors>() ?? AppColors.light;

// ─────────────────────────────────────────────
// 时间表配置（名称 + 20节时间）
// ─────────────────────────────────────────────

class TimeTableConfig {
  final String name;
  final List<List<String>> times;

  TimeTableConfig({required this.name, required this.times});

  Map<String, dynamic> toJson() => {'name': name, 'times': times};

  factory TimeTableConfig.fromJson(Map<String, dynamic> j) => TimeTableConfig(
    name:  j['name'] as String? ?? '时间表',
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
  final String    name;
  final DateTime  firstWeekDay;
  final int       sectionsPerDay; // 1–20
  final int       totalWeeks;    // 1–20

  const ScheduleConfig({
    required this.name,
    required this.firstWeekDay,
    this.sectionsPerDay = 10,
    this.totalWeeks     = 20,
  });

  ScheduleConfig copyWith({
    String? name,
    DateTime? firstWeekDay,
    int? sectionsPerDay,
    int? totalWeeks,
  }) => ScheduleConfig(
    name:           name           ?? this.name,
    firstWeekDay:   firstWeekDay   ?? this.firstWeekDay,
    sectionsPerDay: sectionsPerDay ?? this.sectionsPerDay,
    totalWeeks:     totalWeeks     ?? this.totalWeeks,
  );

  Map<String, dynamic> toJson() => {
    'name':           name,
    'firstWeekDay':   firstWeekDay.millisecondsSinceEpoch,
    'sectionsPerDay': sectionsPerDay,
    'totalWeeks':     totalWeeks,
  };

  factory ScheduleConfig.fromJson(Map<String, dynamic> j) => ScheduleConfig(
    name:           j['name'] as String,
    firstWeekDay:   DateTime.fromMillisecondsSinceEpoch(j['firstWeekDay'] as int),
    sectionsPerDay: j['sectionsPerDay'] as int,
    totalWeeks:     j['totalWeeks'] as int,
  );
}

class AppState extends ChangeNotifier {
  List<TimeTableConfig> allTimeTables;
  int activeTimeTableIndex;

  // 向后兼容：当前激活时间表的 times
  List<List<String>> get customTimes => allTimeTables[activeTimeTableIndex].times;

  bool showWeekend;
  bool showNonWeek;
  bool showSection;
  bool isDarkMode;

  // 全局主题色（null = 使用 kCourseColors[0] 默认值）
  int? themeColorValue;
  Color get themeColor => themeColorValue != null ? Color(themeColorValue!) : kCourseColors[0];

  // ── 多课表：每张课表独立配置 + 课程数据 ──
  List<ScheduleConfig> allConfigs;
  int activeScheduleIndex;
  List<List<Course>> allCourses;

  // ── 快捷 getter ──
  ScheduleConfig get config  => allConfigs[activeScheduleIndex];
  List<Course>   get courses => allCourses[activeScheduleIndex];
  List<String> get scheduleNames => allConfigs.map((c) => c.name).toList();

  static final _defaultFirstWeekDay = DateTime(DateTime.now().year, 9, 1);

  AppState({
    List<TimeTableConfig>? allTimeTables,
    this.activeTimeTableIndex = 0,
    required List<Course> initialCourses,
    this.showWeekend        = true,
    this.showNonWeek        = true,
    this.showSection        = true,
    this.isDarkMode         = false,
    this.themeColorValue,
    this.activeScheduleIndex = 0,
    List<ScheduleConfig>? allConfigs,
  }) : allTimeTables = allTimeTables ?? [
         TimeTableConfig(
           name: '默认',
           times: kTimeSlots.map((s) => [s.start, s.end]).toList(),
         ),
       ], allConfigs = allConfigs ?? [
         ScheduleConfig(
           name:           '新建课表',
           firstWeekDay:   _defaultFirstWeekDay,
           sectionsPerDay: 20,
           totalWeeks:     20,
         ),
       ],
       allCourses = List.generate(
         allConfigs != null ? allConfigs.length : 1,
         (i) => i == (activeScheduleIndex) ? List<Course>.from(initialCourses) : <Course>[],
       );

  // ── 当前课表配置更新 ──
  void updateActiveConfig({DateTime? firstWeekDay, int? sectionsPerDay, int? totalWeeks}) {
    allConfigs = List.from(allConfigs)
      ..[activeScheduleIndex] = allConfigs[activeScheduleIndex].copyWith(
          firstWeekDay:   firstWeekDay,
          sectionsPerDay: sectionsPerDay,
          totalWeeks:     totalWeeks,
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
          .where((c) => c.id != id).toList();
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
    allConfigs = [...allConfigs, cfg];
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
    allConfigs          = newConfigs;
    allCourses          = newCourses;
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
    allConfigs = List.from(allConfigs)
      ..[index] = allConfigs[index].copyWith(name: name);
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
  void updateTimes(List<List<String>> times) => updateTimeTable(activeTimeTableIndex, times);

  void updateSettings({bool? showWeekend, bool? showNonWeek, bool? showSection}) {
    if (showWeekend != null) this.showWeekend = showWeekend;
    if (showNonWeek  != null) this.showNonWeek  = showNonWeek;
    if (showSection  != null) this.showSection  = showSection;
    notifyListeners();
  }

  void updateDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void updateThemeColor(Color color) {
    themeColorValue = color.value;
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
        'activeScheduleIndex':  activeScheduleIndex,
        'activeTimeTableIndex': activeTimeTableIndex,
        'showWeekend':  showWeekend,
        'showNonWeek':  showNonWeek,
        'showSection':  showSection,
        'isDarkMode':   isDarkMode,
        'themeColorValue': themeColorValue,
        'allTimeTables': allTimeTables.map((t) => t.toJson()).toList(),
        'allConfigs':   allConfigs.map((c) => c.toJson()).toList(),
        'allCourses':   allCourses
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
            .map((list) => (list as List)
                .map((e) => Course.fromJson(e as Map<String, dynamic>))
                .toList())
            .toList();

        // 兼容旧数据：优先读 allTimeTables，否则从 customTimes 迁移
        List<TimeTableConfig> allTimeTables;
        if (j['allTimeTables'] != null) {
          allTimeTables = (j['allTimeTables'] as List)
              .map((e) => TimeTableConfig.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (j['customTimes'] != null) {
          final rawTimes = j['customTimes'] as List;
          final times = rawTimes.map((row) => (row as List).cast<String>()).toList();
          allTimeTables = [TimeTableConfig(name: '默认', times: times)];
        } else {
          allTimeTables = [TimeTableConfig(
            name: '默认',
            times: kTimeSlots.map((s) => [s.start, s.end]).toList(),
          )];
        }

        return AppState(
          allTimeTables:        allTimeTables,
          activeTimeTableIndex: j['activeTimeTableIndex'] as int? ?? 0,
          initialCourses:      [],
          activeScheduleIndex: j['activeScheduleIndex'] as int? ?? 0,
          allConfigs:          allConfigs,
          showWeekend:         j['showWeekend'] as bool? ?? true,
          showNonWeek:         j['showNonWeek'] as bool? ?? true,
          showSection:         j['showSection'] as bool? ?? true,
          isDarkMode:          j['isDarkMode'] as bool? ?? false,
          themeColorValue:     j['themeColorValue'] as int?,
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
          name:           '新建课表',
          firstWeekDay:   DateTime(DateTime.now().year, 9, 1),
          sectionsPerDay: 20,
          totalWeeks:     20,
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
  const AppStateScope({super.key, required super.notifier, required super.child});

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
  List<int> get weeks => List.generate(endWeek - startWeek + 1, (i) => startWeek + i);

  CourseSlot copyWith({int? day, int? startSection, int? endSection, int? startWeek, int? endWeek}) =>
      CourseSlot(
        day:          day          ?? this.day,
        startSection: startSection ?? this.startSection,
        endSection:   endSection   ?? this.endSection,
        startWeek:    startWeek    ?? this.startWeek,
        endWeek:      endWeek      ?? this.endWeek,
      );

  Map<String, dynamic> toJson() => {
    'day': day, 'startSection': startSection, 'endSection': endSection,
    'startWeek': startWeek, 'endWeek': endWeek,
  };

  factory CourseSlot.fromJson(Map<String, dynamic> j) => CourseSlot(
    day:          j['day'] as int,
    startSection: j['startSection'] as int,
    endSection:   j['endSection'] as int? ?? j['startSection'] as int,
    startWeek:    j['startWeek'] as int? ?? 1,
    endWeek:      j['endWeek'] as int? ?? 18,
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
    CourseSlot(day: day, startSection: startSection,
        endSection: startSection + span - 1,
        startWeek: startWeek, endWeek: endWeek),
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
    'id':           id,
    'name':         name,
    'location':     location,
    'teacher':      teacher,
    'credit':       credit,
    'note':         note,
    'day':          day,
    'startSection': startSection,
    'span':         span,
    'colorIdx':     colorIdx,
    'customColor':  customColor?.value,
    'isNonWeek':    isNonWeek,
    'weeks':        weeks,
    'startWeek':    startWeek,
    'endWeek':      endWeek,
    'extraSlots':   extraSlots.map((s) => s.toJson()).toList(),
  };

  factory Course.fromJson(Map<String, dynamic> j) => Course(
    id:           j['id'] as int,
    name:         j['name'] as String,
    location:     j['location'] as String? ?? '',
    teacher:      j['teacher'] as String? ?? '',
    credit:       j['credit'] as String? ?? '',
    note:         j['note'] as String? ?? '',
    day:          j['day'] as int,
    startSection: j['startSection'] as int,
    span:         j['span'] as int,
    colorIdx:     j['colorIdx'] as int? ?? 0,
    customColor:  j['customColor'] != null ? Color(j['customColor'] as int) : null,
    isNonWeek:    j['isNonWeek'] as bool? ?? false,
    weeks:        (j['weeks'] as List).cast<int>(),
    startWeek:    j['startWeek'] as int? ?? 1,
    endWeek:      j['endWeek'] as int? ?? 18,
    extraSlots:   (j['extraSlots'] as List? ?? [])
        .map((e) => CourseSlot.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

}

// ─────────────────────────────────────────────
// 常量
// ─────────────────────────────────────────────

const double kSlotHeight = 68.0;

const List<TimeSlot> kTimeSlots = [
  TimeSlot(1,  '08:00', '08:45'),
  TimeSlot(2,  '08:55', '09:40'),
  TimeSlot(3,  '10:10', '10:55'),
  TimeSlot(4,  '11:05', '11:50'),
  TimeSlot(5,  '14:00', '14:45'),
  TimeSlot(6,  '14:50', '15:35'),
  TimeSlot(7,  '15:55', '16:40'),
  TimeSlot(8,  '16:45', '17:30'),
  TimeSlot(9,  '18:30', '19:15'),
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
final List<List<String>> kDefaultTimes =
    kTimeSlots.map((s) => [s.start, s.end]).toList();

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
  Course(id: 1,  name: '蛋白质组学',       location: '东十二楼 F101', day: 1, startSection: 1, span: 2, colorIdx: 0, weeks: kAllWeeks),
  Course(id: 2,  name: '大三-腰旗橄榄球 下', location: '东校区操场',   day: 3, startSection: 1, span: 2, colorIdx: 1, weeks: kAllWeeks),
  Course(id: 3,  name: '基因组学',         location: '东十二楼 212',  day: 5, startSection: 1, span: 2, colorIdx: 1, weeks: kAllWeeks),
  Course(id: 4,  name: '人工智能微生物组学', location: '东十二楼 313',  day: 2, startSection: 3, span: 2, colorIdx: 0, isNonWeek: true, weeks: kEvenWeeks),
  Course(id: 5,  name: '基因组学',         location: '东十二楼 212',  day: 3, startSection: 3, span: 2, colorIdx: 1, weeks: kAllWeeks),
  Course(id: 6,  name: '人工智能微生物组学', location: '东十二楼 313',  day: 4, startSection: 3, span: 2, colorIdx: 0, isNonWeek: true, weeks: kEvenWeeks),
  Course(id: 7,  name: '生物信息数据挖掘',   location: '东十二楼 212',  day: 5, startSection: 3, span: 2, colorIdx: 2, weeks: kAllWeeks),
  Course(id: 8,  name: '蛋白质组学',       location: '东十二楼 F101', day: 3, startSection: 5, span: 2, colorIdx: 0, weeks: kAllWeeks),
  Course(id: 9,  name: '代谢组学',         location: '东十二楼 114',  day: 5, startSection: 5, span: 2, colorIdx: 1, isNonWeek: true, weeks: kEvenWeeks),
  Course(id: 10, name: '系统生物学实验',     location: '东十二楼 520',  day: 6, startSection: 5, span: 2, colorIdx: 7, isNonWeek: true, weeks: kEvenWeeks),
  Course(id: 11, name: '系统生物学实验',     location: '东十二楼 520',  day: 7, startSection: 5, span: 2, colorIdx: 7, isNonWeek: true, weeks: kEvenWeeks),
  Course(id: 12, name: '化学与生物传感器',   location: '',             day: 1, startSection: 7, span: 2, colorIdx: 0, isNonWeek: true, weeks: kEvenWeeks),
  Course(id: 13, name: '生物信息数据挖掘',   location: '东十二楼 212',  day: 2, startSection: 7, span: 2, colorIdx: 2, weeks: kAllWeeks),
  Course(id: 14, name: '形势与政策',        location: '东九楼 D306',   day: 4, startSection: 7, span: 2, colorIdx: 3, isNonWeek: true, weeks: kEvenWeeks),
  Course(id: 15, name: '生物信息数据挖掘',   location: '',             day: 3, startSection: 9, span: 2, colorIdx: 2, isNonWeek: true, weeks: kEvenWeeks),
];

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

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _currentWeek = 1;
  static const int _initialWeek = 1;
  late final PageController _pageController;
  final DateTime _today = DateTime.now();
  int _lastActiveIndex = -1; // 追踪课表切换

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentWeek - 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final idx = AppStateScope.of(context).activeScheduleIndex;
    if (_lastActiveIndex != -1 && idx != _lastActiveIndex) {
      // 课表切换，重置到第1周
      setState(() => _currentWeek = 1);
      _pageController.jumpToPage(0);
    }
    _lastActiveIndex = idx;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _todayCol => _today.weekday;
  DateTime get _thisWeekMonday => _today.subtract(Duration(days: _today.weekday - 1));
  // week1Monday 由当前课表的 firstWeekDay 决定
  DateTime _week1MondayFor(DateTime firstWeekDay) {
    // 找到 firstWeekDay 所在周的周一
    return firstWeekDay.subtract(Duration(days: firstWeekDay.weekday - 1));
  }
  DateTime get _currentWeekMonday {
    final cfg = AppStateScope.of(context).config;
    return _week1MondayFor(cfg.firstWeekDay).add(Duration(days: (_currentWeek - 1) * 7));
  }

  int _currentSectionIdx(List<List<String>> customTimes) {
    final now = TimeOfDay.now();
    final total = now.hour * 60 + now.minute;
    for (int i = 0; i < customTimes.length; i++) {
      final s = customTimes[i][0].split(':');
      final e = customTimes[i][1].split(':');
      final sMin = int.parse(s[0]) * 60 + int.parse(s[1]);
      final eMin = int.parse(e[0]) * 60 + int.parse(e[1]);
      if (total >= sMin && total <= eMin) return i;
    }
    return -1;
  }

  void _deleteCourse(int id) => AppStateScope.of(context).deleteCourse(id);
  void _addCourse(Course course) => AppStateScope.of(context).addCourse(course);

  @override
  Widget build(BuildContext context) {
    final appState    = AppStateScope.of(context);
    final cfg         = appState.config;
    final showWeekend = appState.showWeekend;
    final showNonWeek = appState.showNonWeek;
    final showSection = appState.showSection;
    final customTimes = appState.customTimes;
    final courses     = appState.courses;
    final visibleDays = showWeekend ? 7 : 5;
    final totalWeeks  = cfg.totalWeeks;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              weekMonday: _currentWeekMonday,
              today: _today,
              currentWeek: _currentWeek,
              todayCol: _todayCol,
              onMore: () => _showMoreMenu(context),
              onAdd: () => _showAddPage(context),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalWeeks,
                onPageChanged: (page) {
                  setState(() => _currentWeek = page + 1);
                },
                itemBuilder: (context, page) {
                  final week = page + 1;
                  final weekMonday = _week1MondayFor(cfg.firstWeekDay).add(Duration(days: (week - 1) * 7));
                  var visibleForWeek = courses.where((c) => c.weeks.contains(week)).toList();
                  if (!showNonWeek) {
                    visibleForWeek = visibleForWeek.where((c) => !c.isNonWeek).toList();
                  }
                  List<Course> getCoursesAt(int day, int section) {
                    final result = <Course>[];
                    // 主时间段
                    for (final c in visibleForWeek) {
                      if (c.day == day &&
                          section >= c.startSection &&
                          section < c.startSection + c.span) {
                        result.add(c);
                      }
                    }
                    // 附加时间段：包装成虚拟 Course 供网格渲染
                    for (final c in courses) {
                      for (final s in c.extraSlots) {
                        if (s.weeks.contains(week) &&
                            s.day == day &&
                            section >= s.startSection &&
                            section < s.startSection + s.span) {
                          result.add(Course(
                            id: c.id,
                            name: c.name,
                            location: c.location,
                            teacher: c.teacher,
                            credit: c.credit,
                            note: c.note,
                            day: s.day,
                            startSection: s.startSection,
                            span: s.span,
                            colorIdx: c.colorIdx,
                            customColor: c.customColor,
                            isNonWeek: c.isNonWeek,
                            weeks: s.weeks,
                            startWeek: s.startWeek,
                            endWeek: s.endWeek,
                          ));
                        }
                      }
                    }
                    return result;
                  }
                  return Column(
                    children: [
                      _DayHeader(
                        weekMonday: weekMonday,
                        today: _today,
                        todayCol: _todayCol,
                        visibleDays: visibleDays,
                      ),
                      Expanded(
                        child: _ScheduleGrid(
                          currentWeek: week,
                          courses: courses,
                          visibleCourses: visibleForWeek,
                          currentSectionIdx: _currentSectionIdx(customTimes),
                          todayCol: _todayCol,
                          getCoursesAt: getCoursesAt,
                          onCourseTap: (c) => _showDetailSheet(context, c),
                          customTimes: customTimes.take(cfg.sectionsPerDay).toList(),
                          showSection: showSection,
                          visibleDays: visibleDays,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 详情底部弹窗 ──
  void _showDetailSheet(BuildContext context, Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseDetailSheet(
        course: course,
        onDelete: () {
          _deleteCourse(course.id);
          Navigator.pop(context);
        },
        onEdit: () {
          final appState = AppStateScope.of(context);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => AddCoursePage(
              editCourse: course,
              onEdit: (updated) => appState.editCourse(updated),
            ),
          ));
        },
      ),
    );
  }

  // ── 更多菜单（含周选择器）──
  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreMenuSheet(
        currentWeek: _currentWeek,
        onWeekChanged: (w) {
          setState(() => _currentWeek = w);
          _pageController.animateToPage(
            w - 1,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── 添加课程全屏页 ──
  void _showAddPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddCoursePage(
          onAdd: (_) {}, // _save 内部已直接调用 appState.addCourse
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 顶部 Header（日期 + 周选择器）
// ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  final DateTime weekMonday;   // 当前显示周的周一
  final DateTime today;        // 真实今天
  final int currentWeek;
  final int todayCol;
  final VoidCallback onMore;
  final VoidCallback onAdd;

  const _Header({
    required this.weekMonday,
    required this.today,
    required this.currentWeek,
    required this.todayCol,
    required this.onMore,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final thisWeekMonday = today.subtract(Duration(days: today.weekday - 1));
    final isThisWeek = weekMonday.year == thisWeekMonday.year &&
        weekMonday.month == thisWeekMonday.month &&
        weekMonday.day == thisWeekMonday.day;

    final weekDayStr = kWeekDays[todayCol - 1];
    final appState = AppStateScope.of(context);
    final scheduleName = appState.scheduleNames[appState.activeScheduleIndex];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${today.year}/${today.month}/${today.day}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  // 课表名称标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      scheduleName,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4ECDC4), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '第$currentWeek周',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(width: 6),
                  if (isThisWeek)
                    Text(
                      '周$weekDayStr',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF07B8A).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '非本周',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFF07B8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: onAdd,
                color: const Color(0xFF444444),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SchoolImportPage()),
                ),
                color: const Color(0xFF444444),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 22),
                onPressed: onMore,
                color: const Color(0xFF444444),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 星期表头行
// ─────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  final DateTime weekMonday;
  final DateTime today;
  final int todayCol;
  final int visibleDays;

  const _DayHeader({
    required this.weekMonday,
    required this.today,
    required this.todayCol,
    this.visibleDays = 7,
  });

  @override
  Widget build(BuildContext context) {
    final thisWeekMonday = today.subtract(Duration(days: today.weekday - 1));
    final isCurrentWeek = weekMonday.year == thisWeekMonday.year &&
        weekMonday.month == thisWeekMonday.month &&
        weekMonday.day == thisWeekMonday.day;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: const Border(bottom: BorderSide(color: Color(0x0F000000))),
      ),
      child: Row(
        children: [
          // 月份列
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    '${weekMonday.month}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
                  ),
                  const Text(
                    '月',
                    style: TextStyle(fontSize: 10, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          ),
          // N天列（根据 visibleDays 决定显示5或7列）
          ...List.generate(visibleDays, (i) {
            final col = i + 1;
            final isToday = isCurrentWeek && col == todayCol;
            final date = weekMonday.add(Duration(days: i));
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0x0A000000))),
                ),
                child: Column(
                  children: [
                    Text(
                      kWeekDays[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday ? const Color(0xFF4ECDC4) : const Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFF4ECDC4) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isToday ? Colors.white : const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 课程网格
// ─────────────────────────────────────────────

class _ScheduleGrid extends StatelessWidget {
  final int currentWeek;
  final List<Course> courses;
  final List<Course> visibleCourses;
  final int currentSectionIdx;
  final int todayCol;
  final List<Course> Function(int day, int section) getCoursesAt;
  final ValueChanged<Course> onCourseTap;
  final List<List<String>> customTimes;
  final bool showSection;
  final int visibleDays;

  const _ScheduleGrid({
    required this.currentWeek,
    required this.courses,
    required this.visibleCourses,
    required this.currentSectionIdx,
    required this.todayCol,
    required this.getCoursesAt,
    required this.onCourseTap,
    required this.customTimes,
    this.showSection = true,
    this.visibleDays = 7,
  });

  @override
  Widget build(BuildContext context) {
    final double totalHeight = customTimes.length * kSlotHeight;
    return SingleChildScrollView(
      child: SizedBox(
        height: totalHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧节次时间列
            SizedBox(
              width: 44,
              child: Column(
                children: List.generate(customTimes.length, (i) {
                  final isCurrent = i == currentSectionIdx;
                  final start = customTimes[i][0];
                  final end   = customTimes[i][1];
                  return Container(
                    height: kSlotHeight,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF4ECDC4).withOpacity(0.1)
                          : Colors.transparent,
                      border: const Border(
                        bottom: BorderSide(color: Color(0x08000000)),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showSection)
                          Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isCurrent ? const Color(0xFF4ECDC4) : const Color(0xFFAAAAAA),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(start, style: const TextStyle(fontSize: 8, color: Color(0xFFBBBBBB))),
                        Text(end,   style: const TextStyle(fontSize: 8, color: Color(0xFFBBBBBB))),
                      ],
                    ),
                  );
                }),
              ),
            ),
            // N天列
            ...List.generate(visibleDays, (dIdx) {
              final day = dIdx + 1;
              final isToday = day == todayCol;
              return Expanded(
                child: _DayColumn(
                  day: day,
                  isToday: isToday,
                  sectionCount: customTimes.length,
                  getCoursesAt: getCoursesAt,
                  onCourseTap: onCourseTap,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 单天列（用 Stack 叠加课程块）
// ─────────────────────────────────────────────

class _DayColumn extends StatelessWidget {
  final int day;
  final bool isToday;
  final int sectionCount;
  final List<Course> Function(int day, int section) getCoursesAt;
  final ValueChanged<Course> onCourseTap;

  const _DayColumn({
    required this.day,
    required this.isToday,
    required this.getCoursesAt,
    required this.onCourseTap,
    this.sectionCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = sectionCount * kSlotHeight;

    // 收集每天需要渲染的课程（只取 startSection 处的）
    final Set<String> rendered = {};
    final List<_CoursePosition> positioned = [];

    for (int sIdx = 0; sIdx < sectionCount; sIdx++) {
      final section = sIdx + 1;
      final cs = getCoursesAt(day, section);
      for (final c in cs) {
        final key = '${c.id}_${c.day}_${c.startSection}';
        if (c.startSection == section && !rendered.contains(key)) {
          rendered.add(key);
          positioned.add(_CoursePosition(
            course: c,
            top: sIdx * kSlotHeight,
            height: c.span * kSlotHeight,
          ));
        }
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF4ECDC4).withOpacity(0.03)
            : Colors.transparent,
        border: const Border(left: BorderSide(color: Color(0x08000000))),
      ),
      child: Stack(
        children: [
          // 背景格子线
          Column(
            children: List.generate(sectionCount, (_) {
              return Container(
                height: kSlotHeight,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0x08000000)),
                  ),
                ),
              );
            }),
          ),
          // 课程卡片
          SizedBox(
            height: totalHeight,
            child: Stack(
              children: positioned.map((p) {
                return Positioned(
                  top: p.top + 2,
                  left: 2,
                  right: 2,
                  height: p.height - 4,
                  child: _CourseCard(
                    course: p.course,
                    onTap: () => onCourseTap(p.course),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursePosition {
  final Course course;
  final double top;
  final double height;
  const _CoursePosition(
      {required this.course, required this.top, required this.height});
}

// ─────────────────────────────────────────────
// 课程卡片
// ─────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // customColor 优先；否则用调色板，但 colorIdx 0 受全局主题色覆盖
    Color color;
    if (course.customColor != null) {
      color = course.customColor!;
    } else {
      final idx = course.colorIdx % kCourseColors.length;
      final appState = AppStateScope.of(context);
      color = (idx == 0 && appState.themeColorValue != null)
          ? appState.themeColor
          : kCourseColors[idx];
    }
    final opacity = course.isNonWeek ? 0.55 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (course.isNonWeek)
                const Text(
                  '[非本周]',
                  style: TextStyle(
                    fontSize: 7,
                    color: const Color(0xFF3C3C43),
                  ),
                  textAlign: TextAlign.center,
                ),
              Text(
                course.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (course.location.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  '@${course.location}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: const Color(0xFF3C3C43),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 课程详情底部弹窗
// ─────────────────────────────────────────────

class _CourseDetailSheet extends StatelessWidget {
  final Course course;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _CourseDetailSheet({
    required this.course,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = course.effectiveColor;
    final startSlotIdx = course.startSection - 1;
    final endSlotIdx = course.startSection + course.span - 2;
    final startTime = startSlotIdx >= 0 && startSlotIdx < kTimeSlots.length
        ? kTimeSlots[startSlotIdx].start
        : '';
    final endTime = endSlotIdx >= 0 && endSlotIdx < kTimeSlots.length
        ? kTimeSlots[endSlotIdx].end
        : '';

    return Container(
      decoration: const BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖动条
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 顶部行：标签 + 编辑按钮
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '周${kWeekDays[course.day - 1]}  ·  第${course.startSection}–${course.startSection + course.span - 1}节',
                        style: const TextStyle(
                            fontSize: 12, color: const Color(0xFF1C1C1E), fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
              ),
              // 编辑按钮
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined, size: 15, color: Color(0xFF555555)),
                    SizedBox(width: 4),
                    Text('编辑', style: TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ],
          ),
          if (course.location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Text('📍 ', style: TextStyle(fontSize: 14)),
              Text(course.location,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
            ]),
          ],
          if (course.teacher.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Text('👤 ', style: TextStyle(fontSize: 14)),
              Text(course.teacher,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
            ]),
          ],
          const SizedBox(height: 8),
          Text(
            '$startTime – $endTime',
            style: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 24),
          // 删除 + 关闭按钮行
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F1),
                  foregroundColor: const Color(0xFFE05555),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('删除课程',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  foregroundColor: const Color(0xFF666666),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('关闭', style: TextStyle(fontSize: 15)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 更多菜单底部弹窗（仿 WakeUp 深色风格）
// ─────────────────────────────────────────────

class _MoreMenuSheet extends StatefulWidget {
  final int currentWeek;
  final ValueChanged<int> onWeekChanged;

  const _MoreMenuSheet({
    required this.currentWeek,
    required this.onWeekChanged,
  });

  @override
  State<_MoreMenuSheet> createState() => _MoreMenuSheetState();
}

class _MoreMenuSheetState extends State<_MoreMenuSheet> {
  static const Color _accent = Color(0xFFFF3B5C);

  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentWeek.toDouble();
  }

  // 工具格子数据
  static const List<_MenuTool> _tools = [
    _MenuTool(icon: Icons.access_time_outlined, label: '上课时间',  route: 'class_time'),
    _MenuTool(icon: Icons.tune_outlined,         label: '课表设置',  route: 'schedule_settings'),
    _MenuTool(icon: Icons.inbox_outlined,        label: '已添课程',  route: 'added_courses'),
    _MenuTool(icon: Icons.settings_outlined,     label: '全局设置',  route: 'global_settings'),
    _MenuTool(icon: Icons.ios_share_outlined,    label: '导出课表',  route: 'export'),
    _MenuTool(icon: Icons.info_outline,          label: '关于',      route: 'about'),
  ];

  @override
  Widget build(BuildContext context) {
    final ac = _ac(context);
    return Container(
      decoration: BoxDecoration(
        color: ac.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖动条
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ac.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── 周数卡片 ──
              _Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('周数', style: TextStyle(color: ac.primaryText, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      // 带数字标签的滑块
                      Row(
                        children: [
                          // 当前周气泡
                          Container(
                            width: 44, height: 28,
                            decoration: BoxDecoration(
                              color: ac.divider,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${_sliderValue.round()}',
                              style: TextStyle(color: ac.primaryText, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF4ECDC4),
                                inactiveTrackColor: ac.divider,
                                thumbColor: const Color(0xFF4ECDC4),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                trackHeight: 4,
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                value: _sliderValue,
                                min: 1,
                                max: 20,
                                divisions: 19,
                                onChanged: (v) => setState(() => _sliderValue = v),
                                onChangeEnd: (v) => widget.onWeekChanged(v.round()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── 切换课表卡片 ──
              _Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('切换课表', style: TextStyle(color: ac.primaryText, fontSize: 15, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (_) => const NewSchedulePage(),
                              ));
                            },
                            child: const Text('新建课表  ', style: TextStyle(color: _accent, fontSize: 13)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const ManageSchedulePage(),
                              ));
                            },
                            child: const Text('管理课表', style: TextStyle(color: _accent, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: Builder(builder: (ctx) {
                          final s = AppStateScope.of(ctx);
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: s.scheduleNames.length,
                            itemBuilder: (_, i) => GestureDetector(
                              onTap: () => s.switchSchedule(i),
                              child: _ScheduleThumb(
                                label: s.scheduleNames[i],
                                isSelected: i == s.activeScheduleIndex,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── 工具格子卡片 ──
              _Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.1,
                    children: _tools.map((t) => _ToolCell(tool: t)).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 通用深色卡片 ──
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _ac(context).card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// ── 课表缩略图 ──
class _ScheduleThumb extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _ScheduleThumb({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final ac = _ac(context);
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            width: 72, height: 64,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4ECDC4).withOpacity(0.25) : ac.divider,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: const Color(0xFF4ECDC4), width: 1.5) : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 24)
                : null,
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: ac.secondaryText, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── 工具格子数据模型 ──
class _MenuTool {
  final IconData icon;
  final String label;
  final String route;
  const _MenuTool({required this.icon, required this.label, required this.route});
}

class _ToolCell extends StatelessWidget {
  final _MenuTool tool;
  const _ToolCell({required this.tool});

  static const Map<String, Widget> _pages = {};

  void _navigate(BuildContext context) {
    Widget page;
    switch (tool.route) {
      case 'class_time':
        page = const ClassTimeListPage();
        break;
      case 'schedule_settings':
        page = const ScheduleSettingsPage();
        break;
      case 'added_courses':
        page = const AddedCoursesPage();
        break;
      case 'global_settings':
        page = const GlobalSettingsPage();
        break;
      case 'export':
        Navigator.pop(context); // 关闭菜单
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: _ac(ctx).card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Row(children: [
                Icon(Icons.ios_share_outlined, color: Color(0xFF6C6C70), size: 20),
                SizedBox(width: 8),
                Text('导出课表', style: TextStyle(
                    color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
              content: const Text(
                '「导出课表」功能正在开发中，敬请期待。',
                style: TextStyle(color: Color(0xFF6C6C70), fontSize: 14, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('好的',
                      style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
                ),
              ],
            ),
          );
        });
        return;
      case 'about':
      default:
        page = const AboutPage();
        break;
    }
    Navigator.pop(context); // 关闭菜单
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final ac = _ac(context);
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: ac.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(tool.icon, color: ac.secondaryText, size: 24),
          ),
          const SizedBox(height: 6),
          Text(tool.label, style: TextStyle(color: ac.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 添加/编辑课程全屏页（仿 WakeUp 深色风格）
// ─────────────────────────────────────────────

// 单个时间段（仅用于 AddCoursePage 内部编辑状态）
class _CourseSlot {
  int day;
  int startSection;
  int endSection;
  int startWeek;
  int endWeek;

  _CourseSlot({
    required this.day,
    required this.startSection,
    required this.endSection,
    required this.startWeek,
    required this.endWeek,
  });

  int get span => (endSection - startSection + 1).clamp(1, 20);
  List<int> get weeks => List.generate(endWeek - startWeek + 1, (i) => startWeek + i);

  _CourseSlot copyWith({int? day, int? startSection, int? endSection, int? startWeek, int? endWeek}) =>
      _CourseSlot(
        day:          day          ?? this.day,
        startSection: startSection ?? this.startSection,
        endSection:   endSection   ?? this.endSection,
        startWeek:    startWeek    ?? this.startWeek,
        endWeek:      endWeek      ?? this.endWeek,
      );
}

class AddCoursePage extends StatefulWidget {
  final ValueChanged<Course>? onAdd;
  final ValueChanged<Course>? onEdit;
  final Course? editCourse; // 非 null 时为编辑模式
  const AddCoursePage({super.key, this.onAdd, this.onEdit, this.editCourse})
      : assert(editCourse != null || onAdd != null,
            'Must provide onAdd for add mode or onEdit for edit mode');

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _nameCtrl    = TextEditingController();
  final _creditCtrl  = TextEditingController();
  final _noteCtrl    = TextEditingController();
  final _teacherCtrl = TextEditingController();
  final _locCtrl     = TextEditingController();

  Color? _customColor;   // null = 随机自动
  bool   _initialized = false;

  // ── 多时间段 ──
  late List<_CourseSlot> _slots;
  int _activeSlotIdx = 0;

  _CourseSlot get _activeSlot => _slots[_activeSlotIdx];
  void _updateActiveSlot(_CourseSlot s) => setState(() => _slots[_activeSlotIdx] = s);

  static const Color _accent   = Color(0xFFFF3B5C);

  // 自动选一个与已有课程不冲突的颜色
  Color _pickAutoColor(List<Course> existing) {
    final usedColors = existing.map((c) => c.effectiveColor.value).toSet();
    // 先从预设色盘找未用色
    for (final c in kCourseColors) {
      if (!usedColors.contains(c.value)) return c;
    }
    // 全部用过就从色相环随机取
    final hue = (existing.length * 47.0) % 360;
    return HSVColor.fromAHSV(1, hue, 0.7, 0.9).toColor();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final cfg = AppStateScope.of(context).config;

    final e = widget.editCourse;
    if (e != null) {
      _nameCtrl.text    = e.name;
      _creditCtrl.text  = e.credit;
      _noteCtrl.text    = e.note;
      _teacherCtrl.text = e.teacher;
      _locCtrl.text     = e.location;
      _customColor      = e.customColor ?? e.effectiveColor;
      _slots = [
        _CourseSlot(
          day: e.day,
          startSection: e.startSection,
          endSection: (e.startSection + e.span - 1).clamp(1, cfg.sectionsPerDay),
          startWeek: e.startWeek,
          endWeek: e.endWeek,
        ),
        // 还原附加时间段
        ...e.extraSlots.map((s) => _CourseSlot(
          day: s.day,
          startSection: s.startSection,
          endSection: s.endSection,
          startWeek: s.startWeek,
          endWeek: s.endWeek,
        )),
      ];
    } else {
      _slots = [
        _CourseSlot(
          day: 1,
          startSection: 1,
          endSection: 2.clamp(1, cfg.sectionsPerDay),
          startWeek: 1,
          endWeek: cfg.totalWeeks,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _creditCtrl.dispose(); _noteCtrl.dispose();
    _teacherCtrl.dispose(); _locCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写课程名称'), backgroundColor: Color(0xFFE5E5EA)),
      );
      return;
    }
    final appState = AppStateScope.of(context);
    final color    = _customColor ?? _pickAutoColor(appState.courses);
    final primary  = _slots[0];
    final extras   = _slots.length > 1
        ? _slots.sublist(1).map((s) => CourseSlot(
              day: s.day, startSection: s.startSection,
              endSection: s.endSection,
              startWeek: s.startWeek, endWeek: s.endWeek)).toList()
        : <CourseSlot>[];
    final course = Course(
      id:           widget.editCourse?.id ?? DateTime.now().millisecondsSinceEpoch,
      name:         _nameCtrl.text.trim(),
      location:     _locCtrl.text.trim(),
      teacher:      _teacherCtrl.text.trim(),
      credit:       _creditCtrl.text.trim(),
      note:         _noteCtrl.text.trim(),
      day:          primary.day,
      startSection: primary.startSection,
      span:         primary.span,
      colorIdx:     0,
      customColor:  color,
      weeks:        primary.weeks,
      startWeek:    primary.startWeek,
      endWeek:      primary.endWeek,
      isNonWeek:    widget.editCourse?.isNonWeek ?? false,
      extraSlots:   extras,
    );
    if (widget.editCourse != null) {
      appState.editCourse(course);
    } else {
      appState.addCourse(course);
    }
    Navigator.pop(context);
  }

  // ── 选择器弹窗通用方法 ──
  void _showPicker<T>({
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T) label,
    required ValueChanged<T> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        T current = selected;
        return StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D1D6), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                    Text(title, style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                        onPressed: () { onChanged(current); Navigator.pop(ctx); },
                        child: const Text('确定', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 44,
                  perspective: 0.003,
                  diameterRatio: 1.8,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(initialItem: values.indexOf(selected)),
                  onSelectedItemChanged: (i) => setS(() => current = values[i]),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: values.length,
                    builder: (_, i) => Center(
                      child: Text(label(values[i]),
                        style: TextStyle(
                          color: values[i] == current ? Colors.white : const Color(0xFFC7C7CC),
                          fontSize: values[i] == current ? 18 : 15,
                          fontWeight: values[i] == current ? FontWeight.w600 : FontWeight.w400,
                        )),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        });
      },
    );
  }

  // 周数范围选择器（双轮）
  void _showWeekRangePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        int tmpStart = _activeSlot.startWeek, tmpEnd = _activeSlot.endWeek;
        return StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D1D6), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                    const Text('周数', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                        onPressed: () {
                          _updateActiveSlot(_activeSlot.copyWith(startWeek: tmpStart, endWeek: tmpEnd));
                          Navigator.pop(ctx);
                        },
                        child: const Text('确定', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: Column(children: [
                    const Text('开始', style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 12)),
                    SizedBox(height: 200, child: ListWheelScrollView.useDelegate(
                      itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(initialItem: tmpStart - 1),
                      onSelectedItemChanged: (i) => setS(() => tmpStart = i + 1),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 20,
                        builder: (_, i) => Center(child: Text('第${i+1}周',
                          style: TextStyle(
                            color: i + 1 == tmpStart ? Colors.white : const Color(0xFFC7C7CC),
                            fontSize: i + 1 == tmpStart ? 17 : 14,
                            fontWeight: i + 1 == tmpStart ? FontWeight.w600 : FontWeight.w400,
                          ))),
                      ),
                    )),
                  ])),
                  Expanded(child: Column(children: [
                    const Text('结束', style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 12)),
                    SizedBox(height: 200, child: ListWheelScrollView.useDelegate(
                      itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(initialItem: tmpEnd - 1),
                      onSelectedItemChanged: (i) => setS(() => tmpEnd = i + 1),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 20,
                        builder: (_, i) => Center(child: Text('第${i+1}周',
                          style: TextStyle(
                            color: i + 1 == tmpEnd ? Colors.white : const Color(0xFFC7C7CC),
                            fontSize: i + 1 == tmpEnd ? 17 : 14,
                            fontWeight: i + 1 == tmpEnd ? FontWeight.w600 : FontWeight.w400,
                          ))),
                      ),
                    )),
                  ])),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        });
      },
    );
  }

  // 节次范围选择器（开始节 + 结束节）
  void _showSectionPicker() {
    final cfg = AppStateScope.of(context).config;
    final maxSec = cfg.sectionsPerDay;
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        int tmpStart = _activeSlot.startSection, tmpEnd = _activeSlot.endSection;
        return StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D1D6), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                    const Text('选择节次', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                        onPressed: () {
                          // 确保 end >= start
                          final end = tmpEnd < tmpStart ? tmpStart : tmpEnd;
                          _updateActiveSlot(_activeSlot.copyWith(startSection: tmpStart, endSection: end));
                          Navigator.pop(ctx);
                        },
                        child: const Text('确定', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: Column(children: [
                    const Text('开始节', style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 12)),
                    SizedBox(height: 200, child: ListWheelScrollView.useDelegate(
                      itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(initialItem: tmpStart - 1),
                      onSelectedItemChanged: (i) {
                        setS(() {
                          tmpStart = i + 1;
                          if (tmpEnd < tmpStart) tmpEnd = tmpStart;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: maxSec,
                        builder: (_, i) => Center(child: Text('第${i+1}节',
                          style: TextStyle(
                            color: i + 1 == tmpStart ? Colors.white : const Color(0xFFC7C7CC),
                            fontSize: i + 1 == tmpStart ? 17 : 14,
                            fontWeight: i + 1 == tmpStart ? FontWeight.w600 : FontWeight.w400,
                          ))),
                      ),
                    )),
                  ])),
                  Expanded(child: Column(children: [
                    const Text('结束节', style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 12)),
                    SizedBox(height: 200, child: ListWheelScrollView.useDelegate(
                      itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                          initialItem: (tmpEnd - 1).clamp(0, maxSec - 1)),
                      onSelectedItemChanged: (i) {
                        setS(() {
                          tmpEnd = i + 1;
                          if (tmpEnd < tmpStart) tmpStart = tmpEnd;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: maxSec,
                        builder: (_, i) => Center(child: Text('第${i+1}节',
                          style: TextStyle(
                            color: i + 1 == tmpEnd ? Colors.white : (i + 1 < tmpStart ? const Color(0xFFD1D1D6) : const Color(0xFFC7C7CC)),
                            fontSize: i + 1 == tmpEnd ? 17 : 14,
                            fontWeight: i + 1 == tmpEnd ? FontWeight.w600 : FontWeight.w400,
                          ))),
                      ),
                    )),
                  ])),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        });
      },
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> rows) {
    final ac = _ac(context);
    return Container(
      decoration: BoxDecoration(
        color: ac.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Container(height: 0.5, color: ac.divider, margin: const EdgeInsets.only(left: 16)),
          ],
        ],
      ),
    );
  }

  Widget _buildTextRow(BuildContext context, String label, TextEditingController ctrl, String hint,
      {bool multiline = false, int? maxLength}) {
    final ac = _ac(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(width: 60,
            child: Padding(
              padding: EdgeInsets.only(top: multiline ? 14 : 0),
              child: Text(label, style: TextStyle(color: ac.primaryText, fontSize: 16)),
            )),
          Expanded(
            child: TextField(
              controller: ctrl,
              maxLines: multiline ? 4 : 1,
              maxLength: maxLength,
              style: TextStyle(color: ac.primaryText, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: ac.hint, fontSize: 15),
                border: InputBorder.none,
                counterStyle: TextStyle(color: ac.hint, fontSize: 11),
                contentPadding: EdgeInsets.symmetric(vertical: multiline ? 12 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapRow(BuildContext context, String label, String value, VoidCallback onTap) {
    final ac = _ac(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: ac.primaryText, fontSize: 16)),
            const Spacer(),
            Text(value, style: TextStyle(color: ac.hint, fontSize: 15)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: ac.hint, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final previewColor = _customColor ?? _pickAutoColor(s.courses);
    final ac = _ac(context);

    return Scaffold(
      backgroundColor: ac.bg,
      appBar: AppBar(
        backgroundColor: ac.card,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: _accent, fontSize: 16)),
            ),
            const Spacer(),
            Text(widget.editCourse != null ? '编辑课程' : '添加课程',
                style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 17, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(
              onPressed: _save,
              child: const Text('保存', style: TextStyle(color: _accent, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 基本信息卡 ──
            _buildCard(context, [
              _buildTextRow(context, '课程', _nameCtrl, '必填', maxLength: 20),
              // 颜色行
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text('颜色', style: TextStyle(color: ac.primaryText, fontSize: 16)),
                    const Spacer(),
                    if (_customColor == null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text('自动', style: TextStyle(color: ac.hint, fontSize: 13)),
                      ),
                    GestureDetector(
                      onTap: () => _showColorPicker(s.courses),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: previewColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: ac.divider, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTextRow(context, '学分', _creditCtrl, '选填'),
              _buildTextRow(context, '备注', _noteCtrl, '', multiline: true),
            ]),

            const SizedBox(height: 24),

            // ── 时间段标题 + tab 操作行 ──
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  Text('时间段', style: TextStyle(color: ac.hint, fontSize: 13)),
                  const SizedBox(width: 8),
                  // slot tab 圆点
                  ...List.generate(_slots.length, (i) {
                    final active = i == _activeSlotIdx;
                    return GestureDetector(
                      onTap: () => setState(() => _activeSlotIdx = i),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: active ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? _accent : const Color(0xFFD1D1D6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  // 删除当前 tab（超过1个时显示）
                  if (_slots.length > 1)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _slots.removeAt(_activeSlotIdx);
                          if (_activeSlotIdx >= _slots.length) {
                            _activeSlotIdx = _slots.length - 1;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B5C).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.remove, color: Color(0xFFFF3B5C), size: 13),
                          SizedBox(width: 2),
                          Text('删除', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 12)),
                        ]),
                      ),
                    ),
                  // 复制按钮：克隆当前 slot 新建 tab
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _slots.add(_activeSlot.copyWith());
                        _activeSlotIdx = _slots.length - 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.add, color: _accent, size: 13),
                        SizedBox(width: 2),
                        Text('添加', style: TextStyle(color: _accent, fontSize: 12)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // ── 时间卡（显示当前激活 slot）──
            _buildCard(context, [
              _buildTapRow(context, 
                '周数',
                '第${_activeSlot.startWeek} – ${_activeSlot.endWeek}周',
                _showWeekRangePicker,
              ),
              _buildTapRow(context, 
                '时间',
                '周${kWeekDays[_activeSlot.day - 1]}',
                () => _showPicker<int>(
                  title: '星期',
                  values: List.generate(7, (i) => i + 1),
                  selected: _activeSlot.day,
                  label: (v) => '周${kWeekDays[v - 1]}',
                  onChanged: (v) => _updateActiveSlot(_activeSlot.copyWith(day: v)),
                ),
              ),
              GestureDetector(
                onTap: _showSectionPicker,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Text('节次', style: TextStyle(color: ac.primaryText, fontSize: 16)),
                    const Spacer(),
                    Text('第${_activeSlot.startSection} – ${_activeSlot.endSection}节',
                        style: TextStyle(color: ac.hint, fontSize: 15)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: ac.hint, size: 18),
                  ]),
                ),
              ),
              _buildTextRow(context, '老师', _teacherCtrl, '选填', maxLength: 20),
              _buildTextRow(context, '地点', _locCtrl, '选填', maxLength: 30),
            ]),

            // 多时间段提示
            if (_slots.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8),
                child: Text(
                  '共 ${_slots.length} 个时间段 · 点击圆点切换',
                  style: TextStyle(color: ac.hint, fontSize: 12),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(List<Course> existing) {
    // 生成色相环：12色 × 3饱和度层 = 36色 + 预设色
    final List<Color> palette = [];
    // 第一行：高饱和鲜色
    for (int h = 0; h < 360; h += 30) {
      palette.add(HSVColor.fromAHSV(1, h.toDouble(), 0.75, 0.95).toColor());
    }
    // 第二行：中饱和柔色
    for (int h = 15; h < 360; h += 30) {
      palette.add(HSVColor.fromAHSV(1, h.toDouble(), 0.55, 0.90).toColor());
    }
    // 第三行：低饱和淡色
    for (int h = 0; h < 360; h += 30) {
      palette.add(HSVColor.fromAHSV(1, h.toDouble(), 0.35, 0.95).toColor());
    }
    // 第四行：灰阶 + 深色
    for (int i = 0; i < 12; i++) {
      final v = 0.3 + i * 0.06;
      palette.add(HSVColor.fromAHSV(1, 0, 0, v).toColor());
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        Color? tmpColor = _customColor;
        return StatefulBuilder(builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20,
                MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFD1D1D6),
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('选择颜色',
                        style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
                    // 当前预览色
                    Row(children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: tmpColor ?? _pickAutoColor(existing),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          setState(() => _customColor = tmpColor);
                          Navigator.pop(ctx);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E5EA),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('确定', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 14)),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 14),

                // 自动选色选项
                GestureDetector(
                  onTap: () {
                    setS(() => tmpColor = null);
                    setState(() => _customColor = null);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _customColor == null
                          ? const Color(0xFF4ECDC4).withOpacity(0.15)
                          : const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(8),
                      border: _customColor == null
                          ? Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.4))
                          : null,
                    ),
                    child: Row(children: [
                      Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          gradient: const SweepGradient(colors: [
                            Color(0xFFFF3B5C), Color(0xFFFF9500), Color(0xFFFFD60A),
                            Color(0xFF30D158), Color(0xFF32ADE6), Color(0xFFBF5AF2),
                            Color(0xFFFF3B5C),
                          ]),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('自动选色（不与已有课程冲突）',
                          style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 13)),
                      if (_customColor == null) ...[
                        const Spacer(),
                        const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 16),
                      ],
                    ]),
                  ),
                ),

                // 色盘网格
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 12,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: palette.length,
                  itemBuilder: (_, i) {
                    final c = palette[i];
                    final isSelected = tmpColor?.value == c.value;
                    return GestureDetector(
                      onTap: () => setS(() => tmpColor = c),
                      child: Container(
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: const Color(0xFF1C1C1E), width: 2.5)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 6)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: const Color(0xFF1C1C1E), size: 14)
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }
}


// ═══════════════════════════════════════════════════════════════
// 子页面共用样式常量
// ═══════════════════════════════════════════════════════════════
const Color _kAccent  = Color(0xFFFF3B5C);
const Color _kHint    = Color(0xFF8E8E93); // 中性灰，深浅模式均可读
const Color _kDivider = Color(0xFFD1D1D6); // 用于 const 上下文
// _kBg, _kCard 现由 _ac(context) 动态提供

// 通用子页面脚手架
class _SubPageScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SubPageScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final ac = _ac(context);
    return Scaffold(
      backgroundColor: ac.bg,
      appBar: AppBar(
        backgroundColor: ac.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _kAccent, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: TextStyle(color: ac.primaryText, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}

// 通用卡片行
class _SettingRow extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  const _SettingRow({required this.label, this.trailing, this.onTap, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final ac = _ac(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: ac.primaryText, fontSize: 15)),
          const Spacer(),
          onTap != null
              ? IgnorePointer(child: trailing ?? Icon(Icons.chevron_right, color: ac.hint, size: 18))
              : (trailing ?? Icon(Icons.chevron_right, color: ac.hint, size: 18)),
        ],
      ),
    );
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: row,
        ),
        if (showDivider)
          Container(height: 0.5, color: ac.divider, margin: const EdgeInsets.only(left: 16)),
      ],
    );
  }
}

Widget _settingCard(BuildContext context, List<Widget> rows) => Container(
  margin: const EdgeInsets.only(bottom: 20),
  decoration: BoxDecoration(color: _ac(context).card, borderRadius: BorderRadius.circular(12)),
  child: Column(children: rows),
);

// ─────────────────────────────────────────────
// 上课时间 列表页（入口）
// ─────────────────────────────────────────────

class ClassTimeListPage extends StatefulWidget {
  const ClassTimeListPage({super.key});
  @override
  State<ClassTimeListPage> createState() => _ClassTimeListPageState();
}

class _ClassTimeListPageState extends State<ClassTimeListPage> {
  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final tables = s.allTimeTables;
    final activeIdx = s.activeTimeTableIndex;

    return Scaffold(
      backgroundColor: _ac(context).bg,
      appBar: AppBar(
        backgroundColor: _ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: _kAccent, size: 17),
          ]),
        ),
        leadingWidth: 40,
        title: const Text('上课时间',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _newTimeTable(context, s),
            child: const Text('新建', style: TextStyle(color: _kAccent, fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 当前使用的时间表 ──
          _settingCard(context, [
            _SettingRow(
              label: '当前课表显示的时间表',
              showDivider: false,
              onTap: () => _pickActive(context, s),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(tables[activeIdx].name,
                    style: const TextStyle(color: _kHint, fontSize: 15)),
                const SizedBox(width: 4),
                const Icon(Icons.unfold_more, color: _kHint, size: 16),
              ]),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 16, top: 4),
            child: Text('轻触右侧选择当前使用的时间表',
                style: TextStyle(color: _kHint, fontSize: 12)),
          ),

          // ── 时间表列表 ──
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Row(children: [
              const Text('时间表', style: TextStyle(color: _kHint, fontSize: 12)),
              const Spacer(),
              if (tables.length > 1)
                const Text('条目上左划删除', style: TextStyle(color: _kHint, fontSize: 12)),
            ]),
          ),
          _settingCard(context, 
            List.generate(tables.length, (i) {
              return Dismissible(
                key: ValueKey('tt_$i\_${tables[i].name}'),
                direction: tables.length > 1
                    ? DismissDirection.endToStart
                    : DismissDirection.none,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B5C),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(Icons.delete_outline, color: const Color(0xFF1C1C1E)),
                ),
                confirmDismiss: (_) async {
                  if (tables.length <= 1) return false;
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: _ac(ctx).card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      title: const Text('删除时间表',
                          style: TextStyle(fontSize: 16)),
                      content: Text('确定删除「${tables[i].name}」？',
                          style: const TextStyle(color: _kHint, fontSize: 14)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('取消', style: TextStyle(color: _kHint))),
                        TextButton(onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('删除',
                                style: TextStyle(color: Color(0xFFFF3B5C)))),
                      ],
                    ),
                  ) ?? false;
                },
                onDismissed: (_) => s.deleteTimeTable(i),
                child: _SettingRow(
                  label: tables[i].name,
                  showDivider: i < tables.length - 1,
                  trailing: const Icon(Icons.chevron_right, color: _kHint, size: 18),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ClassTimePage(timeTableIndex: i),
                  )),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _pickActive(BuildContext context, AppState s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('选择时间表',
                  style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            ...List.generate(s.allTimeTables.length, (i) {
              final active = i == s.activeTimeTableIndex;
              return ListTile(
                title: Text(s.allTimeTables[i].name,
                    style: TextStyle(
                        color: active ? _kAccent : Colors.white, fontSize: 16)),
                trailing: active ? const Icon(Icons.check, color: _kAccent) : null,
                onTap: () {
                  s.switchTimeTable(i);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _newTimeTable(BuildContext context, AppState s) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('新建时间表',
            style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: const Color(0xFF1C1C1E)),
          decoration: const InputDecoration(
            hintText: '请输入时间表名称',
            hintStyle: TextStyle(color: _kHint),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4ECDC4))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4ECDC4), width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: _kHint))),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim().isEmpty ? '时间表' : ctrl.text.trim();
              s.addTimeTable(name);
              Navigator.pop(ctx);
            },
            child: const Text('新建', style: TextStyle(color: _kAccent)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 1. 上课时间（仿 WakeUp 风格，固定20节，检查冲突）
// ═══════════════════════════════════════════════════════════════
class ClassTimePage extends StatefulWidget {
  final int timeTableIndex;
  const ClassTimePage({super.key, required this.timeTableIndex});
  @override
  State<ClassTimePage> createState() => _ClassTimePageState();
}

class _ClassTimePageState extends State<ClassTimePage> {
  late List<List<String>> _times;
  bool _sameLength = true;
  int  _duration   = 45;
  late TextEditingController _nameCtrl;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final tt = AppStateScope.of(context).allTimeTables[widget.timeTableIndex];
    _nameCtrl = TextEditingController(text: tt.name);
    _times = List.generate(20, (i) {
      if (i < tt.times.length) return List<String>.from(tt.times[i]);
      return List<String>.from(kDefaultTimes[i]);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _push() {
    final s = AppStateScope.of(context);
    s.updateTimeTable(widget.timeTableIndex, _times.map((t) => List<String>.from(t)).toList());
  }

  void _pushName(String name) {
    AppStateScope.of(context).renameTimeTable(widget.timeTableIndex, name);
  }

  // ── 将 HH:mm 转成分钟数 ──
  int _toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  String _fromMin(int m) {
    final h = m ~/ 60;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

  // ── 检查时间冲突 ──
  void _checkOrder() {
    final List<String> errors = [];
    for (int i = 0; i < _times.length; i++) {
      final s = _toMin(_times[i][0]);
      final e = _toMin(_times[i][1]);
      // 结束 <= 开始
      if (e <= s) {
        errors.add('第 ${i + 1} 节：结束时间不能早于或等于开始时间（${_times[i][0]} – ${_times[i][1]}）');
      }
      // 与下一节重叠
      if (i < _times.length - 1) {
        final nextS = _toMin(_times[i + 1][0]);
        if (e > nextS) {
          errors.add('第 ${i + 1} 节与第 ${i + 2} 节时间重叠\n  第${i+1}节结束 ${_times[i][1]} > 第${i+2}节开始 ${_times[i+1][0]}');
        }
      }
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          Icon(
            errors.isEmpty ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: errors.isEmpty ? const Color(0xFF4ECDC4) : const Color(0xFFFFD60A),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            errors.isEmpty ? '时间顺序正常' : '发现 ${errors.length} 处冲突',
            style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ]),
        content: errors.isEmpty
            ? const Text('所有节次时间区间无冲突，顺序正确。',
                style: TextStyle(color: Color(0xFF6C6C70), fontSize: 14))
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: errors.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFFE5E5EA), height: 16),
                  itemBuilder: (_, i) => Text(
                    errors[i],
                    style: const TextStyle(color: Color(0xFFF07B8A), fontSize: 13, height: 1.5),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // ── 编辑单节时间（弹出选开始+结束）──
  void _editTime(int index) async {
    final sp = _times[index][0].split(':');
    final ep = _times[index][1].split(':');

    final pickedStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(sp[0]), minute: int.parse(sp[1])),
      helpText: '第 ${index + 1} 节  开始时间',
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFF4ECDC4))),
        child: child!,
      ),
    );
    if (!mounted || pickedStart == null) return;

    // 若"每节课时长相同"开启，自动计算结束时间
    String newEnd;
    if (_sameLength) {
      final startMin = pickedStart.hour * 60 + pickedStart.minute;
      newEnd = _fromMin(startMin + _duration);
    } else {
      final pickedEnd = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: int.parse(ep[0]), minute: int.parse(ep[1])),
        helpText: '第 ${index + 1} 节  结束时间',
        builder: (ctx, child) => Theme(
          data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: Color(0xFF4ECDC4))),
          child: child!,
        ),
      );
      if (!mounted || pickedEnd == null) return;
      newEnd = '${pickedEnd.hour.toString().padLeft(2, '0')}:${pickedEnd.minute.toString().padLeft(2, '0')}';
    }

    setState(() {
      _times[index][0] =
          '${pickedStart.hour.toString().padLeft(2, '0')}:${pickedStart.minute.toString().padLeft(2, '0')}';
      _times[index][1] = newEnd;
    });
    _push();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ac(context).bg,
      appBar: AppBar(
        backgroundColor: _ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: _kAccent, size: 17),
            ],
          ),
        ),
        leadingWidth: 40,
        title: const Text(
          '上课时间',
          style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _checkOrder,
            child: const Text('检查时间顺序',
                style: TextStyle(color: _kAccent, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 时间表名称 ──
          _settingCard(context, [
            _SettingRow(
              label: '时间表名称',
              showDivider: false,
              onTap: () => _editName(),
              trailing: Text(
                _nameCtrl.text,
                style: const TextStyle(color: _kHint, fontSize: 15),
              ),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 12),
            child: Text('轻触上方以编辑名称',
                style: TextStyle(color: _kHint, fontSize: 12)),
          ),

          // ── 每节课时长 ──
          _settingCard(context, [
            _SettingRow(
              label: '每节课时长相同',
              trailing: Switch(
                value: _sameLength,
                onChanged: (v) => setState(() => _sameLength = v),
                activeColor: const Color(0xFFFF3B5C),
              ),
            ),
            _SettingRow(
              label: '每节课时长（分钟）',
              showDivider: false,
              onTap: _sameLength ? _pickDuration : null,
              trailing: Text(
                '$_duration',
                style: TextStyle(
                  color: _sameLength ? Colors.white : _kHint,
                  fontSize: 15,
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              _sameLength
                  ? '谨慎调整此项！调整后，将会根据每节课的「上课时间」，\n加上这个时长，来计算并更新「下课时间」，这意味着原来设置的下课时间会被覆盖！'
                  : '调整时间，多余的节数不用管\n如果想修改课表显示的节数，请去「课表设置」中的「每天节次数」',
              style: const TextStyle(color: _kHint, fontSize: 12, height: 1.5),
            ),
          ),

          const SizedBox(height: 8),

          // ── 20节时间列表 ──
          _settingCard(context, 
            List.generate(20, (i) {
              return _SettingRow(
                label: '第 ${i + 1} 节',
                showDivider: i < 19,
                onTap: () => _editTime(i),
                trailing: Text(
                  '${_times[i][0]} - ${_times[i][1]}',
                  style: const TextStyle(color: _kHint, fontSize: 15),
                ),
              );
            }),
          ),

          // ── 重置 ──
          _settingCard(context, [
            _SettingRow(
              label: '重置为默认时间',
              showDivider: false,
              trailing: const SizedBox(),
              onTap: () {
                setState(() {
                  _times = kDefaultTimes
                      .map((t) => List<String>.from(t))
                      .toList();
                });
                _push();
              },
            ),
          ]),
        ],
      ),
    );
  }

  void _editName() {
    final ctrl = TextEditingController(text: _nameCtrl.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('编辑名称', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: const Color(0xFF1C1C1E)),
          decoration: const InputDecoration(
            hintText: '请输入时间表名称',
            hintStyle: TextStyle(color: Color(0xFF6C6C70)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ECDC4))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ECDC4), width: 2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: _kHint))),
          TextButton(
              onPressed: () {
                final newName = ctrl.text.trim().isEmpty ? '时间表' : ctrl.text.trim();
                setState(() => _nameCtrl.text = newName);
                _pushName(newName);
                Navigator.pop(context);
              },
              child: const Text('确定', style: TextStyle(color: _kAccent))),
        ],
      ),
    );
  }

  void _pickDuration() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        int tmp = _duration;
        final options = [30, 35, 40, 45, 50, 55, 60, 75, 90, 100, 120];
        return StatefulBuilder(
          builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消', style: TextStyle(color: _kAccent))),
                const Text('每节课时长（分钟）',
                    style: TextStyle(color: const Color(0xFF1C1C1E), fontWeight: FontWeight.w600, fontSize: 16)),
                TextButton(
                  onPressed: () {
                    // 重新计算所有节的结束时间
                    setState(() {
                      _duration = tmp;
                      for (int i = 0; i < _times.length; i++) {
                        final sMin = _toMin(_times[i][0]);
                        _times[i][1] = _fromMin(sMin + tmp);
                      }
                    });
                    _push();
                    Navigator.pop(ctx);
                  },
                  child: const Text('确定', style: TextStyle(color: _kAccent)),
                ),
              ]),
            ),
            SizedBox(
              height: 200,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                physics: const FixedExtentScrollPhysics(),
                controller: FixedExtentScrollController(
                    initialItem: options.indexOf(_duration).clamp(0, options.length - 1)),
                onSelectedItemChanged: (i) => setS(() => tmp = options[i]),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: options.length,
                  builder: (_, i) => Center(child: Text(
                    '${options[i]} 分钟',
                    style: TextStyle(
                      color: options[i] == tmp ? Colors.white : _kHint,
                      fontSize: options[i] == tmp ? 18 : 15,
                      fontWeight: options[i] == tmp ? FontWeight.w700 : FontWeight.w400,
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. 课表设置 — 三栏入口（课表数据 / 课表外观 / 调课工具）
// ═══════════════════════════════════════════════════════════════
class ScheduleSettingsPage extends StatelessWidget {
  const ScheduleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubPageScaffold(
      title: '课表设置',
      children: [
        _settingCard(context, [
          _SettingRow(
            label: '课表数据',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScheduleDataPage())),
          ),
          _SettingRow(
            label: '课表外观',
            onTap: () => _showComingSoon(context),
          ),
          _SettingRow(
            label: '调课工具',
            showDivider: false,
            onTap: () => _showComingSoon(context),
          ),
        ]),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.lock_outline, color: Color(0xFF6C6C70), size: 20),
          SizedBox(width: 8),
          Text('暂未开放', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        content: const Text(
          '「课表外观」功能正在开发中，敬请期待。',
          style: TextStyle(color: Color(0xFF6C6C70), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2-A. 课表数据
// ─────────────────────────────────────────────
class ScheduleDataPage extends StatefulWidget {
  const ScheduleDataPage({super.key});
  @override
  State<ScheduleDataPage> createState() => _ScheduleDataPageState();
}

class _ScheduleDataPageState extends State<ScheduleDataPage> {
  // 滚轮选数字的通用 bottom sheet
  void _pickNumber(String title, int current, int min, int max, ValueChanged<int> onPick) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        int tmp = current;
        return StatefulBuilder(builder: (ctx, setS) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消', style: TextStyle(color: _kAccent))),
                Text(title, style: const TextStyle(
                    color: const Color(0xFF1C1C1E), fontWeight: FontWeight.w600, fontSize: 16)),
                TextButton(
                    onPressed: () { onPick(tmp); Navigator.pop(ctx); },
                    child: const Text('确定', style: TextStyle(color: _kAccent))),
              ]),
            ),
            SizedBox(
              height: 200,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                physics: const FixedExtentScrollPhysics(),
                controller: FixedExtentScrollController(initialItem: current - min),
                onSelectedItemChanged: (i) => setS(() => tmp = min + i),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: max - min + 1,
                  builder: (_, i) {
                    final v = min + i;
                    return Center(child: Text('$v', style: TextStyle(
                      color: v == tmp ? Colors.white : _kHint,
                      fontSize: v == tmp ? 18 : 15,
                      fontWeight: v == tmp ? FontWeight.w700 : FontWeight.w400,
                    )));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ));
      },
    );
  }

  // 日期选择器
  void _pickDate(DateTime current, ValueChanged<DateTime> onPick) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),

      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF3B5C),
            surface: Color(0xFFFFFFFF),
          ),
          dialogBackgroundColor: const Color(0xFFF2F2F7),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPick(picked);
  }

  // 格式化日期显示
  String _fmtDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  @override
  Widget build(BuildContext context) {
    final s   = AppStateScope.of(context);
    final cfg = s.config;

    // 计算当前周（基于当前课表的第一周日期）
    final now = DateTime.now();
    final diff = now.difference(cfg.firstWeekDay).inDays;
    final autoWeek = (diff ~/ 7 + 1).clamp(1, cfg.totalWeeks);
    final displayWeek = autoWeek;

    return Scaffold(
      backgroundColor: _ac(context).bg,
      appBar: AppBar(
        backgroundColor: _ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: _kAccent, size: 17),
            Text('课表设置', style: TextStyle(color: _kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 100,
        title: const Text('课表数据',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 基本信息卡 ──
          _settingCard(context, [
            _SettingRow(
              label: '课表名称',
              trailing: Text(cfg.name, style: const TextStyle(color: _kHint, fontSize: 15)),
              onTap: () {
                final ctrl = TextEditingController(text: cfg.name);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: _ac(ctx).card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: const Text('修改课表名称',
                        style: TextStyle(fontSize: 16)),
                    content: TextField(
                      controller: ctrl,
                      autofocus: true,
                      style: const TextStyle(color: const Color(0xFF1C1C1E)),
                      decoration: const InputDecoration(
                        hintText: '请输入课表名称',
                        hintStyle: TextStyle(color: _kHint),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: _kAccent)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: _kAccent, width: 2)),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('取消', style: TextStyle(color: _kHint))),
                      TextButton(
                          onPressed: () {
                            final name = ctrl.text.trim();
                            if (name.isNotEmpty) {
                              AppStateScope.of(context).renameSchedule(
                                  AppStateScope.of(context).activeScheduleIndex, name);
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('确定', style: TextStyle(color: _kAccent))),
                    ],
                  ),
                );
              },
            ),
            _SettingRow(
              label: '上课时间',
              showDivider: false,
              onTap: () {
                Navigator.pop(context); // 关闭当前页
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ClassTimeListPage()));
              },
            ),
          ]),

          const SizedBox(height: 20),

          // ── 周次信息卡 ──
          _settingCard(context, [
            _SettingRow(
              label: '第一周的第一天',
              onTap: () => _pickDate(cfg.firstWeekDay,
                  (d) => s.updateActiveConfig(firstWeekDay: d)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_fmtDate(cfg.firstWeekDay),
                    style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 14)),
              ),
            ),
            _SettingRow(
              label: '一周起始天',
              trailing: const Text('Monday', style: TextStyle(color: _kHint, fontSize: 14)),
            ),
            _SettingRow(
              label: '当前周',
              showDivider: false,
              onTap: () => _pickNumber('当前周', displayWeek, 1, cfg.totalWeeks, (v) {}),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('第 $displayWeek 周',
                    style: const TextStyle(color: _kHint, fontSize: 14)),
                const SizedBox(width: 6),
                const Icon(Icons.unfold_more, color: _kHint, size: 18),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 数量卡 ──
          _settingCard(context, [
            _SettingRow(
              label: '一天课程节数',
              onTap: () => _pickNumber('一天课程节数', cfg.sectionsPerDay, 1, 20,
                  (v) => s.updateActiveConfig(sectionsPerDay: v)),
              trailing: Text('${cfg.sectionsPerDay}',
                  style: const TextStyle(color: _kHint, fontSize: 15)),
            ),
            _SettingRow(
              label: '学期周数',
              showDivider: false,
              onTap: () => _pickNumber('学期周数', cfg.totalWeeks, 1, 20,
                  (v) => s.updateActiveConfig(totalWeeks: v)),
              trailing: Text('${cfg.totalWeeks}',
                  style: const TextStyle(color: _kHint, fontSize: 15)),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2-B. 调课工具
// ─────────────────────────────────────────────
class AdjustCoursePage extends StatefulWidget {
  const AdjustCoursePage({super.key});
  @override
  State<AdjustCoursePage> createState() => _AdjustCoursePageState();
}

class _AdjustCoursePageState extends State<AdjustCoursePage> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate   = DateTime.now();

  String _fmtDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPick) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),

      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF3B5C),
            surface: Color(0xFFFFFFFF),
          ),
          dialogBackgroundColor: const Color(0xFFF2F2F7),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPick(picked);
  }

  void _confirm() {
    final s = AppStateScope.of(context);
    // 计算 fromDate 是第几周第几天
    final diff = _fromDate.difference(s.config.firstWeekDay).inDays;
    final fromWeek = diff ~/ 7 + 1;
    final fromDay  = _fromDate.weekday; // 1=周一

    final diff2 = _toDate.difference(s.config.firstWeekDay).inDays;
    final toWeek = diff2 ~/ 7 + 1;
    final toDay  = _toDate.weekday;

    // 将 fromDay 的课程复制到 toDay（同周内交换）
    final newCourses = s.courses.map((c) {
      if (c.weeks.contains(fromWeek) && c.day == fromDay) {
        final newWeeks = c.weeks.toList();
        newWeeks.remove(fromWeek);
        if (!newWeeks.contains(toWeek)) newWeeks.add(toWeek);
        newWeeks.sort();
        return Course(
          id: c.id, name: c.name, location: c.location,
          teacher: c.teacher, credit: c.credit, note: c.note,
          day: c.day == fromDay ? toDay : c.day,
          startSection: c.startSection, span: c.span,
          colorIdx: c.colorIdx, isNonWeek: c.isNonWeek,
          weeks: newWeeks, startWeek: c.startWeek, endWeek: c.endWeek,
        );
      }
      return c;
    }).toList();
    s.replaceCourses(newCourses);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('已将 ${_fmtDate(_fromDate)} 的课程移动到 ${_fmtDate(_toDate)}'),
      backgroundColor: const Color(0xFFE5E5EA),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ac(context).bg,
      appBar: AppBar(
        backgroundColor: _ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: _kAccent, size: 17),
            Text('全局设置', style: TextStyle(color: _kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 100,
        title: const Text('调课工具',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text('确定',
                style: TextStyle(color: _kAccent, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明文字
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 14),
            child: Text(
              '本功能用于节假日调休等场景，可以将某天的课程移动到另一天，请谨慎操作',
              style: TextStyle(color: _kHint, fontSize: 13, height: 1.6),
            ),
          ),

          // ── 选择课表卡 ──
          _settingCard(context, [
            _SettingRow(
              label: '要调整的课表',
              showDivider: false,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('1', style: TextStyle(color: _kHint, fontSize: 15)),
                const SizedBox(width: 4),
                const Icon(Icons.unfold_more, color: _kHint, size: 18),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 日期选择卡 ──
          _settingCard(context, [
            // 将 xxx 的课程
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Text('将', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_fromDate, (d) => setState(() => _fromDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(_fromDate),
                        style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('的课程', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 15)),
              ]),
            ),
            // 分隔线
            Container(height: 0.5, color: const Color(0xFFE5E5EA), margin: const EdgeInsets.only(left: 16)),
            // 移动到 xxx
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Text('移动到', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_toDate, (d) => setState(() => _toDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(_toDate),
                        style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 14)),
                  ),
                ),
              ]),
            ),
          ]),

          const SizedBox(height: 24),

          // 警告提示
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD60A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD60A).withOpacity(0.25)),
            ),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD60A), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '点击「确定」后操作不可撤销，请确认日期选择无误后再执行。',
                  style: TextStyle(color: Color(0xFFFFD60A), fontSize: 13, height: 1.5),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. 已添课程 — 读取 AppState，支持左滑删除
// ═══════════════════════════════════════════════════════════════
class AddedCoursesPage extends StatefulWidget {
  const AddedCoursesPage({super.key});
  @override
  State<AddedCoursesPage> createState() => _AddedCoursesPageState();
}

class _AddedCoursesPageState extends State<AddedCoursesPage> {
  bool _editing = false;
  final Set<int> _selected = {};

  void _toggleEdit() {
    setState(() {
      _editing = !_editing;
      if (!_editing) _selected.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _deleteSelected(AppState s) {
    if (_selected.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('删除课程'),
        content: Text('确定删除已选的 ${_selected.length} 门课程？',
            style: const TextStyle(color: _kHint, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: _kHint))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                for (final id in _selected) s.deleteCourse(id);
                setState(() { _selected.clear(); _editing = false; });
              },
              child: const Text('删除', style: TextStyle(color: Color(0xFFFF3B5C)))),
        ],
      ),
    );
  }

  void _clearAll(AppState s) {
    if (s.courses.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('清空课表'),
        content: Text('确定删除当前课表全部 ${s.courses.length} 门课程？此操作不可恢复。',
            style: const TextStyle(color: _kHint, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: _kHint))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                s.replaceCourses([]);
                setState(() { _selected.clear(); _editing = false; });
              },
              child: const Text('清空', style: TextStyle(color: Color(0xFFFF3B5C)))),
        ],
      ),
    );
  }

  void _addCourse(BuildContext context, AppState s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddCoursePage(onAdd: (_) {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final courses = s.courses;
    final allSelected = courses.isNotEmpty && _selected.length == courses.length;

    return Scaffold(
      backgroundColor: _ac(context).bg,
      appBar: AppBar(
        backgroundColor: _ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: _kAccent, size: 17),
            Text('更多', style: TextStyle(color: _kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 72,
        title: Text(
          _editing
              ? (_selected.isEmpty ? '选择课程' : '已选 ${_selected.length} 门')
              : '已添课程',
          style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _toggleEdit,
            child: Text(
              _editing ? '完成' : '编辑',
              style: const TextStyle(color: _kAccent, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── 课程列表 ──
          ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, _editing ? 80 : 16),
            children: [
              // 统计 + 全选行
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 10),
                child: Row(children: [
                  Text(
                    '共 ${courses.length} 门课程',
                    style: const TextStyle(color: _kHint, fontSize: 13),
                  ),
                  if (_editing && courses.isNotEmpty) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (allSelected) {
                            _selected.clear();
                          } else {
                            _selected.addAll(courses.map((c) => c.id));
                          }
                        });
                      },
                      child: Text(
                        allSelected ? '取消全选' : '全选',
                        style: const TextStyle(color: _kAccent, fontSize: 13),
                      ),
                    ),
                  ] else if (!_editing)
                    const Text('  左滑可删除', style: TextStyle(color: _kHint, fontSize: 13)),
                ]),
              ),

              if (courses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      Icon(Icons.library_books_outlined, color: _kHint, size: 48),
                      SizedBox(height: 12),
                      Text('还没有课程', style: TextStyle(color: _kHint, fontSize: 15)),
                    ]),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: _ac(context).card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: List.generate(courses.length, (i) {
                      final c = courses[i];
                      final color = c.effectiveColor;
                      final isSelected = _selected.contains(c.id);
                      final isLast = i == courses.length - 1;

                      final row = GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _editing
                            ? () => _toggleSelect(c.id)
                            : () {
                                final appState = AppStateScope.of(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (_) => AddCoursePage(
                                      editCourse: c,
                                      onEdit: (updated) => appState.editCourse(updated),
                                    ),
                                  ),
                                );
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          child: Row(children: [
                            // 编辑模式：选择圆圈
                            if (_editing) ...[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFFFF3B5C) : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFF3B5C) : const Color(0xFF6C6C70),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: const Color(0xFF1C1C1E), size: 13)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                            ],
                            // 颜色圆点
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            // 课程名
                            Expanded(
                              child: Text(c.name,
                                  style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 15),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            // 时间信息
                            Text(
                              '周${kWeekDays[c.day - 1]}  第${c.startSection}–${c.startSection + c.span - 1}节',
                              style: const TextStyle(color: _kHint, fontSize: 13),
                            ),
                            if (!_editing) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: _kHint, size: 16),
                            ],
                          ]),
                        ),
                      );

                      if (_editing) {
                        return Column(children: [
                          row,
                          if (!isLast)
                            Container(height: 0.5, color: const Color(0xFFE5E5EA),
                                margin: const EdgeInsets.only(left: 50)),
                        ]);
                      }

                      // 非编辑模式：Dismissible 左滑删除
                      return Column(children: [
                        Dismissible(
                          key: ValueKey(c.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: const Color(0xFFFF3B5C).withOpacity(0.15),
                            child: const Icon(Icons.delete_outline, color: Color(0xFFFF3B5C), size: 22),
                          ),
                          confirmDismiss: (_) async =>
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: _ac(context).card,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  title: const Text('删除课程'),
                                  content: Text('确定删除「${c.name}」？',
                                      style: const TextStyle(color: _kHint)),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('取消', style: TextStyle(color: _kHint))),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('删除',
                                            style: TextStyle(color: Color(0xFFFF3B5C)))),
                                  ],
                                ),
                              ) ?? false,
                          onDismissed: (_) => s.deleteCourse(c.id),
                          child: row,
                        ),
                        if (!isLast)
                          Container(height: 0.5, color: const Color(0xFFE5E5EA),
                              margin: const EdgeInsets.only(left: 32)),
                      ]);
                    }),
                  ),
                ),
            ],
          ),

          // ── 编辑模式底部工具栏 ──
          if (_editing)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                color: const Color(0xFFF2F2F7),
                padding: EdgeInsets.fromLTRB(
                    20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 左：清空当前课表
                    TextButton.icon(
                      onPressed: () => _clearAll(s),
                      icon: const Icon(Icons.delete_sweep_outlined,
                          color: Color(0xFFFF3B5C), size: 18),
                      label: const Text('清空当前课表',
                          style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 14)),
                    ),
                    // 中：删除已选（仅有选中时显示）
                    if (_selected.isNotEmpty)
                      TextButton(
                        onPressed: () => _deleteSelected(s),
                        child: Text(
                          '删除 (${_selected.length})',
                          style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 14),
                        ),
                      ),
                    // 右：添加课程
                    TextButton.icon(
                      onPressed: () => _addCourse(context, s),
                      icon: const Icon(Icons.add_circle_outline,
                          color: _kAccent, size: 18),
                      label: const Text('添加课程',
                          style: TextStyle(color: _kAccent, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════════
// 4. 全局设置
// ═══════════════════════════════════════════════════════════════
class GlobalSettingsPage extends StatefulWidget {
  const GlobalSettingsPage({super.key});
  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  bool _notification = false;
  bool _widgetSync  = false;

  void _showWip(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _ac(ctx).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('功能开发中',
            style: TextStyle(color: _ac(ctx).primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text('该功能正在开发中，敬请期待。',
            style: TextStyle(color: _kHint, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('好的', style: TextStyle(color: _kAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return _SubPageScaffold(
      title: '全局设置',
      children: [
        _settingCard(context, [
          _SettingRow(
            label: '深色模式',
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: (v) => appState.updateDarkMode(v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          _SettingRow(
            label: '课程提醒',
            trailing: Switch(
              value: _notification,
              onChanged: (v) => _showWip(context),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          _SettingRow(
            label: '桌面小组件同步',
            showDivider: false,
            trailing: Switch(
              value: _widgetSync,
              onChanged: (v) => _showWip(context),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
        ]),
        _settingCard(context, [
          _SettingRow(
            label: '设置背景格式',
            showDivider: false,
            onTap: () => _showWip(context),
            trailing: const Icon(Icons.chevron_right, color: _kHint, size: 18),
          ),
        ]),
        _settingCard(context, [
          _SettingRow(
            label: '使用帮助',
            showDivider: false,
            trailing: const Icon(Icons.open_in_new, color: _kHint, size: 16),
            onTap: () async {
              final uri = Uri.parse('https://github.com/Shiroko114514/StayUP-Calendar');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ]),
      ],
    );
  }

}

// ═══════════════════════════════════════════════════════════════
// 5. 导出课表
// ═══════════════════════════════════════════════════════════════
class ExportPage extends StatefulWidget {
  const ExportPage({super.key});
  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _format  = '图片 (PNG)';
  bool _includeNonWeek = false;
  bool _includeSaturday = true;
  bool _includeSunday   = false;

  final List<String> _formats = ['图片 (PNG)', '图片 (JPG)', 'PDF', 'iCalendar (.ics)', 'CSV'];

  @override
  Widget build(BuildContext context) {
    return _SubPageScaffold(
      title: '导出课表',
      children: [
        _settingCard(context, [
          _SettingRow(
            label: '导出格式',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_format, style: const TextStyle(color: _kHint, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: _kHint, size: 18),
            ]),
            onTap: _pickFormat,
          ),
          _SettingRow(
            label: '包含非本周课程',
            trailing: Switch(value: _includeNonWeek, onChanged: (v) => setState(() => _includeNonWeek = v), activeColor: const Color(0xFF4ECDC4)),
          ),
          _SettingRow(
            label: '包含周六',
            trailing: Switch(value: _includeSaturday, onChanged: (v) => setState(() => _includeSaturday = v), activeColor: const Color(0xFF4ECDC4)),
          ),
          _SettingRow(
            label: '包含周日',
            showDivider: false,
            trailing: Switch(value: _includeSunday, onChanged: (v) => setState(() => _includeSunday = v), activeColor: const Color(0xFF4ECDC4)),
          ),
        ]),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('课表已导出为 $_format'),
                  backgroundColor: const Color(0xFFE5E5EA),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('立即导出', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  void _pickFormat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择格式', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._formats.map((f) => GestureDetector(
              onTap: () { setState(() => _format = f); Navigator.pop(context); },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: _kDivider, width: 0.5))),
                child: Row(children: [
                  Text(f, style: TextStyle(
                    color: f == _format ? const Color(0xFF4ECDC4) : Colors.white,
                    fontSize: 15,
                  )),
                  const Spacer(),
                  if (f == _format) const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 18),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 6. 关于
// ═══════════════════════════════════════════════════════════════
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubPageScaffold(
      title: '关于',
      children: [
        // App Logo 区
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  base64Decode('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'),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text('StayUP课程表', style: TextStyle(color: const Color(0xFF1C1C1E), fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('版本 0.0.1 (Beta)', style: TextStyle(color: _kHint, fontSize: 13)),
            ],
          ),
        ),
        _settingCard(context, [
          const _SettingRow(
            label: '版本号',
            trailing: Text('0.0.1 (Beta)', style: TextStyle(color: _kHint, fontSize: 14)),
            showDivider: true,
          ),
          _SettingRow(
            label: '开发者',
            trailing: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Shiroko114514', style: TextStyle(color: _kHint, fontSize: 14)),
              SizedBox(width: 4),
              Icon(Icons.open_in_new, color: _kHint, size: 14),
            ]),
            showDivider: true,
            onTap: () async {
              final uri = Uri.parse('https://github.com/Shiroko114514');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const _SettingRow(
            label: '开源协议',
            trailing: Text('MIT License', style: TextStyle(color: _kHint, fontSize: 14)),
            showDivider: true,
          ),
          const _SettingRow(
            label: '检查更新',
            showDivider: false,
            trailing: Text('已是最新', style: TextStyle(color: Color(0xFF4ECDC4), fontSize: 14)),
          ),
        ]),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '© 2026 Shiroko114514\n因一时兴起而制作的课程表，也希望能陪你走过很多节课',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kHint, fontSize: 12, height: 1.8),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 新建课表页（参考截图1：取消 | 新建课表 | 保存）
// ═══════════════════════════════════════════════════════════════
class NewSchedulePage extends StatefulWidget {
  const NewSchedulePage({super.key});
  @override
  State<NewSchedulePage> createState() => _NewSchedulePageState();
}

class _NewSchedulePageState extends State<NewSchedulePage> {
  final _nameCtrl = TextEditingController();
  DateTime _firstDay = DateTime(DateTime.now().year, 9, 1);
  int _sectionsPerDay = 20;
  int _totalWeeks = 20;

  String _fmtDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF3B5C),
            surface: Color(0xFFFFFFFF),
          ),
          dialogBackgroundColor: const Color(0xFFF2F2F7),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _firstDay = picked);
  }

  void _pickNumber(String title, int current, int min, int max, ValueChanged<int> cb) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ac(context).card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        int tmp = current;
        return StatefulBuilder(builder: (ctx, ss) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消', style: TextStyle(color: _kAccent))),
                Text(title, style: const TextStyle(
                    color: const Color(0xFF1C1C1E), fontWeight: FontWeight.w600, fontSize: 16)),
                TextButton(onPressed: () { cb(tmp); Navigator.pop(ctx); },
                    child: const Text('确定', style: TextStyle(color: _kAccent))),
              ]),
            ),
            SizedBox(
              height: 200,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                physics: const FixedExtentScrollPhysics(),
                controller: FixedExtentScrollController(initialItem: current - min),
                onSelectedItemChanged: (i) => ss(() => tmp = min + i),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: max - min + 1,
                  builder: (_, i) {
                    final v = min + i;
                    return Center(child: Text('$v', style: TextStyle(
                      color: v == tmp ? Colors.white : _kHint,
                      fontSize: v == tmp ? 18 : 15,
                      fontWeight: v == tmp ? FontWeight.w700 : FontWeight.w400,
                    )));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ));
      },
    );
  }

  // 保存时写入 AppState，卡片立即出现
  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('请填写课表名称'),
        backgroundColor: Color(0xFFE5E5EA),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final s = AppStateScope.of(context);
    s.addSchedule(ScheduleConfig(
      name:           name,
      firstWeekDay:   _firstDay,
      sectionsPerDay: _sectionsPerDay,
      totalWeeks:     _totalWeeks,
    ));
    s.switchSchedule(s.allConfigs.length - 1); // 自动切换到新建课表
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _nameCtrl.text.trim().isEmpty;
    return Scaffold(
      backgroundColor: _ac(context).bg,
      appBar: AppBar(
        backgroundColor: _ac(context).card,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: _kAccent, fontSize: 16)),
        ),
        leadingWidth: 64,
        title: const Text('新建课表',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isEmpty ? null : _save,
            child: Text(
              '保存',
              style: TextStyle(
                color: isEmpty ? const Color(0xFFD1D1D6) : const Color(0xFF6C6C70),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 课表名称 ──
          _settingCard(context, [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 15),
                decoration: const InputDecoration(
                  hintText: '课表名称（必填）',
                  hintStyle: TextStyle(color: Color(0xFFD1D1D6), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 周次设置卡 ──
          _settingCard(context, [
            _SettingRow(
              label: '第一周的第一天',
              onTap: _pickDate,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_fmtDate(_firstDay),
                    style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 14)),
              ),
            ),
            const _SettingRow(
              label: '一周起始天',
              trailing: Text('Monday', style: TextStyle(color: _kHint, fontSize: 14)),
            ),
            _SettingRow(
              label: '当前周',
              showDivider: false,
              trailing: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('自动', style: TextStyle(color: _kHint, fontSize: 14)),
                SizedBox(width: 4),
                Icon(Icons.unfold_more, color: _kHint, size: 18),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 数量卡 ──
          _settingCard(context, [
            _SettingRow(
              label: '一天课程节数',
              onTap: () => _pickNumber('一天课程节数', _sectionsPerDay, 1, 20,
                  (v) => setState(() => _sectionsPerDay = v)),
              trailing: Text('$_sectionsPerDay',
                  style: const TextStyle(color: _kHint, fontSize: 15)),
            ),
            _SettingRow(
              label: '学期周数',
              showDivider: false,
              onTap: () => _pickNumber('学期周数', _totalWeeks, 1, 30,
                  (v) => setState(() => _totalWeeks = v)),
              trailing: Text('$_totalWeeks',
                  style: const TextStyle(color: _kHint, fontSize: 15)),
            ),
          ]),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 多课表管理页（参考截图2：返回 | 多课表管理 | 编辑，底部新建课表）
// ═══════════════════════════════════════════════════════════════
class ManageSchedulePage extends StatefulWidget {
  const ManageSchedulePage({super.key});
  @override
  State<ManageSchedulePage> createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final schedules = s.scheduleNames;

    return Scaffold(
      backgroundColor: _ac(context).bg,
      appBar: AppBar(
        backgroundColor: _ac(context).bg,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('返回', style: TextStyle(color: _kAccent, fontSize: 16)),
        ),
        leadingWidth: 60,
        title: const Text('多课表管理',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? '完成' : '编辑',
              style: const TextStyle(color: _kAccent, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 可拖动排序列表
          ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            buildDefaultDragHandles: false,
            onReorder: _isEditing
                ? (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final idxList = List<int>.generate(schedules.length, (i) => i);
                    final item = idxList.removeAt(oldIndex);
                    idxList.insert(newIndex, item);
                    s.reorderSchedules(idxList);
                  }
                : (_, __) {},
            header: const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 10),
              child: Text('点右上角的编辑以排序或删除',
                  style: TextStyle(color: _kHint, fontSize: 13)),
            ),
            itemCount: schedules.length,
            itemBuilder: (ctx, i) {
              final name = schedules[i];
              final isActive = i == s.activeScheduleIndex;
              return _ScheduleListItem(
                key: ValueKey(name + i.toString()),
                name: name,
                isActive: isActive,
                isEditing: _isEditing,
                index: i,
                isLast: i == schedules.length - 1,
                onTap: () {
                  s.switchSchedule(i);
                  if (_isEditing) {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ScheduleDataPage(),
                    ));
                  }
                },
                onDelete: schedules.length > 1
                    ? () => _confirmDelete(ctx, s, i, name)
                    : null,
              );
            },
          ),

          // ── 底部固定「新建课表」按钮 ──
          Positioned(
            bottom: 24,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const NewSchedulePage(),
                ));
                setState(() {}); // 刷新以显示新课表
              },
              child: const Text(
                '新建课表',
                style: TextStyle(
                  color: _kAccent,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AppState s, int i, String name) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('删除课表', style: TextStyle(fontSize: 16)),
        content: Text('确定删除「$name」？此操作不可恢复。',
            style: const TextStyle(color: _kHint, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: _kHint))),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                s.removeSchedule(i);
                setState(() {});
              },
              child: const Text('删除', style: TextStyle(color: Color(0xFFFF3B5C)))),
        ],
      ),
    );
  }
}

// 单行课表条目（编辑/正常模式）
class _ScheduleListItem extends StatelessWidget {
  final String name;
  final bool isActive;
  final bool isEditing;
  final int index;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ScheduleListItem({
    super.key,
    required this.name,
    required this.isActive,
    required this.isEditing,
    required this.index,
    required this.isLast,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 卡片圆角处理
        Container(
          decoration: BoxDecoration(
            color: _ac(context).card,
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(12) : Radius.zero,
              bottom: isLast ? const Radius.circular(12) : Radius.zero,
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isEditing ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(children: [
                // 编辑模式：删除按钮
                if (isEditing) ...[
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: onDelete != null
                            ? const Color(0xFFFF3B5C)
                            : const Color(0xFFD1D1D6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, color: const Color(0xFF1C1C1E), size: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(child: Text(name,
                    style: TextStyle(
                      color: isActive && !isEditing ? const Color(0xFF4ECDC4) : _ac(context).primaryText,
                      fontSize: 16,
                      fontWeight: isActive && !isEditing ? FontWeight.w600 : FontWeight.w400,
                    ))),
                // 激活指示或箭头
                if (isEditing)
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_handle, color: _ac(context).hint, size: 20),
                  )
                else if (isActive)
                  const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 18)
                else
                  Icon(Icons.chevron_right, color: _ac(context).hint, size: 20),
              ]),
            ),
          ),
        ),
        // 最后一项不显示分割线
        if (!isLast)
          Container(
            height: 0.5,
            color: _ac(context).divider,
            margin: EdgeInsets.only(left: isEditing ? 50 : 16),
          ),
      ],
    );
  }
}


// ═══════════════════════════════════════════════════════════════
// 选择学校导入页
// ═══════════════════════════════════════════════════════════════

class SchoolImportPage extends StatefulWidget {
  const SchoolImportPage({super.key});
  @override
  State<SchoolImportPage> createState() => _SchoolImportPageState();
}

class _SchoolImportPageState extends State<SchoolImportPage> {
  // 支持的学校列表（拼音首字母 → 显示名称）
  static const List<Map<String, String>> _allSchools = [
    {'name': '华中科技大学', 'pinyin': 'H'},
    {'name': '江西师范大学', 'pinyin': 'J'},
    {'name': '上海交通大学', 'pinyin': 'S'},
    {'name': '武汉大学',     'pinyin': 'W'},
    {'name': '香港中文大学（深圳）', 'pinyin': 'X'},
    {'name': '中国人民大学', 'pinyin': 'Z'},
  ];

  // 按首字母分组
  static Map<String, List<String>> get _grouped {
    final map = <String, List<String>>{};
    for (final s in _allSchools) {
      final letter = s['pinyin']!;
      map.putIfAbsent(letter, () => []).add(s['name']!);
    }
    return map;
  }

  // 字母索引列表（已排序）
  static List<String> get _letters {
    final keys = _grouped.keys.toList()..sort();
    return keys;
  }

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  String _query = '';

  // 每个字母 section 的 ScrollController key → offset 映射（按索引跳转）
  // 用 GlobalKey 计算各 section 高度
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    for (final l in _letters) {
      _sectionKeys[l] = GlobalKey();
    }
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // 过滤结果
  List<Map<String, String>> get _filtered {
    if (_query.isEmpty) return _allSchools;
    return _allSchools.where((s) => s['name']!.contains(_query)).toList();
  }

  // 按字母分组（过滤后）
  Map<String, List<String>> get _filteredGrouped {
    final map = <String, List<String>>{};
    for (final s in _filtered) {
      final letter = s['pinyin']!;
      map.putIfAbsent(letter, () => []).add(s['name']!);
    }
    return map;
  }

  List<String> get _filteredLetters {
    final keys = _filteredGrouped.keys.toList()..sort();
    return keys;
  }

  // 跳转到某字母 section
  void _jumpToLetter(String letter) {
    final grouped = _filteredGrouped;
    final letters = _filteredLetters;
    if (!letters.contains(letter)) return;
    // 计算该字母前所有 section 的高度偏移量
    // 每个 section = header(36) + items*56
    double offset = 0;
    for (final l in letters) {
      if (l == letter) break;
      final count = grouped[l]!.length;
      offset += 36 + count * 56.0;
    }
    _scrollCtrl.animateTo(
      offset.clamp(0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onSchoolTap(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          const Icon(Icons.school_outlined, color: Color(0xFF6C6C70), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600))),
        ]),
        content: const Text(
          '该学校的课程导入功能正在开发中，敬请期待。',
          style: TextStyle(color: Color(0xFF6C6C70), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _filteredGrouped;
    final letters = _filteredLetters;
    final allLetters = _letters; // 全部字母，用于右侧索引条

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── 顶部搜索栏 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('返回', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: '搜索学校',
                          hintStyle: TextStyle(color: Color(0xFF6C6C70), fontSize: 15),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF6C6C70), size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 提示文字 ──
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                '在搜索框输入学校全称以快速定位',
                style: TextStyle(color: Color(0xFF6C6C70), fontSize: 13),
              ),
            ),

            // ── 列表 + 右侧字母索引条 ──
            Expanded(
              child: Stack(
                children: [
                  // 主列表
                  ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.only(right: 28, bottom: 20),
                    itemCount: letters.fold<int>(0, (sum, l) => sum + 1 + grouped[l]!.length),
                    itemBuilder: (context, index) {
                      // 映射 index → section header 或 item
                      int cursor = 0;
                      for (final letter in letters) {
                        if (index == cursor) {
                          // section header
                          return _SectionHeader(letter: letter);
                        }
                        cursor++;
                        final items = grouped[letter]!;
                        if (index < cursor + items.length) {
                          final itemIdx = index - cursor;
                          final name = items[itemIdx];
                          final isLast = itemIdx == items.length - 1;
                          return _SchoolRow(
                            name: name,
                            showDivider: !isLast,
                            onTap: () => _onSchoolTap(name),
                          );
                        }
                        cursor += items.length;
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // 右侧字母索引条
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _AlphaIndexBar(
                      letters: allLetters,
                      onLetterTap: _jumpToLetter,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section 字母标题 ──
class _SectionHeader extends StatelessWidget {
  final String letter;
  const _SectionHeader({required this.letter});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
    child: Text(letter, style: const TextStyle(color: Color(0xFF6C6C70), fontSize: 13, fontWeight: FontWeight.w600)),
  );
}

// ── 学校行 ──
class _SchoolRow extends StatelessWidget {
  final String name;
  final bool showDivider;
  final VoidCallback onTap;
  const _SchoolRow({required this.name, required this.showDivider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(child: Text(name, style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16))),
                  const Icon(Icons.chevron_right, color: Color(0xFFD1D1D6), size: 20),
                ],
              ),
            ),
            if (showDivider)
              const Divider(height: 1, indent: 16, endIndent: 0, color: Color(0xFFE5E5EA)),
          ],
        ),
      ),
    );
  }
}

// ── 右侧字母索引条 ──
class _AlphaIndexBar extends StatelessWidget {
  final List<String> letters;
  final ValueChanged<String> onLetterTap;
  const _AlphaIndexBar({required this.letters, required this.onLetterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((l) => GestureDetector(
          onTap: () => onLetterTap(l),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              l,
              style: const TextStyle(color: Color(0xFF6C6C70), fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        )).toList(),
      ),
    );
  }
}