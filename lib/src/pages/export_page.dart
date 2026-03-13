import 'package:flutter/material.dart';

import '../common_widgets.dart';
import '../l10n.dart';

enum _ExportFormat { png, jpg, pdf, ics, csv }

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});
  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  _ExportFormat _format = _ExportFormat.png;
  bool _includeNonWeek = false;
  bool _includeSaturday = true;
  bool _includeSunday = false;

  List<_ExportFormat> get _formats => _ExportFormat.values;

  String _formatLabel(BuildContext context, _ExportFormat format) {
    final l10n = context.l10n;
    switch (format) {
      case _ExportFormat.png:
        return l10n.exportFormatPng;
      case _ExportFormat.jpg:
        return l10n.exportFormatJpg;
      case _ExportFormat.pdf:
        return l10n.exportFormatPdf;
      case _ExportFormat.ics:
        return l10n.exportFormatIcs;
      case _ExportFormat.csv:
        return l10n.exportFormatCsv;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: context.l10n.exportScheduleTitle,
      children: [
        settingCard(context, [
          SettingRow(
            label: context.l10n.exportFormatLabel,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatLabel(context, _format),
                  style: const TextStyle(color: kHint, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: kHint, size: 18),
              ],
            ),
            onTap: _pickFormat,
          ),
          SettingRow(
            label: context.l10n.exportIncludeNonWeek,
            trailing: Switch(
              value: _includeNonWeek,
              onChanged: (v) => setState(() => _includeNonWeek = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          SettingRow(
            label: context.l10n.exportIncludeSaturday,
            trailing: Switch(
              value: _includeSaturday,
              onChanged: (v) => setState(() => _includeSaturday = v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          SettingRow(
            label: context.l10n.exportIncludeSunday,
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
                  content: Text(
                    context.l10n.exportSuccess(_formatLabel(context, _format)),
                  ),
                  backgroundColor: const Color(0xFFE5E5EA),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              context.l10n.exportNow,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
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
            Text(
              context.l10n.exportSelectFormat,
              style: TextStyle(
                color: ac(context).primaryText,
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 4,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: kDivider, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatLabel(context, f),
                        style: TextStyle(
                          color: f == _format
                              ? const Color(0xFF4ECDC4)
                              : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      if (f == _format)
                        const Icon(
                          Icons.check,
                          color: Color(0xFF4ECDC4),
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}