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
  String get darkMode => '外観';

  @override
  String get themeModeFollowSystem => 'システムに従う';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get courseReminder => '授業リマインダー';

  @override
  String get widgetSync => 'ウィジェット同期';

  @override
  String get setBackgroundFormat => '背景フォーマット設定';

  @override
  String get materialDynamicColor => 'Material 動的カラー';

  @override
  String get helpUsage => 'ヘルプ';

  @override
  String get featureInDevelopmentTitle => '開発中';

  @override
  String get featureInDevelopmentMessage => 'この機能は現在開発中です。';

  @override
  String get languageSettingLabel => '言語';

  @override
  String get dateFormatSettingLabel => '日付形式';

  @override
  String get dateFormatCustomOptionLabel => 'カスタム';

  @override
  String get dateFormatCustomDialogTitle => '日付形式をカスタム';

  @override
  String get dateFormatCustomDialogHint => 'intl の日付パターンを入力（例: MMM d, yyyy）';

  @override
  String get dateFormatCustomDialogHelper =>
      'DateFormat のパターン構文を使用します。例: yyyy/MM/dd, d MMM. yyyy, MMM d, yyyy';

  @override
  String get dateFormatCustomDialogEmpty => '日付形式を入力してください';

  @override
  String get dateFormatCustomDialogInvalid => '日付形式が無効です。パターンを確認してください';

  @override
  String get languageFollowSystem => 'システム設定に従う';

  @override
  String get languageChangedRestartTitle => '言語を変更しました';

  @override
  String get languageChangedRestartMessage =>
      '新しい言語を適用するため、アプリを自動終了します。再度起動してください。';

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
  String get scheduleNameTruncatedMessage => '文字数制限を超えたため、切り詰めました';

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
  String get exportScheduleTitle => '共有';

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
  String get schoolImportMoreSchools => 'さらに多くの大学に対応中です';

  @override
  String get schoolImportNoticeTitle => '注意事項';

  @override
  String get schoolImportParseDoneTitle => '解析完了';

  @override
  String schoolImportParseDoneMessage(int count) {
    return '$count 件の授業を解析しました。新しい時間割を作成してインポートしますか？';
  }

  @override
  String get schoolImportAction => 'インポート';

  @override
  String schoolImportSuccess(int count) {
    return '新しい時間割を作成し、$count 件の授業をインポートしました';
  }

  @override
  String get schoolImportErrorTitle => 'エラー';

  @override
  String get schoolImportParsing => '解析中...';

  @override
  String get schoolImportScheduleAction => '時間割をインポート';

  @override
  String get schoolImportResetLoginAction => '再ログイン';

  @override
  String get schoolImportResetLoginTitle => 'ログイン状態をクリア';

  @override
  String get schoolImportResetLoginMessage =>
      '内蔵ブラウザ内のログイン Cookie をすべて削除し、ログイン入口を再度開きます。続行しますか？';

  @override
  String get schoolImportResetLoginSuccess => 'ログイン状態をクリアしました。もう一度ログインしてください。';

  @override
  String schoolImportResetLoginFailed(Object error) {
    return 'ログイン状態のクリアに失敗しました: $error';
  }

  @override
  String schoolImportScheduleName(Object school, int month, int day) {
    return '$school インポート $month/$day';
  }

  @override
  String get schoolImportSeasonSpringShort => '春';

  @override
  String get schoolImportSeasonFallShort => '秋';

  @override
  String schoolImportScheduleNameByTerm(int year, Object season) {
    return '$year $season';
  }

  @override
  String get hustNoticeText =>
      '1. 未ログインの場合、先にログインページへ移動します。ログイン後、右下のインポートボタンを押してください。\n\n2. 時間・場所が\"未定\"の授業はインポートされません。後で手動追加してください。';

  @override
  String get hustNeedLoginError => '先にページ内でログインしてから、インポートを押してください。';

  @override
  String hustApiError(Object code) {
    return 'API が異常を返しました（code=$code）。再ログインして再試行してください。';
  }

  @override
  String hustReadFailed(Object error) {
    return '読み取りに失敗しました: $error';
  }

  @override
  String get hustTermDialogTitle => '学期を選択';

  @override
  String get hustTermDialogMessage => 'インポートする学年と学期を選択してください';

  @override
  String get hustAcademicYearLabel => '学年';

  @override
  String hustAcademicYearOption(int year) {
    return '$year学年';
  }

  @override
  String get hustSemesterLabel => '学期';

  @override
  String get hustSemesterFall => '秋学期';

  @override
  String get hustSemesterSpring => '春学期';

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
  String schedulePageCurrentWeek(int week) {
    return '第$week週';
  }

  @override
  String get schedulePageToday => '今日';

  @override
  String get schedulePageNotCurrentWeek => '今週以外';

  @override
  String get schedulePageCourseNotCurrentWeekTag => '[今週以外]';

  @override
  String schedulePageCourseTime(Object weekday, int start, int end) {
    return '$weekday ・ $start-$end限';
  }

  @override
  String get schedulePageDeleteCourse => '授業を削除';

  @override
  String get schedulePageClose => '閉じる';

  @override
  String get schedulePageToolClassTime => '授業時間';

  @override
  String get schedulePageToolScheduleSettings => '時間割設定';

  @override
  String get schedulePageToolAddedCourses => '追加済み授業';

  @override
  String get schedulePageWeekLabel => '週数';

  @override
  String get schedulePageSwitchSchedule => '時間割を切替';

  @override
  String get classTimeNewAction => '新規';

  @override
  String get classTimeCurrentTableLabel => '現在の時間割に使われる時間表';

  @override
  String get classTimeSelectHint => '右側タップで使用する時間表を選択';

  @override
  String get classTimeTableListHeader => '時間表';

  @override
  String get classTimeSwipeHint => '左スワイプで削除';

  @override
  String get classTimeDeleteTitle => '時間表を削除';

  @override
  String classTimeDeleteMessage(Object name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get classTimeSelectTitle => '時間表を選択';

  @override
  String get classTimeNewTitle => '新しい時間表';

  @override
  String get classTimeNewHint => '時間表の名前を入力';

  @override
  String get classTimeDefaultName => '時間表';

  @override
  String get classTimeEditPageTitle => '時間表を編集';

  @override
  String get classTimeCheckOrder => '時間を確認';

  @override
  String get classTimeOrderOkTitle => '問題なし';

  @override
  String classTimeOrderConflicts(int count) {
    return '$count 件の競合';
  }

  @override
  String get classTimeOrderOkMessage => 'すべてのコマに時間の競合はありません。';

  @override
  String get classTimeNameLabel => '時間表の名前';

  @override
  String get classTimeEditNameHint => '上をタップして名前を編集';

  @override
  String get classTimeSameDuration => '全コマの時間を統一';

  @override
  String get classTimeDurationLabel => 'コマの長さ（分）';

  @override
  String get classTimeDurationWarning =>
      '注意！変更すると、各コマの終了時刻は「開始時刻＋この長さ」で再計算され、\n既存の終了時刻が上書きされます。';

  @override
  String classTimeSectionLabel(int n) {
    return '第 $n コマ';
  }

  @override
  String get classTimeSectionListHint =>
      '開始時刻を調整してください。余分なコマは表示に影響しません。\n表示するコマ数を変更するには、時間割設定 › 1日のコマ数 に移動してください。';

  @override
  String get classTimeReset => 'デフォルト時刻にリセット';

  @override
  String get classTimeEditNameTitle => '名前を編集';

  @override
  String get classTimeDurationPickerTitle => 'コマの長さ（分）';

  @override
  String classTimeMinutes(int value) {
    return '$value 分';
  }

  @override
  String classTimePickerStartHelpText(int n) {
    return '第 $n コマ　開始時刻';
  }

  @override
  String classTimePickerEndHelpText(int n) {
    return '第 $n コマ　終了時刻';
  }

  @override
  String classTimeOrderEndBeforeStart(int n, Object start, Object end) {
    return '第 $n コマ：終了時刻は開始時刻より後にしてください（$start–$end）';
  }

  @override
  String classTimeOrderOverlap(int n, int m, Object end, Object start) {
    return '第 $n コマと第 $m コマが重複\n  第$nコマ終了 $end > 第$mコマ開始 $start';
  }

  @override
  String get courseEditorNameRequired => '授業名を入力してください';

  @override
  String get courseEditorWeekdayMon => '月曜';

  @override
  String get courseEditorWeekdayTue => '火曜';

  @override
  String get courseEditorWeekdayWed => '水曜';

  @override
  String get courseEditorWeekdayThu => '木曜';

  @override
  String get courseEditorWeekdayFri => '金曜';

  @override
  String get courseEditorWeekdaySat => '土曜';

  @override
  String get courseEditorWeekdaySun => '日曜';

  @override
  String courseEditorWeekNthLabel(int week) {
    return '第$week週';
  }

  @override
  String courseEditorSectionNthLabel(int section) {
    return '第$section限';
  }

  @override
  String get courseEditorWeekRangeTitle => '週範囲';

  @override
  String get courseEditorStartLabel => '開始';

  @override
  String get courseEditorEndLabel => '終了';

  @override
  String get courseEditorSelectSectionsTitle => 'コマを選択';

  @override
  String get courseEditorStartSectionLabel => '開始コマ';

  @override
  String get courseEditorEndSectionLabel => '終了コマ';

  @override
  String courseEditorTimeSlotTitle(int index) {
    return '時間枠 $index';
  }

  @override
  String get courseEditorWeeksLabel => '週数';

  @override
  String get courseEditorDayLabel => '曜日';

  @override
  String get courseEditorWeekdayTitle => '曜日';

  @override
  String get courseEditorSectionsLabel => 'コマ';

  @override
  String get courseEditorTeacherLabel => '教員';

  @override
  String get courseEditorLocationLabel => '場所';

  @override
  String get courseEditorEditTitle => '授業を編集';

  @override
  String get courseEditorAddTitle => '授業を追加';

  @override
  String get courseEditorCourseLabel => '授業';

  @override
  String get courseEditorRequiredHint => '必須';

  @override
  String get courseEditorOptionalHint => '任意';

  @override
  String get courseEditorColorLabel => '色';

  @override
  String get courseEditorCreditsLabel => '単位';

  @override
  String get courseEditorNotesLabel => 'メモ';

  @override
  String get courseEditorTimeSlotsLabel => '時間枠';

  @override
  String get courseEditorAddSlotAction => '追加';

  @override
  String get courseEditorChooseColorTitle => '色を選択';

  @override
  String get courseEditorAutoPickNoConflict => '自動選択（既存授業と衝突回避）';

  @override
  String get scheduleSettingsTitle => '時間割設定';

  @override
  String get scheduleSettingsDataTitle => '時間割データ';

  @override
  String get scheduleSettingsAppearanceTitle => '時間割の外観';

  @override
  String get scheduleSettingsAdjustToolTitle => '振替ツール';

  @override
  String get scheduleSettingsScheduleNameLabel => '時間割名';

  @override
  String get scheduleSettingsRenameTitle => '時間割名を変更';

  @override
  String get scheduleSettingsRenameHint => '時間割名を入力してください';

  @override
  String scheduleSettingsWeekDisplay(int week) {
    return '第$week週';
  }

  @override
  String scheduleSettingsMoveCourseToast(Object fromDate, Object toDate) {
    return '$fromDate から $toDate に授業を移動しました';
  }

  @override
  String get scheduleSettingsAdjustDescription =>
      '振替休日などの調整用に、ある日の授業を別の日に移動できます。慎重に操作してください。';

  @override
  String get scheduleSettingsScheduleToAdjustLabel => '調整対象の時間割';

  @override
  String get scheduleSettingsMoveFrom => '移動元';

  @override
  String get scheduleSettingsMoveCoursesSuffix => 'の授業';

  @override
  String get scheduleSettingsMoveTo => '移動先';

  @override
  String get scheduleSettingsAdjustWarning => 'この操作は取り消せません。実行前に日付を確認してください。';

  @override
  String get scheduleSettingsDeleteCoursesTitle => '授業を削除';

  @override
  String scheduleSettingsDeleteSelectedMessage(int count) {
    return '選択した$count件の授業を削除しますか？';
  }

  @override
  String get scheduleSettingsClearScheduleTitle => '時間割をクリア';

  @override
  String scheduleSettingsClearAllMessage(int count) {
    return 'この時間割の$count件の授業をすべて削除しますか？この操作は取り消せません。';
  }

  @override
  String get scheduleSettingsMoreTitle => 'その他';

  @override
  String get scheduleSettingsSelectCoursesTitle => '授業を選択';

  @override
  String scheduleSettingsSelectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String scheduleSettingsCoursesCount(int count) {
    return '$count件の授業';
  }

  @override
  String get scheduleSettingsUnselectAll => '全選択解除';

  @override
  String get scheduleSettingsSelectAll => 'すべて選択';

  @override
  String get scheduleSettingsNoCourses => '授業がありません';

  @override
  String scheduleSettingsCourseTimeItem(Object weekday, int start, int end) {
    return '$weekday  $start-$end限';
  }

  @override
  String scheduleSettingsDeleteNamedCourseMessage(Object name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get scheduleSettingsClearCurrentSchedule => '現在の時間割をクリア';

  @override
  String scheduleSettingsDeleteSelectedAction(int count) {
    return '削除 ($count)';
  }

  @override
  String get courseEditorAddSuccess => '授業を追加しました';

  @override
  String get courseEditorEditSuccess => '授業を更新しました';

  @override
  String get scheduleSettingsDeleteSuccess => '授業を削除しました';

  @override
  String scheduleSettingsDeleteSelectedSuccess(int count) {
    return '$count件の授業を削除しました';
  }

  @override
  String get scheduleSettingsClearAllSuccess => 'すべての授業をクリアしました';

  @override
  String newScheduleCreateSuccess(Object name) {
    return '時間割「$name」を作成しました';
  }

  @override
  String get exportCurrentScheduleJsonAction => '現在の時間割をJSONでエクスポート';

  @override
  String get importScheduleFromJsonAction => 'JSONから新しい時間割にインポート';

  @override
  String exportCurrentScheduleLabel(Object name) {
    return '現在の時間割: $name';
  }

  @override
  String get exportJsonSuccess => '時間割をJSONでエクスポートしました';

  @override
  String get exportJsonFailed => 'エクスポートに失敗しました。再試行してください';

  @override
  String get importJsonSuccess => '新しい時間割にインポートしました';

  @override
  String get importJsonInvalid => 'JSON形式が不正のため、インポートに失敗しました';

  @override
  String get importJsonFailed => 'インポートに失敗しました。再試行してください';

  @override
  String get importJsonNotice =>
      'インポート後は新しい時間割が自動作成され、その時間割に切り替わります。現在のデータは上書きされません。';

  @override
  String get importScheduleFallbackName => 'インポートした時間割';
}
