// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CyCitizenship';

  @override
  String get navHome => 'Home';

  @override
  String get navPractice => 'Practice';

  @override
  String get navAi => 'AI';

  @override
  String get navInfo => 'Info';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcomeTitle => 'Welcome to CyCitizenship';

  @override
  String get welcomeSubtitle => 'Your path to Cyprus citizenship';

  @override
  String get selectLanguage => 'Select your language';

  @override
  String get selectRoute => 'Select your route';

  @override
  String get generalRoute => 'General Route (7+ years)';

  @override
  String get fastTrackRoute => 'Fast-Track (3-4 years)';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orSignInWith => 'Or sign in with';

  @override
  String get nextExam => 'Next Exam';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get dailyQuestion => 'Daily Question';

  @override
  String dayStreak(int count) {
    return '$count Day Streak';
  }

  @override
  String get averageScore => 'Average Score';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get mockExam => 'Mock Exam';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get aiTutor => 'AI Tutor';

  @override
  String get greekPractice => 'Greek Practice';

  @override
  String get startExam => 'Start Exam';

  @override
  String get examSimulator => 'Exam Simulator';

  @override
  String questionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get submitExam => 'Submit Exam';

  @override
  String get examResults => 'Results';

  @override
  String get passed => 'PASSED';

  @override
  String get failed => 'FAILED';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get geography => 'Geography';

  @override
  String get politics => 'Politics';

  @override
  String get culture => 'Culture';

  @override
  String get dailyLife => 'Daily Life';

  @override
  String focusOn(String category) {
    return 'Focus on: $category';
  }

  @override
  String get knowIt => 'Know It';

  @override
  String get dontKnow => 'Don\'t Know';

  @override
  String get tapToReveal => 'Tap to reveal';

  @override
  String get aiTutorGreeting =>
      'Hi! I\'m your Cyprus exam tutor. Ask me anything about history, politics, or culture.';

  @override
  String get typeQuestion => 'Type a question...';

  @override
  String get smartPractice => 'Smart Practice';

  @override
  String get examDates => 'Exam Dates';

  @override
  String get examCenters => 'Exam Centers';

  @override
  String get applicationChecklist => 'Application Checklist';

  @override
  String get keepLearning => 'Keep Learning';

  @override
  String get weakAreas => 'Weak Areas';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get subscription => 'Subscription';

  @override
  String get free => 'Free';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumBenefits => 'Unlock all features for just €20';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String questionsToday(int used, int limit) {
    return '$used/$limit questions today';
  }

  @override
  String get internetRequired => 'Internet connection required for AI features';

  @override
  String get noUpcomingExam => 'No upcoming exam scheduled';
}
