import 'package:flutter/material.dart';

import '../common_widgets.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});
  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _format = '图片 (PNG)';
  bool _includeNonWeek = false;
  bool _includeSaturday = true;
  bool _includeSunday = false;

  final List<String> _formats = ['图片 (PNG)', '图片 (JPG)', 'PDF', 'iCalendar (.ics)', 'CSV'];

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: '导出课表',
      children: [
        settingCard(context, [
          SettingRow(
            label: '导出格式',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_format, style: const TextStyle(color: kHint, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: kHint, size: 18),
            ]),
            onTap: _pickFormat,
          ),
          SettingRow(
            label: '包含非本周课程',
            trailing: Switch(
              value: _includeNonWeek,
              onChanged: (v) => setState(() => _includeNonWeek = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          SettingRow(
            label: '包含周六',
            trailing: Switch(
              value: _includeSaturday,
              onChanged: (v) => setState(() => _includeSaturday = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          SettingRow(
            label: '包含周日',
            showDivider: false,
            trailing: Switch(
              value: _includeSunday,
              onChanged: (v) => setState(() => _includeSunday = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
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
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择格式',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._formats.map(
              (f) => GestureDetector(
                onTap: () {
                  setState(() => _format = f);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: kDivider, width: 0.5)),
                  ),
                  child: Row(children: [
                    Text(
                      f,
                      style: TextStyle(
                        color: f == _format ? const Color(0xFF4ECDC4) : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (f == _format)
                      const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 18),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
