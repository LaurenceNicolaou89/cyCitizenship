// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'CyCitizenship';

  @override
  String get navHome => 'Αρχική';

  @override
  String get navPractice => 'Εξάσκηση';

  @override
  String get navAi => 'ΑΙ';

  @override
  String get navInfo => 'Πληροφορίες';

  @override
  String get navProfile => 'Προφίλ';

  @override
  String get welcomeTitle => 'Καλως ήρθατε στο CyCitizenship';

  @override
  String get welcomeSubtitle => 'Ο δρόμος σας προς την κυπριακή υπηκοότητα';

  @override
  String get selectLanguage => 'Επιλέξτε γλώσσα';

  @override
  String get selectRoute => 'Επιλέξτε διαδρομή';

  @override
  String get generalRoute => 'Γενική διαδρομή (7+ χρόνια)';

  @override
  String get fastTrackRoute => 'Ταχεία διαδρομή (3-4 χρόνια)';

  @override
  String get signIn => 'Σύνδεση';

  @override
  String get signUp => 'Εγγραφή';

  @override
  String get continueAsGuest => 'Συνέχεια ως επισκέπτης';

  @override
  String get email => 'Ηλεκτρονικό ταχυδρομείο';

  @override
  String get password => 'Κωδικός';

  @override
  String get forgotPassword => 'Ξεχάσατε τον κωδικό;';

  @override
  String get orSignInWith => 'Ή συνδεθείτε με';

  @override
  String get nextExam => 'Επόμενη εξέταση';

  @override
  String daysLeft(int days) {
    return '$days ημέρες απομένουν';
  }

  @override
  String get dailyQuestion => 'Ερώτηση της ημέρας';

  @override
  String dayStreak(int count) {
    return 'Σερί $count ημερών';
  }

  @override
  String get averageScore => 'Μέσος όρος';

  @override
  String get quickActions => 'Γρήγορες ενέργειες';

  @override
  String get mockExam => 'Προσομοίωση εξέτασης';

  @override
  String get flashcards => 'Κάρτες';

  @override
  String get aiTutor => 'ΑΙ Καθηγητής';

  @override
  String get greekPractice => 'Εξάσκηση Ελληνικών';

  @override
  String get startExam => 'Έναρξη εξέτασης';

  @override
  String get examSimulator => 'Προσομοιωτής εξέτασης';

  @override
  String questionOf(int current, int total) {
    return 'Ερώτηση $current από $total';
  }

  @override
  String get nextQuestion => 'Επόμενη ερώτηση';

  @override
  String get submitExam => 'Υποβολή';

  @override
  String get examResults => 'Αποτελέσματα';

  @override
  String get passed => 'ΕΠΙΤΥΧΙΑ';

  @override
  String get failed => 'ΑΠΟΤΥΧΙΑ';

  @override
  String get reviewAnswers => 'Επισκόπηση απαντήσεων';

  @override
  String get tryAgain => 'Δοκιμάστε ξανά';

  @override
  String get geography => 'Γεωγραφία';

  @override
  String get politics => 'Πολιτική';

  @override
  String get culture => 'Πολιτισμός';

  @override
  String get dailyLife => 'Καθημερινή ζωή';

  @override
  String focusOn(String category) {
    return 'Εστιάστε στο: $category';
  }

  @override
  String get knowIt => 'Το ξέρω';

  @override
  String get dontKnow => 'Δεν ξέρω';

  @override
  String get tapToReveal => 'Πατήστε για αποκάλυψη';

  @override
  String get aiTutorGreeting =>
      'Γεια! Είμαι ο καθηγητής σας για την εξέταση υπηκοότητας Κύπρου. Ρωτήστε με οτιδήποτε!';

  @override
  String get typeQuestion => 'Πληκτρολογήστε μια ερώτηση...';

  @override
  String get smartPractice => 'Έξυπνη εξάσκηση';

  @override
  String get examDates => 'Ημερομηνίες εξετάσεων';

  @override
  String get examCenters => 'Κέντρα εξετάσεων';

  @override
  String get applicationChecklist => 'Λίστα ελέγχου αίτησης';

  @override
  String get keepLearning => 'Keep Learning';

  @override
  String get weakAreas => 'Αδύναμα σημεία';

  @override
  String get profile => 'Προφίλ';

  @override
  String get settings => 'Ρυθμίσεις';

  @override
  String get language => 'Γλώσσα';

  @override
  String get notifications => 'Ειδοποιήσεις';

  @override
  String get darkMode => 'Σκοτεινή λειτουργία';

  @override
  String get subscription => 'Συνδρομή';

  @override
  String get free => 'Δωρεάν';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeToPremium => 'Αναβάθμιση σε Premium';

  @override
  String get premiumBenefits => 'Ξεκλειδώστε όλες τις λειτουργίες με μόνο €20';

  @override
  String get restorePurchase => 'Επαναφορά αγοράς';

  @override
  String questionsToday(int used, int limit) {
    return '$used/$limit ερωτήσεις σήμερα';
  }

  @override
  String get internetRequired =>
      'Απαιτείται σύνδεση στο διαδίκτυο για τις λειτουργίες ΑΙ';

  @override
  String get noUpcomingExam => 'Δεν υπάρχει προγραμματισμένη εξέταση';
}
