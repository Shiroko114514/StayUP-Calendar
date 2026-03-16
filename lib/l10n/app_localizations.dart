import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'WakeUp 课程表'**
  String get appTitle;

  /// No description provided for @loadingSchedule.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在加载课表...'**
  String get loadingSchedule;

  /// No description provided for @aboutTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关于'**
  String get aboutTitle;

  /// No description provided for @appName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'StayUP 课程表'**
  String get appName;

  /// No description provided for @appVersionLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'版本 {version}'**
  String appVersionLabel(Object version);

  /// No description provided for @versionNumber.
  ///
  /// In zh_Hans, this message translates to:
  /// **'版本号'**
  String get versionNumber;

  /// No description provided for @developer.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开发者'**
  String get developer;

  /// No description provided for @openSourceLicense.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开源协议'**
  String get openSourceLicense;

  /// No description provided for @checkUpdate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'检查更新'**
  String get checkUpdate;

  /// No description provided for @alreadyLatest.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已是最新'**
  String get alreadyLatest;

  /// No description provided for @aboutFooter.
  ///
  /// In zh_Hans, this message translates to:
  /// **'© 2026 StayUP Studio \n因一时兴起而制作的课程表，也希望能陪你走过很多节课'**
  String get aboutFooter;

  /// No description provided for @backAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'返回'**
  String get backAction;

  /// No description provided for @doneAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完成'**
  String get doneAction;

  /// No description provided for @editAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑'**
  String get editAction;

  /// No description provided for @cancelAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'取消'**
  String get cancelAction;

  /// No description provided for @confirmAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确定'**
  String get confirmAction;

  /// No description provided for @saveAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存'**
  String get saveAction;

  /// No description provided for @deleteAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除'**
  String get deleteAction;

  /// No description provided for @okAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'好的'**
  String get okAction;

  /// No description provided for @globalSettingsTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'全局设置'**
  String get globalSettingsTitle;

  /// No description provided for @darkMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// No description provided for @courseReminder.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程提醒'**
  String get courseReminder;

  /// No description provided for @widgetSync.
  ///
  /// In zh_Hans, this message translates to:
  /// **'桌面小组件同步'**
  String get widgetSync;

  /// No description provided for @setBackgroundFormat.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置背景格式'**
  String get setBackgroundFormat;

  /// No description provided for @helpUsage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用帮助'**
  String get helpUsage;

  /// No description provided for @featureInDevelopmentTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'功能开发中'**
  String get featureInDevelopmentTitle;

  /// No description provided for @featureInDevelopmentMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'该功能正在开发中，敬请期待。'**
  String get featureInDevelopmentMessage;

  /// No description provided for @languageSettingLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'语言'**
  String get languageSettingLabel;

  /// No description provided for @languageFollowSystem.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随系统'**
  String get languageFollowSystem;

  /// No description provided for @languageChangedRestartTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'语言已切换'**
  String get languageChangedRestartTitle;

  /// No description provided for @languageChangedRestartMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'应用将自动退出以应用新语言，请重新打开。'**
  String get languageChangedRestartMessage;

  /// No description provided for @languageForceChineseSimplified.
  ///
  /// In zh_Hans, this message translates to:
  /// **'中文（简体）'**
  String get languageForceChineseSimplified;

  /// No description provided for @languageForceChineseTraditional.
  ///
  /// In zh_Hans, this message translates to:
  /// **'中文（繁體）'**
  String get languageForceChineseTraditional;

  /// No description provided for @languageForceEnglish.
  ///
  /// In zh_Hans, this message translates to:
  /// **'English'**
  String get languageForceEnglish;

  /// No description provided for @languageForceJapanese.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日本語'**
  String get languageForceJapanese;

  /// No description provided for @manageScheduleTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'多课表管理'**
  String get manageScheduleTitle;

  /// No description provided for @manageScheduleHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点右上角的编辑以排序或删除'**
  String get manageScheduleHint;

  /// No description provided for @newScheduleButton.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新建课表'**
  String get newScheduleButton;

  /// No description provided for @deleteScheduleTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除课表'**
  String get deleteScheduleTitle;

  /// No description provided for @deleteScheduleMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确定删除「{name}」？此操作不可恢复。'**
  String deleteScheduleMessage(Object name);

  /// No description provided for @newScheduleTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新建课表'**
  String get newScheduleTitle;

  /// No description provided for @scheduleNameRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请填写课表名称'**
  String get scheduleNameRequired;

  /// No description provided for @scheduleNameRequiredHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课表名称（必填）'**
  String get scheduleNameRequiredHint;

  /// No description provided for @firstDayOfWeekOne.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第一周的第一天'**
  String get firstDayOfWeekOne;

  /// No description provided for @weekStartDay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'一周起始天'**
  String get weekStartDay;

  /// No description provided for @mondayLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周一'**
  String get mondayLabel;

  /// No description provided for @currentWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前周'**
  String get currentWeek;

  /// No description provided for @autoLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'自动'**
  String get autoLabel;

  /// No description provided for @sectionsPerDay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'一天课程节数'**
  String get sectionsPerDay;

  /// No description provided for @totalWeeks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学期周数'**
  String get totalWeeks;

  /// No description provided for @exportScheduleTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出课表'**
  String get exportScheduleTitle;

  /// No description provided for @exportFormatLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出格式'**
  String get exportFormatLabel;

  /// No description provided for @exportIncludeNonWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'包含非本周课程'**
  String get exportIncludeNonWeek;

  /// No description provided for @exportIncludeSaturday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'包含周六'**
  String get exportIncludeSaturday;

  /// No description provided for @exportIncludeSunday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'包含周日'**
  String get exportIncludeSunday;

  /// No description provided for @exportNow.
  ///
  /// In zh_Hans, this message translates to:
  /// **'立即导出'**
  String get exportNow;

  /// No description provided for @exportSelectFormat.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择格式'**
  String get exportSelectFormat;

  /// No description provided for @exportSuccess.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课表已导出为 {format}'**
  String exportSuccess(Object format);

  /// No description provided for @exportFormatPng.
  ///
  /// In zh_Hans, this message translates to:
  /// **'图片 (PNG)'**
  String get exportFormatPng;

  /// No description provided for @exportFormatJpg.
  ///
  /// In zh_Hans, this message translates to:
  /// **'图片 (JPG)'**
  String get exportFormatJpg;

  /// No description provided for @exportFormatPdf.
  ///
  /// In zh_Hans, this message translates to:
  /// **'PDF'**
  String get exportFormatPdf;

  /// No description provided for @exportFormatIcs.
  ///
  /// In zh_Hans, this message translates to:
  /// **'iCalendar (.ics)'**
  String get exportFormatIcs;

  /// No description provided for @exportFormatCsv.
  ///
  /// In zh_Hans, this message translates to:
  /// **'CSV'**
  String get exportFormatCsv;

  /// No description provided for @searchSchoolHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'搜索学校'**
  String get searchSchoolHint;

  /// No description provided for @schoolImportTip.
  ///
  /// In zh_Hans, this message translates to:
  /// **'在搜索框输入学校全称以快速定位'**
  String get schoolImportTip;

  /// No description provided for @schoolImportMoreSchools.
  ///
  /// In zh_Hans, this message translates to:
  /// **'更多高校正在适配中'**
  String get schoolImportMoreSchools;

  /// No description provided for @schoolImportNoticeTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'注意事项'**
  String get schoolImportNoticeTitle;

  /// No description provided for @schoolImportParseDoneTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'解析完成'**
  String get schoolImportParseDoneTitle;

  /// No description provided for @schoolImportParseDoneMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'共解析到 {count} 门课程，是否新建课表并导入？'**
  String schoolImportParseDoneMessage(int count);

  /// No description provided for @schoolImportAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入'**
  String get schoolImportAction;

  /// No description provided for @schoolImportSuccess.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已新建课表并导入 {count} 门课程'**
  String schoolImportSuccess(int count);

  /// No description provided for @schoolImportErrorTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'错误'**
  String get schoolImportErrorTitle;

  /// No description provided for @schoolImportParsing.
  ///
  /// In zh_Hans, this message translates to:
  /// **'解析中...'**
  String get schoolImportParsing;

  /// No description provided for @schoolImportScheduleAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入课表'**
  String get schoolImportScheduleAction;

  /// No description provided for @schoolImportScheduleName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{school}导入 {month}/{day}'**
  String schoolImportScheduleName(Object school, int month, int day);

  /// No description provided for @hustNoticeText.
  ///
  /// In zh_Hans, this message translates to:
  /// **'1. 若未登录会先跳转到登录页，登录后点击右下角导入按钮\n\n2. 时间地点为\"待定\"的课程不会导入，请后续手动添加'**
  String get hustNoticeText;

  /// No description provided for @hustNeedLoginError.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请先在页面中完成登录，然后再点击导入按钮'**
  String get hustNeedLoginError;

  /// No description provided for @hustApiError.
  ///
  /// In zh_Hans, this message translates to:
  /// **'接口返回异常（code={code}），请重新登录后再试'**
  String hustApiError(Object code);

  /// No description provided for @hustReadFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'读取失败：{error}'**
  String hustReadFailed(Object error);

  /// No description provided for @hustTermDialogTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择学期'**
  String get hustTermDialogTitle;

  /// No description provided for @hustTermDialogMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请选择要导入的学年与学期'**
  String get hustTermDialogMessage;

  /// No description provided for @hustAcademicYearLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学年'**
  String get hustAcademicYearLabel;

  /// No description provided for @hustAcademicYearOption.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{year}学年'**
  String hustAcademicYearOption(int year);

  /// No description provided for @hustSemesterLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学期'**
  String get hustSemesterLabel;

  /// No description provided for @hustSemesterFall.
  ///
  /// In zh_Hans, this message translates to:
  /// **'秋季学期'**
  String get hustSemesterFall;

  /// No description provided for @hustSemesterSpring.
  ///
  /// In zh_Hans, this message translates to:
  /// **'春季学期'**
  String get hustSemesterSpring;

  /// No description provided for @schoolImportWipMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'该学校的课程导入功能正在开发中，敬请期待。'**
  String get schoolImportWipMessage;

  /// No description provided for @schoolHust.
  ///
  /// In zh_Hans, this message translates to:
  /// **'华中科技大学'**
  String get schoolHust;

  /// No description provided for @schoolJxnu.
  ///
  /// In zh_Hans, this message translates to:
  /// **'江西师范大学'**
  String get schoolJxnu;

  /// No description provided for @schoolSjtu.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上海交通大学'**
  String get schoolSjtu;

  /// No description provided for @schoolWhu.
  ///
  /// In zh_Hans, this message translates to:
  /// **'武汉大学'**
  String get schoolWhu;

  /// No description provided for @schoolCuhksz.
  ///
  /// In zh_Hans, this message translates to:
  /// **'香港中文大学（深圳）'**
  String get schoolCuhksz;

  /// No description provided for @schoolRuc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'中国人民大学'**
  String get schoolRuc;

  /// No description provided for @schedulePageCurrentWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第{week}周'**
  String schedulePageCurrentWeek(int week);

  /// No description provided for @schedulePageToday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'今天'**
  String get schedulePageToday;

  /// No description provided for @schedulePageNotCurrentWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'非本周'**
  String get schedulePageNotCurrentWeek;

  /// No description provided for @schedulePageCourseNotCurrentWeekTag.
  ///
  /// In zh_Hans, this message translates to:
  /// **'[非本周]'**
  String get schedulePageCourseNotCurrentWeekTag;

  /// No description provided for @schedulePageCourseTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周{weekday} · 第{start}-{end}节'**
  String schedulePageCourseTime(Object weekday, int start, int end);

  /// No description provided for @schedulePageDeleteCourse.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除课程'**
  String get schedulePageDeleteCourse;

  /// No description provided for @schedulePageClose.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关闭'**
  String get schedulePageClose;

  /// No description provided for @schedulePageToolClassTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上课时间'**
  String get schedulePageToolClassTime;

  /// No description provided for @schedulePageToolScheduleSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课表设置'**
  String get schedulePageToolScheduleSettings;

  /// No description provided for @schedulePageToolAddedCourses.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已添课程'**
  String get schedulePageToolAddedCourses;

  /// No description provided for @schedulePageWeekLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周数'**
  String get schedulePageWeekLabel;

  /// No description provided for @schedulePageSwitchSchedule.
  ///
  /// In zh_Hans, this message translates to:
  /// **'切换课表'**
  String get schedulePageSwitchSchedule;

  /// No description provided for @classTimeNewAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新建'**
  String get classTimeNewAction;

  /// No description provided for @classTimeCurrentTableLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前课表显示的时间表'**
  String get classTimeCurrentTableLabel;

  /// No description provided for @classTimeSelectHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'轻触右侧选择当前使用的时间表'**
  String get classTimeSelectHint;

  /// No description provided for @classTimeTableListHeader.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间表'**
  String get classTimeTableListHeader;

  /// No description provided for @classTimeSwipeHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'条目上左划删除'**
  String get classTimeSwipeHint;

  /// No description provided for @classTimeDeleteTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除时间表'**
  String get classTimeDeleteTitle;

  /// No description provided for @classTimeDeleteMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确定删除「{name}」？'**
  String classTimeDeleteMessage(Object name);

  /// No description provided for @classTimeSelectTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择时间表'**
  String get classTimeSelectTitle;

  /// No description provided for @classTimeNewTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新建时间表'**
  String get classTimeNewTitle;

  /// No description provided for @classTimeNewHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请输入时间表名称'**
  String get classTimeNewHint;

  /// No description provided for @classTimeDefaultName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间表'**
  String get classTimeDefaultName;

  /// No description provided for @classTimeEditPageTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间表编辑'**
  String get classTimeEditPageTitle;

  /// No description provided for @classTimeCheckOrder.
  ///
  /// In zh_Hans, this message translates to:
  /// **'检查时间顺序'**
  String get classTimeCheckOrder;

  /// No description provided for @classTimeOrderOkTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间顺序正常'**
  String get classTimeOrderOkTitle;

  /// No description provided for @classTimeOrderConflicts.
  ///
  /// In zh_Hans, this message translates to:
  /// **'发现 {count} 处冲突'**
  String classTimeOrderConflicts(int count);

  /// No description provided for @classTimeOrderOkMessage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'所有节次时间区间无冲突，顺序正确。'**
  String get classTimeOrderOkMessage;

  /// No description provided for @classTimeNameLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间表名称'**
  String get classTimeNameLabel;

  /// No description provided for @classTimeEditNameHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'轻触上方以编辑名称'**
  String get classTimeEditNameHint;

  /// No description provided for @classTimeSameDuration.
  ///
  /// In zh_Hans, this message translates to:
  /// **'每节课时长相同'**
  String get classTimeSameDuration;

  /// No description provided for @classTimeDurationLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'每节课时长（分钟）'**
  String get classTimeDurationLabel;

  /// No description provided for @classTimeDurationWarning.
  ///
  /// In zh_Hans, this message translates to:
  /// **'谨慎调整此项！调整后，将会根据每节课的「上课时间」，\n加上这个时长，来计算并更新「下课时间」，这意味着原来设置的下课时间会被覆盖！'**
  String get classTimeDurationWarning;

  /// No description provided for @classTimeSectionLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {n} 节'**
  String classTimeSectionLabel(int n);

  /// No description provided for @classTimeSectionListHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'调整时间，多余的节数不用管\n如果想修改课表显示的节数，请去「课表设置」中的「每天节次数」'**
  String get classTimeSectionListHint;

  /// No description provided for @classTimeReset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重置为默认时间'**
  String get classTimeReset;

  /// No description provided for @classTimeEditNameTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑名称'**
  String get classTimeEditNameTitle;

  /// No description provided for @classTimeDurationPickerTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'每节课时长（分钟）'**
  String get classTimeDurationPickerTitle;

  /// No description provided for @classTimeMinutes.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{value} 分钟'**
  String classTimeMinutes(int value);

  /// No description provided for @classTimePickerStartHelpText.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {n} 节  开始时间'**
  String classTimePickerStartHelpText(int n);

  /// No description provided for @classTimePickerEndHelpText.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {n} 节  结束时间'**
  String classTimePickerEndHelpText(int n);

  /// No description provided for @classTimeOrderEndBeforeStart.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {n} 节：结束时间不能早于或等于开始时间（{start} – {end}）'**
  String classTimeOrderEndBeforeStart(int n, Object start, Object end);

  /// No description provided for @classTimeOrderOverlap.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {n} 节与第 {m} 节时间重叠\n  第{n}节结束 {end} > 第{m}节开始 {start}'**
  String classTimeOrderOverlap(int n, int m, Object end, Object start);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
