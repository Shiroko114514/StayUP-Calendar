import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../common_widgets.dart';
import '../l10n.dart';
import '../models.dart';

class NewSchedulePage extends StatefulWidget {
  const NewSchedulePage({super.key});
  @override
  State<NewSchedulePage> createState() => _NewSchedulePageState();
}

class _NewSchedulePageState extends State<NewSchedulePage> {
  final _nameCtrl = TextEditingController();
  bool _initializedName = false;
  DateTime _firstDay = DateTime(DateTime.now().year, 9, 1);
  int _sectionsPerDay = 20;
  int _totalWeeks = 20;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedName) return;
    _nameCtrl.text = context.l10n.newScheduleTitle;
    _nameCtrl.selection = TextSelection.collapsed(offset: _nameCtrl.text.length);
    _initializedName = true;
  }

  String _fmtDate(BuildContext context, DateTime d) =>
      DateFormat.yMd(context.l10n.localeName).format(d);

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
          ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFFF2F2F7)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _firstDay = picked);
  }

  void _pickNumber(
    String title,
    int current,
    int min,
    int max,
    ValueChanged<int> cb,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        int tmp = current;
        return StatefulBuilder(
          builder: (ctx, ss) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        context.l10n.cancelAction,
                        style: const TextStyle(color: kAccent),
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: ac(ctx).primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cb(tmp);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        context.l10n.confirmAction,
                        style: const TextStyle(color: kAccent),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 44,
                  perspective: 0.003,
                  diameterRatio: 1.8,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(
                    initialItem: current - min,
                  ),
                  onSelectedItemChanged: (i) => ss(() => tmp = min + i),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: max - min + 1,
                    builder: (_, i) {
                      final v = min + i;
                      return Center(
                        child: Text(
                          '$v',
                          style: TextStyle(
                            color: v == tmp ? ac(ctx).primaryText : ac(ctx).hint,
                            fontSize: v == tmp ? 18 : 15,
                            fontWeight: v == tmp
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.scheduleNameRequired),
          backgroundColor: const Color(0xFFE5E5EA),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final s = AppStateScope.of(context);
    s.addSchedule(
      ScheduleConfig(
        name: name,
        firstWeekDay: _firstDay,
        sectionsPerDay: _sectionsPerDay,
        totalWeeks: _totalWeeks,
      ),
    );
    s.switchSchedule(s.allConfigs.length - 1);
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
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).card,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancelAction,
            style: const TextStyle(color: kAccent, fontSize: 15),
          ),
        ),
        leadingWidth: 64,
        title: Text(
          context.l10n.newScheduleTitle,
          style: TextStyle(color: ac(context).primaryText, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isEmpty ? null : _save,
            child: Text(
              context.l10n.saveAction,
              style: TextStyle(
                color: isEmpty
                    ? const Color(0xFFD1D1D6)
                    : const Color(0xFF6C6C70),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          settingCard(context, [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(kScheduleNameMaxLength),
                ],
                style: TextStyle(color: ac(context).primaryText, fontSize: 15),
                decoration: InputDecoration(
                  hintText: context.l10n.scheduleNameRequiredHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFFD1D1D6),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          settingCard(context, [
            SettingRow(
              label: context.l10n.firstDayOfWeekOne,
              onTap: _pickDate,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ac(context).divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fmtDate(context, _firstDay),
                  style: TextStyle(
                    color: ac(context).primaryText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SettingRow(
              label: context.l10n.weekStartDay,
              trailing: Text(
                context.l10n.mondayLabel,
                style: const TextStyle(color: kHint, fontSize: 14),
              ),
            ),
            SettingRow(
              label: context.l10n.currentWeek,
              showDivider: false,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.autoLabel,
                    style: const TextStyle(color: kHint, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.unfold_more, color: kHint, size: 18),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          settingCard(context, [
            SettingRow(
              label: context.l10n.sectionsPerDay,
              onTap: () => _pickNumber(
                context.l10n.sectionsPerDay,
                _sectionsPerDay,
                1,
                20,
                (v) => setState(() => _sectionsPerDay = v),
              ),
              trailing: Text(
                '$_sectionsPerDay',
                style: const TextStyle(color: kHint, fontSize: 15),
              ),
            ),
            SettingRow(
              label: context.l10n.totalWeeks,
              showDivider: false,
              onTap: () => _pickNumber(
                context.l10n.totalWeeks,
                _totalWeeks,
                1,
                30,
                (v) => setState(() => _totalWeeks = v),
              ),
              trailing: Text(
                '$_totalWeeks',
                style: const TextStyle(color: kHint, fontSize: 15),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}