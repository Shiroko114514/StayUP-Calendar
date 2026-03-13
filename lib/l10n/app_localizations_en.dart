// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WakeUp Timetable';

  @override
  String get loadingSchedule => 'Loading schedule...';

  @override
  String get aboutTitle => 'About';

  @override
  String get appName => 'StayUP Timetable';

  @override
  String appVersionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get versionNumber => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get openSourceLicense => 'Open Source License';

  @override
  String get checkUpdate => 'Check for Updates';

  @override
  String get alreadyLatest => 'Up to date';

  @override
  String get aboutFooter =>
      '© 2026 StayUP Studio \nA timetable app made on a whim, hoping it can accompany you through many classes.';

  @override
  String get backAction => 'Back';

  @override
  String get doneAction => 'Done';

  @override
  String get editAction => 'Edit';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get saveAction => 'Save';

  @override
  String get deleteAction => 'Delete';

  @override
  String get okAction => 'OK';

  @override
  String get globalSettingsTitle => 'Global Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get courseReminder => 'Course Reminder';

  @override
  String get widgetSync => 'Widget Sync';

  @override
  String get setBackgroundFormat => 'Background Format';

  @override
  String get helpUsage => 'Help';

  @override
  String get featureInDevelopmentTitle => 'In Development';

  @override
  String get featureInDevelopmentMessage =>
      'This feature is currently under development.';

  @override
  String get languageSettingLabel => 'Language';

  @override
  String get languageFollowSystem => 'Follow System';

  @override
  String get languageChangedRestartTitle => 'Language changed';

  @override
  String get languageChangedRestartMessage =>
      'The app will close to apply the new language. Please reopen it.';

  @override
  String get languageForceChineseSimplified => '中文（简体）';

  @override
  String get languageForceChineseTraditional => '中文（繁體）';

  @override
  String get languageForceEnglish => 'English';

  @override
  String get languageForceJapanese => '日本語';

  @override
  String get manageScheduleTitle => 'Manage Schedules';

  @override
  String get manageScheduleHint =>
      'Tap Edit in the top-right corner to reorder or delete.';

  @override
  String get newScheduleButton => 'New Schedule';

  @override
  String get deleteScheduleTitle => 'Delete Schedule';

  @override
  String deleteScheduleMessage(Object name) {
    return 'Delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get newScheduleTitle => 'New Schedule';

  @override
  String get scheduleNameRequired => 'Please enter a schedule name';

  @override
  String get scheduleNameRequiredHint => 'Schedule name (required)';

  @override
  String get firstDayOfWeekOne => 'First day of week 1';

  @override
  String get weekStartDay => 'Week starts on';

  @override
  String get mondayLabel => 'Monday';

  @override
  String get currentWeek => 'Current week';

  @override
  String get autoLabel => 'Auto';

  @override
  String get sectionsPerDay => 'Sections per day';

  @override
  String get totalWeeks => 'Total weeks';

  @override
  String get exportScheduleTitle => 'Export Schedule';

  @override
  String get exportFormatLabel => 'Export Format';

  @override
  String get exportIncludeNonWeek => 'Include non-current-week courses';

  @override
  String get exportIncludeSaturday => 'Include Saturday';

  @override
  String get exportIncludeSunday => 'Include Sunday';

  @override
  String get exportNow => 'Export Now';

  @override
  String get exportSelectFormat => 'Select Format';

  @override
  String exportSuccess(Object format) {
    return 'Schedule exported as $format';
  }

  @override
  String get exportFormatPng => 'Image (PNG)';

  @override
  String get exportFormatJpg => 'Image (JPG)';

  @override
  String get exportFormatPdf => 'PDF';

  @override
  String get exportFormatIcs => 'iCalendar (.ics)';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get searchSchoolHint => 'Search school';

  @override
  String get schoolImportTip =>
      'Type the full school name in the search box for quick access';

  @override
  String get schoolImportWipMessage =>
      'Course import for this school is under development.';

  @override
  String get schoolHust => 'Huazhong University of Science and Technology';

  @override
  String get schoolJxnu => 'Jiangxi Normal University';

  @override
  String get schoolSjtu => 'Shanghai Jiao Tong University';

  @override
  String get schoolWhu => 'Wuhan University';

  @override
  String get schoolCuhksz => 'The Chinese University of Hong Kong, Shenzhen';

  @override
  String get schoolRuc => 'Renmin University of China';
}
