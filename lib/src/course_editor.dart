import 'package:flutter/material.dart';
import 'l10n.dart';
import 'models.dart';
import 'common_widgets.dart';

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

  Color? _customColor;   // null = 随机自动
  bool   _initialized = false;

  // ── 多时间段 ──
  late List<CourseSlot> _slots;
  // 每个时间段独立的老师/地点控制器
  late List<TextEditingController> _teacherCtrls;
  late List<TextEditingController> _locCtrls;

  void _updateSlot(int idx, CourseSlot s) => setState(() => _slots[idx] = s);

  static const Color _accent   = Color(0xFFFF3B5C);

  String _weekdayLabel(BuildContext context, int day) {
    switch (day) {
      case 1:
        return context.l10n.courseEditorWeekdayMon;
      case 2:
        return context.l10n.courseEditorWeekdayTue;
      case 3:
        return context.l10n.courseEditorWeekdayWed;
      case 4:
        return context.l10n.courseEditorWeekdayThu;
      case 5:
        return context.l10n.courseEditorWeekdayFri;
      case 6:
        return context.l10n.courseEditorWeekdaySat;
      case 7:
        return context.l10n.courseEditorWeekdaySun;
      default:
        return context.l10n.courseEditorWeekdayMon;
    }
  }

  String _weekNthLabel(BuildContext context, int week) {
    return context.l10n.courseEditorWeekNthLabel(week);
  }

  String _sectionNthLabel(BuildContext context, int section) {
    return context.l10n.courseEditorSectionNthLabel(section);
  }

  // 自动选一个与已有课程不冲突的颜色
  Color _pickAutoColor(List<Course> existing) {
    final usedColors = existing
        .map((c) => c.effectiveColor.toARGB32())
        .toSet();
    for (final c in kCourseColors) {
      if (!usedColors.contains(c.toARGB32())) return c;
    }
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
      _nameCtrl.text   = e.name;
      _creditCtrl.text = e.credit;
      _noteCtrl.text   = e.note;
      _customColor     = e.customColor ?? e.effectiveColor;

      // 主时间段
      final primarySlot = CourseSlot(
        day: e.day,
        startSection: e.startSection,
        endSection: (e.startSection + e.span - 1).clamp(1, cfg.sectionsPerDay),
        startWeek: e.startWeek,
        endWeek: e.endWeek,
      );
      // 附加时间段
      final extraSlots = e.extraSlots.map((s) => CourseSlot(
        day: s.day,
        startSection: s.startSection,
        endSection: s.endSection,
        startWeek: s.startWeek,
        endWeek: s.endWeek,
      )).toList();

      _slots = [primarySlot, ...extraSlots];

      // 老师/地点：主时间段用课程本身，附加时间段暂用相同值
      _teacherCtrls = List.generate(_slots.length,
          (i) => TextEditingController(text: e.teacher));
      _locCtrls = List.generate(_slots.length,
          (i) => TextEditingController(text: e.location));
    } else {
      _slots = [
        CourseSlot(
          day: 1,
          startSection: 1,
          endSection: 2.clamp(1, cfg.sectionsPerDay),
          startWeek: 1,
          endWeek: cfg.totalWeeks,
        ),
      ];
      _teacherCtrls = [TextEditingController()];
      _locCtrls     = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _creditCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _teacherCtrls) {
      c.dispose();
    }
    for (final c in _locCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // 添加一个新时间段（复制最后一个 slot，并新建独立的控制器）
  void _addSlot() {
    setState(() {
      _slots.add(_slots.last.copyWith());
      _teacherCtrls.add(TextEditingController(text: _teacherCtrls.last.text));
      _locCtrls.add(TextEditingController(text: _locCtrls.last.text));
    });
  }

  // 删除指定时间段
  void _removeSlot(int idx) {
    setState(() {
      _slots.removeAt(idx);
      _teacherCtrls[idx].dispose();
      _teacherCtrls.removeAt(idx);
      _locCtrls[idx].dispose();
      _locCtrls.removeAt(idx);
    });
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      showAppToast(
        context,
        context.l10n.courseEditorNameRequired,
      );
      return;
    }
    final appState = AppStateScope.of(context);
    final color    = _customColor ?? _pickAutoColor(appState.courses);
    final primary  = _slots[0];
    final extras   = _slots.length > 1
        ? _slots.sublist(1).map((s) => CourseSlot(
              day: s.day,
              startSection: s.startSection,
              endSection: s.endSection,
              startWeek: s.startWeek,
              endWeek: s.endWeek,
            )).toList()
        : <CourseSlot>[];

    final course = Course(
      id:           widget.editCourse?.id ?? DateTime.now().millisecondsSinceEpoch,
      name:         _nameCtrl.text.trim(),
      location:     _locCtrls[0].text.trim(),
      teacher:      _teacherCtrls[0].text.trim(),
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
      showAppToast(context, context.l10n.courseEditorEditSuccess);
    } else {
      appState.addCourse(course);
      showAppToast(context, context.l10n.courseEditorAddSuccess);
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
      backgroundColor: ac(context).card,
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
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: ac(context).divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(context.l10n.cancelAction,
                          style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
                    Text(title,
                        style: TextStyle(
                            color: ac(context).primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        onChanged(current);
                        Navigator.pop(ctx);
                      },
                      child: Text(context.l10n.confirmAction,
                          style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
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
                  controller: FixedExtentScrollController(
                      initialItem: values.indexOf(selected)),
                  onSelectedItemChanged: (i) => setS(() => current = values[i]),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: values.length,
                    builder: (_, i) => Center(
                      child: Text(
                        label(values[i]),
                        style: TextStyle(
                          color: values[i] == current
                              ? ac(context).primaryText
                              : ac(context).hint,
                          fontSize: values[i] == current ? 18 : 15,
                          fontWeight: values[i] == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
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
  void _showWeekRangePicker(int slotIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        int tmpStart = _slots[slotIndex].startWeek;
        int tmpEnd   = _slots[slotIndex].endWeek;
        return StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: ac(context).divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(context.l10n.cancelAction,
                        style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
                    Text(context.l10n.courseEditorWeekRangeTitle,
                        style: TextStyle(
                            color: ac(context).primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        _updateSlot(slotIndex,
                            _slots[slotIndex].copyWith(
                                startWeek: tmpStart, endWeek: tmpEnd));
                        Navigator.pop(ctx);
                      },
                      child: Text(context.l10n.confirmAction,
                          style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: Column(children: [
                    Text(context.l10n.courseEditorStartLabel,
                        style: TextStyle(color: ac(context).hint, fontSize: 12)),
                    SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                            initialItem: tmpStart - 1),
                        onSelectedItemChanged: (i) =>
                            setS(() => tmpStart = i + 1),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 20,
                          builder: (_, i) => Center(
                            child: Text(_weekNthLabel(context, i + 1),
                              style: TextStyle(
                                color: i + 1 == tmpStart
                                    ? ac(ctx).primaryText
                                    : ac(ctx).hint,
                                fontSize: i + 1 == tmpStart ? 17 : 14,
                                fontWeight: i + 1 == tmpStart
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                          ),
                        ),
                      ),
                    ),
                  ])),
                  Expanded(child: Column(children: [
                    Text(context.l10n.courseEditorEndLabel,
                        style: TextStyle(color: ac(context).hint, fontSize: 12)),
                    SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                            initialItem: tmpEnd - 1),
                        onSelectedItemChanged: (i) => setS(() => tmpEnd = i + 1),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 20,
                          builder: (_, i) => Center(
                            child: Text(_weekNthLabel(context, i + 1),
                              style: TextStyle(
                                color: i + 1 == tmpEnd
                                    ? ac(ctx).primaryText
                                    : ac(ctx).hint,
                                fontSize: i + 1 == tmpEnd ? 17 : 14,
                                fontWeight: i + 1 == tmpEnd
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                          ),
                        ),
                      ),
                    ),
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
  void _showSectionPicker(int slotIndex) {
    final cfg = AppStateScope.of(context).config;
    final maxSec = cfg.sectionsPerDay;
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        int tmpStart = _slots[slotIndex].startSection;
        int tmpEnd   = _slots[slotIndex].endSection;
        return StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: ac(context).divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(context.l10n.cancelAction,
                        style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
                    Text(context.l10n.courseEditorSelectSectionsTitle,
                        style: TextStyle(
                            color: ac(context).primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        final end = tmpEnd < tmpStart ? tmpStart : tmpEnd;
                        _updateSlot(slotIndex,
                            _slots[slotIndex].copyWith(
                                startSection: tmpStart, endSection: end));
                        Navigator.pop(ctx);
                      },
                      child: Text(context.l10n.confirmAction,
                          style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: Column(children: [
                    Text(context.l10n.courseEditorStartSectionLabel,
                        style: TextStyle(color: ac(context).hint, fontSize: 12)),
                    SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 44, perspective: 0.003, diameterRatio: 1.8,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                            initialItem: tmpStart - 1),
                        onSelectedItemChanged: (i) {
                          setS(() {
                            tmpStart = i + 1;
                            if (tmpEnd < tmpStart) tmpEnd = tmpStart;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: maxSec,
                          builder: (_, i) => Center(
                            child: Text(_sectionNthLabel(context, i + 1),
                              style: TextStyle(
                                color: i + 1 == tmpStart
                                    ? ac(ctx).primaryText
                                    : ac(ctx).hint,
                                fontSize: i + 1 == tmpStart ? 17 : 14,
                                fontWeight: i + 1 == tmpStart
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                          ),
                        ),
                      ),
                    ),
                  ])),
                  Expanded(child: Column(children: [
                    Text(context.l10n.courseEditorEndSectionLabel,
                        style: TextStyle(color: ac(context).hint, fontSize: 12)),
                    SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
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
                          builder: (_, i) => Center(
                            child: Text(_sectionNthLabel(context, i + 1),
                              style: TextStyle(
                                color: i + 1 == tmpEnd
                                    ? ac(ctx).primaryText
                                    : ac(ctx).hint,
                                fontSize: i + 1 == tmpEnd ? 17 : 14,
                                fontWeight: i + 1 == tmpEnd
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                          ),
                        ),
                      ),
                    ),
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
    final colors = ac(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Container(
                height: 0.5,
                color: colors.divider,
                margin: const EdgeInsets.only(left: 16),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextRow(
    BuildContext context,
    String label,
    TextEditingController ctrl,
    String hint, {
    int? maxLength,
  }) {
    final colors = ac(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 86,
            child: Text(label,
                style: TextStyle(color: colors.primaryText, fontSize: 16)),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              maxLines: null,
              maxLength: maxLength,
              textAlign: TextAlign.right,
              style: TextStyle(color: colors.primaryText, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: colors.hint, fontSize: 15),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapRow(
      BuildContext context, String label, String value, VoidCallback onTap) {
    final colors = ac(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(color: colors.primaryText, fontSize: 16)),
            const Spacer(),
            Text(value,
                style: TextStyle(color: colors.hint, fontSize: 15)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.hint, size: 18),
          ],
        ),
      ),
    );
  }

  // ── 构建单个时间段卡片 ──
  Widget _buildSlotCard(BuildContext context, int i) {
    final colors = ac(context);
    final slot = _slots[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题行：时间段 N + 删除按钮
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                Text(
                  context.l10n.courseEditorTimeSlotTitle(i + 1),
                  style: TextStyle(color: colors.hint, fontSize: 13),
                ),
                const Spacer(),
                if (_slots.length > 1)
                  GestureDetector(
                    onTap: () => _removeSlot(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B5C).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove,
                              color: Color(0xFFFF3B5C), size: 13),
                          const SizedBox(width: 2),
                          Text(context.l10n.deleteAction,
                              style: TextStyle(
                                  color: Color(0xFFFF3B5C), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 卡片内容
          _buildCard(context, [
            _buildTapRow(
              context,
              context.l10n.courseEditorWeeksLabel,
              '${_weekNthLabel(context, slot.startWeek)} - ${_weekNthLabel(context, slot.endWeek)}',
              () => _showWeekRangePicker(i),
            ),
            _buildTapRow(
              context,
              context.l10n.courseEditorDayLabel,
              _weekdayLabel(context, slot.day),
              () => _showPicker<int>(
                title: context.l10n.courseEditorWeekdayTitle,
                values: List.generate(7, (d) => d + 1),
                selected: slot.day,
                label: (v) => _weekdayLabel(context, v),
                onChanged: (v) => _updateSlot(i, slot.copyWith(day: v)),
              ),
            ),
            GestureDetector(
              onTap: () => _showSectionPicker(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(children: [
                  Text(context.l10n.courseEditorSectionsLabel,
                      style: TextStyle(
                          color: colors.primaryText, fontSize: 16)),
                  const Spacer(),
                  Text('${_sectionNthLabel(context, slot.startSection)} - ${_sectionNthLabel(context, slot.endSection)}',
                      style:
                          TextStyle(color: colors.hint, fontSize: 15)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: colors.hint, size: 18),
                ]),
              ),
            ),
            _buildTextRow(context, context.l10n.courseEditorTeacherLabel, _teacherCtrls[i], context.l10n.courseEditorOptionalHint,
                maxLength: 50),
            _buildTextRow(context, context.l10n.courseEditorLocationLabel, _locCtrls[i], context.l10n.courseEditorOptionalHint,
                maxLength: 50),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final previewColor = _customColor ?? _pickAutoColor(s.courses);
    final colors = ac(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            buildLeadingTextAction(
              context,
              label: context.l10n.cancelAction,
              onPressed: () => Navigator.pop(context),
              color: _accent,
            ),
            const Spacer(),
            Text(
              widget.editCourse != null
                ? context.l10n.courseEditorEditTitle
                : context.l10n.courseEditorAddTitle,
              style: TextStyle(
                  color: ac(context).primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton(
              onPressed: _save,
              child: Text(context.l10n.saveAction,
                style: const TextStyle(
                      color: _accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
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
              _buildTextRow(context, context.l10n.courseEditorCourseLabel, _nameCtrl, context.l10n.courseEditorRequiredHint,
                  maxLength: 50),
              // 颜色行
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(context.l10n.courseEditorColorLabel,
                        style: TextStyle(
                            color: colors.primaryText, fontSize: 16)),
                    const Spacer(),
                    if (_customColor == null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(context.l10n.autoLabel,
                            style: TextStyle(
                                color: colors.hint, fontSize: 13)),
                      ),
                    GestureDetector(
                      onTap: () => _showColorPicker(s.courses),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: previewColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colors.divider, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTextRow(context, context.l10n.courseEditorCreditsLabel, _creditCtrl, context.l10n.courseEditorOptionalHint),
              _buildTextRow(context, context.l10n.courseEditorNotesLabel, _noteCtrl, ''),
            ]),

            const SizedBox(height: 24),

            // ── 时间段标题行 ──
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                    Text(context.l10n.courseEditorTimeSlotsLabel,
                      style:
                          TextStyle(color: colors.hint, fontSize: 13)),
                  const Spacer(),
                  // 添加时间段按钮
                  GestureDetector(
                    onTap: _addSlot,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: _accent, size: 13),
                          const SizedBox(width: 2),
                          Text(context.l10n.courseEditorAddSlotAction,
                              style: TextStyle(
                                  color: _accent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 所有时间段卡片（上下并列）──
            ...List.generate(
              _slots.length,
              (i) => _buildSlotCard(context, i),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(List<Course> existing) {
    final List<Color> palette = [];
    for (int h = 0; h < 360; h += 30) {
      palette.add(
          HSVColor.fromAHSV(1, h.toDouble(), 0.75, 0.95).toColor());
    }
    for (int h = 15; h < 360; h += 30) {
      palette.add(
          HSVColor.fromAHSV(1, h.toDouble(), 0.55, 0.90).toColor());
    }
    for (int h = 0; h < 360; h += 30) {
      palette.add(
          HSVColor.fromAHSV(1, h.toDouble(), 0.35, 0.95).toColor());
    }
    for (int i = 0; i < 12; i++) {
      final v = 0.3 + i * 0.06;
      palette.add(HSVColor.fromAHSV(1, 0, 0, v).toColor());
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        Color? tmpColor = _customColor;
        return StatefulBuilder(builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ac(context).divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.l10n.courseEditorChooseColorTitle,
                        style: TextStyle(
                            color: ac(context).primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    Row(children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: tmpColor ?? _pickAutoColor(existing),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white30, width: 1.5),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(context.l10n.confirmAction,
                            style: TextStyle(
                                color: ac(context).primaryText,
                                fontSize: 14)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _customColor == null
                        ? const Color(0xFF4ECDC4).withValues(alpha: 0.15)
                          : const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(8),
                      border: _customColor == null
                          ? Border.all(
                              color: const Color(0xFF4ECDC4)
                            .withValues(alpha: 0.4))
                          : null,
                    ),
                    child: Row(children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          gradient: SweepGradient(colors: [
                            Color(0xFFFF3B5C),
                            Color(0xFFFF9500),
                            Color(0xFFFFD60A),
                            Color(0xFF30D158),
                            Color(0xFF32ADE6),
                            Color(0xFFBF5AF2),
                            Color(0xFFFF3B5C),
                          ]),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                        Text(context.l10n.courseEditorAutoPickNoConflict,
                          style: TextStyle(
                              color: ac(context).primaryText,
                              fontSize: 13)),
                      if (_customColor == null) ...[
                        const Spacer(),
                        const Icon(Icons.check,
                            color: Color(0xFF4ECDC4), size: 16),
                      ],
                    ]),
                  ),
                ),

                // 色盘网格
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 12,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: palette.length,
                  itemBuilder: (_, i) {
                    final c = palette[i];
                    final isSelected = tmpColor?.toARGB32() == c.toARGB32();
                    return GestureDetector(
                      onTap: () => setS(() => tmpColor = c),
                      child: Container(
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: ac(context).primaryText,
                                  width: 2.5)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                  color: c.withValues(alpha: 0.6),
                                      blurRadius: 6)
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                                color: ac(context).primaryText, size: 14)
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
const Color _kHint    = Color(0xFF8E8E93);
// 通用卡片行
class _SettingRow extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  const _SettingRow(
      {required this.label,
      this.trailing,
      this.onTap,
      this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final colors = ac(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(color: colors.primaryText, fontSize: 15)),
          const Spacer(),
          onTap != null
              ? IgnorePointer(
                  child: trailing ??
                      Icon(Icons.chevron_right,
                          color: colors.hint, size: 18))
              : (trailing ??
                  Icon(Icons.chevron_right, color: colors.hint, size: 18)),
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
          Container(
              height: 0.5,
              color: colors.divider,
              margin: const EdgeInsets.only(left: 16)),
      ],
    );
  }
}

Widget _settingCard(BuildContext context, List<Widget> rows) => Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: ac(context).card,
          borderRadius: BorderRadius.circular(12)),
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
     final l = context.l10n;

    return Scaffold(
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: buildBackLeading(
          context,
          label: l.backAction,
          color: _kAccent,
        ),
        leadingWidth: 64,
          title: Text(l.schedulePageToolClassTime,
            style: TextStyle(color: ac(context).primaryText, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _newTimeTable(context, s),
              child: Text(l.classTimeNewAction,
                  style: const TextStyle(color: _kAccent, fontSize: 15)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingCard(context, [
            _SettingRow(
               label: l.classTimeCurrentTableLabel,
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
             Padding(
            padding: EdgeInsets.only(left: 6, bottom: 16, top: 4),
             child: Text(l.classTimeSelectHint,
               style: TextStyle(color: _kHint, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Row(children: [
               Text(l.classTimeTableListHeader,
                   style: const TextStyle(color: _kHint, fontSize: 12)),
              const Spacer(),
              if (tables.length > 1)
                 Text(l.classTimeSwipeHint,
                     style: const TextStyle(color: _kHint, fontSize: 12)),
            ]),
          ),
          _settingCard(
              context,
              List.generate(tables.length, (i) {
                return Dismissible(
                  key: ValueKey('tt_${i}_${tables[i].name}'),
                  direction: tables.length > 1
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B5C),
                      borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Icon(Icons.delete_outline,
                        color: ac(context).primaryText),
                  ),
                  confirmDismiss: (_) async {
                    if (tables.length <= 1) return false;
                    return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: ac(ctx).card,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                           title: Text(l.classTimeDeleteTitle,
                                style: TextStyle(color: ac(ctx).primaryText, fontSize: 16)),
                            content: Text(
                             l.classTimeDeleteMessage(tables[i].name),
                                style: const TextStyle(
                                    color: _kHint, fontSize: 14)),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                             child: Text(l.cancelAction,
                               style: const TextStyle(color: _kHint))),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                             child: Text(l.deleteAction,
                               style: const TextStyle(
                                 color: Color(0xFFFF3B5C)))),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) => s.deleteTimeTable(i),
                  child: _SettingRow(
                    label: tables[i].name,
                    showDivider: i < tables.length - 1,
                    trailing: const Icon(Icons.chevron_right,
                        color: _kHint, size: 18),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ClassTimePage(timeTableIndex: i),
                        )),
                  ),
                );
              })),
        ],
      ),
    );
  }

  void _pickActive(BuildContext context, AppState s) {
    final l = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: ac(context).divider,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
               child: Text(l.classTimeSelectTitle,
                  style: TextStyle(
                      color: ac(ctx).primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            ...List.generate(s.allTimeTables.length, (i) {
              final active = i == s.activeTimeTableIndex;
              return ListTile(
                title: Text(s.allTimeTables[i].name,
                    style: TextStyle(
                        color: active ? _kAccent : ac(context).primaryText,
                        fontSize: 16)),
                trailing: active
                    ? const Icon(Icons.check, color: _kAccent)
                    : null,
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
     final l = context.l10n;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(ctx).card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
         title: Text(l.classTimeNewTitle,
            style: TextStyle(color: ac(ctx).primaryText, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: ac(ctx).primaryText),
           decoration: InputDecoration(
             hintText: l.classTimeNewHint,
             hintStyle: const TextStyle(color: _kHint),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4ECDC4))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xFF4ECDC4), width: 2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
               child: Text(l.cancelAction,
                   style: const TextStyle(color: _kHint))),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim().isEmpty
                   ? l.classTimeDefaultName
                  : ctrl.text.trim();
              s.addTimeTable(name);
              Navigator.pop(ctx);
            },
             child: Text(l.classTimeNewAction,
                 style: const TextStyle(color: _kAccent)),
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
    final tt =
        AppStateScope.of(context).allTimeTables[widget.timeTableIndex];
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
    s.updateTimeTable(widget.timeTableIndex,
        _times.map((t) => List<String>.from(t)).toList());
  }

  void _pushName(String name) {
    AppStateScope.of(context)
        .renameTimeTable(widget.timeTableIndex, name);
  }

  int _toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  String _fromMin(int m) {
    final h = m ~/ 60;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

  void _checkOrder() {
     final l = context.l10n;
    final List<String> errors = [];
    for (int i = 0; i < _times.length; i++) {
      final s = _toMin(_times[i][0]);
      final e = _toMin(_times[i][1]);
      if (e <= s) {
        errors.add(
             l.classTimeOrderEndBeforeStart(i + 1, _times[i][0], _times[i][1]));
      }
      if (i < _times.length - 1) {
        final nextS = _toMin(_times[i + 1][0]);
        if (e > nextS) {
          errors.add(
               l.classTimeOrderOverlap(i + 1, i + 2, _times[i][1], _times[i + 1][0]));
        }
      }
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          Icon(
            errors.isEmpty
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            color: errors.isEmpty
                ? const Color(0xFF4ECDC4)
                : const Color(0xFFFFD60A),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
             errors.isEmpty ? l.classTimeOrderOkTitle : l.classTimeOrderConflicts(errors.length),
            style: TextStyle(
                color: ac(context).primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ]),
        content: errors.isEmpty
               ? Text(l.classTimeOrderOkMessage,
                style: TextStyle(
                    color: ac(context).hint, fontSize: 14))
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: errors.length,
                  separatorBuilder: (_, _) => const Divider(
                      color: Color(0xFFE5E5EA), height: 16),
                  itemBuilder: (_, i) => Text(
                    errors[i],
                    style: const TextStyle(
                        color: Color(0xFFF07B8A),
                        fontSize: 13,
                        height: 1.5),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
             child: Text(l.okAction,
                 style: const TextStyle(
                     color: Color(0xFFFF3B5C), fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _editTime(int index) async {
     final l = context.l10n;
    final sp = _times[index][0].split(':');
    final ep = _times[index][1].split(':');

    final pickedStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(sp[0]), minute: int.parse(sp[1])),
       helpText: l.classTimePickerStartHelpText(index + 1),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4ECDC4))),
        child: child!,
      ),
    );
    if (!mounted || pickedStart == null) return;

    String newEnd;
    if (_sameLength) {
      final startMin =
          pickedStart.hour * 60 + pickedStart.minute;
      newEnd = _fromMin(startMin + _duration);
    } else {
      final pickedEnd = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(ep[0]), minute: int.parse(ep[1])),
          helpText: l.classTimePickerEndHelpText(index + 1),
        builder: (ctx, child) => Theme(
          data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF4ECDC4))),
          child: child!,
        ),
      );
      if (!mounted || pickedEnd == null) return;
      newEnd =
          '${pickedEnd.hour.toString().padLeft(2, '0')}:${pickedEnd.minute.toString().padLeft(2, '0')}';
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
     final l = context.l10n;
    return Scaffold(
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        leading: buildBackLeading(
          context,
          label: l.schedulePageToolClassTime,
          color: _kAccent,
        ),
        leadingWidth: 88,
        title: Text(
           l.classTimeEditPageTitle,
          style: TextStyle(
              color: ac(context).primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _checkOrder,
             child: Text(l.classTimeCheckOrder,
                 style: const TextStyle(
                     color: _kAccent,
                     fontSize: 14,
                     fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingCard(context, [
            _SettingRow(
               label: l.classTimeNameLabel,
              showDivider: false,
              onTap: () => _editName(),
              trailing: Text(
                _nameCtrl.text,
                style: const TextStyle(color: _kHint, fontSize: 15),
              ),
            ),
          ]),
             Padding(
            padding: EdgeInsets.only(left: 6, bottom: 12),
             child: Text(l.classTimeEditNameHint,
               style: TextStyle(color: _kHint, fontSize: 12)),
          ),
          _settingCard(context, [
            _SettingRow(
               label: l.classTimeSameDuration,
              showDivider: _sameLength,
              trailing: Switch(
                value: _sameLength,
                onChanged: (v) => setState(() => _sameLength = v),
                activeThumbColor: const Color(0xFFFF3B5C),
              ),
            ),
            if (_sameLength) ...[
              _SettingRow(
                 label: l.classTimeDurationLabel,
                showDivider: false,
                onTap: _pickDuration,
                trailing: Text(
                  '$_duration',
                  style: const TextStyle(color: _kHint, fontSize: 15),
                ),
              ),
              GestureDetector(
                onTap: _pickDuration,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                     l.classTimeDurationWarning,
                    style: const TextStyle(color: _kHint, fontSize: 12, height: 1.5),
                  ),
                ),
              ),
            ],
          ]),
          if (!_sameLength)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 8),
              child: Text(
                 l.classTimeSectionListHint,
                style: const TextStyle(color: _kHint, fontSize: 12, height: 1.5),
              ),
            ),
          const SizedBox(height: 8),
          _settingCard(
              context,
              List.generate(20, (i) {
                return _SettingRow(
                   label: l.classTimeSectionLabel(i + 1),
                  showDivider: i < 19,
                  onTap: () => _editTime(i),
                  trailing: Text(
                    '${_times[i][0]} - ${_times[i][1]}',
                    style:
                        const TextStyle(color: _kHint, fontSize: 15),
                  ),
                );
              })),
          _settingCard(context, [
            _SettingRow(
               label: l.classTimeReset,
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
       final l = context.l10n;
    final ctrl = TextEditingController(text: _nameCtrl.text);
    showDialog(
      context: context,
      builder: (bCtx) => AlertDialog(
        backgroundColor: ac(bCtx).card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
         title: Text(l.classTimeEditNameTitle,
            style: TextStyle(color: ac(bCtx).primaryText, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: ac(bCtx).primaryText),
          decoration: InputDecoration(
             hintText: l.classTimeNewHint,
            hintStyle: TextStyle(color: ac(bCtx).hint),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4ECDC4))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xFF4ECDC4), width: 2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(bCtx),
               child: Text(l.cancelAction,
                 style: const TextStyle(color: _kHint))),
          TextButton(
              onPressed: () {
                final newName = ctrl.text.trim().isEmpty
                   ? l.classTimeDefaultName
                    : ctrl.text.trim();
                setState(() => _nameCtrl.text = newName);
                _pushName(newName);
                Navigator.pop(bCtx);
              },
               child: Text(l.confirmAction,
                 style: const TextStyle(color: _kAccent))),
        ],
      ),
    );
  }

  void _pickDuration() {
    final l = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        int tmp = _duration;
        final options = [30, 35, 40, 45, 50, 55, 60, 75, 90, 100, 120];
        return StatefulBuilder(
          builder: (ctx, setS) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                               child: Text(l.cancelAction,
                                 style: const TextStyle(color: _kAccent))),
                             Text(l.classTimeDurationPickerTitle,
                            style: TextStyle(
                                color: ac(ctx).primaryText,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _duration = tmp;
                              for (int i = 0;
                                  i < _times.length;
                                  i++) {
                                final sMin =
                                    _toMin(_times[i][0]);
                                _times[i][1] =
                                    _fromMin(sMin + tmp);
                              }
                            });
                            _push();
                            Navigator.pop(ctx);
                          },
                           child: Text(l.confirmAction,
                             style: const TextStyle(color: _kAccent)),
                        ),
                      ]),
                ),
                SizedBox(
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 44,
                    perspective: 0.003,
                    diameterRatio: 1.8,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                        initialItem: options
                            .indexOf(_duration)
                            .clamp(0, options.length - 1)),
                    onSelectedItemChanged: (i) =>
                        setS(() => tmp = options[i]),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: options.length,
                      builder: (_, i) => Center(
                          child: Text(
                         l.classTimeMinutes(options[i]),
                        style: TextStyle(
                          color: options[i] == tmp
                              ? ac(ctx).primaryText
                              : ac(ctx).hint,
                          fontSize: options[i] == tmp ? 18 : 15,
                          fontWeight: options[i] == tmp
                              ? FontWeight.w700
                              : FontWeight.w400,
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