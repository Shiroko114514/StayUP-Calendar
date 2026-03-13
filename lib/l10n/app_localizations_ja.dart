// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'WakeUp 時間割';

  @override
  String get loadingSchedule => '時間割を読み込み中...';

  @override
  String get aboutTitle => 'このアプリについて';

  @override
  String get appName => 'StayUP 時間割';

  @override
  String appVersionLabel(Object version) {
    return 'バージョン $version';
  }

  @override
  String get versionNumber => 'バージョン';

  @override
  String get developer => '開発者';

  @override
  String get openSourceLicense => 'オープンソースライセンス';

  @override
  String get checkUpdate => '更新を確認';

  @override
  String get alreadyLatest => '最新です';

  @override
  String get aboutFooter =>
      '© 2026 StayUP Studio \n思いつきで作った時間割アプリですが、たくさんの授業で役立てば嬉しいです。';

  @override
  String get backAction => '戻る';

  @override
  String get doneAction => '完了';

  @override
  String get editAction => '編集';

  @override
  String get cancelAction => 'キャンセル';

  @override
  String get confirmAction => '確認';

  @override
  String get saveAction => '保存';

  @override
  String get deleteAction => '削除';

  @override
  String get okAction => 'OK';

  @override
  String get globalSettingsTitle => '全体設定';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get courseReminder => '授業リマインダー';

  @override
  String get widgetSync => 'ウィジェット同期';

  @override
  String get setBackgroundFormat => '背景フォーマット設定';

  @override
  String get helpUsage => 'ヘルプ';

  @override
  String get featureInDevelopmentTitle => '開発中';

  @override
  String get featureInDevelopmentMessage => 'この機能は現在開発中です。';

  @override
  String get languageSettingLabel => '言語';

  @override
  String get languageFollowSystem => 'システム設定に従う';

  @override
  String get languageForceChineseSimplified => '中文（简体）';

  @override
  String get languageForceChineseTraditional => '中文（繁體）';

  @override
  String get languageForceEnglish => 'English';

  @override
  String get languageForceJapanese => '日本語';

  @override
  String get manageScheduleTitle => '時間割管理';

  @override
  String get manageScheduleHint => '右上の編集で並べ替え・削除できます';

  @override
  String get newScheduleButton => '新規時間割';

  @override
  String get deleteScheduleTitle => '時間割を削除';

  @override
  String deleteScheduleMessage(Object name) {
    return '「$name」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get newScheduleTitle => '新規時間割';

  @override
  String get scheduleNameRequired => '時間割名を入力してください';

  @override
  String get scheduleNameRequiredHint => '時間割名（必須）';

  @override
  String get firstDayOfWeekOne => '第1週の初日';

  @override
  String get weekStartDay => '週の開始曜日';

  @override
  String get mondayLabel => '月曜日';

  @override
  String get currentWeek => '現在の週';

  @override
  String get autoLabel => '自動';

  @override
  String get sectionsPerDay => '1日の授業数';

  @override
  String get totalWeeks => '学期週数';

  @override
  String get exportScheduleTitle => '時間割をエクスポート';

  @override
  String get exportFormatLabel => '形式';

  @override
  String get exportIncludeNonWeek => '今週以外の授業を含める';

  @override
  String get exportIncludeSaturday => '土曜日を含める';

  @override
  String get exportIncludeSunday => '日曜日を含める';

  @override
  String get exportNow => '今すぐエクスポート';

  @override
  String get exportSelectFormat => '形式を選択';

  @override
  String exportSuccess(Object format) {
    return '$format としてエクスポートしました';
  }

  @override
  String get exportFormatPng => '画像 (PNG)';

  @override
  String get exportFormatJpg => '画像 (JPG)';

  @override
  String get exportFormatPdf => 'PDF';

  @override
  String get exportFormatIcs => 'iCalendar (.ics)';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get searchSchoolHint => '学校を検索';

  @override
  String get schoolImportTip => '検索ボックスに学校名を入力して素早く見つけられます';

  @override
  String get schoolImportWipMessage => 'この学校の授業インポート機能は現在開発中です。';

  @override
  String get schoolHust => '華中科技大学';

  @override
  String get schoolJxnu => '江西師範大学';

  @override
  String get schoolSjtu => '上海交通大学';

  @override
  String get schoolWhu => '武漢大学';

  @override
  String get schoolCuhksz => '香港中文大学（深圳）';

  @override
  String get schoolRuc => '中国人民大学';

  @override
  String get scheduleSettingsTitle => '時間割設定';

  @override
  String get scheduleDataTitle => '時間割データ';

  @override
  String get scheduleAppearanceLabel => '時間割の外観';

  @override
  String get adjustToolTitle => '振替ツール';

  @override
  String get scheduleAppearanceWipMessage => '「時間割の外観」機能は現在開発中です。';

  @override
  String get scheduleNameLabel => '時間割名';

  @override
  String get renameScheduleTitle => '時間割名を変更';

  @override
  String get enterScheduleNameHint => '時間割名を入力してください';

  @override
  String get classTimeTitle => '授業時間';

  @override
  String scheduleSettingsCurrentWeekDisplay(int week) {
    return '第$week週';
  }

  @override
  String adjustMoveSuccess(Object from, Object to) {
    return '$from の授業を $to に移動しました';
  }

  @override
  String get adjustDescription => '振替休日などの調整用に、ある日の授業を別の日に移動できます。慎重に操作してください。';

  @override
  String get adjustTargetSchedule => '調整対象の時間割';

  @override
  String get adjustFromLabel => '移動元';

  @override
  String get adjustCoursesSuffix => 'の授業';

  @override
  String get adjustToLabel => '移動先';

  @override
  String get adjustWarning => 'この操作は取り消せません。実行前に日付を確認してください。';

  @override
  String get deleteCoursesTitle => '授業を削除';

  @override
  String deleteSelectedCoursesMessage(int count) {
    return '選択した$count件の授業を削除しますか？';
  }

  @override
  String get clearScheduleTitle => '時間割をクリア';

  @override
  String clearScheduleMessage(int count) {
    return 'この時間割の$count件の授業をすべて削除しますか？この操作は取り消せません。';
  }

  @override
  String get clearAction => 'クリア';

  @override
  String get moreAction => 'その他';

  @override
  String get selectCoursesTitle => '授業を選択';

  @override
  String selectedCoursesCount(int count) {
    return '$count件選択中';
  }

  @override
  String get addedCoursesTitle => '追加済み授業';

  @override
  String totalCoursesCount(int count) {
    return '$count件の授業';
  }

  @override
  String get unselectAllAction => '全選択解除';

  @override
  String get selectAllAction => 'すべて選択';

  @override
  String get swipeDeleteHint => '  左スワイプで削除';

  @override
  String get noCoursesYet => '授業がありません';

  @override
  String courseTimeSummary(Object weekday, int start, int end) {
    return '$weekday $start-$end限';
  }

  @override
  String deleteCourseMessage(Object name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get clearCurrentSchedule => '現在の時間割をクリア';

  @override
  String deleteSelectedCount(int count) {
    return '削除 ($count)';
  }

  @override
  String get addCourseAction => '授業を追加';
}
