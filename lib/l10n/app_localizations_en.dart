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
  String get darkMode => 'Appearance';

  @override
  String get themeModeFollowSystem => 'Follow System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get courseReminder => 'Course Reminder';

  @override
  String get widgetSync => 'Widget Sync';

  @override
  String get setBackgroundFormat => 'Background Format';

  @override
  String get materialDynamicColor => 'Material Dynamic Color';

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
  String get dateFormatSettingLabel => 'Date Format';

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
  String get schoolImportResetLoginAction => 'Log in again';

  @override
  String get schoolImportResetLoginTitle => 'Clear login state';

  @override
  String get schoolImportResetLoginMessage =>
      'This will clear all login cookies in the built-in browser and reopen the login entry page. Continue?';

  @override
  String get schoolImportResetLoginSuccess =>
      'Login state cleared. Please sign in again.';

  @override
  String schoolImportResetLoginFailed(Object error) {
    return 'Failed to clear login state: $error';
  }

  @override
  String schoolImportScheduleName(Object school, int month, int day) {
    return '$school import $month/$day';
  }

  @override
  String get schoolImportSeasonSpringShort => 'Spring';

  @override
  String get schoolImportSeasonFallShort => 'Fall';

  @override
  String schoolImportScheduleNameByTerm(int year, Object season) {
    return '$year $season';
  }

  @override
  String get hustNoticeText =>
      '1. If you are not logged in, you will be redirected to the login page. After login, tap the import button in the bottom-right.\n\n2. Courses with \"TBD\" time/location will not be imported. Please add them manually later.';

  @override
  String get hustNeedLoginError =>
      'Please finish login in the page first, then tap import.';

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
  String get hustTermDialogMessage =>
      'Please select the academic year and semester to import';

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

  @override
  String get classTimeNewAction => 'New';

  @override
  String get classTimeCurrentTableLabel => 'Timetable for current schedule';

  @override
  String get classTimeSelectHint => 'Tap right to select the active timetable';

  @override
  String get classTimeTableListHeader => 'Timetables';

  @override
  String get classTimeSwipeHint => 'Swipe left on an item to delete';

  @override
  String get classTimeDeleteTitle => 'Delete Timetable';

  @override
  String classTimeDeleteMessage(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get classTimeSelectTitle => 'Select Timetable';

  @override
  String get classTimeNewTitle => 'New Timetable';

  @override
  String get classTimeNewHint => 'Enter a timetable name';

  @override
  String get classTimeDefaultName => 'Timetable';

  @override
  String get classTimeEditPageTitle => 'Edit Timetable';

  @override
  String get classTimeCheckOrder => 'Check Order';

  @override
  String get classTimeOrderOkTitle => 'No Conflicts';

  @override
  String classTimeOrderConflicts(int count) {
    return '$count conflict(s) found';
  }

  @override
  String get classTimeOrderOkMessage =>
      'All section times are valid with no conflicts.';

  @override
  String get classTimeNameLabel => 'Timetable Name';

  @override
  String get classTimeEditNameHint => 'Tap above to edit name';

  @override
  String get classTimeSameDuration => 'Same duration for all sections';

  @override
  String get classTimeDurationLabel => 'Section duration (min)';

  @override
  String get classTimeDurationWarning =>
      'Caution! After updating, each section\'s end time will be recalculated as start time + this duration, overwriting existing end times.';

  @override
  String classTimeSectionLabel(int n) {
    return 'Section $n';
  }

  @override
  String get classTimeSectionListHint =>
      'Adjust start times; extra sections don\'t affect the display.\nTo change the number of visible sections, go to Schedule Settings › Sections per Day.';

  @override
  String get classTimeReset => 'Reset to default times';

  @override
  String get classTimeEditNameTitle => 'Edit Name';

  @override
  String get classTimeDurationPickerTitle => 'Section duration (minutes)';

  @override
  String classTimeMinutes(int value) {
    return '$value min';
  }

  @override
  String classTimePickerStartHelpText(int n) {
    return 'Section $n – Start time';
  }

  @override
  String classTimePickerEndHelpText(int n) {
    return 'Section $n – End time';
  }

  @override
  String classTimeOrderEndBeforeStart(int n, Object start, Object end) {
    return 'Section $n: End time must be after start time ($start–$end)';
  }

  @override
  String classTimeOrderOverlap(int n, int m, Object end, Object start) {
    return 'Section $n and $m overlap\n  Section $n ends $end > Section $m starts $start';
  }

  @override
  String get courseEditorNameRequired => 'Please enter course name';

  @override
  String get courseEditorWeekdayMon => 'Mon';

  @override
  String get courseEditorWeekdayTue => 'Tue';

  @override
  String get courseEditorWeekdayWed => 'Wed';

  @override
  String get courseEditorWeekdayThu => 'Thu';

  @override
  String get courseEditorWeekdayFri => 'Fri';

  @override
  String get courseEditorWeekdaySat => 'Sat';

  @override
  String get courseEditorWeekdaySun => 'Sun';

  @override
  String courseEditorWeekNthLabel(int week) {
    return 'Week $week';
  }

  @override
  String courseEditorSectionNthLabel(int section) {
    return 'Sec $section';
  }

  @override
  String get courseEditorWeekRangeTitle => 'Week Range';

  @override
  String get courseEditorStartLabel => 'Start';

  @override
  String get courseEditorEndLabel => 'End';

  @override
  String get courseEditorSelectSectionsTitle => 'Select Sections';

  @override
  String get courseEditorStartSectionLabel => 'Start Section';

  @override
  String get courseEditorEndSectionLabel => 'End Section';

  @override
  String courseEditorTimeSlotTitle(int index) {
    return 'Time Slot $index';
  }

  @override
  String get courseEditorWeeksLabel => 'Weeks';

  @override
  String get courseEditorDayLabel => 'Day';

  @override
  String get courseEditorWeekdayTitle => 'Weekday';

  @override
  String get courseEditorSectionsLabel => 'Sections';

  @override
  String get courseEditorTeacherLabel => 'Teacher';

  @override
  String get courseEditorLocationLabel => 'Location';

  @override
  String get courseEditorEditTitle => 'Edit Course';

  @override
  String get courseEditorAddTitle => 'Add Course';

  @override
  String get courseEditorCourseLabel => 'Course';

  @override
  String get courseEditorRequiredHint => 'Required';

  @override
  String get courseEditorOptionalHint => 'Optional';

  @override
  String get courseEditorColorLabel => 'Color';

  @override
  String get courseEditorCreditsLabel => 'Credits';

  @override
  String get courseEditorNotesLabel => 'Notes';

  @override
  String get courseEditorTimeSlotsLabel => 'Time Slots';

  @override
  String get courseEditorAddSlotAction => 'Add';

  @override
  String get courseEditorChooseColorTitle => 'Choose Color';

  @override
  String get courseEditorAutoPickNoConflict => 'Auto pick (avoid conflicts)';

  @override
  String get scheduleSettingsTitle => 'Schedule Settings';

  @override
  String get scheduleSettingsDataTitle => 'Schedule Data';

  @override
  String get scheduleSettingsAppearanceTitle => 'Schedule Appearance';

  @override
  String get scheduleSettingsAdjustToolTitle => 'Adjust Tool';

  @override
  String get scheduleSettingsScheduleNameLabel => 'Schedule Name';

  @override
  String get scheduleSettingsRenameTitle => 'Rename Schedule';

  @override
  String get scheduleSettingsRenameHint => 'Enter schedule name';

  @override
  String scheduleSettingsWeekDisplay(int week) {
    return 'Week $week';
  }

  @override
  String scheduleSettingsMoveCourseToast(Object fromDate, Object toDate) {
    return 'Moved courses from $fromDate to $toDate';
  }

  @override
  String get scheduleSettingsAdjustDescription =>
      'Move courses from one date to another for schedule adjustment. Please use carefully.';

  @override
  String get scheduleSettingsScheduleToAdjustLabel => 'Schedule to adjust';

  @override
  String get scheduleSettingsMoveFrom => 'Move';

  @override
  String get scheduleSettingsMoveCoursesSuffix => 'courses';

  @override
  String get scheduleSettingsMoveTo => 'to';

  @override
  String get scheduleSettingsAdjustWarning =>
      'This action cannot be undone. Please confirm the selected dates before continuing.';

  @override
  String get scheduleSettingsDeleteCoursesTitle => 'Delete Courses';

  @override
  String scheduleSettingsDeleteSelectedMessage(int count) {
    return 'Delete $count selected courses?';
  }

  @override
  String get scheduleSettingsClearScheduleTitle => 'Clear Schedule';

  @override
  String scheduleSettingsClearAllMessage(int count) {
    return 'Delete all $count courses in this schedule? This cannot be undone.';
  }

  @override
  String get scheduleSettingsMoreTitle => 'More';

  @override
  String get scheduleSettingsSelectCoursesTitle => 'Select Courses';

  @override
  String scheduleSettingsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String scheduleSettingsCoursesCount(int count) {
    return '$count courses';
  }

  @override
  String get scheduleSettingsUnselectAll => 'Unselect All';

  @override
  String get scheduleSettingsSelectAll => 'Select All';

  @override
  String get scheduleSettingsNoCourses => 'No courses yet';

  @override
  String scheduleSettingsCourseTimeItem(Object weekday, int start, int end) {
    return '$weekday  $start-$end';
  }

  @override
  String scheduleSettingsDeleteNamedCourseMessage(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get scheduleSettingsClearCurrentSchedule => 'Clear Current Schedule';

  @override
  String scheduleSettingsDeleteSelectedAction(int count) {
    return 'Delete ($count)';
  }

  @override
  String get courseEditorAddSuccess => 'Course added';

  @override
  String get courseEditorEditSuccess => 'Course updated';

  @override
  String get scheduleSettingsDeleteSuccess => 'Course deleted';

  @override
  String scheduleSettingsDeleteSelectedSuccess(int count) {
    return 'Deleted $count courses';
  }

  @override
  String get scheduleSettingsClearAllSuccess => 'All courses cleared';

  @override
  String newScheduleCreateSuccess(Object name) {
    return 'Created schedule \"$name\"';
  }
}
