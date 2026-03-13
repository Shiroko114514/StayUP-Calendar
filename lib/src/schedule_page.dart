import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'common_widgets.dart';
import 'course_editor.dart';
import 'schedule_settings.dart';
import 'app_pages.dart';
import 'l10n.dart';

String _weekdayShort(BuildContext context, int weekday) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final base = DateTime(2020, 1, 6).add(Duration(days: weekday - 1));
  return DateFormat.E(locale).format(base);
}

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

    final weekDayStr = _weekdayShort(context, todayCol);
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
                    context.l10n.schedulePageCurrentWeek(currentWeek),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(width: 6),
                  if (isThisWeek)
                    Text(
                      context.l10n.schedulePageToday,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF07B8A).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.l10n.schedulePageNotCurrentWeek,
                        style: const TextStyle(
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
                    'M',
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
                      _weekdayShort(context, col),
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
                Text(
                  context.l10n.schedulePageCourseNotCurrentWeekTag,
                  style: TextStyle(
                    fontSize: 7,
                    color: ac(context).hint,
                  ),
                  textAlign: TextAlign.center,
                ),
              Text(
                course.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ac(context).primaryText,
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
                  style: TextStyle(
                    fontSize: 8,
                    color: ac(context).hint,
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
      decoration: BoxDecoration(
        color: ac(context).primaryText,
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
                        context.l10n.schedulePageCourseTime(
                          _weekdayShort(context, course.day),
                          course.startSection,
                          course.startSection + course.span - 1,
                        ),
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
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined, size: 15, color: Color(0xFF555555)),
                    SizedBox(width: 4),
                    Text(context.l10n.editAction, style: const TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
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
                child: Text(context.l10n.schedulePageDeleteCourse,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
                child: Text(context.l10n.schedulePageClose,
                  style: const TextStyle(fontSize: 15)),
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
  @override
  Widget build(BuildContext context) {
    final colors = ac(context);
    final tools = [
      _MenuTool(icon: Icons.access_time_outlined, label: context.l10n.schedulePageToolClassTime, route: 'class_time'),
      _MenuTool(icon: Icons.tune_outlined, label: context.l10n.schedulePageToolScheduleSettings, route: 'schedule_settings'),
      _MenuTool(icon: Icons.inbox_outlined, label: context.l10n.schedulePageToolAddedCourses, route: 'added_courses'),
      _MenuTool(icon: Icons.settings_outlined, label: context.l10n.globalSettingsTitle, route: 'global_settings'),
      _MenuTool(icon: Icons.ios_share_outlined, label: context.l10n.exportScheduleTitle, route: 'export'),
      _MenuTool(icon: Icons.info_outline, label: context.l10n.aboutTitle, route: 'about'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
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
                    color: colors.divider,
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
                      Text(context.l10n.schedulePageWeekLabel, style: TextStyle(color: colors.primaryText, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      // 带数字标签的滑块
                      Row(
                        children: [
                          // 当前周气泡
                          Container(
                            width: 44, height: 28,
                            decoration: BoxDecoration(
                              color: colors.divider,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${_sliderValue.round()}',
                              style: TextStyle(color: colors.primaryText, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF4ECDC4),
                                inactiveTrackColor: colors.divider,
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
                          Text(context.l10n.schedulePageSwitchSchedule, style: TextStyle(color: colors.primaryText, fontSize: 15, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (_) => const NewSchedulePage(),
                              ));
                            },
                            child: Text('${context.l10n.newScheduleButton}  ', style: const TextStyle(color: _accent, fontSize: 13)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const ManageSchedulePage(),
                              ));
                            },
                            child: Text(context.l10n.manageScheduleTitle, style: const TextStyle(color: _accent, fontSize: 13)),
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
                    children: tools.map((t) => _ToolCell(tool: t)).toList(),
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
        color: ac(context).card,
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
    final colors = ac(context);
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            width: 72, height: 64,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4ECDC4).withOpacity(0.25) : colors.divider,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: const Color(0xFF4ECDC4), width: 1.5) : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 24)
                : null,
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: colors.secondaryText, fontSize: 11), textAlign: TextAlign.center),
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
              backgroundColor: ac(ctx).card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Row(children: [
                Icon(Icons.ios_share_outlined, color: Color(0xFF6C6C70), size: 20),
                SizedBox(width: 8),
                Text(ctx.l10n.exportScheduleTitle, style: const TextStyle(
                    color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
              content: Text(
                ctx.l10n.featureInDevelopmentMessage,
                style: const TextStyle(color: Color(0xFF6C6C70), fontSize: 14, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(ctx.l10n.okAction,
                      style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
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
    final colors = ac(context);
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: colors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(tool.icon, color: colors.secondaryText, size: 24),
          ),
          const SizedBox(height: 6),
          Text(tool.label, style: TextStyle(color: colors.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 添加/编辑课程全屏页（仿 WakeUp 深色风格）
// ─────────────────────────────────────────────