import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'common_widgets.dart';
import 'course_editor.dart';

String _t(BuildContext context, String zh, String en, {String? ja}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'zh') return zh;
  if (code == 'ja') return ja ?? en;
  return en;
}

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
      title: _t(context, '返回', 'Back', ja: '戻る'),
      centerTitle: _t(context, '课表设置', 'Schedule Settings', ja: '時間割設定'),
      children: [
        settingCard(context, [
          SettingRow(
            label: _t(context, '课表数据', 'Schedule Data', ja: '時間割データ'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScheduleDataPage())),
          ),
          SettingRow(
            label: _t(context, '课表外观', 'Schedule Appearance', ja: '時間割の外観'),
            onTap: () => _showComingSoon(context),
          ),
          SettingRow(
            label: _t(context, '调课工具', 'Adjust Tool', ja: '振替ツール'),
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
          Icon(Icons.lock_outline, color: Color(0xFF6C6C70), size: 20),
          SizedBox(width: 8),
          Text(_t(context, '暂未开放', 'Coming Soon', ja: '近日公開'), style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        content: Text(
          _t(context, '「课表外观」功能正在开发中，敬请期待。', 'This feature is currently under development.', ja: 'この機能は現在開発中です。'),
          style: const TextStyle(color: Color(0xFF6C6C70), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t(context, '好的', 'OK', ja: 'OK'), style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
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
                  child: Text(_t(context, '取消', 'Cancel', ja: 'キャンセル'), style: const TextStyle(color: kAccent))),
                Text(title, style: const TextStyle(
                    color: const Color(0xFF1C1C1E), fontWeight: FontWeight.w600, fontSize: 16)),
                TextButton(
                    onPressed: () { onPick(tmp); Navigator.pop(ctx); },
                  child: Text(_t(context, '确定', 'Confirm', ja: '確認'), style: const TextStyle(color: kAccent))),
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
            Text(_t(context, '课表设置', 'Settings', ja: '設定'), style: const TextStyle(color: kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 100,
        title: Text(_t(context, '课表数据', 'Schedule Data', ja: '時間割データ'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 基本信息卡 ──
          settingCard(context, [
            SettingRow(
              label: _t(context, '课表名称', 'Schedule Name', ja: '時間割名'),
              trailing: Text(cfg.name, style: const TextStyle(color: kHint, fontSize: 15)),
              onTap: () {
                final ctrl = TextEditingController(text: cfg.name);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: ac(ctx).card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text(_t(context, '修改课表名称', 'Rename Schedule', ja: '時間割名を変更'),
                      style: const TextStyle(fontSize: 16)),
                    content: TextField(
                      controller: ctrl,
                      autofocus: true,
                      style: const TextStyle(color: const Color(0xFF1C1C1E)),
                      decoration: InputDecoration(
                        hintText: _t(context, '请输入课表名称', 'Enter schedule name', ja: '時間割名を入力してください'),
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
                          child: Text(_t(context, '取消', 'Cancel', ja: 'キャンセル'), style: const TextStyle(color: kHint))),
                      TextButton(
                          onPressed: () {
                            final name = ctrl.text.trim();
                            if (name.isNotEmpty) {
                              AppStateScope.of(context).renameSchedule(
                                  AppStateScope.of(context).activeScheduleIndex, name);
                            }
                            Navigator.pop(ctx);
                          },
                          child: Text(_t(context, '确定', 'Confirm', ja: '確認'), style: const TextStyle(color: kAccent))),
                    ],
                  ),
                );
              },
            ),
            SettingRow(
              label: _t(context, '上课时间', 'Class Time', ja: '授業時間'),
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
              label: _t(context, '第一周的第一天', 'First day of week 1', ja: '第1週の初日'),
              onTap: () => _pickDate(cfg.firstWeekDay,
                  (d) => s.updateActiveConfig(firstWeekDay: d)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_fmtDate(context, cfg.firstWeekDay),
                    style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 14)),
              ),
            ),
            SettingRow(
              label: _t(context, '一周起始天', 'Week starts on', ja: '週の開始曜日'),
              trailing: Text(_t(context, '周一', 'Monday', ja: '月曜日'), style: const TextStyle(color: kHint, fontSize: 14)),
            ),
            SettingRow(
              label: _t(context, '当前周', 'Current week', ja: '現在の週'),
              showDivider: false,
              onTap: () => _pickNumber(_t(context, '当前周', 'Current week', ja: '現在の週'), displayWeek, 1, cfg.totalWeeks, (v) {}),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_t(context, '第 $displayWeek 周', 'Week $displayWeek', ja: '第$displayWeek週'),
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
                label: _t(context, '一天课程节数', 'Sections per day', ja: '1日の授業数'),
                onTap: () => _pickNumber(_t(context, '一天课程节数', 'Sections per day', ja: '1日の授業数'), cfg.sectionsPerDay, 1, 20,
                  (v) => s.updateActiveConfig(sectionsPerDay: v)),
              trailing: Text('${cfg.sectionsPerDay}',
                  style: const TextStyle(color: kHint, fontSize: 15)),
            ),
            SettingRow(
                label: _t(context, '学期周数', 'Total weeks', ja: '学期週数'),
              showDivider: false,
                onTap: () => _pickNumber(_t(context, '学期周数', 'Total weeks', ja: '学期週数'), cfg.totalWeeks, 1, 20,
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

  String _fmtDate(BuildContext context, DateTime d) =>
      DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(d);

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
      content: Text(_t(context, '已将 ${_fmtDate(context, _fromDate)} 的课程移动到 ${_fmtDate(context, _toDate)}', 'Moved courses from ${_fmtDate(context, _fromDate)} to ${_fmtDate(context, _toDate)}', ja: '${_fmtDate(context, _fromDate)} から ${_fmtDate(context, _toDate)} に授業を移動しました')),
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
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
            Text(_t(context, '全局设置', 'Global Settings', ja: '全体設定'), style: const TextStyle(color: kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 100,
        title: Text(_t(context, '调课工具', 'Adjust Tool', ja: '振替ツール'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _confirm,
            child: Text(_t(context, '确定', 'Confirm', ja: '確認'),
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
              _t(context, '本功能用于节假日调休等场景，可以将某天的课程移动到另一天，请谨慎操作', 'Move courses from one date to another for schedule adjustment. Please use carefully.', ja: '振替休日などの調整用に、ある日の授業を別の日に移動できます。慎重に操作してください。'),
              style: const TextStyle(color: kHint, fontSize: 13, height: 1.6),
            ),
          ),

          // ── 选择课表卡 ──
          settingCard(context, [
            SettingRow(
              label: _t(context, '要调整的课表', 'Schedule to adjust', ja: '調整対象の時間割'),
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
                Text(_t(context, '将', 'From', ja: '移動元'), style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_fromDate, (d) => setState(() => _fromDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(context, _fromDate),
                        style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(_t(context, '的课程', 'courses', ja: 'の授業'), style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15)),
              ]),
            ),
            // 分隔线
            Container(height: 0.5, color: const Color(0xFFE5E5EA), margin: const EdgeInsets.only(left: 16)),
            // 移动到 xxx
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Text(_t(context, '移动到', 'Move to', ja: '移動先'), style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickDate(_toDate, (d) => setState(() => _toDate = d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(context, _toDate),
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
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD60A), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t(context, '点击「确定」后操作不可撤销，请确认日期选择无误后再执行。', 'This action cannot be undone. Please confirm the selected dates before continuing.', ja: 'この操作は取り消せません。実行前に日付を確認してください。'),
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
        title: Text(_t(context, '删除课程', 'Delete Courses', ja: '授業を削除')),
        content: Text(_t(context, '确定删除已选的 ${_selected.length} 门课程？', 'Delete ${_selected.length} selected courses?', ja: '選択した${_selected.length}件の授業を削除しますか？'),
          style: const TextStyle(color: kHint, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
            child: Text(_t(context, '取消', 'Cancel', ja: 'キャンセル'), style: const TextStyle(color: kHint))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                for (final id in _selected) s.deleteCourse(id);
                setState(() { _selected.clear(); _editing = false; });
              },
              child: Text(_t(context, '删除', 'Delete', ja: '削除'), style: const TextStyle(color: Color(0xFFFF3B5C)))),
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
        title: Text(_t(context, '清空课表', 'Clear Schedule', ja: '時間割をクリア')),
        content: Text(_t(context, '确定删除当前课表全部 ${s.courses.length} 门课程？此操作不可恢复。', 'Delete all ${s.courses.length} courses in this schedule? This cannot be undone.', ja: 'この時間割の${s.courses.length}件の授業をすべて削除しますか？この操作は取り消せません。'),
            style: const TextStyle(color: kHint, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t(context, '取消', 'Cancel', ja: 'キャンセル'), style: const TextStyle(color: kHint))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                s.replaceCourses([]);
                setState(() { _selected.clear(); _editing = false; });
              },
              child: Text(_t(context, '清空', 'Clear', ja: 'クリア'), style: const TextStyle(color: Color(0xFFFF3B5C)))),
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
            Text(_t(context, '更多', 'More', ja: 'その他'), style: const TextStyle(color: kAccent, fontSize: 15)),
          ]),
        ),
        leadingWidth: 72,
        title: Text(
          _editing
              ? (_selected.isEmpty ? _t(context, '选择课程', 'Select Courses', ja: '授業を選択') : _t(context, '已选 ${_selected.length} 门', '${_selected.length} selected', ja: '${_selected.length}件選択中'))
              : _t(context, '已添课程', 'Added Courses', ja: '追加済み授業'),
          style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _toggleEdit,
            child: Text(
              _editing ? _t(context, '完成', 'Done', ja: '完了') : _t(context, '编辑', 'Edit', ja: '編集'),
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
                    _t(context, '共 ${courses.length} 门课程', '${courses.length} courses', ja: '${courses.length}件の授業'),
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
                        allSelected ? _t(context, '取消全选', 'Unselect All', ja: '全選択解除') : _t(context, '全选', 'Select All', ja: 'すべて選択'),
                        style: const TextStyle(color: kAccent, fontSize: 13),
                      ),
                    ),
                  ] else if (!_editing)
                    Text(_t(context, '  左滑可删除', '  Swipe left to delete', ja: '  左スワイプで削除'), style: const TextStyle(color: kHint, fontSize: 13)),
                ]),
              ),

              if (courses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      const Icon(Icons.library_books_outlined, color: kHint, size: 48),
                      const SizedBox(height: 12),
                      Text(_t(context, '还没有课程', 'No courses yet', ja: '授業がありません'), style: const TextStyle(color: kHint, fontSize: 15)),
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
                              _t(context, '周${_weekdayShort(context, c.day)}  第${c.startSection}–${c.startSection + c.span - 1}节', '${_weekdayShort(context, c.day)}  ${c.startSection}-${c.startSection + c.span - 1}', ja: '${_weekdayShort(context, c.day)}  ${c.startSection}-${c.startSection + c.span - 1}限'),
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