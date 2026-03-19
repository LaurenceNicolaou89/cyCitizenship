// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CyCitizenship';

  @override
  String get navHome => 'Главная';

  @override
  String get navPractice => 'Практика';

  @override
  String get navAi => 'ИИ';

  @override
  String get navInfo => 'Инфо';

  @override
  String get navProfile => 'Профиль';

  @override
  String get welcomeTitle => 'Добро пожаловать в CyCitizenship';

  @override
  String get welcomeSubtitle => 'Ваш путь к гражданству Кипра';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get selectRoute => 'Выберите маршрут';

  @override
  String get generalRoute => 'Общий путь (7+ лет)';

  @override
  String get fastTrackRoute => 'Ускоренный (3-4 года)';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get continueAsGuest => 'Продолжить как гость';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get orSignInWith => 'Или войдите через';

  @override
  String get nextExam => 'Следующий экзамен';

  @override
  String daysLeft(int days) {
    return '$days дней осталось';
  }

  @override
  String get dailyQuestion => 'Вопрос дня';

  @override
  String dayStreak(int count) {
    return 'Серия $count дней';
  }

  @override
  String get averageScore => 'Средний балл';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get mockExam => 'Пробный экзамен';

  @override
  String get flashcards => 'Карточки';

  @override
  String get aiTutor => 'ИИ Тьютор';

  @override
  String get greekPractice => 'Практика греческого';

  @override
  String get startExam => 'Начать экзамен';

  @override
  String get examSimulator => 'Симулятор экзамена';

  @override
  String questionOf(int current, int total) {
    return 'Вопрос $current из $total';
  }

  @override
  String get nextQuestion => 'Следующий вопрос';

  @override
  String get submitExam => 'Отправить';

  @override
  String get examResults => 'Результаты';

  @override
  String get passed => 'СДАНО';

  @override
  String get failed => 'НЕ СДАНО';

  @override
  String get reviewAnswers => 'Просмотр ответов';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get geography => 'География';

  @override
  String get politics => 'Политика';

  @override
  String get culture => 'Культура';

  @override
  String get dailyLife => 'Повседневная жизнь';

  @override
  String focusOn(String category) {
    return 'Сосредоточьтесь на: $category';
  }

  @override
  String get knowIt => 'Знаю';

  @override
  String get dontKnow => 'Не знаю';

  @override
  String get tapToReveal => 'Нажмите, чтобы открыть';

  @override
  String get aiTutorGreeting =>
      'Привет! Я ваш тьютор по экзамену на гражданство Кипра. Спрашивайте о чём угодно!';

  @override
  String get typeQuestion => 'Введите вопрос...';

  @override
  String get smartPractice => 'Умная практика';

  @override
  String get examDates => 'Даты экзаменов';

  @override
  String get examCenters => 'Центры экзаменов';

  @override
  String get applicationChecklist => 'Чек-лист документов';

  @override
  String get keepLearning => 'Keep Learning';

  @override
  String get weakAreas => 'Слабые места';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get notifications => 'Уведомления';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get subscription => 'Подписка';

  @override
  String get free => 'Бесплатно';

  @override
  String get premium => 'Премиум';

  @override
  String get upgradeToPremium => 'Перейти на Премиум';

  @override
  String get premiumBenefits => 'Откройте все функции всего за €20';

  @override
  String get restorePurchase => 'Восстановить покупку';

  @override
  String questionsToday(int used, int limit) {
    return '$used/$limit вопросов сегодня';
  }

  @override
  String get internetRequired =>
      'Требуется подключение к интернету для функций ИИ';

  @override
  String get noUpcomingExam => 'Нет запланированных экзаменов';
}
