import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common_widgets.dart';
import '../../l10n.dart';
import '../../models.dart';
import '../widgets/school_importers.dart';

class HustImporter extends SchoolImporter {
  int _selectedAcademicYear = _defaultAcademicYear(DateTime.now());
  int _selectedSemester = _defaultSemester(DateTime.now());
  bool _termPrepared = false;

  @override
  String get schoolId => 'hust';

  @override
  String displayName(BuildContext context) => context.l10n.schoolHust;

  @override
  String get pinyin => 'H';

  static const String _baseUrl =
      'http://mhub.hust.edu.cn/LsController/findNameCourse';
  static const String _entryUrl = 'http://mhub.hust.edu.cn';

  static int _defaultAcademicYear(DateTime now) => now.month >= 8 ? now.year : now.year - 1;

  static int _defaultSemester(DateTime now) => now.month >= 8 ? 1 : 2;

  String _buildUrl(int academicYear, int semester) =>
      '$_baseUrl?kcbxqh=$academicYear$semester';

  @override
  String get webUrl => _entryUrl;

  @override
  String noticeText(BuildContext context) => context.l10n.hustNoticeText;

  @override
  String newScheduleName(BuildContext context) {
    final now = DateTime.now();
    return context.l10n.schoolImportScheduleName(displayName(context), now.month, now.day);
  }

  Future<bool> prepareTermAndLoad(
    BuildContext context,
    WebViewController controller,
    void Function(String error) onError,
  ) async {
    final l10n = context.l10n;
    try {
      final selection = await _showTermDialog(context);
      // Cancelled → fall back to the date-derived default term.
      _selectedAcademicYear = selection?.academicYear ?? _defaultAcademicYear(DateTime.now());
      _selectedSemester    = selection?.semester    ?? _defaultSemester(DateTime.now());

      await controller.loadRequest(
        Uri.parse(_buildUrl(_selectedAcademicYear, _selectedSemester)),
      );
      await _waitForPageReady(controller);
      _termPrepared = true;
      return true;
    } catch (e) {
      onError(l10n.hustReadFailed(e));
      return false;
    }
  }

  @override
  Future<List<Course>?> onPageLoaded(
    BuildContext context,
    WebViewController controller,
    AppState appState,
    void Function(String error) onError,
  ) async {
    final l10n = context.l10n;
    try {
      if (!_termPrepared) {
        final ready = await prepareTermAndLoad(context, controller, onError);
        if (!ready) {
          return null;
        }
      }

      final result = await controller.runJavaScriptReturningResult(
        'document.body.innerText',
      );

      // result 可能是带引号的 JSON 字符串，也可能已被平台解析
      String raw = result.toString();

      // 如果带外层引号（iOS WKWebView 的 JSON 编码），去掉并反转义
      if (raw.startsWith('"') && raw.endsWith('"')) {
        raw = jsonDecode(raw) as String;
      }

      if (raw.trim().startsWith('<') || raw.trim().isEmpty) {
        onError(l10n.hustNeedLoginError);
        return null;
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;

      if (json['code'] != '200' || json['data'] == null) {
        onError(l10n.hustApiError(json['code']));
        return null;
      }

      return _parse(json, appState);
    } catch (e) {
      onError(l10n.hustReadFailed(e));
      return null;
    }
  }

  Future<_HustTermSelection?> _showTermDialog(BuildContext context) async {
    final now = DateTime.now();
    final nowYear = now.year;
    // 6 years: current year −4 … current year +1  (12 semesters total)
    final yearOptions = List<int>.generate(6, (index) => nowYear - 4 + index);

    // Default pre-selection: date-derived, not the last user choice
    int draftYear     = _defaultAcademicYear(now);
    int draftSemester = _defaultSemester(now);
    if (!yearOptions.contains(draftYear)) {
      draftYear = nowYear;
    }

    return showDialog<_HustTermSelection>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: ac(context).card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(
                context.l10n.hustTermDialogTitle,
                style: TextStyle(
                  color: ac(context).primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.hustTermDialogMessage,
                    style: TextStyle(
                      color: ac(context).hint,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: draftYear,
                    decoration: InputDecoration(
                      labelText: context.l10n.hustAcademicYearLabel,
                      border: OutlineInputBorder(),
                    ),
                    items: yearOptions
                        .map((year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text(context.l10n.hustAcademicYearOption(year)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => draftYear = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: draftSemester,
                    decoration: InputDecoration(
                      labelText: context.l10n.hustSemesterLabel,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(context.l10n.hustSemesterFall),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text(context.l10n.hustSemesterSpring),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => draftSemester = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    context.l10n.cancelAction,
                    style: TextStyle(color: ac(context).hint),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(
                    _HustTermSelection(
                      academicYear: draftYear,
                      semester: draftSemester,
                    ),
                  ),
                  child: Text(
                    context.l10n.confirmAction,
                    style: TextStyle(
                      color: Color(0xFFFF3B5C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _waitForPageReady(WebViewController controller) async {
    for (int i = 0; i < 20; i++) {
      final readyState = await controller.runJavaScriptReturningResult(
        'document.readyState',
      );
      final state = readyState.toString().replaceAll('"', '').trim().toLowerCase();
      if (state == 'complete') {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  List<Course> _parse(Map<String, dynamic> json, AppState appState) {
    final existingIds = appState.courses.map((c) => c.id).toSet();
    int nextId = existingIds.isEmpty
        ? 1
        : existingIds.reduce((a, b) => a > b ? a : b) + 1;
    int colorIdx = 0;

    final courses = <Course>[];

    for (final item in json['data'] as List<dynamic>) {
      final name = (item['KCMC'] as String?)?.trim() ?? '';
      if (name.isEmpty) {
        continue;
      }

      final trs = (item['tr'] as List<dynamic>)
          .where((tr) =>
              tr['XQS'] != null &&
              tr['XQS'] != '<待定>' &&
              tr['QSJC'] != '<待定>')
          .toList();

      if (trs.isEmpty) {
        continue;
      }

      CourseSlot? parseSlot(dynamic tr) {
        try {
          return CourseSlot(
            day: int.parse(tr['XQS'].toString()),
            startSection: int.parse(tr['QSJC'].toString()),
            endSection: int.parse(tr['JSJC'].toString()),
            startWeek: int.parse(tr['QSZC'].toString()),
            endWeek: int.parse(tr['JSZC'].toString()),
          );
        } catch (_) {
          return null;
        }
      }

      final first = parseSlot(trs[0]);
      if (first == null) {
        continue;
      }

      final extras = <CourseSlot>[];
      for (int i = 1; i < trs.length; i++) {
        final slot = parseSlot(trs[i]);
        if (slot != null) {
          extras.add(slot);
        }
      }

      courses.add(Course(
        id: nextId++,
        name: name,
        teacher: trs[0]['XM']?.toString() ?? '',
        location: trs[0]['JSMC']?.toString() ?? '',
        day: first.day,
        startSection: first.startSection,
        span: first.endSection - first.startSection + 1,
        colorIdx: (colorIdx++) % kCourseColors.length,
        weeks: List.generate(
          first.endWeek - first.startWeek + 1,
          (i) => first.startWeek + i,
        ),
        startWeek: first.startWeek,
        endWeek: first.endWeek,
        extraSlots: extras,
      ));
    }

    return courses;
  }
}

class _HustTermSelection {
  final int academicYear;
  final int semester;

  const _HustTermSelection({
    required this.academicYear,
    required this.semester,
  });
}
