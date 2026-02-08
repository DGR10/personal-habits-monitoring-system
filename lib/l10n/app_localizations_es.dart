// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Monitor de Hábitos';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get themeSubtitle => 'Personalizar apariencia';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get pomodoroSubtitle => 'Temporizador de enfoque';

  @override
  String get vacationMode => 'Modo Vacaciones';

  @override
  String get vacationModeSubtitle => 'Pausar hábitos sin perder rachas';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get habits => 'Hábitos';

  @override
  String get stats => 'Estadísticas';

  @override
  String get goals => 'Metas';

  @override
  String get noHabitsYet => 'No hay hábitos aún. ¡Añade uno!';

  @override
  String get notDueToday => 'No toca hoy';

  @override
  String get options => 'Opciones';

  @override
  String get deleteHabit => 'Eliminar hábito';

  @override
  String get editHabit => 'Editar Hábito';

  @override
  String get habitDetail => 'Detalle y estadísticas del hábito';

  @override
  String get habitDetailSubtitle =>
      'Obtén estadísticas detalladas. Sigue tu racha, progreso y consistencia.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteHabitTitle => 'Eliminar Hábito';

  @override
  String deleteHabitConfirmation(Object habitTitle) {
    return '¿Estás seguro de que quieres eliminar \"$habitTitle\"?';
  }

  @override
  String get insights => 'Estadísticas';

  @override
  String get noHabitsToAnalyze => 'No hay hábitos para analizar.';

  @override
  String get consistencyHeatmap => 'Mapa de Calor de Consistencia';

  @override
  String get last12Weeks => 'Últimas 12 semanas';

  @override
  String get weeklyMomentum => 'Impulso Semanal';

  @override
  String get onFire => '¡En Racha! 🔥';

  @override
  String get needsFocus => 'Necesita Atención 🎯';

  @override
  String get habitBreakdown => 'Desglose de Hábitos';

  @override
  String get dayStreak => 'días de racha';

  @override
  String get thisMonth => 'este mes';

  @override
  String get noGoalsSet => 'No hay metas establecidas.\n¡Apunta alto!';

  @override
  String get newGoal => 'Nueva Meta';

  @override
  String get deadlinePrefix => 'Fecha límite: ';

  @override
  String get progress => 'Progreso';

  @override
  String get linkedHabits => 'Hábitos Vinculados:';

  @override
  String get goalTitle => 'Título de la Meta';

  @override
  String get deadline => 'Fecha límite';

  @override
  String get linkHabits => 'Vincular Hábitos';

  @override
  String get create => 'Crear';

  @override
  String get goalCreated => '¡Meta creada!';

  @override
  String get updateGoal => 'Actualizar Meta';

  @override
  String get save => 'Guardar';

  @override
  String get pomodoroTimer => 'Temporizador Pomodoro';

  @override
  String get ready => 'Listo';

  @override
  String get done => '¡Hecho!';

  @override
  String get breakTime => 'Descanso';

  @override
  String get focus => 'Enfoque';

  @override
  String get rep => 'Repetición';

  @override
  String get pause => 'Pausar';

  @override
  String get start => 'Iniciar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get configuration => 'Configuración';

  @override
  String get focusMin => 'Enfoque (min)';

  @override
  String get breakMin => 'Descanso (min)';

  @override
  String get reps => 'Repeticiones';

  @override
  String get sounds => 'Sonidos';

  @override
  String get startSound => 'Sonido de Inicio';

  @override
  String get breakSound => 'Sonido de Descanso';

  @override
  String get endSound => 'Sonido de Fin';

  @override
  String get selectPausePeriod => 'Seleccionar Período de Pausa';

  @override
  String get selectDates => 'Seleccionar fechas';

  @override
  String get currentlyPaused => 'Actualmente Pausado';

  @override
  String get applyVacationMode => 'Aplicar Modo Vacaciones';

  @override
  String get selectStartDate => 'Seleccionar Fecha de Inicio';

  @override
  String get selectEndDate => 'Seleccionar Fecha de Fin';

  @override
  String vacationModeApplied(Object count) {
    return 'Modo vacaciones aplicado a $count hábitos';
  }

  @override
  String get addNewHabit => 'Agregar Nuevo Hábito';

  @override
  String get habitTitle => 'Título del Hábito';

  @override
  String get habitTitleError => 'Por favor ingresa un título';

  @override
  String get descriptionOptional => 'Descripción (Opcional)';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get selectIcon => 'Seleccionar Ícono';

  @override
  String get selectColor => 'Seleccionar Color';

  @override
  String get updateHabit => 'Actualizar Hábito';

  @override
  String get saveHabit => 'Guardar Hábito';

  @override
  String get frequencyType => 'Tipo';

  @override
  String get dailyEveryXDays => 'Diario / Cada X Días';

  @override
  String get weeklySpecificDays => 'Semanal (Días Específicos)';

  @override
  String get intervalXTimesInYDays => 'Intervalo (X veces en Y días)';

  @override
  String get every => 'Cada';

  @override
  String get days => 'días';

  @override
  String get selectDays => 'Seleccionar Días:';

  @override
  String get timesIn => 'veces en';

  @override
  String get current => 'Actual';

  @override
  String get longest => 'Más larga';

  @override
  String get month => 'Mes';

  @override
  String get year => 'Año';

  @override
  String monthlyAdherence(Object percentage) {
    return 'Adherencia Mensual: $percentage%';
  }

  @override
  String yearOverview(Object year) {
    return 'Resumen $year';
  }

  @override
  String complete(Object percentage) {
    return '$percentage Completado';
  }

  @override
  String get themeSettings => 'Configuración del Tema';

  @override
  String get themeModeLabel => 'Modo del Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get themeStyleLabel => 'Estilo del Tema';

  @override
  String get material => 'Material';

  @override
  String get minimalist => 'Nothing (Minimalista)';

  @override
  String get colorTheme => 'Color del Tema';
}
