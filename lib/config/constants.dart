class AppConstants {
  // Exam
  static const int examQuestionCount = 25;
  static const int examDurationMinutes = 45;
  static const double citizenshipPassRate = 0.60;
  static const double ltrPassRate = 0.50;

  // Category distribution (out of 25)
  static const int geographyQuestions = 6;
  static const int politicsQuestions = 7;
  static const int cultureQuestions = 6;
  static const int dailyLifeQuestions = 6;

  // Free tier limits
  static const int freeQuestionsPerDay = 5;
  static const int freeAiMessagesPerDay = 3;
  static const int freeFlashcardsPerSession = 10;

  // Paid tier limits
  static const int paidAiMessagesPerDay = 50;

  // AI limit aliases (used by AI feature blocs and UI)
  static const int freeAiLimit = freeAiMessagesPerDay;
  static const int premiumAiLimit = paidAiMessagesPerDay;

  // Spaced repetition (Leitner box intervals in days)
  static const List<int> leitnerIntervals = [1, 3, 7, 14, 30];

  // Notifications
  static const int dailyQuestionHour = 9;
  static const int streakReminderHour = 20;
  static const int recentQuestionAvoidDays = 30;

  // Pricing
  static const String premiumProductId = 'cy_citizenship_premium';
  static const double premiumPrice = 20.0;

  // App
  static const String appName = 'CyCitizenship';
  static const List<String> supportedLanguages = ['en', 'ru', 'el'];
}
