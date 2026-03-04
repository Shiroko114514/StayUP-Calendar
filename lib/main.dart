import 'package:flutter/material.dart';

void main() {
  runApp(const WakeUpApp());
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
}

class AppState extends ChangeNotifier {
  List<List<String>> customTimes;

  bool showWeekend;
  bool showNonWeek;
  bool showSection;

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
    required this.customTimes,
    required List<Course> initialCourses,
    this.showWeekend        = true,
    this.showNonWeek        = true,
    this.showSection        = true,
    this.activeScheduleIndex = 0,
    List<ScheduleConfig>? allConfigs,
  }) : allConfigs = allConfigs ?? [
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

  void updateTimes(List<List<String>> times) {
    customTimes = times;
    notifyListeners();
  }

  void updateSettings({bool? showWeekend, bool? showNonWeek, bool? showSection}) {
    if (showWeekend != null) this.showWeekend = showWeekend;
    if (showNonWeek != null) this.showNonWeek = showNonWeek;
    if (showSection != null) this.showSection = showSection;
    notifyListeners();
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
  final Color? customColor; // 任意颜色，优先于 colorIdx
  final bool isNonWeek;
  final List<int> weeks;
  final int startWeek;
  final int endWeek;

  // 实际使用的颜色
  Color get effectiveColor =>
      customColor ?? kCourseColors[colorIdx % kCourseColors.length];

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
  });

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

// ─────────────────────────────────────────────
// 根 App
// ─────────────────────────────────────────────

class WakeUpApp extends StatefulWidget {
  const WakeUpApp({super.key});
  @override
  State<WakeUpApp> createState() => _WakeUpAppState();
}

class _WakeUpAppState extends State<WakeUpApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      customTimes:    kTimeSlots.map((s) => [s.start, s.end]).toList(),
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

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WakeUp 课程表',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4ECDC4)),
          fontFamily: 'PingFang SC',
          useMaterial3: true,
        ),
        home: const SchedulePage(),
      ),
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
                    return visibleForWeek
                        .where((c) =>
                            c.day == day &&
                            section >= c.startSection &&
                            section < c.startSection + c.span)
                        .toList();
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
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => AddCoursePage(
              editCourse: course,
              onEdit: (updated) => AppStateScope.of(context).editCourse(updated),
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
          onAdd: (c) {
            _addCourse(c);
          },
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF2C2C2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: const Row(children: [
                      Icon(Icons.downloading_outlined, color: Color(0xFF8E8E93), size: 20),
                      SizedBox(width: 8),
                      Text('导入功能', style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
                    content: const Text(
                      '「导入功能」正在开发中，敬请期待。',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14, height: 1.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('好的',
                            style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
                      ),
                    ],
                  ),
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
                        right: BorderSide(color: Color(0x10000000)),
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
    final Set<int> rendered = {};
    final List<_CoursePosition> positioned = [];

    for (int sIdx = 0; sIdx < sectionCount; sIdx++) {
      final section = sIdx + 1;
      final cs = getCoursesAt(day, section);
      for (final c in cs) {
        if (c.startSection == section && !rendered.contains(c.id)) {
          rendered.add(c.id);
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
    final color = course.effectiveColor;
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
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              Text(
                course.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
                    color: Colors.white70,
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
        color: Colors.white,
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
                            fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
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
  static const Color _bg     = Color(0xFF2C2C2E);
  static const Color _card   = Color(0xFF3A3A3C);
  static const Color _accent = Color(0xFFFF3B5C);
  static const Color _white  = Colors.white;

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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: const Color(0xFF48484A),
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
                      const Text('周数', style: TextStyle(color: _white, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      // 带数字标签的滑块
                      Row(
                        children: [
                          // 当前周气泡
                          Container(
                            width: 44, height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${_sliderValue.round()}',
                              style: const TextStyle(color: _white, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF636366),
                                inactiveTrackColor: const Color(0xFF48484A),
                                thumbColor: _white,
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
                          const Text('切换课表', style: TextStyle(color: _white, fontSize: 15, fontWeight: FontWeight.w600)),
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
        color: const Color(0xFF2C2C2E),
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
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            width: 72, height: 64,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4ECDC4).withOpacity(0.25) : const Color(0xFF48484A),
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: const Color(0xFF4ECDC4), width: 1.5) : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 24)
                : null,
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
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
        page = const ClassTimePage();
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
        page = const ExportPage();
        break;
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
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52, height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: Icon(tool.icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(height: 6),
          Text(tool.label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 添加/编辑课程全屏页（仿 WakeUp 深色风格）
// ─────────────────────────────────────────────

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
  int _day          = 1;
  int _startSection = 1;
  int _endSection   = 2;   // 直接用结束节，span = end - start + 1
  int _startWeek    = 1;
  int _endWeek      = 18;

  static const Color _bg       = Color(0xFF1C1C1E);
  static const Color _card     = Color(0xFF2C2C2E);
  static const Color _divider  = Color(0xFF3A3A3C);
  static const Color _label    = Color(0xFFFFFFFF);
  static const Color _hint     = Color(0xFF6B6B6D);
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
    _endWeek = cfg.totalWeeks;

    final e = widget.editCourse;
    if (e != null) {
      // 编辑模式：预填所有字段
      _nameCtrl.text    = e.name;
      _creditCtrl.text  = e.credit;
      _noteCtrl.text    = e.note;
      _teacherCtrl.text = e.teacher;
      _locCtrl.text     = e.location;
      _customColor      = e.customColor ?? e.effectiveColor;
      _day              = e.day;
      _startSection     = e.startSection;
      _endSection       = (e.startSection + e.span - 1).clamp(1, cfg.sectionsPerDay);
      _startWeek        = e.startWeek;
      _endWeek          = e.endWeek;
    } else {
      _endSection = (_startSection + 1).clamp(1, cfg.sectionsPerDay);
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
        const SnackBar(content: Text('请填写课程名称'), backgroundColor: Color(0xFF3A3A3C)),
      );
      return;
    }
    final s = AppStateScope.of(context);
    final color = _customColor ?? _pickAutoColor(s.courses);
    final span  = (_endSection - _startSection + 1).clamp(1, 20);
    final weeks = List.generate(_endWeek - _startWeek + 1, (i) => _startWeek + i);
    final course = Course(
      id: widget.editCourse?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: _nameCtrl.text.trim(),
      location: _locCtrl.text.trim(),
      teacher: _teacherCtrl.text.trim(),
      credit: _creditCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
      day: _day,
      startSection: _startSection,
      span: span,
      colorIdx: 0,
      customColor: color,
      weeks: weeks,
      startWeek: _startWeek,
      endWeek: _endWeek,
    );
    if (widget.editCourse != null) {
      widget.onEdit?.call(course);
    } else {
      widget.onAdd?.call(course);
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
      backgroundColor: const Color(0xFF2C2C2E),
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
                decoration: BoxDecoration(color: const Color(0xFF48484A), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
                          color: values[i] == current ? Colors.white : const Color(0xFF6B6B6D),
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
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        int tmpStart = _startWeek, tmpEnd = _endWeek;
        return StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xFF48484A), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                    const Text('周数', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                        onPressed: () {
                          setState(() { _startWeek = tmpStart; _endWeek = tmpEnd; });
                          Navigator.pop(ctx);
                        },
                        child: const Text('确定', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: Column(children: [
                    const Text('开始', style: TextStyle(color: Color(0xFF6B6B6D), fontSize: 12)),
                    SizedBox(height: 200, child: ListWheelScrollView.useDelegate(
                      itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(initialItem: tmpStart - 1),
                      onSelectedItemChanged: (i) => setS(() => tmpStart = i + 1),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 20,
                        builder: (_, i) => Center(child: Text('第${i+1}周',
                          style: TextStyle(
                            color: i + 1 == tmpStart ? Colors.white : const Color(0xFF6B6B6D),
                            fontSize: i + 1 == tmpStart ? 17 : 14,
                            fontWeight: i + 1 == tmpStart ? FontWeight.w600 : FontWeight.w400,
                          ))),
                      ),
                    )),
                  ])),
                  Expanded(child: Column(children: [
                    const Text('结束', style: TextStyle(color: Color(0xFF6B6B6D), fontSize: 12)),
                    SizedBox(height: 200, child: ListWheelScrollView.useDelegate(
                      itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(initialItem: tmpEnd - 1),
                      onSelectedItemChanged: (i) => setS(() => tmpEnd = i + 1),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 20,
                        builder: (_, i) => Center(child: Text('第${i+1}周',
                          style: TextStyle(
                            color: i + 1 == tmpEnd ? Colors.white : const Color(0xFF6B6B6D),
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
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        int tmpStart = _startSection, tmpEnd = _endSection;
        return StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xFF48484A), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                    const Text('选择节次', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                        onPressed: () {
                          // 确保 end >= start
                          final end = tmpEnd < tmpStart ? tmpStart : tmpEnd;
                          setState(() { _startSection = tmpStart; _endSection = end; });
                          Navigator.pop(ctx);
                        },
                        child: const Text('确定', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16))),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: Column(children: [
                    const Text('开始节', style: TextStyle(color: Color(0xFF6B6B6D), fontSize: 12)),
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
                            color: i + 1 == tmpStart ? Colors.white : const Color(0xFF6B6B6D),
                            fontSize: i + 1 == tmpStart ? 17 : 14,
                            fontWeight: i + 1 == tmpStart ? FontWeight.w600 : FontWeight.w400,
                          ))),
                      ),
                    )),
                  ])),
                  Expanded(child: Column(children: [
                    const Text('结束节', style: TextStyle(color: Color(0xFF6B6B6D), fontSize: 12)),
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
                            color: i + 1 == tmpEnd ? Colors.white : (i + 1 < tmpStart ? const Color(0xFF48484A) : const Color(0xFF6B6B6D)),
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

  Widget _buildCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Container(height: 0.5, color: _divider, margin: const EdgeInsets.only(left: 16)),
          ],
        ],
      ),
    );
  }

  Widget _buildTextRow(String label, TextEditingController ctrl, String hint,
      {bool multiline = false, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(width: 60,
            child: Padding(
              padding: EdgeInsets.only(top: multiline ? 14 : 0),
              child: Text(label, style: const TextStyle(color: _label, fontSize: 16)),
            )),
          Expanded(
            child: TextField(
              controller: ctrl,
              maxLines: multiline ? 4 : 1,
              maxLength: maxLength,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _hint, fontSize: 15),
                border: InputBorder.none,
                counterStyle: const TextStyle(color: _hint, fontSize: 11),
                contentPadding: EdgeInsets.symmetric(vertical: multiline ? 12 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: _label, fontSize: 16)),
            const Spacer(),
            Text(value, style: const TextStyle(color: _hint, fontSize: 15)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: _hint, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final previewColor = _customColor ?? _pickAutoColor(s.courses);
    final sectionLabel = '周${kWeekDays[_day - 1]}   第$_startSection – $_endSection节';
    final weekLabel    = '第$_startWeek – $_endWeek周';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
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
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
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
            _buildCard([
              _buildTextRow('课程', _nameCtrl, '必填', maxLength: 20),
              // 颜色行
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Text('颜色', style: TextStyle(color: _label, fontSize: 16)),
                    const Spacer(),
                    if (_customColor == null)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('自动', style: TextStyle(color: _hint, fontSize: 13)),
                      ),
                    GestureDetector(
                      onTap: () => _showColorPicker(s.courses),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: previewColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTextRow('学分', _creditCtrl, '选填'),
              _buildTextRow('备注', _noteCtrl, '', multiline: true),
            ]),

            const SizedBox(height: 24),

            // ── 时间段标题行 ──
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  const Text('时间段', style: TextStyle(color: _hint, fontSize: 13)),
                  const Spacer(),
                  // 复制按钮（暂为空操作）
                  TextButton(onPressed: () {}, child: const Text('复制', style: TextStyle(color: _accent, fontSize: 13))),
                ],
              ),
            ),

            // ── 时间卡 ──
            _buildCard([
              _buildTapRow('周数', weekLabel, _showWeekRangePicker),
              _buildTapRow('时间', sectionLabel, () {
                _showPicker<int>(
                  title: '星期',
                  values: List.generate(7, (i) => i + 1),
                  selected: _day,
                  label: (v) => '周${kWeekDays[v - 1]}',
                  onChanged: (v) => setState(() => _day = v),
                );
              }),
              GestureDetector(
                onTap: _showSectionPicker,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    const Text('节次', style: TextStyle(color: _label, fontSize: 16)),
                    const Spacer(),
                    Text('第$_startSection – $_endSection节',
                        style: const TextStyle(color: _hint, fontSize: 15)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: _hint, size: 18),
                  ]),
                ),
              ),
              _buildTextRow('老师', _teacherCtrl, '选填', maxLength: 20),
              _buildTextRow('地点', _locCtrl, '选填', maxLength: 30),
            ]),

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
      backgroundColor: const Color(0xFF2C2C2E),
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
                        color: const Color(0xFF48484A),
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('选择颜色',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
                          backgroundColor: const Color(0xFF3A3A3C),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('确定', style: TextStyle(color: Colors.white, fontSize: 14)),
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
                          : const Color(0xFF3A3A3C),
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
                          style: TextStyle(color: Colors.white, fontSize: 13)),
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
                              ? Border.all(color: Colors.white, width: 2.5)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 6)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
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
const Color _kBg      = Color(0xFF1C1C1E);
const Color _kCard    = Color(0xFF2C2C2E);
const Color _kDivider = Color(0xFF3A3A3C);
const Color _kAccent  = Color(0xFFFF3B5C);
const Color _kHint    = Color(0xFF8E8E93);

// 通用子页面脚手架
class _SubPageScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SubPageScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _kAccent, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
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
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
                const Spacer(),
                trailing ?? const Icon(Icons.chevron_right, color: _kHint, size: 18),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(height: 0.5, color: _kDivider, margin: const EdgeInsets.only(left: 16)),
      ],
    );
  }
}

Widget _settingCard(List<Widget> rows) => Container(
  margin: const EdgeInsets.only(bottom: 20),
  decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12)),
  child: Column(children: rows),
);

// ═══════════════════════════════════════════════════════════════
// 1. 上课时间（仿 WakeUp 风格，固定20节，检查冲突）
// ═══════════════════════════════════════════════════════════════
class ClassTimePage extends StatefulWidget {
  const ClassTimePage({super.key});
  @override
  State<ClassTimePage> createState() => _ClassTimePageState();
}

class _ClassTimePageState extends State<ClassTimePage> {
  // 本地副本，20节固定
  late List<List<String>> _times;
  bool _sameLength = true;
  int  _duration   = 45; // 每节课时长（分钟）
  final TextEditingController _nameCtrl = TextEditingController(text: '默认时间表');
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final appTimes = AppStateScope.of(context).customTimes;
    // 始终保持20节，不足补默认
    _times = List.generate(20, (i) {
      if (i < appTimes.length) return List<String>.from(appTimes[i]);
      return List<String>.from(kDefaultTimes[i]);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _push() {
    AppStateScope.of(context)
        .updateTimes(_times.map((t) => List<String>.from(t)).toList());
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
        backgroundColor: const Color(0xFF2C2C2E),
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
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ]),
        content: errors.isEmpty
            ? const Text('所有节次时间区间无冲突，顺序正确。',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14))
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: errors.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF3A3A3C), height: 16),
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
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: _kAccent, size: 17),
              Text('上课时间', style: TextStyle(color: _kAccent, fontSize: 15)),
            ],
          ),
        ),
        leadingWidth: 100,
        title: Text(
          _nameCtrl.text,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
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
          _settingCard([
            _SettingRow(
              label: '时间表名称',
              showDivider: false,
              trailing: GestureDetector(
                onTap: () => _editName(),
                child: Text(
                  _nameCtrl.text,
                  style: const TextStyle(color: _kHint, fontSize: 15),
                ),
              ),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 12),
            child: Text('轻触上方以编辑名称',
                style: TextStyle(color: _kHint, fontSize: 12)),
          ),

          // ── 每节课时长 ──
          _settingCard([
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
              trailing: GestureDetector(
                onTap: _sameLength ? _pickDuration : null,
                child: Text(
                  '$_duration',
                  style: TextStyle(
                    color: _sameLength ? Colors.white : _kHint,
                    fontSize: 15,
                  ),
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
          _settingCard(
            List.generate(20, (i) {
              return _SettingRow(
                label: '第 ${i + 1} 节',
                showDivider: i < 19,
                trailing: GestureDetector(
                  onTap: () => _editTime(i),
                  child: Text(
                    '${_times[i][0]} - ${_times[i][1]}',
                    style: const TextStyle(color: _kHint, fontSize: 15),
                  ),
                ),
              );
            }),
          ),

          // ── 重置 ──
          _settingCard([
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
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('编辑名称', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '请输入时间表名称',
            hintStyle: TextStyle(color: Color(0xFF8E8E93)),
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
                setState(() => _nameCtrl.text = ctrl.text.isEmpty ? '默认时间表' : ctrl.text);
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
      backgroundColor: _kCard,
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
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
        _settingCard([
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
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdjustCoursePage())),
          ),
        ]),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.lock_outline, color: Color(0xFF8E8E93), size: 20),
          SizedBox(width: 8),
          Text('暂未开放', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        content: const Text(
          '「课表外观」功能正在开发中，敬请期待。',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14, height: 1.5),
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
      backgroundColor: _kCard,
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
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
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
            surface: Color(0xFF2C2C2E),
          ),
          dialogBackgroundColor: const Color(0xFF1C1C1E),
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
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
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
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 基本信息卡 ──
          _settingCard([
            _SettingRow(
              label: '课表名称',
              trailing: Text(cfg.name, style: const TextStyle(color: _kHint, fontSize: 15)),
            ),
            _SettingRow(
              label: '上课时间',
              showDivider: false,
              onTap: () {
                Navigator.pop(context); // 关闭当前页
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ClassTimePage()));
              },
            ),
          ]),

          const SizedBox(height: 20),

          // ── 周次信息卡 ──
          _settingCard([
            _SettingRow(
              label: '第一周的第一天',
              trailing: GestureDetector(
                onTap: () => _pickDate(cfg.firstWeekDay,
                    (d) => s.updateActiveConfig(firstWeekDay: d)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_fmtDate(cfg.firstWeekDay),
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),
            _SettingRow(
              label: '一周起始天',
              trailing: const Text('Monday', style: TextStyle(color: _kHint, fontSize: 14)),
            ),
            _SettingRow(
              label: '当前周',
              showDivider: false,
              trailing: GestureDetector(
                onTap: () => _pickNumber('当前周', displayWeek, 1, cfg.totalWeeks,
                    (v) {}),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('第 $displayWeek 周',
                      style: const TextStyle(color: _kHint, fontSize: 14)),
                  const SizedBox(width: 6),
                  const Icon(Icons.unfold_more, color: _kHint, size: 18),
                ]),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 数量卡 ──
          _settingCard([
            _SettingRow(
              label: '一天课程节数',
              trailing: GestureDetector(
                onTap: () => _pickNumber('一天课程节数', cfg.sectionsPerDay, 1, 20,
                    (v) => s.updateActiveConfig(sectionsPerDay: v)),
                child: Text('${cfg.sectionsPerDay}',
                    style: const TextStyle(color: _kHint, fontSize: 15)),
              ),
            ),
            _SettingRow(
              label: '学期周数',
              showDivider: false,
              trailing: GestureDetector(
                onTap: () => _pickNumber('学期周数', cfg.totalWeeks, 1, 20,
                    (v) => s.updateActiveConfig(totalWeeks: v)),
                child: Text('${cfg.totalWeeks}',
                    style: const TextStyle(color: _kHint, fontSize: 15)),
              ),
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
            surface: Color(0xFF2C2C2E),
          ),
          dialogBackgroundColor: const Color(0xFF1C1C1E),
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
      backgroundColor: const Color(0xFF3A3A3C),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
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
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
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
          _settingCard([
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
          _settingCard([
            // 将 xxx 的课程
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Text('将', style: TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_fromDate, (d) => setState(() => _fromDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(_fromDate),
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('的课程', style: TextStyle(color: Colors.white, fontSize: 15)),
              ]),
            ),
            // 分隔线
            Container(height: 0.5, color: const Color(0xFF3A3A3C), margin: const EdgeInsets.only(left: 16)),
            // 移动到 xxx
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Text('移动到', style: TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_toDate, (d) => setState(() => _toDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(_toDate),
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
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
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('删除课程', style: TextStyle(color: Colors.white)),
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
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('清空课表', style: TextStyle(color: Colors.white)),
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
        builder: (_) => AddCoursePage(onAdd: (c) => s.addCourse(c)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final courses = s.courses;
    final allSelected = courses.isNotEmpty && _selected.length == courses.length;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
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
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
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
                    color: _kCard,
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
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (_) => AddCoursePage(
                                      editCourse: c,
                                      onEdit: (updated) =>
                                          AppStateScope.of(context).editCourse(updated),
                                    ),
                                  ),
                                ),
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
                                    color: isSelected ? const Color(0xFFFF3B5C) : const Color(0xFF636366),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 13)
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
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
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
                            Container(height: 0.5, color: const Color(0xFF3A3A3C),
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
                                  backgroundColor: _kCard,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  title: const Text('删除课程', style: TextStyle(color: Colors.white)),
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
                          Container(height: 0.5, color: const Color(0xFF3A3A3C),
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
                color: const Color(0xFF1C1C1E),
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
  bool _darkMode    = true;
  bool _notification = false;
  bool _widgetSync  = true;
  String _theme     = '青绿';
  final List<String> _themes = ['青绿', '珊瑚红', '薰衣草', '晴空蓝', '橙黄'];

  @override
  Widget build(BuildContext context) {
    return _SubPageScaffold(
      title: '全局设置',
      children: [
        _settingCard([
          _SettingRow(
            label: '深色模式',
            trailing: Switch(
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          _SettingRow(
            label: '课程提醒',
            trailing: Switch(
              value: _notification,
              onChanged: (v) => setState(() => _notification = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          _SettingRow(
            label: '桌面小组件同步',
            showDivider: false,
            trailing: Switch(
              value: _widgetSync,
              onChanged: (v) => setState(() => _widgetSync = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
        ]),
        _settingCard([
          _SettingRow(
            label: '主题色',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_theme, style: const TextStyle(color: _kHint, fontSize: 14)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: _kHint, size: 18),
              ],
            ),
            onTap: () => _pickTheme(),
          ),
          _SettingRow(
            label: '字体大小',
            showDivider: false,
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('标准', style: TextStyle(color: _kHint, fontSize: 14)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: _kHint, size: 18),
              ],
            ),
          ),
        ]),
        _settingCard([
          _SettingRow(
            label: '清除缓存',
            showDivider: false,
            trailing: const Text('2.3 MB', style: TextStyle(color: _kHint, fontSize: 14)),
            onTap: () {},
          ),
        ]),
      ],
    );
  }

  void _pickTheme() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择主题色', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _themes.map((t) {
                final isSelected = t == _theme;
                return GestureDetector(
                  onTap: () { setState(() => _theme = t); Navigator.pop(context); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4ECDC4).withOpacity(0.2) : const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? Border.all(color: const Color(0xFF4ECDC4)) : null,
                    ),
                    child: Text(t, style: TextStyle(
                      color: isSelected ? const Color(0xFF4ECDC4) : Colors.white70,
                      fontSize: 14,
                    )),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
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
        _settingCard([
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
                  backgroundColor: const Color(0xFF3A3A3C),
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
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择格式', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A5A0)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF4ECDC4).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 16),
              const Text('WakeUp 课程表', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('版本 1.0.0', style: TextStyle(color: _kHint, fontSize: 13)),
            ],
          ),
        ),
        _settingCard([
          _SettingRow(label: '版本号',      trailing: const Text('1.0.0', style: TextStyle(color: _kHint, fontSize: 14)), showDivider: true),
          _SettingRow(label: '开发者',      trailing: const Text('WakeUp Team', style: TextStyle(color: _kHint, fontSize: 14)), showDivider: true),
          _SettingRow(label: '开源协议',    trailing: const Text('MIT', style: TextStyle(color: _kHint, fontSize: 14)), showDivider: true),
          _SettingRow(label: '用户协议',    showDivider: true),
          _SettingRow(label: '隐私政策',    showDivider: true),
          _SettingRow(label: '检查更新',    showDivider: false,
              trailing: const Text('已是最新', style: TextStyle(color: Color(0xFF4ECDC4), fontSize: 14))),
        ]),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '© 2026 WakeUp Team\n用心打造每一天的课程表',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _kHint, fontSize: 12, height: 1.8),
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
            surface: Color(0xFF2C2C2E),
          ),
          dialogBackgroundColor: const Color(0xFF1C1C1E),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _firstDay = picked);
  }

  void _pickNumber(String title, int current, int min, int max, ValueChanged<int> cb) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kCard,
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
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
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
        backgroundColor: Color(0xFF3A3A3C),
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
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: _kAccent, fontSize: 16)),
        ),
        leadingWidth: 64,
        title: const Text('新建课表',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isEmpty ? null : _save,
            child: Text(
              '保存',
              style: TextStyle(
                color: isEmpty ? const Color(0xFF48484A) : const Color(0xFF8E8E93),
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
          _settingCard([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: '课表名称（必填）',
                  hintStyle: TextStyle(color: Color(0xFF48484A), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 周次设置卡 ──
          _settingCard([
            _SettingRow(
              label: '第一周的第一天',
              trailing: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_fmtDate(_firstDay),
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
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
          _settingCard([
            _SettingRow(
              label: '一天课程节数',
              trailing: GestureDetector(
                onTap: () => _pickNumber('一天课程节数', _sectionsPerDay, 1, 20,
                    (v) => setState(() => _sectionsPerDay = v)),
                child: Text('$_sectionsPerDay',
                    style: const TextStyle(color: _kHint, fontSize: 15)),
              ),
            ),
            _SettingRow(
              label: '学期周数',
              showDivider: false,
              trailing: GestureDetector(
                onTap: () => _pickNumber('学期周数', _totalWeeks, 1, 30,
                    (v) => setState(() => _totalWeeks = v)),
                child: Text('$_totalWeeks',
                    style: const TextStyle(color: _kHint, fontSize: 15)),
              ),
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
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('返回', style: TextStyle(color: _kAccent, fontSize: 16)),
        ),
        leadingWidth: 60,
        title: const Text('多课表管理',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
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
                onTap: () {
                  s.switchSchedule(i);
                  Navigator.pop(context);
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
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('删除课表', style: TextStyle(color: Colors.white, fontSize: 16)),
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
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ScheduleListItem({
    super.key,
    required this.name,
    required this.isActive,
    required this.isEditing,
    required this.index,
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
            color: _kCard,
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(12) : Radius.zero,
              bottom: Radius.zero, // 由外部列表控制
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
                            : const Color(0xFF48484A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, color: Colors.white, size: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(child: Text(name,
                    style: TextStyle(
                      color: isActive && !isEditing ? const Color(0xFF4ECDC4) : Colors.white,
                      fontSize: 16,
                      fontWeight: isActive && !isEditing ? FontWeight.w600 : FontWeight.w400,
                    ))),
                // 激活指示或箭头
                if (isEditing)
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: _kHint, size: 20),
                  )
                else if (isActive)
                  const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 18)
                else
                  const Icon(Icons.chevron_right, color: _kHint, size: 20),
              ]),
            ),
          ),
        ),
        Container(
          height: 0.5,
          color: const Color(0xFF3A3A3C),
          margin: EdgeInsets.only(left: isEditing ? 50 : 16),
        ),
      ],
    );
  }
}