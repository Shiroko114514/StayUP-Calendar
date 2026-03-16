import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models.dart';
import '../../common_widgets.dart';

// ══════════════════════════════════════════════════════════
// 抽象基类
// ══════════════════════════════════════════════════════════
abstract class SchoolImporter {
  String get schoolId;
  String get webUrl;       // WebView 打开的网址（直接是数据接口）
  String get pinyin;
  String get noticeText;

  String get newScheduleName {
    final now = DateTime.now();
    return '$displayName导入 ${now.month}/${now.day}';
  }

  String get displayName;

  /// 页面加载完成后调用，返回解析好的课程列表
  Future<List<Course>?> onPageLoaded(
    WebViewController controller,
    AppState appState,
    void Function(String error) onError,
  );
}

// ══════════════════════════════════════════════════════════
// 全局注册表
// ══════════════════════════════════════════════════════════
final Map<String, SchoolImporter> kSchoolImporters = {
  'hust': HustImporter(),
};

// ══════════════════════════════════════════════════════════
// 华中科技大学
// ══════════════════════════════════════════════════════════
class HustImporter extends SchoolImporter {
  @override String get schoolId => 'hust';
  @override String get displayName => '华科';
  @override String get pinyin => 'H';

  // 直接打开 JSON 接口，登录后 Cookie 会自动携带
  @override
  String get webUrl =>
      'http://mhub.hust.edu.cn/LsController/findNameCourse?kcbxqh=20252';

  @override
  String get noticeText =>
      '1. 若未登录会先跳转到登录页，登录后点击右下角导入按钮\n\n'
      '2. 时间地点为"待定"的课程不会导入，请后续手动添加';

  @override
  Future<List<Course>?> onPageLoaded(
    WebViewController controller,
    AppState appState,
    void Function(String error) onError,
  ) async {
    try {
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
        onError('请先在页面中完成登录，然后再点击导入按钮');
        return null;
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;

      if (json['code'] != '200' || json['data'] == null) {
        onError('接口返回异常（code=${json['code']}），请重新登录后再试');
        return null;
      }

      return _parse(json, appState);
    } catch (e) {
      onError('读取失败：$e');
      return null;
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
      if (name.isEmpty) continue;

      final trs = (item['tr'] as List<dynamic>)
          .where((tr) =>
              tr['XQS'] != null &&
              tr['XQS'] != '<待定>' &&
              tr['QSJC'] != '<待定>')
          .toList();

      if (trs.isEmpty) continue;

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
      if (first == null) continue;

      final extras = <CourseSlot>[];
      for (int i = 1; i < trs.length; i++) {
        final s = parseSlot(trs[i]);
        if (s != null) extras.add(s);
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
            first.endWeek - first.startWeek + 1, (i) => first.startWeek + i),
        startWeek: first.startWeek,
        endWeek: first.endWeek,
        extraSlots: extras,
      ));
    }
    return courses;
  }
}

// ══════════════════════════════════════════════════════════
// 新增学校模板
// ══════════════════════════════════════════════════════════
/*
class XxxImporter extends SchoolImporter {
  @override String get schoolId    => 'xxx';
  @override String get displayName => 'XXX大学';
  @override String get pinyin      => 'X';
  @override String get webUrl      => 'https://xxx.edu.cn/api/courses';
  @override String get noticeText  => '1. 登录后点击导入\n\n2. 待定课程不导入';

  @override
  Future<List<Course>?> onPageLoaded(controller, appState, onError) async {
    // 读取页面内容并解析
    return null;
  }
}
*/