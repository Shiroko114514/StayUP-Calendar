import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';
import 'common_widgets.dart';
import 'course_editor.dart';

class ScheduleSettingsPage extends StatelessWidget {
  const ScheduleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: '课表设置',
      children: [
        settingCard(context, [
          SettingRow(
            label: '课表数据',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScheduleDataPage())),
          ),
          SettingRow(
            label: '课表外观',
            onTap: () => _showComingSoon(context),
          ),
          SettingRow(
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
        backgroundColor: ac(context).card,
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
      backgroundColor: ac(context).card,
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
                    child: const Text('取消', style: TextStyle(color: kAccent))),
                Text(title, style: const TextStyle(
                    color: const Color(0xFF1C1C1E), fontWeight: FontWeight.w600, fontSize: 16)),
                TextButton(
                    onPressed: () { onPick(tmp); Navigator.pop(ctx); },
                    child: const Text('确定', style: TextStyle(color: kAccent))),
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
                      color: v == tmp ? Colors.white : kHint,
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
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
            Text('课表设置', style: TextStyle(color: kAccent, fontSize: 15)),
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
          settingCard(context, [
            SettingRow(
              label: '课表名称',
              trailing: Text(cfg.name, style: const TextStyle(color: kHint, fontSize: 15)),
              onTap: () {
                final ctrl = TextEditingController(text: cfg.name);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: ac(ctx).card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: const Text('修改课表名称',
                        style: TextStyle(fontSize: 16)),
                    content: TextField(
                      controller: ctrl,
                      autofocus: true,
                      style: const TextStyle(color: const Color(0xFF1C1C1E)),
                      decoration: const InputDecoration(
                        hintText: '请输入课表名称',
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
                          child: const Text('取消', style: TextStyle(color: kHint))),
                      TextButton(
                          onPressed: () {
                            final name = ctrl.text.trim();
                            if (name.isNotEmpty) {
                              AppStateScope.of(context).renameSchedule(
                                  AppStateScope.of(context).activeScheduleIndex, name);
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('确定', style: TextStyle(color: kAccent))),
                    ],
                  ),
                );
              },
            ),
            SettingRow(
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
          settingCard(context, [
            SettingRow(
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
            SettingRow(
              label: '一周起始天',
              trailing: const Text('Monday', style: TextStyle(color: kHint, fontSize: 14)),
            ),
            SettingRow(
              label: '当前周',
              showDivider: false,
              onTap: () => _pickNumber('当前周', displayWeek, 1, cfg.totalWeeks, (v) {}),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('第 $displayWeek 周',
                    style: const TextStyle(color: kHint, fontSize: 14)),
                const SizedBox(width: 6),
                const Icon(Icons.unfold_more, color: kHint, size: 18),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // ── 数量卡 ──
          settingCard(context, [
            SettingRow(
              label: '一天课程节数',
              onTap: () => _pickNumber('一天课程节数', cfg.sectionsPerDay, 1, 20,
                  (v) => s.updateActiveConfig(sectionsPerDay: v)),
              trailing: Text('${cfg.sectionsPerDay}',
                  style: const TextStyle(color: kHint, fontSize: 15)),
            ),
            SettingRow(
              label: '学期周数',
              showDivider: false,
              onTap: () => _pickNumber('学期周数', cfg.totalWeeks, 1, 20,
                  (v) => s.updateActiveConfig(totalWeeks: v)),
              trailing: Text('${cfg.totalWeeks}',
                  style: const TextStyle(color: kHint, fontSize: 15)),
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
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
            Text('全局设置', style: TextStyle(color: kAccent, fontSize: 15)),
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
                style: TextStyle(color: kAccent, fontSize: 15, fontWeight: FontWeight.w500)),
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
              style: TextStyle(color: kHint, fontSize: 13, height: 1.6),
            ),
          ),

          // ── 选择课表卡 ──
          settingCard(context, [
            SettingRow(
              label: '要调整的课表',
              showDivider: false,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('1', style: TextStyle(color: kHint, fontSize: 15)),
                const SizedBox(width: 4),
                const Icon(Icons.unfold_more, color: kHint, size: 18),
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
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('删除课程'),
        content: Text('确定删除已选的 ${_selected.length} 门课程？',
            style: const TextStyle(color: kHint, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: kHint))),
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
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('清空课表'),
        content: Text('确定删除当前课表全部 ${s.courses.length} 门课程？此操作不可恢复。',
            style: const TextStyle(color: kHint, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: kHint))),
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
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
            Text('更多', style: TextStyle(color: kAccent, fontSize: 15)),
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
                    '共 ${courses.length} 门课程',
                    style: const TextStyle(color: kHint, fontSize: 13),
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
                        style: const TextStyle(color: kAccent, fontSize: 13),
                      ),
                    ),
                  ] else if (!_editing)
                    const Text('  左滑可删除', style: TextStyle(color: kHint, fontSize: 13)),
                ]),
              ),

              if (courses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      Icon(Icons.library_books_outlined, color: kHint, size: 48),
                      SizedBox(height: 12),
                      Text('还没有课程', style: TextStyle(color: kHint, fontSize: 15)),
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
                              style: const TextStyle(color: kHint, fontSize: 13),
                            ),
                            if (!_editing) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: kHint, size: 16),
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
                                  backgroundColor: ac(context).card,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  title: const Text('删除课程'),
                                  content: Text('确定删除「${c.name}」？',
                                      style: const TextStyle(color: kHint)),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('取消', style: TextStyle(color: kHint))),
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
                          color: kAccent, size: 18),
                      label: const Text('添加课程',
                          style: TextStyle(color: kAccent, fontSize: 14)),
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
