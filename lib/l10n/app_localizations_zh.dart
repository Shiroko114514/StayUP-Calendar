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
  String get appName => 'StayUP 课程表';

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
  String get darkMode => '外观';

  @override
  String get themeModeFollowSystem => '跟随系统';

  @override
  String get themeModeLight => '亮色';

  @override
  String get themeModeDark => '深色';

  @override
  String get courseReminder => '课程提醒';

  @override
  String get widgetSync => '桌面小组件同步';

  @override
  String get setBackgroundFormat => '设置背景格式';

  @override
  String get materialDynamicColor => 'Material 动态取色';

  @override
  String get helpUsage => '使用帮助';

  @override
  String get featureInDevelopmentTitle => '功能开发中';

  @override
  String get featureInDevelopmentMessage => '该功能正在开发中，敬请期待。';

  @override
  String get languageSettingLabel => '语言';

  @override
  String get dateFormatSettingLabel => '日期格式';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageChangedRestartTitle => '语言已切换';

  @override
  String get languageChangedRestartMessage => '应用将自动退出以应用新语言，请重新打开。';

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
  String get schoolImportMoreSchools => '更多高校正在适配中';

  @override
  String get schoolImportNoticeTitle => '注意事项';

  @override
  String get schoolImportParseDoneTitle => '解析完成';

  @override
  String schoolImportParseDoneMessage(int count) {
    return '共解析到 $count 门课程，是否新建课表并导入？';
  }

  @override
  String get schoolImportAction => '导入';

  @override
  String schoolImportSuccess(int count) {
    return '已新建课表并导入 $count 门课程';
  }

  @override
  String get schoolImportErrorTitle => '错误';

  @override
  String get schoolImportParsing => '解析中...';

  @override
  String get schoolImportScheduleAction => '导入课表';

  @override
  String get schoolImportResetLoginAction => '重新登录';

  @override
  String get schoolImportResetLoginTitle => '清除登录状态';

  @override
  String get schoolImportResetLoginMessage =>
      '这会清除当前内置浏览器中的所有登录 Cookie，并重新打开登录入口。确定继续吗？';

  @override
  String get schoolImportResetLoginSuccess => '已清除登录状态，请重新登录';

  @override
  String schoolImportResetLoginFailed(Object error) {
    return '清除登录状态失败：$error';
  }

  @override
  String schoolImportScheduleName(Object school, int month, int day) {
    return '$school导入 $month/$day';
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
      '1. 若未登录会先跳转到登录页，登录后点击右下角导入按钮\n\n2. 时间地点为\"待定\"的课程不会导入，请后续手动添加';

  @override
  String get hustNeedLoginError => '请先在页面中完成登录，然后再点击导入按钮';

  @override
  String hustApiError(Object code) {
    return '接口返回异常（code=$code），请重新登录后再试';
  }

  @override
  String hustReadFailed(Object error) {
    return '读取失败：$error';
  }

  @override
  String get hustTermDialogTitle => '选择学期';

  @override
  String get hustTermDialogMessage => '请选择要导入的学年与学期';

  @override
  String get hustAcademicYearLabel => '学年';

  @override
  String hustAcademicYearOption(int year) {
    return '$year学年';
  }

  @override
  String get hustSemesterLabel => '学期';

  @override
  String get hustSemesterFall => '秋季学期';

  @override
  String get hustSemesterSpring => '春季学期';

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
  String schedulePageCurrentWeek(int week) {
    return '第$week周';
  }

  @override
  String get schedulePageToday => '今天';

  @override
  String get schedulePageNotCurrentWeek => '非本周';

  @override
  String get schedulePageCourseNotCurrentWeekTag => '[非本周]';

  @override
  String schedulePageCourseTime(Object weekday, int start, int end) {
    return '周$weekday · 第$start-$end节';
  }

  @override
  String get schedulePageDeleteCourse => '删除课程';

  @override
  String get schedulePageClose => '关闭';

  @override
  String get schedulePageToolClassTime => '上课时间';

  @override
  String get schedulePageToolScheduleSettings => '课表设置';

  @override
  String get schedulePageToolAddedCourses => '已添课程';

  @override
  String get schedulePageWeekLabel => '周数';

  @override
  String get schedulePageSwitchSchedule => '切换课表';

  @override
  String get classTimeNewAction => '新建';

  @override
  String get classTimeCurrentTableLabel => '当前课表显示的时间表';

  @override
  String get classTimeSelectHint => '轻触右侧选择当前使用的时间表';

  @override
  String get classTimeTableListHeader => '时间表';

  @override
  String get classTimeSwipeHint => '条目上左划删除';

  @override
  String get classTimeDeleteTitle => '删除时间表';

  @override
  String classTimeDeleteMessage(Object name) {
    return '确定删除「$name」？';
  }

  @override
  String get classTimeSelectTitle => '选择时间表';

  @override
  String get classTimeNewTitle => '新建时间表';

  @override
  String get classTimeNewHint => '请输入时间表名称';

  @override
  String get classTimeDefaultName => '时间表';

  @override
  String get classTimeEditPageTitle => '时间表编辑';

  @override
  String get classTimeCheckOrder => '检查时间顺序';

  @override
  String get classTimeOrderOkTitle => '时间顺序正常';

  @override
  String classTimeOrderConflicts(int count) {
    return '发现 $count 处冲突';
  }

  @override
  String get classTimeOrderOkMessage => '所有节次时间区间无冲突，顺序正确。';

  @override
  String get classTimeNameLabel => '时间表名称';

  @override
  String get classTimeEditNameHint => '轻触上方以编辑名称';

  @override
  String get classTimeSameDuration => '每节课时长相同';

  @override
  String get classTimeDurationLabel => '每节课时长（分钟）';

  @override
  String get classTimeDurationWarning =>
      '谨慎调整此项！调整后，将会根据每节课的「上课时间」，\n加上这个时长，来计算并更新「下课时间」，这意味着原来设置的下课时间会被覆盖！';

  @override
  String classTimeSectionLabel(int n) {
    return '第 $n 节';
  }

  @override
  String get classTimeSectionListHint =>
      '调整时间，多余的节数不用管\n如果想修改课表显示的节数，请去「课表设置」中的「每天节次数」';

  @override
  String get classTimeReset => '重置为默认时间';

  @override
  String get classTimeEditNameTitle => '编辑名称';

  @override
  String get classTimeDurationPickerTitle => '每节课时长（分钟）';

  @override
  String classTimeMinutes(int value) {
    return '$value 分钟';
  }

  @override
  String classTimePickerStartHelpText(int n) {
    return '第 $n 节  开始时间';
  }

  @override
  String classTimePickerEndHelpText(int n) {
    return '第 $n 节  结束时间';
  }

  @override
  String classTimeOrderEndBeforeStart(int n, Object start, Object end) {
    return '第 $n 节：结束时间不能早于或等于开始时间（$start – $end）';
  }

  @override
  String classTimeOrderOverlap(int n, int m, Object end, Object start) {
    return '第 $n 节与第 $m 节时间重叠\n  第$n节结束 $end > 第$m节开始 $start';
  }

  @override
  String get courseEditorNameRequired => '请填写课程名称';

  @override
  String get courseEditorWeekdayMon => '周一';

  @override
  String get courseEditorWeekdayTue => '周二';

  @override
  String get courseEditorWeekdayWed => '周三';

  @override
  String get courseEditorWeekdayThu => '周四';

  @override
  String get courseEditorWeekdayFri => '周五';

  @override
  String get courseEditorWeekdaySat => '周六';

  @override
  String get courseEditorWeekdaySun => '周日';

  @override
  String courseEditorWeekNthLabel(int week) {
    return '第$week周';
  }

  @override
  String courseEditorSectionNthLabel(int section) {
    return '第$section节';
  }

  @override
  String get courseEditorWeekRangeTitle => '周数';

  @override
  String get courseEditorStartLabel => '开始';

  @override
  String get courseEditorEndLabel => '结束';

  @override
  String get courseEditorSelectSectionsTitle => '选择节次';

  @override
  String get courseEditorStartSectionLabel => '开始节';

  @override
  String get courseEditorEndSectionLabel => '结束节';

  @override
  String courseEditorTimeSlotTitle(int index) {
    return '时间段 $index';
  }

  @override
  String get courseEditorWeeksLabel => '周数';

  @override
  String get courseEditorDayLabel => '时间';

  @override
  String get courseEditorWeekdayTitle => '星期';

  @override
  String get courseEditorSectionsLabel => '节次';

  @override
  String get courseEditorTeacherLabel => '老师';

  @override
  String get courseEditorLocationLabel => '地点';

  @override
  String get courseEditorEditTitle => '编辑课程';

  @override
  String get courseEditorAddTitle => '添加课程';

  @override
  String get courseEditorCourseLabel => '课程';

  @override
  String get courseEditorRequiredHint => '必填';

  @override
  String get courseEditorOptionalHint => '选填';

  @override
  String get courseEditorColorLabel => '颜色';

  @override
  String get courseEditorCreditsLabel => '学分';

  @override
  String get courseEditorNotesLabel => '备注';

  @override
  String get courseEditorTimeSlotsLabel => '时间段';

  @override
  String get courseEditorAddSlotAction => '添加';

  @override
  String get courseEditorChooseColorTitle => '选择颜色';

  @override
  String get courseEditorAutoPickNoConflict => '自动选色（不与已有课程冲突）';

  @override
  String get scheduleSettingsTitle => '课表设置';

  @override
  String get scheduleSettingsDataTitle => '课表数据';

  @override
  String get scheduleSettingsAppearanceTitle => '课表外观';

  @override
  String get scheduleSettingsAdjustToolTitle => '调课工具';

  @override
  String get scheduleSettingsScheduleNameLabel => '课表名称';

  @override
  String get scheduleSettingsRenameTitle => '修改课表名称';

  @override
  String get scheduleSettingsRenameHint => '请输入课表名称';

  @override
  String scheduleSettingsWeekDisplay(int week) {
    return '第 $week 周';
  }

  @override
  String scheduleSettingsMoveCourseToast(Object fromDate, Object toDate) {
    return '已将 $fromDate 的课程移动到 $toDate';
  }

  @override
  String get scheduleSettingsAdjustDescription =>
      '本功能用于节假日调休等场景，可以将某天的课程移动到另一天，请谨慎操作';

  @override
  String get scheduleSettingsScheduleToAdjustLabel => '要调整的课表';

  @override
  String get scheduleSettingsMoveFrom => '将';

  @override
  String get scheduleSettingsMoveCoursesSuffix => '的课程';

  @override
  String get scheduleSettingsMoveTo => '移动到';

  @override
  String get scheduleSettingsAdjustWarning => '点击「确定」后操作不可撤销，请确认日期选择无误后再执行。';

  @override
  String get scheduleSettingsDeleteCoursesTitle => '删除课程';

  @override
  String scheduleSettingsDeleteSelectedMessage(int count) {
    return '确定删除已选的 $count 门课程？';
  }

  @override
  String get scheduleSettingsClearScheduleTitle => '清空课表';

  @override
  String scheduleSettingsClearAllMessage(int count) {
    return '确定删除当前课表全部 $count 门课程？此操作不可恢复。';
  }

  @override
  String get scheduleSettingsMoreTitle => '更多';

  @override
  String get scheduleSettingsSelectCoursesTitle => '选择课程';

  @override
  String scheduleSettingsSelectedCount(int count) {
    return '已选 $count 门';
  }

  @override
  String scheduleSettingsCoursesCount(int count) {
    return '共 $count 门课程';
  }

  @override
  String get scheduleSettingsUnselectAll => '取消全选';

  @override
  String get scheduleSettingsSelectAll => '全选';

  @override
  String get scheduleSettingsNoCourses => '还没有课程';

  @override
  String scheduleSettingsCourseTimeItem(Object weekday, int start, int end) {
    return '周$weekday  第$start–$end节';
  }

  @override
  String scheduleSettingsDeleteNamedCourseMessage(Object name) {
    return '确定删除「$name」？';
  }

  @override
  String get scheduleSettingsClearCurrentSchedule => '清空当前课表';

  @override
  String scheduleSettingsDeleteSelectedAction(int count) {
    return '删除 ($count)';
  }

  @override
  String get courseEditorAddSuccess => '已添加课程';

  @override
  String get courseEditorEditSuccess => '已修改课程';

  @override
  String get scheduleSettingsDeleteSuccess => '已删除课程';

  @override
  String scheduleSettingsDeleteSelectedSuccess(int count) {
    return '已删除 $count 门课程';
  }

  @override
  String get scheduleSettingsClearAllSuccess => '已清空全部课程';

  @override
  String newScheduleCreateSuccess(Object name) {
    return '已创建新课表：$name';
  }
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
  String get appName => 'StayUP 课程表';

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
  String get darkMode => '外观';

  @override
  String get themeModeFollowSystem => '跟随系统';

  @override
  String get themeModeLight => '亮色';

  @override
  String get themeModeDark => '深色';

  @override
  String get courseReminder => '课程提醒';

  @override
  String get widgetSync => '桌面小组件同步';

  @override
  String get setBackgroundFormat => '设置背景格式';

  @override
  String get materialDynamicColor => 'Material 动态取色';

  @override
  String get helpUsage => '使用帮助';

  @override
  String get featureInDevelopmentTitle => '功能开发中';

  @override
  String get featureInDevelopmentMessage => '该功能正在开发中，敬请期待。';

  @override
  String get languageSettingLabel => '语言';

  @override
  String get dateFormatSettingLabel => '日期格式';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageChangedRestartTitle => '语言已切换';

  @override
  String get languageChangedRestartMessage => '应用将自动退出以应用新语言，请重新打开。';

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
  String get schoolImportMoreSchools => '更多高校正在适配中';

  @override
  String get schoolImportNoticeTitle => '注意事项';

  @override
  String get schoolImportParseDoneTitle => '解析完成';

  @override
  String schoolImportParseDoneMessage(int count) {
    return '共解析到 $count 门课程，是否新建课表并导入？';
  }

  @override
  String get schoolImportAction => '导入';

  @override
  String schoolImportSuccess(int count) {
    return '已新建课表并导入 $count 门课程';
  }

  @override
  String get schoolImportErrorTitle => '错误';

  @override
  String get schoolImportParsing => '解析中...';

  @override
  String get schoolImportScheduleAction => '导入课表';

  @override
  String get schoolImportResetLoginAction => '重新登录';

  @override
  String get schoolImportResetLoginTitle => '清除登录状态';

  @override
  String get schoolImportResetLoginMessage =>
      '这会清除当前内置浏览器中的所有登录 Cookie，并重新打开登录入口。确定继续吗？';

  @override
  String get schoolImportResetLoginSuccess => '已清除登录状态，请重新登录';

  @override
  String schoolImportResetLoginFailed(Object error) {
    return '清除登录状态失败：$error';
  }

  @override
  String schoolImportScheduleName(Object school, int month, int day) {
    return '$school导入 $month/$day';
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
      '1. 若未登录会先跳转到登录页，登录后点击右下角导入按钮\n\n2. 时间地点为\"待定\"的课程不会导入，请后续手动添加';

  @override
  String get hustNeedLoginError => '请先在页面中完成登录，然后再点击导入按钮';

  @override
  String hustApiError(Object code) {
    return '接口返回异常（code=$code），请重新登录后再试';
  }

  @override
  String hustReadFailed(Object error) {
    return '读取失败：$error';
  }

  @override
  String get hustTermDialogTitle => '选择学期';

  @override
  String get hustTermDialogMessage => '请选择要导入的学年与学期';

  @override
  String get hustAcademicYearLabel => '学年';

  @override
  String hustAcademicYearOption(int year) {
    return '$year学年';
  }

  @override
  String get hustSemesterLabel => '学期';

  @override
  String get hustSemesterFall => '秋季学期';

  @override
  String get hustSemesterSpring => '春季学期';

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
  String schedulePageCurrentWeek(int week) {
    return '第$week周';
  }

  @override
  String get schedulePageToday => '今天';

  @override
  String get schedulePageNotCurrentWeek => '非本周';

  @override
  String get schedulePageCourseNotCurrentWeekTag => '[非本周]';

  @override
  String schedulePageCourseTime(Object weekday, int start, int end) {
    return '周$weekday · 第$start-$end节';
  }

  @override
  String get schedulePageDeleteCourse => '删除课程';

  @override
  String get schedulePageClose => '关闭';

  @override
  String get schedulePageToolClassTime => '上课时间';

  @override
  String get schedulePageToolScheduleSettings => '课表设置';

  @override
  String get schedulePageToolAddedCourses => '已添课程';

  @override
  String get schedulePageWeekLabel => '周数';

  @override
  String get schedulePageSwitchSchedule => '切换课表';

  @override
  String get classTimeNewAction => '新建';

  @override
  String get classTimeCurrentTableLabel => '当前课表显示的时间表';

  @override
  String get classTimeSelectHint => '轻触右侧选择当前使用的时间表';

  @override
  String get classTimeTableListHeader => '时间表';

  @override
  String get classTimeSwipeHint => '条目上左划删除';

  @override
  String get classTimeDeleteTitle => '删除时间表';

  @override
  String classTimeDeleteMessage(Object name) {
    return '确定删除「$name」？';
  }

  @override
  String get classTimeSelectTitle => '选择时间表';

  @override
  String get classTimeNewTitle => '新建时间表';

  @override
  String get classTimeNewHint => '请输入时间表名称';

  @override
  String get classTimeDefaultName => '时间表';

  @override
  String get classTimeEditPageTitle => '时间表编辑';

  @override
  String get classTimeCheckOrder => '检查时间顺序';

  @override
  String get classTimeOrderOkTitle => '时间顺序正常';

  @override
  String classTimeOrderConflicts(int count) {
    return '发现 $count 处冲突';
  }

  @override
  String get classTimeOrderOkMessage => '所有节次时间区间无冲突，顺序正确。';

  @override
  String get classTimeNameLabel => '时间表名称';

  @override
  String get classTimeEditNameHint => '轻触上方以编辑名称';

  @override
  String get classTimeSameDuration => '每节课时长相同';

  @override
  String get classTimeDurationLabel => '每节课时长（分钟）';

  @override
  String get classTimeDurationWarning =>
      '谨慎调整此项！调整后，将会根据每节课的「上课时间」，\n加上这个时长，来计算并更新「下课时间」，这意味着原来设置的下课时间会被覆盖！';

  @override
  String classTimeSectionLabel(int n) {
    return '第 $n 节';
  }

  @override
  String get classTimeSectionListHint =>
      '调整时间，多余的节数不用管\n如果想修改课表显示的节数，请去「课表设置」中的「每天节次数」';

  @override
  String get classTimeReset => '重置为默认时间';

  @override
  String get classTimeEditNameTitle => '编辑名称';

  @override
  String get classTimeDurationPickerTitle => '每节课时长（分钟）';

  @override
  String classTimeMinutes(int value) {
    return '$value 分钟';
  }

  @override
  String classTimePickerStartHelpText(int n) {
    return '第 $n 节  开始时间';
  }

  @override
  String classTimePickerEndHelpText(int n) {
    return '第 $n 节  结束时间';
  }

  @override
  String classTimeOrderEndBeforeStart(int n, Object start, Object end) {
    return '第 $n 节：结束时间不能早于或等于开始时间（$start – $end）';
  }

  @override
  String classTimeOrderOverlap(int n, int m, Object end, Object start) {
    return '第 $n 节与第 $m 节时间重叠\n  第$n节结束 $end > 第$m节开始 $start';
  }

  @override
  String get courseEditorNameRequired => '请填写课程名称';

  @override
  String get courseEditorWeekdayMon => '周一';

  @override
  String get courseEditorWeekdayTue => '周二';

  @override
  String get courseEditorWeekdayWed => '周三';

  @override
  String get courseEditorWeekdayThu => '周四';

  @override
  String get courseEditorWeekdayFri => '周五';

  @override
  String get courseEditorWeekdaySat => '周六';

  @override
  String get courseEditorWeekdaySun => '周日';

  @override
  String courseEditorWeekNthLabel(int week) {
    return '第$week周';
  }

  @override
  String courseEditorSectionNthLabel(int section) {
    return '第$section节';
  }

  @override
  String get courseEditorWeekRangeTitle => '周数';

  @override
  String get courseEditorStartLabel => '开始';

  @override
  String get courseEditorEndLabel => '结束';

  @override
  String get courseEditorSelectSectionsTitle => '选择节次';

  @override
  String get courseEditorStartSectionLabel => '开始节';

  @override
  String get courseEditorEndSectionLabel => '结束节';

  @override
  String courseEditorTimeSlotTitle(int index) {
    return '时间段 $index';
  }

  @override
  String get courseEditorWeeksLabel => '周数';

  @override
  String get courseEditorDayLabel => '时间';

  @override
  String get courseEditorWeekdayTitle => '星期';

  @override
  String get courseEditorSectionsLabel => '节次';

  @override
  String get courseEditorTeacherLabel => '老师';

  @override
  String get courseEditorLocationLabel => '地点';

  @override
  String get courseEditorEditTitle => '编辑课程';

  @override
  String get courseEditorAddTitle => '添加课程';

  @override
  String get courseEditorCourseLabel => '课程';

  @override
  String get courseEditorRequiredHint => '必填';

  @override
  String get courseEditorOptionalHint => '选填';

  @override
  String get courseEditorColorLabel => '颜色';

  @override
  String get courseEditorCreditsLabel => '学分';

  @override
  String get courseEditorNotesLabel => '备注';

  @override
  String get courseEditorTimeSlotsLabel => '时间段';

  @override
  String get courseEditorAddSlotAction => '添加';

  @override
  String get courseEditorChooseColorTitle => '选择颜色';

  @override
  String get courseEditorAutoPickNoConflict => '自动选色（不与已有课程冲突）';

  @override
  String get scheduleSettingsTitle => '课表设置';

  @override
  String get scheduleSettingsDataTitle => '课表数据';

  @override
  String get scheduleSettingsAppearanceTitle => '课表外观';

  @override
  String get scheduleSettingsAdjustToolTitle => '调课工具';

  @override
  String get scheduleSettingsScheduleNameLabel => '课表名称';

  @override
  String get scheduleSettingsRenameTitle => '修改课表名称';

  @override
  String get scheduleSettingsRenameHint => '请输入课表名称';

  @override
  String scheduleSettingsWeekDisplay(int week) {
    return '第 $week 周';
  }

  @override
  String scheduleSettingsMoveCourseToast(Object fromDate, Object toDate) {
    return '已将 $fromDate 的课程移动到 $toDate';
  }

  @override
  String get scheduleSettingsAdjustDescription =>
      '本功能用于节假日调休等场景，可以将某天的课程移动到另一天，请谨慎操作';

  @override
  String get scheduleSettingsScheduleToAdjustLabel => '要调整的课表';

  @override
  String get scheduleSettingsMoveFrom => '将';

  @override
  String get scheduleSettingsMoveCoursesSuffix => '的课程';

  @override
  String get scheduleSettingsMoveTo => '移动到';

  @override
  String get scheduleSettingsAdjustWarning => '点击「确定」后操作不可撤销，请确认日期选择无误后再执行。';

  @override
  String get scheduleSettingsDeleteCoursesTitle => '删除课程';

  @override
  String scheduleSettingsDeleteSelectedMessage(int count) {
    return '确定删除已选的 $count 门课程？';
  }

  @override
  String get scheduleSettingsClearScheduleTitle => '清空课表';

  @override
  String scheduleSettingsClearAllMessage(int count) {
    return '确定删除当前课表全部 $count 门课程？此操作不可恢复。';
  }

  @override
  String get scheduleSettingsMoreTitle => '更多';

  @override
  String get scheduleSettingsSelectCoursesTitle => '选择课程';

  @override
  String scheduleSettingsSelectedCount(int count) {
    return '已选 $count 门';
  }

  @override
  String scheduleSettingsCoursesCount(int count) {
    return '共 $count 门课程';
  }

  @override
  String get scheduleSettingsUnselectAll => '取消全选';

  @override
  String get scheduleSettingsSelectAll => '全选';

  @override
  String get scheduleSettingsNoCourses => '还没有课程';

  @override
  String scheduleSettingsCourseTimeItem(Object weekday, int start, int end) {
    return '周$weekday  第$start–$end节';
  }

  @override
  String scheduleSettingsDeleteNamedCourseMessage(Object name) {
    return '确定删除「$name」？';
  }

  @override
  String get scheduleSettingsClearCurrentSchedule => '清空当前课表';

  @override
  String scheduleSettingsDeleteSelectedAction(int count) {
    return '删除 ($count)';
  }

  @override
  String get courseEditorAddSuccess => '已添加课程';

  @override
  String get courseEditorEditSuccess => '已修改课程';

  @override
  String get scheduleSettingsDeleteSuccess => '已删除课程';

  @override
  String scheduleSettingsDeleteSelectedSuccess(int count) {
    return '已删除 $count 门课程';
  }

  @override
  String get scheduleSettingsClearAllSuccess => '已清空全部课程';

  @override
  String newScheduleCreateSuccess(Object name) {
    return '已创建新课表：$name';
  }
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
  String get darkMode => '外觀';

  @override
  String get themeModeFollowSystem => '跟隨系統';

  @override
  String get themeModeLight => '亮色';

  @override
  String get themeModeDark => '深色';

  @override
  String get courseReminder => '課程提醒';

  @override
  String get widgetSync => '桌面小工具同步';

  @override
  String get setBackgroundFormat => '設定背景格式';

  @override
  String get materialDynamicColor => 'Material 動態取色';

  @override
  String get helpUsage => '使用說明';

  @override
  String get featureInDevelopmentTitle => '功能開發中';

  @override
  String get featureInDevelopmentMessage => '該功能正在開發中，敬請期待。';

  @override
  String get languageSettingLabel => '語言';

  @override
  String get dateFormatSettingLabel => '日期格式';

  @override
  String get languageFollowSystem => '跟隨系統';

  @override
  String get languageChangedRestartTitle => '語言已切換';

  @override
  String get languageChangedRestartMessage => '應用將自動退出以套用新語言，請重新開啟。';

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
  String get schoolImportMoreSchools => '更多高校正在適配中';

  @override
  String get schoolImportNoticeTitle => '注意事項';

  @override
  String get schoolImportParseDoneTitle => '解析完成';

  @override
  String schoolImportParseDoneMessage(int count) {
    return '共解析到 $count 門課程，是否新建課表並導入？';
  }

  @override
  String get schoolImportAction => '導入';

  @override
  String schoolImportSuccess(int count) {
    return '已新建課表並導入 $count 門課程';
  }

  @override
  String get schoolImportErrorTitle => '錯誤';

  @override
  String get schoolImportParsing => '解析中...';

  @override
  String get schoolImportScheduleAction => '導入課表';

  @override
  String get schoolImportResetLoginAction => '重新登入';

  @override
  String get schoolImportResetLoginTitle => '清除登入狀態';

  @override
  String get schoolImportResetLoginMessage =>
      '這會清除目前內建瀏覽器中的所有登入 Cookie，並重新開啟登入入口。確定要繼續嗎？';

  @override
  String get schoolImportResetLoginSuccess => '已清除登入狀態，請重新登入';

  @override
  String schoolImportResetLoginFailed(Object error) {
    return '清除登入狀態失敗：$error';
  }

  @override
  String schoolImportScheduleName(Object school, int month, int day) {
    return '$school導入 $month/$day';
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
      '1. 若未登入會先跳轉到登入頁，登入後點擊右下角導入按鈕\n\n2. 時間地點為\"待定\"的課程不會導入，請後續手動添加';

  @override
  String get hustNeedLoginError => '請先在頁面中完成登入，然後再點擊導入按鈕';

  @override
  String hustApiError(Object code) {
    return '介面返回異常（code=$code），請重新登入後再試';
  }

  @override
  String hustReadFailed(Object error) {
    return '讀取失敗：$error';
  }

  @override
  String get hustTermDialogTitle => '選擇學期';

  @override
  String get hustTermDialogMessage => '請選擇要導入的學年與學期';

  @override
  String get hustAcademicYearLabel => '學年';

  @override
  String hustAcademicYearOption(int year) {
    return '$year學年';
  }

  @override
  String get hustSemesterLabel => '學期';

  @override
  String get hustSemesterFall => '秋季學期';

  @override
  String get hustSemesterSpring => '春季學期';

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
  String schedulePageCurrentWeek(int week) {
    return '第$week週';
  }

  @override
  String get schedulePageToday => '今天';

  @override
  String get schedulePageNotCurrentWeek => '非本週';

  @override
  String get schedulePageCourseNotCurrentWeekTag => '[非本週]';

  @override
  String schedulePageCourseTime(Object weekday, int start, int end) {
    return '週$weekday · 第$start-$end節';
  }

  @override
  String get schedulePageDeleteCourse => '刪除課程';

  @override
  String get schedulePageClose => '關閉';

  @override
  String get schedulePageToolClassTime => '上課時間';

  @override
  String get schedulePageToolScheduleSettings => '課表設定';

  @override
  String get schedulePageToolAddedCourses => '已添課程';

  @override
  String get schedulePageWeekLabel => '週數';

  @override
  String get schedulePageSwitchSchedule => '切換課表';

  @override
  String get classTimeNewAction => '新建';

  @override
  String get classTimeCurrentTableLabel => '當前課表顯示的時間表';

  @override
  String get classTimeSelectHint => '輕觸右側選擇目前使用的時間表';

  @override
  String get classTimeTableListHeader => '時間表';

  @override
  String get classTimeSwipeHint => '條目上左滑刪除';

  @override
  String get classTimeDeleteTitle => '刪除時間表';

  @override
  String classTimeDeleteMessage(Object name) {
    return '確定刪除「$name」？';
  }

  @override
  String get classTimeSelectTitle => '選擇時間表';

  @override
  String get classTimeNewTitle => '新建時間表';

  @override
  String get classTimeNewHint => '請輸入時間表名稱';

  @override
  String get classTimeDefaultName => '時間表';

  @override
  String get classTimeEditPageTitle => '時間表編輯';

  @override
  String get classTimeCheckOrder => '檢查時間順序';

  @override
  String get classTimeOrderOkTitle => '時間順序正常';

  @override
  String classTimeOrderConflicts(int count) {
    return '發現 $count 處衝突';
  }

  @override
  String get classTimeOrderOkMessage => '所有節次時間區間無衝突，順序正確。';

  @override
  String get classTimeNameLabel => '時間表名稱';

  @override
  String get classTimeEditNameHint => '輕觸上方以編輯名稱';

  @override
  String get classTimeSameDuration => '每節課時長相同';

  @override
  String get classTimeDurationLabel => '每節課時長（分鐘）';

  @override
  String get classTimeDurationWarning =>
      '謹慎調整此項！調整後，將會根據每節課的「上課時間」，\n加上這個時長，來計算並更新「下課時間」，這意味著原來設置的下課時間會被覆蓋！';

  @override
  String classTimeSectionLabel(int n) {
    return '第 $n 節';
  }

  @override
  String get classTimeSectionListHint =>
      '調整時間，多餘的節數不用管\n如果想修改課表顯示的節數，請去「課表設置」中的「每天節次數」';

  @override
  String get classTimeReset => '重置為預設時間';

  @override
  String get classTimeEditNameTitle => '編輯名稱';

  @override
  String get classTimeDurationPickerTitle => '每節課時長（分鐘）';

  @override
  String classTimeMinutes(int value) {
    return '$value 分鐘';
  }

  @override
  String classTimePickerStartHelpText(int n) {
    return '第 $n 節  開始時間';
  }

  @override
  String classTimePickerEndHelpText(int n) {
    return '第 $n 節  結束時間';
  }

  @override
  String classTimeOrderEndBeforeStart(int n, Object start, Object end) {
    return '第 $n 節：結束時間不能早於或等於開始時間（$start – $end）';
  }

  @override
  String classTimeOrderOverlap(int n, int m, Object end, Object start) {
    return '第 $n 節與第 $m 節時間重疊\n  第$n節結束 $end > 第$m節開始 $start';
  }

  @override
  String get courseEditorNameRequired => '請填寫課程名稱';

  @override
  String get courseEditorWeekdayMon => '週一';

  @override
  String get courseEditorWeekdayTue => '週二';

  @override
  String get courseEditorWeekdayWed => '週三';

  @override
  String get courseEditorWeekdayThu => '週四';

  @override
  String get courseEditorWeekdayFri => '週五';

  @override
  String get courseEditorWeekdaySat => '週六';

  @override
  String get courseEditorWeekdaySun => '週日';

  @override
  String courseEditorWeekNthLabel(int week) {
    return '第$week週';
  }

  @override
  String courseEditorSectionNthLabel(int section) {
    return '第$section節';
  }

  @override
  String get courseEditorWeekRangeTitle => '週數';

  @override
  String get courseEditorStartLabel => '開始';

  @override
  String get courseEditorEndLabel => '結束';

  @override
  String get courseEditorSelectSectionsTitle => '選擇節次';

  @override
  String get courseEditorStartSectionLabel => '開始節';

  @override
  String get courseEditorEndSectionLabel => '結束節';

  @override
  String courseEditorTimeSlotTitle(int index) {
    return '時間段 $index';
  }

  @override
  String get courseEditorWeeksLabel => '週數';

  @override
  String get courseEditorDayLabel => '時間';

  @override
  String get courseEditorWeekdayTitle => '星期';

  @override
  String get courseEditorSectionsLabel => '節次';

  @override
  String get courseEditorTeacherLabel => '老師';

  @override
  String get courseEditorLocationLabel => '地點';

  @override
  String get courseEditorEditTitle => '編輯課程';

  @override
  String get courseEditorAddTitle => '添加課程';

  @override
  String get courseEditorCourseLabel => '課程';

  @override
  String get courseEditorRequiredHint => '必填';

  @override
  String get courseEditorOptionalHint => '選填';

  @override
  String get courseEditorColorLabel => '顏色';

  @override
  String get courseEditorCreditsLabel => '學分';

  @override
  String get courseEditorNotesLabel => '備註';

  @override
  String get courseEditorTimeSlotsLabel => '時間段';

  @override
  String get courseEditorAddSlotAction => '添加';

  @override
  String get courseEditorChooseColorTitle => '選擇顏色';

  @override
  String get courseEditorAutoPickNoConflict => '自動選色（不與已有課程衝突）';

  @override
  String get scheduleSettingsTitle => '課表設置';

  @override
  String get scheduleSettingsDataTitle => '課表資料';

  @override
  String get scheduleSettingsAppearanceTitle => '課表外觀';

  @override
  String get scheduleSettingsAdjustToolTitle => '調課工具';

  @override
  String get scheduleSettingsScheduleNameLabel => '課表名稱';

  @override
  String get scheduleSettingsRenameTitle => '修改課表名稱';

  @override
  String get scheduleSettingsRenameHint => '請輸入課表名稱';

  @override
  String scheduleSettingsWeekDisplay(int week) {
    return '第 $week 週';
  }

  @override
  String scheduleSettingsMoveCourseToast(Object fromDate, Object toDate) {
    return '已將 $fromDate 的課程移動到 $toDate';
  }

  @override
  String get scheduleSettingsAdjustDescription =>
      '本功能用於節假日調休等場景，可以將某天的課程移動到另一天，請謹慎操作';

  @override
  String get scheduleSettingsScheduleToAdjustLabel => '要調整的課表';

  @override
  String get scheduleSettingsMoveFrom => '將';

  @override
  String get scheduleSettingsMoveCoursesSuffix => '的課程';

  @override
  String get scheduleSettingsMoveTo => '移動到';

  @override
  String get scheduleSettingsAdjustWarning => '點擊「確定」後操作不可撤銷，請確認日期選擇無誤後再執行。';

  @override
  String get scheduleSettingsDeleteCoursesTitle => '刪除課程';

  @override
  String scheduleSettingsDeleteSelectedMessage(int count) {
    return '確定刪除已選的 $count 門課程？';
  }

  @override
  String get scheduleSettingsClearScheduleTitle => '清空課表';

  @override
  String scheduleSettingsClearAllMessage(int count) {
    return '確定刪除當前課表全部 $count 門課程？此操作不可恢復。';
  }

  @override
  String get scheduleSettingsMoreTitle => '更多';

  @override
  String get scheduleSettingsSelectCoursesTitle => '選擇課程';

  @override
  String scheduleSettingsSelectedCount(int count) {
    return '已選 $count 門';
  }

  @override
  String scheduleSettingsCoursesCount(int count) {
    return '共 $count 門課程';
  }

  @override
  String get scheduleSettingsUnselectAll => '取消全選';

  @override
  String get scheduleSettingsSelectAll => '全選';

  @override
  String get scheduleSettingsNoCourses => '還沒有課程';

  @override
  String scheduleSettingsCourseTimeItem(Object weekday, int start, int end) {
    return '週$weekday  第$start–$end節';
  }

  @override
  String scheduleSettingsDeleteNamedCourseMessage(Object name) {
    return '確定刪除「$name」？';
  }

  @override
  String get scheduleSettingsClearCurrentSchedule => '清空當前課表';

  @override
  String scheduleSettingsDeleteSelectedAction(int count) {
    return '刪除 ($count)';
  }

  @override
  String get courseEditorAddSuccess => '已添加課程';

  @override
  String get courseEditorEditSuccess => '已修改課程';

  @override
  String get scheduleSettingsDeleteSuccess => '已刪除課程';

  @override
  String scheduleSettingsDeleteSelectedSuccess(int count) {
    return '已刪除 $count 門課程';
  }

  @override
  String get scheduleSettingsClearAllSuccess => '已清空全部課程';

  @override
  String newScheduleCreateSuccess(Object name) {
    return '已建立新課表：$name';
  }
}
