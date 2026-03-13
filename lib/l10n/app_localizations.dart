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
