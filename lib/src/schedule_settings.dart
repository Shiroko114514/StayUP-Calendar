import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'l10n.dart';
import 'models.dart';
import 'common_widgets.dart';
import 'course_editor.dart';

String _weekdayShort(BuildContext context, int weekday) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final base = DateTime(2020, 1, 6).add(Duration(days: weekday - 1));
  return DateFormat.E(locale).format(base);
}

class ScheduleSettingsPage extends StatelessWidget {
  const ScheduleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: context.l10n.backAction,
      centerTitle: context.l10n.scheduleSettingsTitle,
      children: [
        settingCard(context, [
          SettingRow(
            label: context.l10n.scheduleSettingsDataTitle,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScheduleDataPage())),
          ),
          SettingRow(
            label: context.l10n.scheduleSettingsAppearanceTitle,
            onTap: () => _showComingSoon(context),
          ),
          SettingRow(
            label: context.l10n.scheduleSettingsAdjustToolTitle,
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
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          Icon(Icons.lock_outline, color: ac(context).hint, size: 20),
          SizedBox(width: 8),
          Text(context.l10n.featureInDevelopmentTitle, style: TextStyle(color: ac(context).primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        content: Text(
          context.l10n.featureInDevelopmentMessage,
          style: TextStyle(color: ac(context).hint, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.okAction, style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
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
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (bCtx) {
        int tmp = current;
        return StatefulBuilder(builder: (ctx, setS) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () => Navigator.pop(ctx),
                  child: Text(context.l10n.cancelAction, style: const TextStyle(color: kAccent))),
                Text(title, style: TextStyle(
                    color: ac(context).primaryText, fontWeight: FontWeight.w600, fontSize: 16)),
                TextButton(
                    onPressed: () { onPick(tmp); Navigator.pop(ctx); },
                  child: Text(context.l10n.confirmAction, style: const TextStyle(color: kAccent))),
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
                      color: v == tmp ? ac(ctx).primaryText : ac(ctx).hint,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),

      builder: (ctx, child) => Theme(
        data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: const Color(0xFFFF3B5C),
                  surface: bgColor,
                  surfaceContainerHigh: bgColor,
                  onSurface: const Color(0xFFFFFFFF),
                )
              : ColorScheme.light(
                  primary: const Color(0xFFFF3B5C),
                  surface: bgColor,
                  surfaceContainerHigh: bgColor,
                  onSurface: const Color(0xFF1C1C1E),
                ),
          dialogTheme: DialogThemeData(backgroundColor: bgColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPick(picked);
  }

  // 格式化日期显示
  String _fmtDate(BuildContext context, DateTime d) =>
      DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(d);

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
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
            Text(context.l10n.scheduleSettingsTitle, style: const TextStyle(color: kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 100,
        title: Text(context.l10n.scheduleSettingsDataTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 基本信息卡 ──
          settingCard(context, [
            SettingRow(
              label: context.l10n.scheduleSettingsScheduleNameLabel,
              trailing: Text(cfg.name, style: TextStyle(color: kHint, fontSize: 15)),
              onTap: () {
                final ctrl = TextEditingController(text: cfg.name);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: ac(ctx).card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text(context.l10n.scheduleSettingsRenameTitle,
                      style: const TextStyle(fontSize: 16)),
                    content: TextField(
                      controller: ctrl,
                      autofocus: true,
                      style: TextStyle(color: ac(context).primaryText),
                      decoration: InputDecoration(
                        hintText: context.l10n.scheduleSettingsRenameHint,
                        hintStyle: TextStyle(color: kHint),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kAccent)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kAccent, width: 2)),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(context.l10n.cancelAction, style: TextStyle(color: kHint))),
                      TextButton(
                          onPressed: () {
                            final rawName = ctrl.text.trim();
                            final name = AppState.normalizeScheduleName(rawName);
                            final exceeded = AppState.isScheduleNameExceeded(rawName);
                            Navigator.pop(ctx);
                            if (name.isEmpty) return;
                            if (exceeded) {
                              showDialog(
                                context: context,
                                builder: (warnCtx) => AlertDialog(
                                  backgroundColor: ac(warnCtx).card,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  content: Text(
                                    context.l10n.scheduleNameTruncatedMessage,
                                    style: TextStyle(fontSize: 14, height: 1.5),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        AppStateScope.of(context).renameSchedule(
                                          AppStateScope.of(context)
                                              .activeScheduleIndex,
                                          name,
                                        );
                                        Navigator.pop(warnCtx);
                                      },
                                      child: Text(
                                        context.l10n.confirmAction,
                                        style: const TextStyle(color: kAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            AppStateScope.of(context).renameSchedule(
                              AppStateScope.of(context).activeScheduleIndex,
                              name,
                            );
                          },
                          child: Text(context.l10n.confirmAction, style: const TextStyle(color: kAccent))),
                    ],
                  ),
                );
              },
            ),
            SettingRow(
              label: context.l10n.schedulePageToolClassTime,
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
          settingCard(context, [
            SettingRow(
              label: context.l10n.firstDayOfWeekOne,
              onTap: () => _pickDate(cfg.firstWeekDay,
                  (d) => s.updateActiveConfig(firstWeekDay: d)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ac(context).divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_fmtDate(context, cfg.firstWeekDay),
                    style: TextStyle(color: ac(context).primaryText, fontSize: 14)),
              ),
            ),
            SettingRow(
              label: context.l10n.weekStartDay,
              trailing: Text(context.l10n.mondayLabel, style: TextStyle(color: kHint, fontSize: 14)),
            ),
            SettingRow(
              label: context.l10n.currentWeek,
              showDivider: false,
              onTap: () => _pickNumber(context.l10n.currentWeek, displayWeek, 1, cfg.totalWeeks, (v) {}),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(context.l10n.scheduleSettingsWeekDisplay(displayWeek),
                    style: TextStyle(color: kHint, fontSize: 14)),
                const SizedBox(width: 6),
                Icon(Icons.unfold_more, color: kHint, size: 18),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 数量卡 ──
          settingCard(context, [
            SettingRow(
                label: context.l10n.sectionsPerDay,
                onTap: () => _pickNumber(context.l10n.sectionsPerDay, cfg.sectionsPerDay, 1, 12,
                  (v) => s.updateActiveConfig(sectionsPerDay: v)),
              trailing: Text('${cfg.sectionsPerDay}',
                  style: TextStyle(color: kHint, fontSize: 15)),
            ),
            SettingRow(
                label: context.l10n.totalWeeks,
              showDivider: false,
                onTap: () => _pickNumber(context.l10n.totalWeeks, cfg.totalWeeks, 1, 20,
                  (v) => s.updateActiveConfig(totalWeeks: v)),
              trailing: Text('${cfg.totalWeeks}',
                  style: TextStyle(color: kHint, fontSize: 15)),
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

  String _fmtDate(BuildContext context, DateTime d) =>
      DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(d);

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPick) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),

      builder: (ctx, child) => Theme(
        data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: const Color(0xFFFF3B5C),
                  surface: bgColor,
                  surfaceContainerHigh: bgColor,
                  onSurface: const Color(0xFFFFFFFF),
                )
              : ColorScheme.light(
                  primary: const Color(0xFFFF3B5C),
                  surface: bgColor,
                  surfaceContainerHigh: bgColor,
                  onSurface: const Color(0xFF1C1C1E),
                ),
          dialogTheme: DialogThemeData(backgroundColor: bgColor),
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
    showAppToast(
      context,
      context.l10n.scheduleSettingsMoveCourseToast(
        _fmtDate(context, _fromDate),
        _fmtDate(context, _toDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
            Text(context.l10n.globalSettingsTitle, style: const TextStyle(color: kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 100,
        title: Text(context.l10n.scheduleSettingsAdjustToolTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _confirm,
            child: Text(context.l10n.confirmAction,
                style: const TextStyle(color: kAccent, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明文字
          Padding(
            padding: EdgeInsets.only(left: 2, bottom: 14),
            child: Text(
              context.l10n.scheduleSettingsAdjustDescription,
              style: TextStyle(color: kHint, fontSize: 13, height: 1.6),
            ),
          ),

          // ── 选择课表卡 ──
          settingCard(context, [
            SettingRow(
              label: context.l10n.scheduleSettingsScheduleToAdjustLabel,
              showDivider: false,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('1', style: TextStyle(color: kHint, fontSize: 15)),
                const SizedBox(width: 4),
                Icon(Icons.unfold_more, color: kHint, size: 18),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 日期选择卡 ──
          settingCard(context, [
            // 将 xxx 的课程
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Text(context.l10n.scheduleSettingsMoveFrom, style: TextStyle(color: ac(context).primaryText, fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_fromDate, (d) => setState(() => _fromDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ac(context).divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(context, _fromDate),
                        style: TextStyle(color: ac(context).primaryText, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(context.l10n.scheduleSettingsMoveCoursesSuffix, style: TextStyle(color: ac(context).primaryText, fontSize: 15)),
              ]),
            ),
            // 分隔线
            Container(height: 0.5, color: const Color(0xFFE5E5EA), margin: const EdgeInsets.only(left: 16)),
            // 移动到 xxx
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Text(context.l10n.scheduleSettingsMoveTo, style: TextStyle(color: ac(context).primaryText, fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_toDate, (d) => setState(() => _toDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ac(context).divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(context, _toDate),
                        style: TextStyle(color: ac(context).primaryText, fontSize: 14)),
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
              color: const Color(0xFFFFD60A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD60A).withValues(alpha: 0.25),
              ),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD60A), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.scheduleSettingsAdjustWarning,
                  style: const TextStyle(color: Color(0xFFFFD60A), fontSize: 13, height: 1.5),
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
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(context.l10n.scheduleSettingsDeleteCoursesTitle),
        content: Text(context.l10n.scheduleSettingsDeleteSelectedMessage(_selected.length),
          style: TextStyle(color: kHint, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelAction, style: TextStyle(color: kHint))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                for (final id in _selected) {
                  s.deleteCourse(id);
                }
                showAppToast(context, context.l10n.scheduleSettingsDeleteSelectedSuccess(_selected.length));
                setState(() { _selected.clear(); _editing = false; });
              },
              child: Text(context.l10n.deleteAction, style: const TextStyle(color: Color(0xFFFF3B5C)))),
        ],
      ),
    );
  }

  void _clearAll(AppState s) {
    if (s.courses.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(context.l10n.scheduleSettingsClearScheduleTitle),
        content: Text(context.l10n.scheduleSettingsClearAllMessage(s.courses.length),
            style: TextStyle(color: kHint, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancelAction, style: TextStyle(color: kHint))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                s.replaceCourses([]);
                showAppToast(context, context.l10n.scheduleSettingsClearAllSuccess);
                setState(() { _selected.clear(); _editing = false; });
              },
              child: Text(context.l10n.scheduleSettingsClearScheduleTitle, style: const TextStyle(color: Color(0xFFFF3B5C)))),
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
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
            Text(context.l10n.scheduleSettingsMoreTitle, style: const TextStyle(color: kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 72,
        title: Text(
          _editing
              ? (_selected.isEmpty ? context.l10n.scheduleSettingsSelectCoursesTitle : context.l10n.scheduleSettingsSelectedCount(_selected.length))
              : context.l10n.schedulePageToolAddedCourses,
          style: TextStyle(color: ac(context).primaryText, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _toggleEdit,
            child: Text(
              _editing ? context.l10n.doneAction : context.l10n.editAction,
              style: const TextStyle(color: kAccent, fontSize: 15, fontWeight: FontWeight.w500),
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
                    context.l10n.scheduleSettingsCoursesCount(courses.length),
                    style: TextStyle(color: kHint, fontSize: 13),
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
                        allSelected ? context.l10n.scheduleSettingsUnselectAll : context.l10n.scheduleSettingsSelectAll,
                        style: const TextStyle(color: kAccent, fontSize: 13),
                      ),
                    ),
                  ] else if (!_editing)
                    Text('  ${context.l10n.classTimeSwipeHint}', style: TextStyle(color: kHint, fontSize: 13)),
                ]),
              ),

              if (courses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      Icon(Icons.library_books_outlined, color: kHint, size: 48),
                      const SizedBox(height: 12),
                      Text(context.l10n.scheduleSettingsNoCourses, style: TextStyle(color: kHint, fontSize: 15)),
                    ]),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: ac(context).card,
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
                                    color: isSelected ? const Color(0xFFFF3B5C) : ac(context).hint,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(Icons.check, color: ac(context).primaryText, size: 13)
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
                                  style: TextStyle(color: ac(context).primaryText, fontSize: 15),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            // 时间信息
                            Text(
                              context.l10n.scheduleSettingsCourseTimeItem(
                                _weekdayShort(context, c.day),
                                c.startSection,
                                c.startSection + c.span - 1,
                              ),
                              style: TextStyle(color: kHint, fontSize: 13),
                            ),
                            if (!_editing) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: kHint, size: 16),
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
                            color: const Color(0xFFFF3B5C).withValues(alpha: 0.15),
                            child: const Icon(Icons.delete_outline, color: Color(0xFFFF3B5C), size: 22),
                          ),
                          confirmDismiss: (_) async =>
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: ac(context).card,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  title: Text(context.l10n.schedulePageDeleteCourse),
                                  content: Text(context.l10n.scheduleSettingsDeleteNamedCourseMessage(c.name),
                                      style: TextStyle(color: kHint)),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text(context.l10n.cancelAction, style: TextStyle(color: kHint))),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text(context.l10n.deleteAction,
                                            style: TextStyle(color: Color(0xFFFF3B5C)))),
                                  ],
                                ),
                              ) ?? false,
                          onDismissed: (_) {
                            s.deleteCourse(c.id);
                            showAppToast(context, context.l10n.scheduleSettingsDeleteSuccess);
                          },
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
                color: ac(context).card,
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
                      label: Text(context.l10n.scheduleSettingsClearCurrentSchedule,
                          style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 14)),
                    ),
                    // 中：删除已选（仅有选中时显示）
                    if (_selected.isNotEmpty)
                      TextButton(
                        onPressed: () => _deleteSelected(s),
                        child: Text(
                          context.l10n.scheduleSettingsDeleteSelectedAction(_selected.length),
                          style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 14),
                        ),
                      ),
                    // 右：添加课程
                    TextButton.icon(
                      onPressed: () => _addCourse(context, s),
                      icon: const Icon(Icons.add_circle_outline,
                          color: kAccent, size: 18),
                      label: Text(context.l10n.courseEditorAddTitle,
                          style: const TextStyle(color: kAccent, fontSize: 14)),
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