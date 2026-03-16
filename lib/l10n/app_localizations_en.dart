// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'StayUP Schedule';

  @override
  String get loadingSchedule => 'Loading schedule...';

  @override
  String get aboutTitle => 'About';

  @override
  String get appName => 'StayUP Schedule';

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
  String get aboutFooter => '© 2026 StayUP Studio \nA timetable app made on a whim, hoping it can accompany you through many classes.';

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
  String get featureInDevelopmentMessage => 'This feature is currently under development.';

  @override
  String get languageSettingLabel => 'Language';

  @override
  String get languageFollowSystem => 'Follow System';

  @override
  String get languageChangedRestartTitle => 'Language changed';

  @override
  String get languageChangedRestartMessage => 'The app will close to apply the new language. Please reopen it.';

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
  String get manageScheduleHint => 'Tap Edit in the top-right corner to reorder or delete.';

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
  String get schoolImportTip => 'Type the full school name in the search box for quick access';

  @override
  String get schoolImportMoreSchools => 'More universities are being adapted';

  @override
  String get schoolImportNoticeTitle => 'Notes';

  @override
  String get schoolImportParseDoneTitle => 'Parsing completed';

  @override
  String schoolImportParseDoneMessage(int count) {
    return 'Parsed $count courses. Create a new schedule and import?';
  }

  @override
  String get schoolImportAction => 'Import';

  @override
  String schoolImportSuccess(int count) {
    return 'Created a new schedule and imported $count courses';
  }

  @override
  String get schoolImportErrorTitle => 'Error';

  @override
  String get schoolImportParsing => 'Parsing...';

  @override
  String get schoolImportScheduleAction => 'Import Schedule';

  @override
  String schoolImportScheduleName(Object school, int month, int day) {
    return '$school import $month/$day';
  }

  @override
  String get hustNoticeText => '1. If you are not logged in, you will be redirected to the login page. After login, tap the import button in the bottom-right.\n\n2. Courses with \"TBD\" time/location will not be imported. Please add them manually later.';

  @override
  String get hustNeedLoginError => 'Please finish login in the page first, then tap import.';

  @override
  String hustApiError(Object code) {
    return 'API returned an error (code=$code). Please log in again and retry.';
  }

  @override
  String hustReadFailed(Object error) {
    return 'Read failed: $error';
  }

  @override
  String get hustTermDialogTitle => 'Select term';

  @override
  String get hustTermDialogMessage => 'Please select the academic year and semester to import';

  @override
  String get hustAcademicYearLabel => 'Academic year';

  @override
  String hustAcademicYearOption(int year) {
    return '$year academic year';
  }

  @override
  String get hustSemesterLabel => 'Semester';

  @override
  String get hustSemesterFall => 'Fall semester';

  @override
  String get hustSemesterSpring => 'Spring semester';

  @override
  String get schoolImportWipMessage => 'Course import for this school is under development.';

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

  @override
  String schedulePageCurrentWeek(int week) {
    return 'Week $week';
  }

  @override
  String get schedulePageToday => 'Today';

  @override
  String get schedulePageNotCurrentWeek => 'Not this week';

  @override
  String get schedulePageCourseNotCurrentWeekTag => '[Not this week]';

  @override
  String schedulePageCourseTime(Object weekday, int start, int end) {
    return '$weekday · $start-$end';
  }

  @override
  String get schedulePageDeleteCourse => 'Delete Course';

  @override
  String get schedulePageClose => 'Close';

  @override
  String get schedulePageToolClassTime => 'Class Time';

  @override
  String get schedulePageToolScheduleSettings => 'Schedule Settings';

  @override
  String get schedulePageToolAddedCourses => 'Added Courses';

  @override
  String get schedulePageWeekLabel => 'Week';

  @override
  String get schedulePageSwitchSchedule => 'Switch Schedule';
}
