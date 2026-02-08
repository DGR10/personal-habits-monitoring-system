// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker';

  @override
  String get homeTitle => 'Home';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSubtitle => 'Customize app appearance';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get pomodoroSubtitle => 'Focus timer';

  @override
  String get vacationMode => 'Vacation Mode';

  @override
  String get vacationModeSubtitle => 'Pause habits without breaking streaks';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get habits => 'Habits';

  @override
  String get stats => 'Stats';

  @override
  String get goals => 'Goals';

  @override
  String get noHabitsYet => 'No habits yet. Add one!';

  @override
  String get notDueToday => 'Not due today';

  @override
  String get options => 'Options';

  @override
  String get deleteHabit => 'Delete habit';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get habitDetail => 'Habit detail & analytics';

  @override
  String get habitDetailSubtitle =>
      'Get detailed analytics for the habit. Track your streak, progress and consistency.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteHabitTitle => 'Delete Habit';

  @override
  String deleteHabitConfirmation(Object habitTitle) {
    return 'Are you sure you want to delete \"$habitTitle\"?';
  }

  @override
  String get insights => 'Insights';

  @override
  String get noHabitsToAnalyze => 'No habits to analyze.';

  @override
  String get consistencyHeatmap => 'Consistency Heatmap';

  @override
  String get last12Weeks => 'Last 12 weeks';

  @override
  String get weeklyMomentum => 'Weekly Momentum';

  @override
  String get onFire => 'On Fire 🔥';

  @override
  String get needsFocus => 'Needs Focus 🎯';

  @override
  String get habitBreakdown => 'Habit Breakdown';

  @override
  String get dayStreak => 'day streak';

  @override
  String get thisMonth => 'this month';

  @override
  String get noGoalsSet => 'No goals set.\nAim high!';

  @override
  String get newGoal => 'New Goal';

  @override
  String get deadlinePrefix => 'Deadline: ';

  @override
  String get progress => 'Progress';

  @override
  String get linkedHabits => 'Linked Habits:';

  @override
  String get goalTitle => 'Goal Title';

  @override
  String get deadline => 'Deadline';

  @override
  String get linkHabits => 'Link Habits';

  @override
  String get create => 'Create';

  @override
  String get goalCreated => 'Goal created!';

  @override
  String get updateGoal => 'Update Goal';

  @override
  String get save => 'Save';

  @override
  String get pomodoroTimer => 'Pomodoro Timer';

  @override
  String get ready => 'Ready';

  @override
  String get done => 'Done!';

  @override
  String get breakTime => 'Break';

  @override
  String get focus => 'Focus';

  @override
  String get rep => 'Rep';

  @override
  String get pause => 'Pause';

  @override
  String get start => 'Start';

  @override
  String get reset => 'Reset';

  @override
  String get configuration => 'Configuration';

  @override
  String get focusMin => 'Focus (min)';

  @override
  String get breakMin => 'Break (min)';

  @override
  String get reps => 'Reps';

  @override
  String get sounds => 'Sounds';

  @override
  String get startSound => 'Start Sound';

  @override
  String get breakSound => 'Break Sound';

  @override
  String get endSound => 'End Sound';

  @override
  String get selectPausePeriod => 'Select Pause Period';

  @override
  String get selectDates => 'Select dates';

  @override
  String get currentlyPaused => 'Currently Paused';

  @override
  String get applyVacationMode => 'Apply Vacation Mode';

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get selectEndDate => 'Select End Date';

  @override
  String vacationModeApplied(Object count) {
    return 'Vacation mode applied to $count habits';
  }

  @override
  String get addNewHabit => 'Add New Habit';

  @override
  String get habitTitle => 'Habit Title';

  @override
  String get habitTitleError => 'Please enter a title';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get frequency => 'Frequency';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get updateHabit => 'Update Habit';

  @override
  String get saveHabit => 'Save Habit';

  @override
  String get frequencyType => 'Type';

  @override
  String get dailyEveryXDays => 'Daily / Every X Days';

  @override
  String get weeklySpecificDays => 'Weekly (Specific Days)';

  @override
  String get intervalXTimesInYDays => 'Interval (X times in Y days)';

  @override
  String get every => 'Every';

  @override
  String get days => 'days';

  @override
  String get selectDays => 'Select Days:';

  @override
  String get timesIn => 'times in';

  @override
  String get current => 'Current';

  @override
  String get longest => 'Longest';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String monthlyAdherence(Object percentage) {
    return 'Monthly Adherence: $percentage%';
  }

  @override
  String yearOverview(Object year) {
    return '$year Overview';
  }

  @override
  String complete(Object percentage) {
    return '$percentage Complete';
  }

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get themeModeLabel => 'Theme Mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get themeStyleLabel => 'Theme Style';

  @override
  String get material => 'Material';

  @override
  String get minimalist => 'Nothing (Minimalist)';

  @override
  String get colorTheme => 'Color Theme';
}
