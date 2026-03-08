import 'package:flutter/material.dart';

import '../common_widgets.dart';
import '../models.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消', style: TextStyle(color: kAccent)),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cb(tmp);
                        Navigator.pop(ctx);
                      },
                      child: const Text('确定', style: TextStyle(color: kAccent)),
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
                  controller: FixedExtentScrollController(initialItem: current - min),
                  onSelectedItemChanged: (i) => ss(() => tmp = min + i),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: max - min + 1,
                    builder: (_, i) {
                      final v = min + i;
                      return Center(
                        child: Text(
                          '$v',
                          style: TextStyle(
                            color: v == tmp ? Colors.white : kHint,
                            fontSize: v == tmp ? 18 : 15,
                            fontWeight: v == tmp ? FontWeight.w700 : FontWeight.w400,
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
        const SnackBar(
          content: Text('请填写课表名称'),
          backgroundColor: Color(0xFFE5E5EA),
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
          child: const Text('取消', style: TextStyle(color: kAccent, fontSize: 16)),
        ),
        leadingWidth: 64,
        title: const Text('新建课表', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
          settingCard(context, [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15),
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
          settingCard(context, [
            SettingRow(
              label: '第一周的第一天',
              onTap: _pickDate,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fmtDate(_firstDay),
                  style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 14),
                ),
              ),
            ),
            const SettingRow(
              label: '一周起始天',
              trailing: Text('Monday', style: TextStyle(color: kHint, fontSize: 14)),
            ),
            const SettingRow(
              label: '当前周',
              showDivider: false,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('自动', style: TextStyle(color: kHint, fontSize: 14)),
                SizedBox(width: 4),
                Icon(Icons.unfold_more, color: kHint, size: 18),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          settingCard(context, [
            SettingRow(
              label: '一天课程节数',
              onTap: () => _pickNumber(
                '一天课程节数',
                _sectionsPerDay,
                1,
                20,
                (v) => setState(() => _sectionsPerDay = v),
              ),
              trailing: Text('$_sectionsPerDay', style: const TextStyle(color: kHint, fontSize: 15)),
            ),
            SettingRow(
              label: '学期周数',
              showDivider: false,
              onTap: () => _pickNumber(
                '学期周数',
                _totalWeeks,
                1,
                30,
                (v) => setState(() => _totalWeeks = v),
              ),
              trailing: Text('$_totalWeeks', style: const TextStyle(color: kHint, fontSize: 15)),
            ),
          ]),
        ],
      ),
    );
  }
}
