import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models.dart';

// ══════════════════════════════════════════════════════════
// 抽象基类
// ══════════════════════════════════════════════════════════
abstract class SchoolImporter {
  String get schoolId;
  String get webUrl;       // WebView 打开的网址（直接是数据接口）
  String get pinyin;
  String noticeText(BuildContext context);

  void resetSession() {}

  String newScheduleName(BuildContext context) {
    final now = DateTime.now();
    return '${displayName(context)} ${now.month}/${now.day}';
  }

  String displayName(BuildContext context);

  /// 页面加载完成后调用，返回解析好的课程列表
  Future<List<Course>?> onPageLoaded(
    BuildContext context,
    WebViewController controller,
    AppState appState,
    void Function(String error) onError,
  );
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