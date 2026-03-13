// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WakeUp 课程表';

  @override
  String get loadingSchedule => '正在加载课表...';

  @override
  String get aboutTitle => '关于';

  @override
  String get appName => 'StayUP课程表';

  @override
  String appVersionLabel(Object version) {
    return '版本 $version';
  }

  @override
  String get versionNumber => '版本号';

  @override
  String get developer => '开发者';

  @override
  String get openSourceLicense => '开源协议';

  @override
  String get checkUpdate => '检查更新';

  @override
  String get alreadyLatest => '已是最新';

  @override
  String get aboutFooter => '© 2026 StayUP Studio \n因一时兴起而制作的课程表，也希望能陪你走过很多节课';

  @override
  String get backAction => '返回';

  @override
  String get doneAction => '完成';

  @override
  String get editAction => '编辑';

  @override
  String get cancelAction => '取消';

  @override
  String get confirmAction => '确定';

  @override
  String get saveAction => '保存';

  @override
  String get deleteAction => '删除';

  @override
  String get okAction => '好的';

  @override
  String get globalSettingsTitle => '全局设置';

  @override
  String get darkMode => '深色模式';

  @override
  String get courseReminder => '课程提醒';

  @override
  String get widgetSync => '桌面小组件同步';

  @override
  String get setBackgroundFormat => '设置背景格式';

  @override
  String get helpUsage => '使用帮助';

  @override
  String get featureInDevelopmentTitle => '功能开发中';

  @override
  String get featureInDevelopmentMessage => '该功能正在开发中，敬请期待。';

  @override
  String get languageSettingLabel => '语言';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageForceChineseSimplified => '中文（简体）';

  @override
  String get languageForceChineseTraditional => '中文（繁體）';

  @override
  String get languageForceEnglish => 'English';

  @override
  String get languageForceJapanese => '日本語';

  @override
  String get manageScheduleTitle => '多课表管理';

  @override
  String get manageScheduleHint => '点右上角的编辑以排序或删除';

  @override
  String get newScheduleButton => '新建课表';

  @override
  String get deleteScheduleTitle => '删除课表';

  @override
  String deleteScheduleMessage(Object name) {
    return '确定删除「$name」？此操作不可恢复。';
  }

  @override
  String get newScheduleTitle => '新建课表';

  @override
  String get scheduleNameRequired => '请填写课表名称';

  @override
  String get scheduleNameRequiredHint => '课表名称（必填）';

  @override
  String get firstDayOfWeekOne => '第一周的第一天';

  @override
  String get weekStartDay => '一周起始天';

  @override
  String get mondayLabel => '周一';

  @override
  String get currentWeek => '当前周';

  @override
  String get autoLabel => '自动';

  @override
  String get sectionsPerDay => '一天课程节数';

  @override
  String get totalWeeks => '学期周数';

  @override
  String get exportScheduleTitle => '导出课表';

  @override
  String get exportFormatLabel => '导出格式';

  @override
  String get exportIncludeNonWeek => '包含非本周课程';

  @override
  String get exportIncludeSaturday => '包含周六';

  @override
  String get exportIncludeSunday => '包含周日';

  @override
  String get exportNow => '立即导出';

  @override
  String get exportSelectFormat => '选择格式';

  @override
  String exportSuccess(Object format) {
    return '课表已导出为 $format';
  }

  @override
  String get exportFormatPng => '图片 (PNG)';

  @override
  String get exportFormatJpg => '图片 (JPG)';

  @override
  String get exportFormatPdf => 'PDF';

  @override
  String get exportFormatIcs => 'iCalendar (.ics)';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get searchSchoolHint => '搜索学校';

  @override
  String get schoolImportTip => '在搜索框输入学校全称以快速定位';

  @override
  String get schoolImportWipMessage => '该学校的课程导入功能正在开发中，敬请期待。';

  @override
  String get schoolHust => '华中科技大学';

  @override
  String get schoolJxnu => '江西师范大学';

  @override
  String get schoolSjtu => '上海交通大学';

  @override
  String get schoolWhu => '武汉大学';

  @override
  String get schoolCuhksz => '香港中文大学（深圳）';

  @override
  String get schoolRuc => '中国人民大学';

  @override
  String get scheduleSettingsTitle => '课表设置';

  @override
  String get scheduleDataTitle => '课表数据';

  @override
  String get scheduleAppearanceLabel => '课表外观';

  @override
  String get adjustToolTitle => '调课工具';

  @override
  String get scheduleAppearanceWipMessage => '「课表外观」功能正在开发中，敬请期待。';

  @override
  String get scheduleNameLabel => '课表名称';

  @override
  String get renameScheduleTitle => '修改课表名称';

  @override
  String get enterScheduleNameHint => '请输入课表名称';

  @override
  String get classTimeTitle => '上课时间';

  @override
  String scheduleSettingsCurrentWeekDisplay(int week) {
    return '第 $week 周';
  }

  @override
  String adjustMoveSuccess(Object from, Object to) {
    return '已将 $from 的课程移动到 $to';
  }

  @override
  String get adjustDescription => '本功能用于节假日调休等场景，可以将某天的课程移动到另一天，请谨慎操作';

  @override
  String get adjustTargetSchedule => '要调整的课表';

  @override
  String get adjustFromLabel => '将';

  @override
  String get adjustCoursesSuffix => '的课程';

  @override
  String get adjustToLabel => '移动到';

  @override
  String get adjustWarning => '点击「确定」后操作不可撤销，请确认日期选择无误后再执行。';

  @override
  String get deleteCoursesTitle => '删除课程';

  @override
  String deleteSelectedCoursesMessage(int count) {
    return '确定删除已选的 $count 门课程？';
  }

  @override
  String get clearScheduleTitle => '清空课表';

  @override
  String clearScheduleMessage(int count) {
    return '确定删除当前课表全部 $count 门课程？此操作不可恢复。';
  }

  @override
  String get clearAction => '清空';

  @override
  String get moreAction => '更多';

  @override
  String get selectCoursesTitle => '选择课程';

  @override
  String selectedCoursesCount(int count) {
    return '已选 $count 门';
  }

  @override
  String get addedCoursesTitle => '已添课程';

  @override
  String totalCoursesCount(int count) {
    return '共 $count 门课程';
  }

  @override
  String get unselectAllAction => '取消全选';

  @override
  String get selectAllAction => '全选';

  @override
  String get swipeDeleteHint => '  左滑可删除';

  @override
  String get noCoursesYet => '还没有课程';

  @override
  String courseTimeSummary(Object weekday, int start, int end) {
    return '周$weekday 第$start-$end节';
  }

  @override
  String deleteCourseMessage(Object name) {
    return '确定删除「$name」？';
  }

  @override
  String get clearCurrentSchedule => '清空当前课表';

  @override
  String deleteSelectedCount(int count) {
    return '删除 ($count)';
  }

  @override
  String get addCourseAction => '添加课程';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'WakeUp 课程表';

  @override
  String get loadingSchedule => '正在加载课表...';

  @override
  String get aboutTitle => '关于';

  @override
  String get appName => 'StayUP课程表';

  @override
  String appVersionLabel(Object version) {
    return '版本 $version';
  }

  @override
  String get versionNumber => '版本号';

  @override
  String get developer => '开发者';

  @override
  String get openSourceLicense => '开源协议';

  @override
  String get checkUpdate => '检查更新';

  @override
  String get alreadyLatest => '已是最新';

  @override
  String get aboutFooter => '© 2026 StayUP Studio \n因一时兴起而制作的课程表，也希望能陪你走过很多节课';

  @override
  String get backAction => '返回';

  @override
  String get doneAction => '完成';

  @override
  String get editAction => '编辑';

  @override
  String get cancelAction => '取消';

  @override
  String get confirmAction => '确定';

  @override
  String get saveAction => '保存';

  @override
  String get deleteAction => '删除';

  @override
  String get okAction => '好的';

  @override
  String get globalSettingsTitle => '全局设置';

  @override
  String get darkMode => '深色模式';

  @override
  String get courseReminder => '课程提醒';

  @override
  String get widgetSync => '桌面小组件同步';

  @override
  String get setBackgroundFormat => '设置背景格式';

  @override
  String get helpUsage => '使用帮助';

  @override
  String get featureInDevelopmentTitle => '功能开发中';

  @override
  String get featureInDevelopmentMessage => '该功能正在开发中，敬请期待。';

  @override
  String get languageSettingLabel => '语言';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageForceChineseSimplified => '中文（简体）';

  @override
  String get languageForceChineseTraditional => '中文（繁體）';

  @override
  String get languageForceEnglish => 'English';

  @override
  String get languageForceJapanese => '日本語';

  @override
  String get manageScheduleTitle => '多课表管理';

  @override
  String get manageScheduleHint => '点右上角的编辑以排序或删除';

  @override
  String get newScheduleButton => '新建课表';

  @override
  String get deleteScheduleTitle => '删除课表';

  @override
  String deleteScheduleMessage(Object name) {
    return '确定删除「$name」？此操作不可恢复。';
  }

  @override
  String get newScheduleTitle => '新建课表';

  @override
  String get scheduleNameRequired => '请填写课表名称';

  @override
  String get scheduleNameRequiredHint => '课表名称（必填）';

  @override
  String get firstDayOfWeekOne => '第一周的第一天';

  @override
  String get weekStartDay => '一周起始天';

  @override
  String get mondayLabel => '周一';

  @override
  String get currentWeek => '当前周';

  @override
  String get autoLabel => '自动';

  @override
  String get sectionsPerDay => '一天课程节数';

  @override
  String get totalWeeks => '学期周数';

  @override
  String get exportScheduleTitle => '导出课表';

  @override
  String get exportFormatLabel => '导出格式';

  @override
  String get exportIncludeNonWeek => '包含非本周课程';

  @override
  String get exportIncludeSaturday => '包含周六';

  @override
  String get exportIncludeSunday => '包含周日';

  @override
  String get exportNow => '立即导出';

  @override
  String get exportSelectFormat => '选择格式';

  @override
  String exportSuccess(Object format) {
    return '课表已导出为 $format';
  }

  @override
  String get exportFormatPng => '图片 (PNG)';

  @override
  String get exportFormatJpg => '图片 (JPG)';

  @override
  String get exportFormatPdf => 'PDF';

  @override
  String get exportFormatIcs => 'iCalendar (.ics)';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get searchSchoolHint => '搜索学校';

  @override
  String get schoolImportTip => '在搜索框输入学校全称以快速定位';

  @override
  String get schoolImportWipMessage => '该学校的课程导入功能正在开发中，敬请期待。';

  @override
  String get schoolHust => '华中科技大学';

  @override
  String get schoolJxnu => '江西师范大学';

  @override
  String get schoolSjtu => '上海交通大学';

  @override
  String get schoolWhu => '武汉大学';

  @override
  String get schoolCuhksz => '香港中文大学（深圳）';

  @override
  String get schoolRuc => '中国人民大学';

  @override
  String get scheduleSettingsTitle => '课表设置';

  @override
  String get scheduleDataTitle => '课表数据';

  @override
  String get scheduleAppearanceLabel => '课表外观';

  @override
  String get adjustToolTitle => '调课工具';

  @override
  String get scheduleAppearanceWipMessage => '「课表外观」功能正在开发中，敬请期待。';

  @override
  String get scheduleNameLabel => '课表名称';

  @override
  String get renameScheduleTitle => '修改课表名称';

  @override
  String get enterScheduleNameHint => '请输入课表名称';

  @override
  String get classTimeTitle => '上课时间';

  @override
  String scheduleSettingsCurrentWeekDisplay(int week) {
    return '第 $week 周';
  }

  @override
  String adjustMoveSuccess(Object from, Object to) {
    return '已将 $from 的课程移动到 $to';
  }

  @override
  String get adjustDescription => '本功能用于节假日调休等场景，可以将某天的课程移动到另一天，请谨慎操作';

  @override
  String get adjustTargetSchedule => '要调整的课表';

  @override
  String get adjustFromLabel => '将';

  @override
  String get adjustCoursesSuffix => '的课程';

  @override
  String get adjustToLabel => '移动到';

  @override
  String get adjustWarning => '点击「确定」后操作不可撤销，请确认日期选择无误后再执行。';

  @override
  String get deleteCoursesTitle => '删除课程';

  @override
  String deleteSelectedCoursesMessage(int count) {
    return '确定删除已选的 $count 门课程？';
  }

  @override
  String get clearScheduleTitle => '清空课表';

  @override
  String clearScheduleMessage(int count) {
    return '确定删除当前课表全部 $count 门课程？此操作不可恢复。';
  }

  @override
  String get clearAction => '清空';

  @override
  String get moreAction => '更多';

  @override
  String get selectCoursesTitle => '选择课程';

  @override
  String selectedCoursesCount(int count) {
    return '已选 $count 门';
  }

  @override
  String get addedCoursesTitle => '已添课程';

  @override
  String totalCoursesCount(int count) {
    return '共 $count 门课程';
  }

  @override
  String get unselectAllAction => '取消全选';

  @override
  String get selectAllAction => '全选';

  @override
  String get swipeDeleteHint => '  左滑可删除';

  @override
  String get noCoursesYet => '还没有课程';

  @override
  String courseTimeSummary(Object weekday, int start, int end) {
    return '周$weekday 第$start-$end节';
  }

  @override
  String deleteCourseMessage(Object name) {
    return '确定删除「$name」？';
  }

  @override
  String get clearCurrentSchedule => '清空当前课表';

  @override
  String deleteSelectedCount(int count) {
    return '删除 ($count)';
  }

  @override
  String get addCourseAction => '添加课程';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'WakeUp 課表';

  @override
  String get loadingSchedule => '正在載入課表...';

  @override
  String get aboutTitle => '關於';

  @override
  String get appName => 'StayUP課表';

  @override
  String appVersionLabel(Object version) {
    return '版本 $version';
  }

  @override
  String get versionNumber => '版本號';

  @override
  String get developer => '開發者';

  @override
  String get openSourceLicense => '開源協議';

  @override
  String get checkUpdate => '檢查更新';

  @override
  String get alreadyLatest => '已是最新';

  @override
  String get aboutFooter => '© 2026 StayUP Studio \n因一時興起而製作的課表，也希望能陪你走過很多節課';

  @override
  String get backAction => '返回';

  @override
  String get doneAction => '完成';

  @override
  String get editAction => '編輯';

  @override
  String get cancelAction => '取消';

  @override
  String get confirmAction => '確定';

  @override
  String get saveAction => '保存';

  @override
  String get deleteAction => '刪除';

  @override
  String get okAction => '好的';

  @override
  String get globalSettingsTitle => '全域設定';

  @override
  String get darkMode => '深色模式';

  @override
  String get courseReminder => '課程提醒';

  @override
  String get widgetSync => '桌面小工具同步';

  @override
  String get setBackgroundFormat => '設定背景格式';

  @override
  String get helpUsage => '使用說明';

  @override
  String get featureInDevelopmentTitle => '功能開發中';

  @override
  String get featureInDevelopmentMessage => '該功能正在開發中，敬請期待。';

  @override
  String get languageSettingLabel => '語言';

  @override
  String get languageFollowSystem => '跟隨系統';

  @override
  String get languageForceChineseSimplified => '中文（简体）';

  @override
  String get languageForceChineseTraditional => '中文（繁體）';

  @override
  String get languageForceEnglish => 'English';

  @override
  String get languageForceJapanese => '日本語';

  @override
  String get manageScheduleTitle => '多課表管理';

  @override
  String get manageScheduleHint => '點右上角的編輯以排序或刪除';

  @override
  String get newScheduleButton => '新建課表';

  @override
  String get deleteScheduleTitle => '刪除課表';

  @override
  String deleteScheduleMessage(Object name) {
    return '確定刪除「$name」？此操作不可恢復。';
  }

  @override
  String get newScheduleTitle => '新建課表';

  @override
  String get scheduleNameRequired => '請填寫課表名稱';

  @override
  String get scheduleNameRequiredHint => '課表名稱（必填）';

  @override
  String get firstDayOfWeekOne => '第一週的第一天';

  @override
  String get weekStartDay => '一週起始天';

  @override
  String get mondayLabel => '週一';

  @override
  String get currentWeek => '當前週';

  @override
  String get autoLabel => '自動';

  @override
  String get sectionsPerDay => '一天課程節數';

  @override
  String get totalWeeks => '學期週數';

  @override
  String get exportScheduleTitle => '導出課表';

  @override
  String get exportFormatLabel => '導出格式';

  @override
  String get exportIncludeNonWeek => '包含非本週課程';

  @override
  String get exportIncludeSaturday => '包含週六';

  @override
  String get exportIncludeSunday => '包含週日';

  @override
  String get exportNow => '立即導出';

  @override
  String get exportSelectFormat => '選擇格式';

  @override
  String exportSuccess(Object format) {
    return '課表已導出為 $format';
  }

  @override
  String get exportFormatPng => '圖片 (PNG)';

  @override
  String get exportFormatJpg => '圖片 (JPG)';

  @override
  String get exportFormatPdf => 'PDF';

  @override
  String get exportFormatIcs => 'iCalendar (.ics)';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get searchSchoolHint => '搜尋學校';

  @override
  String get schoolImportTip => '在搜尋框輸入學校全稱以快速定位';

  @override
  String get schoolImportWipMessage => '該學校的課程導入功能正在開發中，敬請期待。';

  @override
  String get schoolHust => '華中科技大學';

  @override
  String get schoolJxnu => '江西師範大學';

  @override
  String get schoolSjtu => '上海交通大學';

  @override
  String get schoolWhu => '武漢大學';

  @override
  String get schoolCuhksz => '香港中文大學（深圳）';

  @override
  String get schoolRuc => '中國人民大學';

  @override
  String get scheduleSettingsTitle => '課表設定';

  @override
  String get scheduleDataTitle => '課表資料';

  @override
  String get scheduleAppearanceLabel => '課表外觀';

  @override
  String get adjustToolTitle => '調課工具';

  @override
  String get scheduleAppearanceWipMessage => '「課表外觀」功能正在開發中，敬請期待。';

  @override
  String get scheduleNameLabel => '課表名稱';

  @override
  String get renameScheduleTitle => '修改課表名稱';

  @override
  String get enterScheduleNameHint => '請輸入課表名稱';

  @override
  String get classTimeTitle => '上課時間';

  @override
  String scheduleSettingsCurrentWeekDisplay(int week) {
    return '第 $week 週';
  }

  @override
  String adjustMoveSuccess(Object from, Object to) {
    return '已將 $from 的課程移動到 $to';
  }

  @override
  String get adjustDescription => '本功能用於節假日調休等場景，可以將某天的課程移動到另一天，請謹慎操作';

  @override
  String get adjustTargetSchedule => '要調整的課表';

  @override
  String get adjustFromLabel => '將';

  @override
  String get adjustCoursesSuffix => '的課程';

  @override
  String get adjustToLabel => '移動到';

  @override
  String get adjustWarning => '點擊「確定」後操作不可撤銷，請確認日期選擇無誤後再執行。';

  @override
  String get deleteCoursesTitle => '刪除課程';

  @override
  String deleteSelectedCoursesMessage(int count) {
    return '確定刪除已選的 $count 門課程？';
  }

  @override
  String get clearScheduleTitle => '清空課表';

  @override
  String clearScheduleMessage(int count) {
    return '確定刪除當前課表全部 $count 門課程？此操作不可恢復。';
  }

  @override
  String get clearAction => '清空';

  @override
  String get moreAction => '更多';

  @override
  String get selectCoursesTitle => '選擇課程';

  @override
  String selectedCoursesCount(int count) {
    return '已選 $count 門';
  }

  @override
  String get addedCoursesTitle => '已添課程';

  @override
  String totalCoursesCount(int count) {
    return '共 $count 門課程';
  }

  @override
  String get unselectAllAction => '取消全選';

  @override
  String get selectAllAction => '全選';

  @override
  String get swipeDeleteHint => '  左滑可刪除';

  @override
  String get noCoursesYet => '還沒有課程';

  @override
  String courseTimeSummary(Object weekday, int start, int end) {
    return '週$weekday 第$start-$end節';
  }

  @override
  String deleteCourseMessage(Object name) {
    return '確定刪除「$name」？';
  }

  @override
  String get clearCurrentSchedule => '清空當前課表';

  @override
  String deleteSelectedCount(int count) {
    return '刪除 ($count)';
  }

  @override
  String get addCourseAction => '添加課程';
}
