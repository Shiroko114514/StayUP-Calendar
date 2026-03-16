import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../common_widgets.dart';
import '../l10n.dart';
import '../models.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});
  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  static const XTypeGroup _jsonTypeGroup = XTypeGroup(
    label: 'JSON',
    extensions: <String>['json'],
    mimeTypes: <String>['application/json', 'text/json'],
  );

  Future<void> _exportCurrentSchedule() async {
    final appState = AppStateScope.of(context);
    final scheduleName = appState.config.name.trim();
    final suggested = scheduleName.isEmpty
        ? 'stayup_schedule.json'
        : '${scheduleName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.json';

    try {
      final location = await getSaveLocation(
        suggestedName: suggested,
        acceptedTypeGroups: const <XTypeGroup>[_jsonTypeGroup],
      );
      if (location == null || !mounted) return;

      final payload = appState.exportActiveScheduleJson();
      final pretty = const JsonEncoder.withIndent('  ').convert(payload);
      final file = XFile.fromData(
        utf8.encode(pretty),
        mimeType: 'application/json',
        name: suggested,
      );
      await file.saveTo(location.path);
      if (!mounted) return;
      showAppToast(context, context.l10n.exportJsonSuccess);
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, context.l10n.exportJsonFailed);
    }
  }

  String _resolveImportedScheduleName(
    AppLocalizations l10n,
    Map<String, dynamic> decoded,
  ) {
    String? rawName;
    final topLevelName = decoded['scheduleName'];
    if (topLevelName is String && topLevelName.trim().isNotEmpty) {
      rawName = topLevelName.trim();
    }

    final scheduleRaw = decoded['schedule'];
    if (rawName == null && scheduleRaw is Map) {
      final configRaw = scheduleRaw['config'];
      if (configRaw is Map) {
        final name = configRaw['name'];
        if (name is String && name.trim().isNotEmpty) {
          rawName = name.trim();
        }
      }
    }

    if (rawName == null || rawName.isEmpty) {
      return l10n.importScheduleFallbackName;
    }

    final match = RegExp(
      r'^(\\d{4})\\s+(Spring|Fall|Autumn|春|秋)$',
      caseSensitive: false,
    ).firstMatch(rawName);
    if (match == null) return rawName;

    final year = int.tryParse(match.group(1) ?? '');
    final seasonToken = (match.group(2) ?? '').toLowerCase();
    if (year == null) return rawName;

    final season =
        (seasonToken == 'spring' || seasonToken == '春')
            ? l10n.schoolImportSeasonSpringShort
            : l10n.schoolImportSeasonFallShort;
    return l10n.schoolImportScheduleNameByTerm(year, season);
  }

  Future<void> _importFromJson() async {
    try {
      final l10n = context.l10n;
      final appState = AppStateScope.of(context);
      final file = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[_jsonTypeGroup],
      );
      if (file == null || !mounted) return;

      final text = await file.readAsString();
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        throw const FormatException('Top-level JSON must be an object.');
      }

      final decodedMap = Map<String, dynamic>.from(decoded);
      final resolvedName = _resolveImportedScheduleName(l10n, decodedMap);
      appState.importScheduleFromJsonMap(
        decodedMap,
        importedNameOverride: resolvedName,
      );
      if (!mounted) return;
      showAppToast(context, context.l10n.importJsonSuccess);
    } on FormatException {
      if (!mounted) return;
      showAppToast(context, context.l10n.importJsonInvalid);
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, context.l10n.importJsonFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return SubPageScaffold(
      title: context.l10n.exportScheduleTitle,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            context.l10n.exportCurrentScheduleLabel(appState.config.name),
            style: TextStyle(color: ac(context).hint, fontSize: 13),
          ),
        ),
        settingCard(context, [
          SettingRow(
            label: context.l10n.exportCurrentScheduleJsonAction,
            onTap: _exportCurrentSchedule,
            trailing: const Icon(Icons.chevron_right, color: kHint, size: 18),
          ),
          SettingRow(
            label: context.l10n.importScheduleFromJsonAction,
            showDivider: false,
            onTap: _importFromJson,
            trailing: const Icon(Icons.chevron_right, color: kHint, size: 18),
          ),
        ]),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ac(context).card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            context.l10n.importJsonNotice,
            style: TextStyle(color: ac(context).hint, fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }
}