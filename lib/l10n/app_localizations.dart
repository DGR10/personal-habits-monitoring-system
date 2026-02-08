import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize app appearance'**
  String get themeSubtitle;

  /// No description provided for @pomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoro;

  /// No description provided for @pomodoroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focus timer'**
  String get pomodoroSubtitle;

  /// No description provided for @vacationMode.
  ///
  /// In en, this message translates to:
  /// **'Vacation Mode'**
  String get vacationMode;

  /// No description provided for @vacationModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pause habits without breaking streaks'**
  String get vacationModeSubtitle;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Add one!'**
  String get noHabitsYet;

  /// No description provided for @notDueToday.
  ///
  /// In en, this message translates to:
  /// **'Not due today'**
  String get notDueToday;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get deleteHabit;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabit;

  /// No description provided for @habitDetail.
  ///
  /// In en, this message translates to:
  /// **'Habit detail & analytics'**
  String get habitDetail;

  /// No description provided for @habitDetailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get detailed analytics for the habit. Track your streak, progress and consistency.'**
  String get habitDetailSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabitTitle;

  /// No description provided for @deleteHabitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{habitTitle}\"?'**
  String deleteHabitConfirmation(Object habitTitle);

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @noHabitsToAnalyze.
  ///
  /// In en, this message translates to:
  /// **'No habits to analyze.'**
  String get noHabitsToAnalyze;

  /// No description provided for @consistencyHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Consistency Heatmap'**
  String get consistencyHeatmap;

  /// No description provided for @last12Weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 12 weeks'**
  String get last12Weeks;

  /// No description provided for @weeklyMomentum.
  ///
  /// In en, this message translates to:
  /// **'Weekly Momentum'**
  String get weeklyMomentum;

  /// No description provided for @onFire.
  ///
  /// In en, this message translates to:
  /// **'On Fire 🔥'**
  String get onFire;

  /// No description provided for @needsFocus.
  ///
  /// In en, this message translates to:
  /// **'Needs Focus 🎯'**
  String get needsFocus;

  /// No description provided for @habitBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Habit Breakdown'**
  String get habitBreakdown;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get thisMonth;

  /// No description provided for @noGoalsSet.
  ///
  /// In en, this message translates to:
  /// **'No goals set.\nAim high!'**
  String get noGoalsSet;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// No description provided for @deadlinePrefix.
  ///
  /// In en, this message translates to:
  /// **'Deadline: '**
  String get deadlinePrefix;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @linkedHabits.
  ///
  /// In en, this message translates to:
  /// **'Linked Habits:'**
  String get linkedHabits;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Title'**
  String get goalTitle;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @linkHabits.
  ///
  /// In en, this message translates to:
  /// **'Link Habits'**
  String get linkHabits;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @goalCreated.
  ///
  /// In en, this message translates to:
  /// **'Goal created!'**
  String get goalCreated;

  /// No description provided for @updateGoal.
  ///
  /// In en, this message translates to:
  /// **'Update Goal'**
  String get updateGoal;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pomodoroTimer.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Timer'**
  String get pomodoroTimer;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get done;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakTime;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @rep.
  ///
  /// In en, this message translates to:
  /// **'Rep'**
  String get rep;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @focusMin.
  ///
  /// In en, this message translates to:
  /// **'Focus (min)'**
  String get focusMin;

  /// No description provided for @breakMin.
  ///
  /// In en, this message translates to:
  /// **'Break (min)'**
  String get breakMin;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// No description provided for @startSound.
  ///
  /// In en, this message translates to:
  /// **'Start Sound'**
  String get startSound;

  /// No description provided for @breakSound.
  ///
  /// In en, this message translates to:
  /// **'Break Sound'**
  String get breakSound;

  /// No description provided for @endSound.
  ///
  /// In en, this message translates to:
  /// **'End Sound'**
  String get endSound;

  /// No description provided for @selectPausePeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Pause Period'**
  String get selectPausePeriod;

  /// No description provided for @selectDates.
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get selectDates;

  /// No description provided for @currentlyPaused.
  ///
  /// In en, this message translates to:
  /// **'Currently Paused'**
  String get currentlyPaused;

  /// No description provided for @applyVacationMode.
  ///
  /// In en, this message translates to:
  /// **'Apply Vacation Mode'**
  String get applyVacationMode;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get selectEndDate;

  /// No description provided for @vacationModeApplied.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode applied to {count} habits'**
  String vacationModeApplied(Object count);

  /// No description provided for @addNewHabit.
  ///
  /// In en, this message translates to:
  /// **'Add New Habit'**
  String get addNewHabit;

  /// No description provided for @habitTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Title'**
  String get habitTitle;

  /// No description provided for @habitTitleError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get habitTitleError;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @updateHabit.
  ///
  /// In en, this message translates to:
  /// **'Update Habit'**
  String get updateHabit;

  /// No description provided for @saveHabit.
  ///
  /// In en, this message translates to:
  /// **'Save Habit'**
  String get saveHabit;

  /// No description provided for @frequencyType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get frequencyType;

  /// No description provided for @dailyEveryXDays.
  ///
  /// In en, this message translates to:
  /// **'Daily / Every X Days'**
  String get dailyEveryXDays;

  /// No description provided for @weeklySpecificDays.
  ///
  /// In en, this message translates to:
  /// **'Weekly (Specific Days)'**
  String get weeklySpecificDays;

  /// No description provided for @intervalXTimesInYDays.
  ///
  /// In en, this message translates to:
  /// **'Interval (X times in Y days)'**
  String get intervalXTimesInYDays;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select Days:'**
  String get selectDays;

  /// No description provided for @timesIn.
  ///
  /// In en, this message translates to:
  /// **'times in'**
  String get timesIn;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @longest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get longest;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @monthlyAdherence.
  ///
  /// In en, this message translates to:
  /// **'Monthly Adherence: {percentage}%'**
  String monthlyAdherence(Object percentage);

  /// No description provided for @yearOverview.
  ///
  /// In en, this message translates to:
  /// **'{year} Overview'**
  String yearOverview(Object year);

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'{percentage} Complete'**
  String complete(Object percentage);
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
