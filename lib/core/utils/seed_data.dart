import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static Future<void> seedFirestore(FirebaseFirestore db) async {
    final batch = db.batch();

    for (final q in questions) {
      final ref = db.collection('questions').doc();
      batch.set(ref, {...q, 'updatedAt': FieldValue.serverTimestamp()});
    }

    for (final e in examDates) {
      final ref = db.collection('exam_dates').doc();
      batch.set(ref, e);
    }

    for (final c in courses) {
      final ref = db
          .collection('keep_learning')
          .doc('courses')
          .collection('items')
          .doc();
      batch.set(ref, c);
    }

    await batch.commit();
  }

  // ── Geography Questions (12) ──
  static final List<Map<String, dynamic>> questions = [
    {
      'textEn': 'What is the capital of Cyprus?',
      'textRu': '\u041a\u0430\u043a\u0430\u044f \u0441\u0442\u043e\u043b\u0438\u0446\u0430 \u041a\u0438\u043f\u0440\u0430?',
      'textEl': '\u03a0\u03bf\u03b9\u03b1 \u03b5\u03af\u03bd\u03b1\u03b9 \u03b7 \u03c0\u03c1\u03c9\u03c4\u03b5\u03cd\u03bf\u03c5\u03c3\u03b1 \u03c4\u03b7\u03c2 \u039a\u03cd\u03c0\u03c1\u03bf\u03c5;',
      'options': [
        {'textEn': 'Limassol', 'textRu': '\u041b\u0438\u043c\u0430\u0441\u043e\u043b', 'textEl': '\u039b\u03b5\u03bc\u03b5\u03c3\u03cc\u03c2'},
        {'textEn': 'Nicosia', 'textRu': '\u041d\u0438\u043a\u043e\u0441\u0438\u044f', 'textEl': '\u039b\u03b5\u03c5\u03ba\u03c9\u03c3\u03af\u03b1'},
        {'textEn': 'Larnaca', 'textRu': '\u041b\u0430\u0440\u043d\u0430\u043a\u0430', 'textEl': '\u039b\u03ac\u03c1\u03bd\u03b1\u03ba\u03b1'},
        {'textEn': 'Paphos', 'textRu': '\u041f\u0430\u0444\u043e\u0441', 'textEl': '\u03a0\u03ac\u03c6\u03bf\u03c2'},
      ],
      'correctIndex': 1,
      'category': 'geography',
      'difficulty': 'easy',
      'explanation': {'en': 'Nicosia (Lefkosia) is the capital and largest city of Cyprus, and the only divided capital in the world.', 'ru': '\u041d\u0438\u043a\u043e\u0441\u0438\u044f (\u041b\u0435\u0444\u043a\u043e\u0441\u0438\u044f) \u2014 \u0441\u0442\u043e\u043b\u0438\u0446\u0430 \u0438 \u043a\u0440\u0443\u043f\u043d\u0435\u0439\u0448\u0438\u0439 \u0433\u043e\u0440\u043e\u0434 \u041a\u0438\u043f\u0440\u0430.', 'el': '\u0397 \u039b\u03b5\u03c5\u03ba\u03c9\u03c3\u03af\u03b1 \u03b5\u03af\u03bd\u03b1\u03b9 \u03b7 \u03c0\u03c1\u03c9\u03c4\u03b5\u03cd\u03bf\u03c5\u03c3\u03b1 \u03c4\u03b7\u03c2 \u039a\u03cd\u03c0\u03c1\u03bf\u03c5.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What is the highest mountain in Cyprus?',
      'textRu': '\u041a\u0430\u043a\u0430\u044f \u0441\u0430\u043c\u0430\u044f \u0432\u044b\u0441\u043e\u043a\u0430\u044f \u0433\u043e\u0440\u0430 \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u03a0\u03bf\u03b9\u03bf \u03b5\u03af\u03bd\u03b1\u03b9 \u03c4\u03bf \u03c8\u03b7\u03bb\u03cc\u03c4\u03b5\u03c1\u03bf \u03b2\u03bf\u03c5\u03bd\u03cc \u03c4\u03b7\u03c2 \u039a\u03cd\u03c0\u03c1\u03bf\u03c5;',
      'options': [
        {'textEn': 'Mount Troodos', 'textRu': '\u0413\u043e\u0440\u0430 \u0422\u0440\u043e\u043e\u0434\u043e\u0441', 'textEl': '\u03a4\u03c1\u03cc\u03bf\u03b4\u03bf\u03c2'},
        {'textEn': 'Mount Olympus (Chionistra)', 'textRu': '\u0413\u043e\u0440\u0430 \u041e\u043b\u0438\u043c\u043f (\u0425\u0438\u043e\u043d\u0438\u0441\u0442\u0440\u0430)', 'textEl': '\u038c\u03bb\u03c5\u03bc\u03c0\u03bf\u03c2 (\u03a7\u03b9\u03bf\u03bd\u03af\u03c3\u03c4\u03c1\u03b1)'},
        {'textEn': 'Mount Stavrovouni', 'textRu': '\u0413\u043e\u0440\u0430 \u0421\u0442\u0430\u0432\u0440\u043e\u0432\u0443\u043d\u0438', 'textEl': '\u03a3\u03c4\u03b1\u03c5\u03c1\u03bf\u03b2\u03bf\u03cd\u03bd\u03b9'},
        {'textEn': 'Mount Machairas', 'textRu': '\u0413\u043e\u0440\u0430 \u041c\u0430\u0445\u0435\u0440\u0430\u0441', 'textEl': '\u039c\u03b1\u03c7\u03b1\u03b9\u03c1\u03ac\u03c2'},
      ],
      'correctIndex': 1,
      'category': 'geography',
      'difficulty': 'easy',
      'explanation': {'en': 'Mount Olympus (Chionistra) at 1,952m is the highest peak in Cyprus, located in the Troodos mountain range.', 'ru': '\u0413\u043e\u0440\u0430 \u041e\u043b\u0438\u043c\u043f (\u0425\u0438\u043e\u043d\u0438\u0441\u0442\u0440\u0430) \u0432\u044b\u0441\u043e\u0442\u043e\u0439 1952 \u043c \u2014 \u0441\u0430\u043c\u0430\u044f \u0432\u044b\u0441\u043e\u043a\u0430\u044f \u0442\u043e\u0447\u043a\u0430 \u041a\u0438\u043f\u0440\u0430.', 'el': '\u039f \u038c\u03bb\u03c5\u03bc\u03c0\u03bf\u03c2 (\u03a7\u03b9\u03bf\u03bd\u03af\u03c3\u03c4\u03c1\u03b1) \u03c3\u03c4\u03b1 1.952\u03bc \u03b5\u03af\u03bd\u03b1\u03b9 \u03b7 \u03c8\u03b7\u03bb\u03cc\u03c4\u03b5\u03c1\u03b7 \u03ba\u03bf\u03c1\u03c5\u03c6\u03ae.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'How many districts does Cyprus have?',
      'textRu': '\u0421\u043a\u043e\u043b\u044c\u043a\u043e \u043e\u043a\u0440\u0443\u0433\u043e\u0432 \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u03a0\u03cc\u03c3\u03b5\u03c2 \u03b5\u03c0\u03b1\u03c1\u03c7\u03af\u03b5\u03c2 \u03ad\u03c7\u03b5\u03b9 \u03b7 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2;',
      'options': [
        {'textEn': '4', 'textRu': '4', 'textEl': '4'},
        {'textEn': '5', 'textRu': '5', 'textEl': '5'},
        {'textEn': '6', 'textRu': '6', 'textEl': '6'},
        {'textEn': '7', 'textRu': '7', 'textEl': '7'},
      ],
      'correctIndex': 2,
      'category': 'geography',
      'difficulty': 'easy',
      'explanation': {'en': 'Cyprus has 6 districts: Nicosia, Limassol, Larnaca, Paphos, Famagusta, and Kyrenia.', 'ru': '\u041d\u0430 \u041a\u0438\u043f\u0440\u0435 6 \u043e\u043a\u0440\u0443\u0433\u043e\u0432: \u041d\u0438\u043a\u043e\u0441\u0438\u044f, \u041b\u0438\u043c\u0430\u0441\u043e\u043b, \u041b\u0430\u0440\u043d\u0430\u043a\u0430, \u041f\u0430\u0444\u043e\u0441, \u0424\u0430\u043c\u0430\u0433\u0443\u0441\u0442\u0430, \u041a\u0438\u0440\u0435\u043d\u0438\u044f.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03ad\u03c7\u03b5\u03b9 6 \u03b5\u03c0\u03b1\u03c1\u03c7\u03af\u03b5\u03c2.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'In which year did Cyprus join the European Union?',
      'textRu': '\u0412 \u043a\u0430\u043a\u043e\u043c \u0433\u043e\u0434\u0443 \u041a\u0438\u043f\u0440 \u0432\u0441\u0442\u0443\u043f\u0438\u043b \u0432 \u0415\u0432\u0440\u043e\u043f\u0435\u0439\u0441\u043a\u0438\u0439 \u0441\u043e\u044e\u0437?',
      'textEl': '\u03a0\u03cc\u03c4\u03b5 \u03b5\u03bd\u03c4\u03ac\u03c7\u03b8\u03b7\u03ba\u03b5 \u03b7 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03c3\u03c4\u03b7\u03bd \u0395\u03c5\u03c1\u03c9\u03c0\u03b1\u03ca\u03ba\u03ae \u0388\u03bd\u03c9\u03c3\u03b7;',
      'options': [
        {'textEn': '2001', 'textRu': '2001', 'textEl': '2001'},
        {'textEn': '2004', 'textRu': '2004', 'textEl': '2004'},
        {'textEn': '2007', 'textRu': '2007', 'textEl': '2007'},
        {'textEn': '2008', 'textRu': '2008', 'textEl': '2008'},
      ],
      'correctIndex': 1,
      'category': 'geography',
      'difficulty': 'medium',
      'explanation': {'en': 'Cyprus joined the EU on 1 May 2004 along with 9 other countries.', 'ru': '\u041a\u0438\u043f\u0440 \u0432\u0441\u0442\u0443\u043f\u0438\u043b \u0432 \u0415\u0421 1 \u043c\u0430\u044f 2004 \u0433\u043e\u0434\u0430.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03b5\u03bd\u03c4\u03ac\u03c7\u03b8\u03b7\u03ba\u03b5 \u03c3\u03c4\u03b7\u03bd \u0395\u0395 \u03c4\u03b7\u03bd 1\u03b7 \u039c\u03b1\u0390\u03bf\u03c5 2004.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What is the climate of Cyprus?',
      'textRu': '\u041a\u0430\u043a\u043e\u0439 \u043a\u043b\u0438\u043c\u0430\u0442 \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u03a0\u03bf\u03b9\u03bf \u03b5\u03af\u03bd\u03b1\u03b9 \u03c4\u03bf \u03ba\u03bb\u03af\u03bc\u03b1 \u03c4\u03b7\u03c2 \u039a\u03cd\u03c0\u03c1\u03bf\u03c5;',
      'options': [
        {'textEn': 'Continental', 'textRu': '\u041a\u043e\u043d\u0442\u0438\u043d\u0435\u043d\u0442\u0430\u043b\u044c\u043d\u044b\u0439', 'textEl': '\u0397\u03c0\u03b5\u03b9\u03c1\u03c9\u03c4\u03b9\u03ba\u03cc'},
        {'textEn': 'Mediterranean', 'textRu': '\u0421\u0440\u0435\u0434\u0438\u0437\u0435\u043c\u043d\u043e\u043c\u043e\u0440\u0441\u043a\u0438\u0439', 'textEl': '\u039c\u03b5\u03c3\u03bf\u03b3\u03b5\u03b9\u03b1\u03ba\u03cc'},
        {'textEn': 'Tropical', 'textRu': '\u0422\u0440\u043e\u043f\u0438\u0447\u0435\u0441\u043a\u0438\u0439', 'textEl': '\u03a4\u03c1\u03bf\u03c0\u03b9\u03ba\u03cc'},
        {'textEn': 'Oceanic', 'textRu': '\u041e\u043a\u0435\u0430\u043d\u0438\u0447\u0435\u0441\u043a\u0438\u0439', 'textEl': '\u03a9\u03ba\u03b5\u03ac\u03bd\u03b9\u03bf'},
      ],
      'correctIndex': 1,
      'category': 'geography',
      'difficulty': 'easy',
      'explanation': {'en': 'Cyprus has a Mediterranean climate with hot dry summers and mild wet winters.', 'ru': '\u041d\u0430 \u041a\u0438\u043f\u0440\u0435 \u0441\u0440\u0435\u0434\u0438\u0437\u0435\u043c\u043d\u043e\u043c\u043e\u0440\u0441\u043a\u0438\u0439 \u043a\u043b\u0438\u043c\u0430\u0442.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03ad\u03c7\u03b5\u03b9 \u03bc\u03b5\u03c3\u03bf\u03b3\u03b5\u03b9\u03b1\u03ba\u03cc \u03ba\u03bb\u03af\u03bc\u03b1.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'Which sea surrounds Cyprus?',
      'textRu': '\u041a\u0430\u043a\u043e\u0435 \u043c\u043e\u0440\u0435 \u043e\u043a\u0440\u0443\u0436\u0430\u0435\u0442 \u041a\u0438\u043f\u0440?',
      'textEl': '\u03a0\u03bf\u03b9\u03b1 \u03b8\u03ac\u03bb\u03b1\u03c3\u03c3\u03b1 \u03c0\u03b5\u03c1\u03b9\u03b2\u03ac\u03bb\u03bb\u03b5\u03b9 \u03c4\u03b7\u03bd \u039a\u03cd\u03c0\u03c1\u03bf;',
      'options': [
        {'textEn': 'Aegean Sea', 'textRu': '\u042d\u0433\u0435\u0439\u0441\u043a\u043e\u0435 \u043c\u043e\u0440\u0435', 'textEl': '\u0391\u03b9\u03b3\u03b1\u03af\u03bf'},
        {'textEn': 'Black Sea', 'textRu': '\u0427\u0451\u0440\u043d\u043e\u0435 \u043c\u043e\u0440\u0435', 'textEl': '\u039c\u03b1\u03cd\u03c1\u03b7 \u0398\u03ac\u03bb\u03b1\u03c3\u03c3\u03b1'},
        {'textEn': 'Mediterranean Sea', 'textRu': '\u0421\u0440\u0435\u0434\u0438\u0437\u0435\u043c\u043d\u043e\u0435 \u043c\u043e\u0440\u0435', 'textEl': '\u039c\u03b5\u03c3\u03cc\u03b3\u03b5\u03b9\u03bf\u03c2'},
        {'textEn': 'Red Sea', 'textRu': '\u041a\u0440\u0430\u0441\u043d\u043e\u0435 \u043c\u043e\u0440\u0435', 'textEl': '\u0395\u03c1\u03c5\u03b8\u03c1\u03ac \u0398\u03ac\u03bb\u03b1\u03c3\u03c3\u03b1'},
      ],
      'correctIndex': 2,
      'category': 'geography',
      'difficulty': 'easy',
      'explanation': {'en': 'Cyprus is the third largest island in the Mediterranean Sea.', 'ru': '\u041a\u0438\u043f\u0440 \u2014 \u0442\u0440\u0435\u0442\u0438\u0439 \u043f\u043e \u0432\u0435\u043b\u0438\u0447\u0438\u043d\u0435 \u043e\u0441\u0442\u0440\u043e\u0432 \u0432 \u0421\u0440\u0435\u0434\u0438\u0437\u0435\u043c\u043d\u043e\u043c \u043c\u043e\u0440\u0435.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03b5\u03af\u03bd\u03b1\u03b9 \u03c4\u03bf \u03c4\u03c1\u03af\u03c4\u03bf \u03bc\u03b5\u03b3\u03b1\u03bb\u03cd\u03c4\u03b5\u03c1\u03bf \u03bd\u03b7\u03c3\u03af \u03c4\u03b7\u03c2 \u039c\u03b5\u03c3\u03bf\u03b3\u03b5\u03af\u03bf\u03c5.'},
      'source': 'visitcyprus.com',
    },
    // ── Politics Questions (14) ──
    {
      'textEn': 'What type of government does Cyprus have?',
      'textRu': '\u041a\u0430\u043a\u0430\u044f \u0444\u043e\u0440\u043c\u0430 \u043f\u0440\u0430\u0432\u043b\u0435\u043d\u0438\u044f \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u03a4\u03b9 \u03c0\u03bf\u03bb\u03af\u03c4\u03b5\u03c5\u03bc\u03b1 \u03ad\u03c7\u03b5\u03b9 \u03b7 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2;',
      'options': [
        {'textEn': 'Constitutional monarchy', 'textRu': '\u041a\u043e\u043d\u0441\u0442\u0438\u0442\u0443\u0446\u0438\u043e\u043d\u043d\u0430\u044f \u043c\u043e\u043d\u0430\u0440\u0445\u0438\u044f', 'textEl': '\u03a3\u03c5\u03bd\u03c4\u03b1\u03b3\u03bc\u03b1\u03c4\u03b9\u03ba\u03ae \u03bc\u03bf\u03bd\u03b1\u03c1\u03c7\u03af\u03b1'},
        {'textEn': 'Presidential republic', 'textRu': '\u041f\u0440\u0435\u0437\u0438\u0434\u0435\u043d\u0442\u0441\u043a\u0430\u044f \u0440\u0435\u0441\u043f\u0443\u0431\u043b\u0438\u043a\u0430', 'textEl': '\u03a0\u03c1\u03bf\u03b5\u03b4\u03c1\u03b9\u03ba\u03ae \u03b4\u03b7\u03bc\u03bf\u03ba\u03c1\u03b1\u03c4\u03af\u03b1'},
        {'textEn': 'Parliamentary democracy', 'textRu': '\u041f\u0430\u0440\u043b\u0430\u043c\u0435\u043d\u0442\u0441\u043a\u0430\u044f \u0434\u0435\u043c\u043e\u043a\u0440\u0430\u0442\u0438\u044f', 'textEl': '\u039a\u03bf\u03b9\u03bd\u03bf\u03b2\u03bf\u03c5\u03bb\u03b5\u03c5\u03c4\u03b9\u03ba\u03ae \u03b4\u03b7\u03bc\u03bf\u03ba\u03c1\u03b1\u03c4\u03af\u03b1'},
        {'textEn': 'Federal republic', 'textRu': '\u0424\u0435\u0434\u0435\u0440\u0430\u0442\u0438\u0432\u043d\u0430\u044f \u0440\u0435\u0441\u043f\u0443\u0431\u043b\u0438\u043a\u0430', 'textEl': '\u039f\u03bc\u03bf\u03c3\u03c0\u03bf\u03bd\u03b4\u03b9\u03b1\u03ba\u03ae \u03b4\u03b7\u03bc\u03bf\u03ba\u03c1\u03b1\u03c4\u03af\u03b1'},
      ],
      'correctIndex': 1,
      'category': 'politics',
      'difficulty': 'easy',
      'explanation': {'en': 'Cyprus is a presidential republic. The President is both head of state and head of government.', 'ru': '\u041a\u0438\u043f\u0440 \u2014 \u043f\u0440\u0435\u0437\u0438\u0434\u0435\u043d\u0442\u0441\u043a\u0430\u044f \u0440\u0435\u0441\u043f\u0443\u0431\u043b\u0438\u043a\u0430.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03b5\u03af\u03bd\u03b1\u03b9 \u03c0\u03c1\u03bf\u03b5\u03b4\u03c1\u03b9\u03ba\u03ae \u03b4\u03b7\u03bc\u03bf\u03ba\u03c1\u03b1\u03c4\u03af\u03b1.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'How many seats does the House of Representatives have?',
      'textRu': '\u0421\u043a\u043e\u043b\u044c\u043a\u043e \u043c\u0435\u0441\u0442 \u0432 \u041f\u0430\u043b\u0430\u0442\u0435 \u043f\u0440\u0435\u0434\u0441\u0442\u0430\u0432\u0438\u0442\u0435\u043b\u0435\u0439?',
      'textEl': '\u03a0\u03cc\u03c3\u03b5\u03c2 \u03ad\u03b4\u03c1\u03b5\u03c2 \u03ad\u03c7\u03b5\u03b9 \u03b7 \u0392\u03bf\u03c5\u03bb\u03ae;',
      'options': [
        {'textEn': '50', 'textRu': '50', 'textEl': '50'},
        {'textEn': '56', 'textRu': '56', 'textEl': '56'},
        {'textEn': '80', 'textRu': '80', 'textEl': '80'},
        {'textEn': '100', 'textRu': '100', 'textEl': '100'},
      ],
      'correctIndex': 1,
      'category': 'politics',
      'difficulty': 'medium',
      'explanation': {'en': 'The House of Representatives has 80 seats, but only 56 are filled (24 reserved for Turkish Cypriots remain vacant).', 'ru': '\u0412 \u041f\u0430\u043b\u0430\u0442\u0435 80 \u043c\u0435\u0441\u0442, \u043d\u043e \u0437\u0430\u043d\u044f\u0442\u044b \u0442\u043e\u043b\u044c\u043a\u043e 56.', 'el': '\u0397 \u0392\u03bf\u03c5\u03bb\u03ae \u03ad\u03c7\u03b5\u03b9 80 \u03ad\u03b4\u03c1\u03b5\u03c2, \u03b1\u03bb\u03bb\u03ac \u03bc\u03cc\u03bd\u03bf 56 \u03b5\u03af\u03bd\u03b1\u03b9 \u03ba\u03b1\u03c4\u03b5\u03b9\u03bb\u03b7\u03bc\u03bc\u03ad\u03bd\u03b5\u03c2.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'When did Cyprus gain independence?',
      'textRu': '\u041a\u043e\u0433\u0434\u0430 \u041a\u0438\u043f\u0440 \u043f\u043e\u043b\u0443\u0447\u0438\u043b \u043d\u0435\u0437\u0430\u0432\u0438\u0441\u0438\u043c\u043e\u0441\u0442\u044c?',
      'textEl': '\u03a0\u03cc\u03c4\u03b5 \u03ad\u03b3\u03b9\u03bd\u03b5 \u03b7 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03b1\u03bd\u03b5\u03be\u03ac\u03c1\u03c4\u03b7\u03c4\u03b7;',
      'options': [
        {'textEn': '1955', 'textRu': '1955', 'textEl': '1955'},
        {'textEn': '1960', 'textRu': '1960', 'textEl': '1960'},
        {'textEn': '1974', 'textRu': '1974', 'textEl': '1974'},
        {'textEn': '1983', 'textRu': '1983', 'textEl': '1983'},
      ],
      'correctIndex': 1,
      'category': 'politics',
      'difficulty': 'easy',
      'explanation': {'en': 'Cyprus became independent from Britain on 16 August 1960.', 'ru': '\u041a\u0438\u043f\u0440 \u043e\u0431\u0440\u0435\u043b \u043d\u0435\u0437\u0430\u0432\u0438\u0441\u0438\u043c\u043e\u0441\u0442\u044c 16 \u0430\u0432\u0433\u0443\u0441\u0442\u0430 1960 \u0433\u043e\u0434\u0430.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03ad\u03b3\u03b9\u03bd\u03b5 \u03b1\u03bd\u03b5\u03be\u03ac\u03c1\u03c4\u03b7\u03c4\u03b7 \u03c3\u03c4\u03b9\u03c2 16 \u0391\u03c5\u03b3\u03bf\u03cd\u03c3\u03c4\u03bf\u03c5 1960.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What happened in Cyprus in 1974?',
      'textRu': '\u0427\u0442\u043e \u043f\u0440\u043e\u0438\u0437\u043e\u0448\u043b\u043e \u043d\u0430 \u041a\u0438\u043f\u0440\u0435 \u0432 1974 \u0433\u043e\u0434\u0443?',
      'textEl': '\u03a4\u03b9 \u03c3\u03c5\u03bd\u03ad\u03b2\u03b7 \u03c3\u03c4\u03b7\u03bd \u039a\u03cd\u03c0\u03c1\u03bf \u03c4\u03bf 1974;',
      'options': [
        {'textEn': 'Cyprus joined the EU', 'textRu': '\u041a\u0438\u043f\u0440 \u0432\u0441\u0442\u0443\u043f\u0438\u043b \u0432 \u0415\u0421', 'textEl': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03b5\u03bd\u03c4\u03ac\u03c7\u03b8\u03b7\u03ba\u03b5 \u03c3\u03c4\u03b7\u03bd \u0395\u0395'},
        {'textEn': 'Turkish military invasion', 'textRu': '\u0422\u0443\u0440\u0435\u0446\u043a\u043e\u0435 \u0432\u043e\u0435\u043d\u043d\u043e\u0435 \u0432\u0442\u043e\u0440\u0436\u0435\u043d\u0438\u0435', 'textEl': '\u03a4\u03bf\u03c5\u03c1\u03ba\u03b9\u03ba\u03ae \u03b5\u03b9\u03c3\u03b2\u03bf\u03bb\u03ae'},
        {'textEn': 'Independence from Britain', 'textRu': '\u041d\u0435\u0437\u0430\u0432\u0438\u0441\u0438\u043c\u043e\u0441\u0442\u044c \u043e\u0442 \u0411\u0440\u0438\u0442\u0430\u043d\u0438\u0438', 'textEl': '\u0391\u03bd\u03b5\u03be\u03b1\u03c1\u03c4\u03b7\u03c3\u03af\u03b1 \u03b1\u03c0\u03cc \u0392\u03c1\u03b5\u03c4\u03b1\u03bd\u03af\u03b1'},
        {'textEn': 'Adoption of the Euro', 'textRu': '\u041f\u0440\u0438\u043d\u044f\u0442\u0438\u0435 \u0435\u0432\u0440\u043e', 'textEl': '\u03a5\u03b9\u03bf\u03b8\u03ad\u03c4\u03b7\u03c3\u03b7 \u03c4\u03bf\u03c5 \u03b5\u03c5\u03c1\u03ce'},
      ],
      'correctIndex': 1,
      'category': 'politics',
      'difficulty': 'easy',
      'explanation': {'en': 'In July 1974, Turkey invaded Cyprus following a coup, leading to the division of the island.', 'ru': '\u0412 \u0438\u044e\u043b\u0435 1974 \u0422\u0443\u0440\u0446\u0438\u044f \u0432\u0442\u043e\u0440\u0433\u043b\u0430\u0441\u044c \u043d\u0430 \u041a\u0438\u043f\u0440.', 'el': '\u03a4\u03bf\u03bd \u0399\u03bf\u03cd\u03bb\u03b9\u03bf 1974 \u03b7 \u03a4\u03bf\u03c5\u03c1\u03ba\u03af\u03b1 \u03b5\u03b9\u03c3\u03ad\u03b2\u03b1\u03bb\u03b5 \u03c3\u03c4\u03b7\u03bd \u039a\u03cd\u03c0\u03c1\u03bf.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'Which is the largest political party in Cyprus (center-right)?',
      'textRu': '\u041a\u0430\u043a\u0430\u044f \u043a\u0440\u0443\u043f\u043d\u0435\u0439\u0448\u0430\u044f \u043f\u043e\u043b\u0438\u0442\u0438\u0447\u0435\u0441\u043a\u0430\u044f \u043f\u0430\u0440\u0442\u0438\u044f \u041a\u0438\u043f\u0440\u0430?',
      'textEl': '\u03a0\u03bf\u03b9\u03bf \u03b5\u03af\u03bd\u03b1\u03b9 \u03c4\u03bf \u03bc\u03b5\u03b3\u03b1\u03bb\u03cd\u03c4\u03b5\u03c1\u03bf \u03ba\u03cc\u03bc\u03bc\u03b1 \u03c4\u03b7\u03c2 \u039a\u03cd\u03c0\u03c1\u03bf\u03c5;',
      'options': [
        {'textEn': 'AKEL', 'textRu': '\u0410\u041a\u042d\u041b', 'textEl': '\u0391\u039a\u0395\u039b'},
        {'textEn': 'DISY', 'textRu': '\u0414\u0418\u0421\u0418', 'textEl': '\u0394\u0397\u03a3\u03a5'},
        {'textEn': 'DIKO', 'textRu': '\u0414\u0418\u041a\u041e', 'textEl': '\u0394\u0397\u039a\u039f'},
        {'textEn': 'EDEK', 'textRu': '\u042d\u0414\u042d\u041a', 'textEl': '\u0395\u0394\u0395\u039a'},
      ],
      'correctIndex': 1,
      'category': 'politics',
      'difficulty': 'medium',
      'explanation': {'en': 'DISY (Democratic Rally) is the largest center-right party in Cyprus.', 'ru': '\u0414\u0418\u0421\u0418 (\u0414\u0435\u043c\u043e\u043a\u0440\u0430\u0442\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u0441\u0431\u043e\u0440) \u2014 \u043a\u0440\u0443\u043f\u043d\u0435\u0439\u0448\u0430\u044f \u043f\u0440\u0430\u0432\u043e\u0446\u0435\u043d\u0442\u0440\u0438\u0441\u0442\u0441\u043a\u0430\u044f \u043f\u0430\u0440\u0442\u0438\u044f.', 'el': '\u039f \u0394\u0397\u03a3\u03a5 \u03b5\u03af\u03bd\u03b1\u03b9 \u03c4\u03bf \u03bc\u03b5\u03b3\u03b1\u03bb\u03cd\u03c4\u03b5\u03c1\u03bf \u03ba\u03b5\u03bd\u03c4\u03c1\u03bf\u03b4\u03b5\u03be\u03b9\u03cc \u03ba\u03cc\u03bc\u03bc\u03b1.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'Who was the first President of Cyprus?',
      'textRu': '\u041a\u0442\u043e \u0431\u044b\u043b \u043f\u0435\u0440\u0432\u044b\u043c \u043f\u0440\u0435\u0437\u0438\u0434\u0435\u043d\u0442\u043e\u043c \u041a\u0438\u043f\u0440\u0430?',
      'textEl': '\u03a0\u03bf\u03b9\u03bf\u03c2 \u03ae\u03c4\u03b1\u03bd \u03bf \u03c0\u03c1\u03ce\u03c4\u03bf\u03c2 \u03a0\u03c1\u03cc\u03b5\u03b4\u03c1\u03bf\u03c2 \u03c4\u03b7\u03c2 \u039a\u03cd\u03c0\u03c1\u03bf\u03c5;',
      'options': [
        {'textEn': 'Glafcos Clerides', 'textRu': '\u0413\u043b\u0430\u0444\u043a\u043e\u0441 \u041a\u043b\u0438\u0440\u0438\u0434\u0438\u0441', 'textEl': '\u0393\u03bb\u03b1\u03cd\u03ba\u03bf\u03c2 \u039a\u03bb\u03b7\u03c1\u03af\u03b4\u03b7\u03c2'},
        {'textEn': 'Tassos Papadopoulos', 'textRu': '\u0422\u0430\u0441\u0441\u043e\u0441 \u041f\u0430\u043f\u0430\u0434\u043e\u043f\u0443\u043b\u043e\u0441', 'textEl': '\u03a4\u03ac\u03c3\u03c3\u03bf\u03c2 \u03a0\u03b1\u03c0\u03b1\u03b4\u03cc\u03c0\u03bf\u03c5\u03bb\u03bf\u03c2'},
        {'textEn': 'Archbishop Makarios III', 'textRu': '\u0410\u0440\u0445\u0438\u0435\u043f\u0438\u0441\u043a\u043e\u043f \u041c\u0430\u043a\u0430\u0440\u0438\u043e\u0441 III', 'textEl': '\u0391\u03c1\u03c7\u03b9\u03b5\u03c0\u03af\u03c3\u03ba\u03bf\u03c0\u03bf\u03c2 \u039c\u03b1\u03ba\u03ac\u03c1\u03b9\u03bf\u03c2 \u0393\u0384'},
        {'textEn': 'Spyros Kyprianou', 'textRu': '\u0421\u043f\u0438\u0440\u043e\u0441 \u041a\u0438\u043f\u0440\u0438\u0430\u043d\u0443', 'textEl': '\u03a3\u03c0\u03cd\u03c1\u03bf\u03c2 \u039a\u03c5\u03c0\u03c1\u03b9\u03b1\u03bd\u03bf\u03cd'},
      ],
      'correctIndex': 2,
      'category': 'politics',
      'difficulty': 'medium',
      'explanation': {'en': 'Archbishop Makarios III was the first President of Cyprus, serving from 1960 to 1977.', 'ru': '\u0410\u0440\u0445\u0438\u0435\u043f\u0438\u0441\u043a\u043e\u043f \u041c\u0430\u043a\u0430\u0440\u0438\u043e\u0441 III \u0431\u044b\u043b \u043f\u0435\u0440\u0432\u044b\u043c \u043f\u0440\u0435\u0437\u0438\u0434\u0435\u043d\u0442\u043e\u043c (1960-1977).', 'el': '\u039f \u0391\u03c1\u03c7\u03b9\u03b5\u03c0\u03af\u03c3\u03ba\u03bf\u03c0\u03bf\u03c2 \u039c\u03b1\u03ba\u03ac\u03c1\u03b9\u03bf\u03c2 \u0393\u0384 \u03ae\u03c4\u03b1\u03bd \u03bf \u03c0\u03c1\u03ce\u03c4\u03bf\u03c2 \u03a0\u03c1\u03cc\u03b5\u03b4\u03c1\u03bf\u03c2 (1960-1977).'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'When did Cyprus adopt the Euro?',
      'textRu': '\u041a\u043e\u0433\u0434\u0430 \u041a\u0438\u043f\u0440 \u043f\u0435\u0440\u0435\u0448\u0451\u043b \u043d\u0430 \u0435\u0432\u0440\u043e?',
      'textEl': '\u03a0\u03cc\u03c4\u03b5 \u03c5\u03b9\u03bf\u03b8\u03ad\u03c4\u03b7\u03c3\u03b5 \u03b7 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03c4\u03bf \u03b5\u03c5\u03c1\u03ce;',
      'options': [
        {'textEn': '2004', 'textRu': '2004', 'textEl': '2004'},
        {'textEn': '2006', 'textRu': '2006', 'textEl': '2006'},
        {'textEn': '2008', 'textRu': '2008', 'textEl': '2008'},
        {'textEn': '2010', 'textRu': '2010', 'textEl': '2010'},
      ],
      'correctIndex': 2,
      'category': 'politics',
      'difficulty': 'medium',
      'explanation': {'en': 'Cyprus adopted the Euro on 1 January 2008, replacing the Cyprus pound.', 'ru': '\u041a\u0438\u043f\u0440 \u043f\u0435\u0440\u0435\u0448\u0451\u043b \u043d\u0430 \u0435\u0432\u0440\u043e 1 \u044f\u043d\u0432\u0430\u0440\u044f 2008 \u0433\u043e\u0434\u0430.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03c5\u03b9\u03bf\u03b8\u03ad\u03c4\u03b7\u03c3\u03b5 \u03c4\u03bf \u03b5\u03c5\u03c1\u03ce \u03c4\u03b7\u03bd 1\u03b7 \u0399\u03b1\u03bd\u03bf\u03c5\u03b1\u03c1\u03af\u03bf\u03c5 2008.'},
      'source': 'visitcyprus.com',
    },
    // ── Culture Questions (12) ──
    {
      'textEn': 'What is Lefkara village famous for?',
      'textRu': '\u0427\u0435\u043c \u0437\u043d\u0430\u043c\u0435\u043d\u0438\u0442\u0430 \u0434\u0435\u0440\u0435\u0432\u043d\u044f \u041b\u0435\u0444\u043a\u0430\u0440\u0430?',
      'textEl': '\u0393\u03b9\u03b1 \u03c4\u03b9 \u03b5\u03af\u03bd\u03b1\u03b9 \u03b3\u03bd\u03c9\u03c3\u03c4\u03cc \u03c4\u03bf \u03c7\u03c9\u03c1\u03b9\u03cc \u039b\u03b5\u03cd\u03ba\u03b1\u03c1\u03b1;',
      'options': [
        {'textEn': 'Wine production', 'textRu': '\u0412\u0438\u043d\u043e\u0434\u0435\u043b\u0438\u0435', 'textEl': '\u03a0\u03b1\u03c1\u03b1\u03b3\u03c9\u03b3\u03ae \u03ba\u03c1\u03b1\u03c3\u03b9\u03bf\u03cd'},
        {'textEn': 'Lace and silverwork', 'textRu': '\u041a\u0440\u0443\u0436\u0435\u0432\u043e \u0438 \u0441\u0435\u0440\u0435\u0431\u0440\u043e', 'textEl': '\u039a\u03b5\u03bd\u03c4\u03ae\u03bc\u03b1\u03c4\u03b1 \u03ba\u03b1\u03b9 \u03b1\u03c3\u03b7\u03bc\u03b9\u03ba\u03ac'},
        {'textEn': 'Olive oil', 'textRu': '\u041e\u043b\u0438\u0432\u043a\u043e\u0432\u043e\u0435 \u043c\u0430\u0441\u043b\u043e', 'textEl': '\u0395\u03bb\u03b1\u03b9\u03cc\u03bb\u03b1\u03b4\u03bf'},
        {'textEn': 'Pottery', 'textRu': '\u0413\u043e\u043d\u0447\u0430\u0440\u043d\u043e\u0435 \u0434\u0435\u043b\u043e', 'textEl': '\u039a\u03b5\u03c1\u03b1\u03bc\u03b9\u03ba\u03ae'},
      ],
      'correctIndex': 1,
      'category': 'culture',
      'difficulty': 'easy',
      'explanation': {'en': 'Lefkara is famous for its traditional lace (lefkaritika) and silverwork, a UNESCO Intangible Heritage.', 'ru': '\u041b\u0435\u0444\u043a\u0430\u0440\u0430 \u0437\u043d\u0430\u043c\u0435\u043d\u0438\u0442\u0430 \u043a\u0440\u0443\u0436\u0435\u0432\u043e\u043c (\u043b\u0435\u0444\u043a\u0430\u0440\u0438\u0442\u0438\u043a\u0430), \u043d\u0430\u0441\u043b\u0435\u0434\u0438\u0435 \u042e\u041d\u0415\u0421\u041a\u041e.', 'el': '\u0397 \u039b\u03b5\u03cd\u03ba\u03b1\u03c1\u03b1 \u03b5\u03af\u03bd\u03b1\u03b9 \u03b3\u03bd\u03c9\u03c3\u03c4\u03ae \u03b3\u03b9\u03b1 \u03c4\u03b1 \u03bb\u03b5\u03c5\u03ba\u03b1\u03c1\u03af\u03c4\u03b9\u03ba\u03b1 \u03ba\u03b5\u03bd\u03c4\u03ae\u03bc\u03b1\u03c4\u03b1.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What is Commandaria?',
      'textRu': '\u0427\u0442\u043e \u0442\u0430\u043a\u043e\u0435 \u041a\u043e\u043c\u043c\u0430\u043d\u0434\u0430\u0440\u0438\u044f?',
      'textEl': '\u03a4\u03b9 \u03b5\u03af\u03bd\u03b1\u03b9 \u03b7 \u039a\u03bf\u03bc\u03bc\u03b1\u03bd\u03c4\u03b1\u03c1\u03af\u03b1;',
      'options': [
        {'textEn': 'A traditional dance', 'textRu': '\u0422\u0440\u0430\u0434\u0438\u0446\u0438\u043e\u043d\u043d\u044b\u0439 \u0442\u0430\u043d\u0435\u0446', 'textEl': '\u03a0\u03b1\u03c1\u03b1\u03b4\u03bf\u03c3\u03b9\u03b1\u03ba\u03cc\u03c2 \u03c7\u03bf\u03c1\u03cc\u03c2'},
        {'textEn': 'A type of cheese', 'textRu': '\u0412\u0438\u0434 \u0441\u044b\u0440\u0430', 'textEl': '\u0395\u03af\u03b4\u03bf\u03c2 \u03c4\u03c5\u03c1\u03b9\u03bf\u03cd'},
        {'textEn': 'A sweet dessert wine', 'textRu': '\u0421\u043b\u0430\u0434\u043a\u043e\u0435 \u0434\u0435\u0441\u0435\u0440\u0442\u043d\u043e\u0435 \u0432\u0438\u043d\u043e', 'textEl': '\u0393\u03bb\u03c5\u03ba\u03cc \u03b5\u03c0\u03b9\u03b4\u03cc\u03c1\u03c0\u03b9\u03bf \u03ba\u03c1\u03b1\u03c3\u03af'},
        {'textEn': 'A historical monument', 'textRu': '\u0418\u0441\u0442\u043e\u0440\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u043f\u0430\u043c\u044f\u0442\u043d\u0438\u043a', 'textEl': '\u0399\u03c3\u03c4\u03bf\u03c1\u03b9\u03ba\u03cc \u03bc\u03bd\u03b7\u03bc\u03b5\u03af\u03bf'},
      ],
      'correctIndex': 2,
      'category': 'culture',
      'difficulty': 'easy',
      'explanation': {'en': 'Commandaria is the oldest named wine in the world, a sweet dessert wine produced in Cyprus since 800 BC.', 'ru': '\u041a\u043e\u043c\u043c\u0430\u043d\u0434\u0430\u0440\u0438\u044f \u2014 \u0441\u0442\u0430\u0440\u0435\u0439\u0448\u0435\u0435 \u0438\u043c\u0435\u043d\u043e\u0432\u0430\u043d\u043d\u043e\u0435 \u0432\u0438\u043d\u043e \u0432 \u043c\u0438\u0440\u0435.', 'el': '\u0397 \u039a\u03bf\u03bc\u03bc\u03b1\u03bd\u03c4\u03b1\u03c1\u03af\u03b1 \u03b5\u03af\u03bd\u03b1\u03b9 \u03c4\u03bf \u03b1\u03c1\u03c7\u03b1\u03b9\u03cc\u03c4\u03b5\u03c1\u03bf \u03ba\u03b1\u03c4\u03bf\u03bd\u03bf\u03bc\u03b1\u03b6\u03cc\u03bc\u03b5\u03bd\u03bf \u03ba\u03c1\u03b1\u03c3\u03af.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What is halloumi?',
      'textRu': '\u0427\u0442\u043e \u0442\u0430\u043a\u043e\u0435 \u0445\u0430\u043b\u043b\u0443\u043c\u0438?',
      'textEl': '\u03a4\u03b9 \u03b5\u03af\u03bd\u03b1\u03b9 \u03c4\u03bf \u03c7\u03b1\u03bb\u03bf\u03cd\u03bc\u03b9;',
      'options': [
        {'textEn': 'A traditional cheese', 'textRu': '\u0422\u0440\u0430\u0434\u0438\u0446\u0438\u043e\u043d\u043d\u044b\u0439 \u0441\u044b\u0440', 'textEl': '\u03a0\u03b1\u03c1\u03b1\u03b4\u03bf\u03c3\u03b9\u03b1\u03ba\u03cc \u03c4\u03c5\u03c1\u03af'},
        {'textEn': 'A dessert pastry', 'textRu': '\u0414\u0435\u0441\u0435\u0440\u0442\u043d\u0430\u044f \u0432\u044b\u043f\u0435\u0447\u043a\u0430', 'textEl': '\u0393\u03bb\u03c5\u03ba\u03cc \u03b6\u03b1\u03c7\u03b1\u03c1\u03bf\u03c0\u03bb\u03b1\u03c3\u03c4\u03b9\u03ba\u03ae\u03c2'},
        {'textEn': 'A meat dish', 'textRu': '\u041c\u044f\u0441\u043d\u043e\u0435 \u0431\u043b\u044e\u0434\u043e', 'textEl': '\u039a\u03c1\u03b5\u03b1\u03c4\u03b9\u03ba\u03cc \u03c0\u03b9\u03ac\u03c4\u03bf'},
        {'textEn': 'A bread', 'textRu': '\u0425\u043b\u0435\u0431', 'textEl': '\u03a8\u03c9\u03bc\u03af'},
      ],
      'correctIndex': 0,
      'category': 'culture',
      'difficulty': 'easy',
      'explanation': {'en': 'Halloumi is a traditional Cypriot cheese made from a mixture of goat and sheep milk, with a high melting point ideal for grilling.', 'ru': '\u0425\u0430\u043b\u043b\u0443\u043c\u0438 \u2014 \u0442\u0440\u0430\u0434\u0438\u0446\u0438\u043e\u043d\u043d\u044b\u0439 \u043a\u0438\u043f\u0440\u0441\u043a\u0438\u0439 \u0441\u044b\u0440.', 'el': '\u03a4\u03bf \u03c7\u03b1\u03bb\u03bf\u03cd\u03bc\u03b9 \u03b5\u03af\u03bd\u03b1\u03b9 \u03c0\u03b1\u03c1\u03b1\u03b4\u03bf\u03c3\u03b9\u03b1\u03ba\u03cc \u03ba\u03c5\u03c0\u03c1\u03b9\u03b1\u03ba\u03cc \u03c4\u03c5\u03c1\u03af.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'Which festival celebrates the Great Flood and is unique to Cyprus?',
      'textRu': '\u041a\u0430\u043a\u043e\u0439 \u043f\u0440\u0430\u0437\u0434\u043d\u0438\u043a \u043e\u0442\u043c\u0435\u0447\u0430\u0435\u0442 \u0412\u0435\u043b\u0438\u043a\u0438\u0439 \u043f\u043e\u0442\u043e\u043f \u0438 \u0443\u043d\u0438\u043a\u0430\u043b\u0435\u043d \u0434\u043b\u044f \u041a\u0438\u043f\u0440\u0430?',
      'textEl': '\u03a0\u03bf\u03b9\u03b1 \u03b3\u03b9\u03bf\u03c1\u03c4\u03ae \u03c4\u03b9\u03bc\u03ac \u03c4\u03bf\u03bd \u039a\u03b1\u03c4\u03b1\u03ba\u03bb\u03c5\u03c3\u03bc\u03cc;',
      'options': [
        {'textEn': 'Carnival', 'textRu': '\u041a\u0430\u0440\u043d\u0430\u0432\u0430\u043b', 'textEl': '\u039a\u03b1\u03c1\u03bd\u03b1\u03b2\u03ac\u03bb\u03b9'},
        {'textEn': 'Kataklysmos', 'textRu': '\u041a\u0430\u0442\u0430\u043a\u043b\u0438\u0437\u043c\u043e\u0441', 'textEl': '\u039a\u03b1\u03c4\u03b1\u03ba\u03bb\u03c5\u03c3\u03bc\u03cc\u03c2'},
        {'textEn': 'Anthestiria', 'textRu': '\u0410\u043d\u0444\u0435\u0441\u0442\u0438\u0440\u0438\u044f', 'textEl': '\u0391\u03bd\u03b8\u03b5\u03c3\u03c4\u03ae\u03c1\u03b9\u03b1'},
        {'textEn': 'Limassol Wine Festival', 'textRu': '\u0424\u0435\u0441\u0442\u0438\u0432\u0430\u043b\u044c \u0432\u0438\u043d\u0430 \u0432 \u041b\u0438\u043c\u0430\u0441\u043e\u043b\u0435', 'textEl': '\u0393\u03b9\u03bf\u03c1\u03c4\u03ae \u039a\u03c1\u03b1\u03c3\u03b9\u03bf\u03cd \u039b\u03b5\u03bc\u03b5\u03c3\u03bf\u03cd'},
      ],
      'correctIndex': 1,
      'category': 'culture',
      'difficulty': 'medium',
      'explanation': {'en': 'Kataklysmos (Festival of the Flood) is a uniquely Cypriot celebration held 50 days after Easter.', 'ru': '\u041a\u0430\u0442\u0430\u043a\u043b\u0438\u0437\u043c\u043e\u0441 \u2014 \u0443\u043d\u0438\u043a\u0430\u043b\u044c\u043d\u044b\u0439 \u043a\u0438\u043f\u0440\u0441\u043a\u0438\u0439 \u043f\u0440\u0430\u0437\u0434\u043d\u0438\u043a.', 'el': '\u039f \u039a\u03b1\u03c4\u03b1\u03ba\u03bb\u03c5\u03c3\u03bc\u03cc\u03c2 \u03b5\u03af\u03bd\u03b1\u03b9 \u03bc\u03bf\u03bd\u03b1\u03b4\u03b9\u03ba\u03ae \u03ba\u03c5\u03c0\u03c1\u03b9\u03b1\u03ba\u03ae \u03b3\u03b9\u03bf\u03c1\u03c4\u03ae.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'Which ancient city in Cyprus is a UNESCO World Heritage Site famous for mosaics?',
      'textRu': '\u041a\u0430\u043a\u043e\u0439 \u0434\u0440\u0435\u0432\u043d\u0438\u0439 \u0433\u043e\u0440\u043e\u0434 \u041a\u0438\u043f\u0440\u0430 \u0437\u043d\u0430\u043c\u0435\u043d\u0438\u0442 \u043c\u043e\u0437\u0430\u0438\u043a\u0430\u043c\u0438?',
      'textEl': '\u03a0\u03bf\u03b9\u03b1 \u03b1\u03c1\u03c7\u03b1\u03af\u03b1 \u03c0\u03cc\u03bb\u03b7 \u03b5\u03af\u03bd\u03b1\u03b9 \u03b3\u03bd\u03c9\u03c3\u03c4\u03ae \u03b3\u03b9\u03b1 \u03c8\u03b7\u03c6\u03b9\u03b4\u03c9\u03c4\u03ac;',
      'options': [
        {'textEn': 'Kourion', 'textRu': '\u041a\u0443\u0440\u0438\u043e\u043d', 'textEl': '\u039a\u03bf\u03cd\u03c1\u03b9\u03bf\u03bd'},
        {'textEn': 'Paphos', 'textRu': '\u041f\u0430\u0444\u043e\u0441', 'textEl': '\u03a0\u03ac\u03c6\u03bf\u03c2'},
        {'textEn': 'Salamis', 'textRu': '\u0421\u0430\u043b\u0430\u043c\u0438\u0441', 'textEl': '\u03a3\u03b1\u03bb\u03b1\u03bc\u03af\u03c2'},
        {'textEn': 'Amathus', 'textRu': '\u0410\u043c\u0430\u0442\u0443\u0441', 'textEl': '\u0391\u03bc\u03b1\u03b8\u03bf\u03cd\u03c2'},
      ],
      'correctIndex': 1,
      'category': 'culture',
      'difficulty': 'medium',
      'explanation': {'en': 'Paphos is a UNESCO World Heritage Site famous for its Roman mosaics in the House of Dionysus.', 'ru': '\u041f\u0430\u0444\u043e\u0441 \u2014 \u043e\u0431\u044a\u0435\u043a\u0442 \u042e\u041d\u0415\u0421\u041a\u041e, \u0437\u043d\u0430\u043c\u0435\u043d\u0438\u0442 \u0440\u0438\u043c\u0441\u043a\u0438\u043c\u0438 \u043c\u043e\u0437\u0430\u0438\u043a\u0430\u043c\u0438.', 'el': '\u0397 \u03a0\u03ac\u03c6\u03bf\u03c2 \u03b5\u03af\u03bd\u03b1\u03b9 \u03bc\u03bd\u03b7\u03bc\u03b5\u03af\u03bf UNESCO \u03b3\u03bd\u03c9\u03c3\u03c4\u03cc \u03b3\u03b9\u03b1 \u03c1\u03c9\u03bc\u03b1\u03ca\u03ba\u03ac \u03c8\u03b7\u03c6\u03b9\u03b4\u03c9\u03c4\u03ac.'},
      'source': 'visitcyprus.com',
    },
    // ── Daily Life Questions (12) ──
    {
      'textEn': 'What is the emergency telephone number in Cyprus?',
      'textRu': '\u041a\u0430\u043a\u043e\u0439 \u043d\u043e\u043c\u0435\u0440 \u044d\u043a\u0441\u0442\u0440\u0435\u043d\u043d\u043e\u0439 \u043f\u043e\u043c\u043e\u0449\u0438 \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u03a0\u03bf\u03b9\u03bf\u03c2 \u03b5\u03af\u03bd\u03b1\u03b9 \u03bf \u03b1\u03c1\u03b9\u03b8\u03bc\u03cc\u03c2 \u03ad\u03ba\u03c4\u03b1\u03ba\u03c4\u03b7\u03c2 \u03b1\u03bd\u03ac\u03b3\u03ba\u03b7\u03c2;',
      'options': [
        {'textEn': '911', 'textRu': '911', 'textEl': '911'},
        {'textEn': '999', 'textRu': '999', 'textEl': '999'},
        {'textEn': '112', 'textRu': '112', 'textEl': '112'},
        {'textEn': '100', 'textRu': '100', 'textEl': '100'},
      ],
      'correctIndex': 2,
      'category': 'daily_life',
      'difficulty': 'easy',
      'explanation': {'en': '112 is the European emergency number, also used in Cyprus. The local police number is 199.', 'ru': '112 \u2014 \u0435\u0432\u0440\u043e\u043f\u0435\u0439\u0441\u043a\u0438\u0439 \u043d\u043e\u043c\u0435\u0440 \u044d\u043a\u0441\u0442\u0440\u0435\u043d\u043d\u043e\u0439 \u043f\u043e\u043c\u043e\u0449\u0438.', 'el': '\u03a4\u03bf 112 \u03b5\u03af\u03bd\u03b1\u03b9 \u03bf \u03b5\u03c5\u03c1\u03c9\u03c0\u03b1\u03ca\u03ba\u03cc\u03c2 \u03b1\u03c1\u03b9\u03b8\u03bc\u03cc\u03c2 \u03ad\u03ba\u03c4\u03b1\u03ba\u03c4\u03b7\u03c2 \u03b1\u03bd\u03ac\u03b3\u03ba\u03b7\u03c2.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What is the standard VAT rate in Cyprus?',
      'textRu': '\u041a\u0430\u043a\u0430\u044f \u0441\u0442\u0430\u043d\u0434\u0430\u0440\u0442\u043d\u0430\u044f \u0441\u0442\u0430\u0432\u043a\u0430 \u041d\u0414\u0421 \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u03a0\u03bf\u03b9\u03bf\u03c2 \u03b5\u03af\u03bd\u03b1\u03b9 \u03bf \u03ba\u03b1\u03bd\u03bf\u03bd\u03b9\u03ba\u03cc\u03c2 \u03c3\u03c5\u03bd\u03c4\u03b5\u03bb\u03b5\u03c3\u03c4\u03ae\u03c2 \u03a6\u03a0\u0391;',
      'options': [
        {'textEn': '15%', 'textRu': '15%', 'textEl': '15%'},
        {'textEn': '19%', 'textRu': '19%', 'textEl': '19%'},
        {'textEn': '21%', 'textRu': '21%', 'textEl': '21%'},
        {'textEn': '23%', 'textRu': '23%', 'textEl': '23%'},
      ],
      'correctIndex': 1,
      'category': 'daily_life',
      'difficulty': 'medium',
      'explanation': {'en': 'The standard VAT rate in Cyprus is 19%.', 'ru': '\u0421\u0442\u0430\u043d\u0434\u0430\u0440\u0442\u043d\u0430\u044f \u0441\u0442\u0430\u0432\u043a\u0430 \u041d\u0414\u0421 \u043d\u0430 \u041a\u0438\u043f\u0440\u0435 \u2014 19%.', 'el': '\u039f \u03ba\u03b1\u03bd\u03bf\u03bd\u03b9\u03ba\u03cc\u03c2 \u03a6\u03a0\u0391 \u03c3\u03c4\u03b7\u03bd \u039a\u03cd\u03c0\u03c1\u03bf \u03b5\u03af\u03bd\u03b1\u03b9 19%.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'On which side of the road do people drive in Cyprus?',
      'textRu': '\u041f\u043e \u043a\u0430\u043a\u043e\u0439 \u0441\u0442\u043e\u0440\u043e\u043d\u0435 \u0434\u043e\u0440\u043e\u0433\u0438 \u0435\u0437\u0434\u044f\u0442 \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u0391\u03c0\u03cc \u03c0\u03bf\u03b9\u03b1 \u03c0\u03bb\u03b5\u03c5\u03c1\u03ac \u03bf\u03b4\u03b7\u03b3\u03bf\u03cd\u03bd \u03c3\u03c4\u03b7\u03bd \u039a\u03cd\u03c0\u03c1\u03bf;',
      'options': [
        {'textEn': 'Right', 'textRu': '\u041f\u0440\u0430\u0432\u0430\u044f', 'textEl': '\u0394\u03b5\u03be\u03b9\u03ac'},
        {'textEn': 'Left', 'textRu': '\u041b\u0435\u0432\u0430\u044f', 'textEl': '\u0391\u03c1\u03b9\u03c3\u03c4\u03b5\u03c1\u03ac'},
        {'textEn': 'It varies by district', 'textRu': '\u0417\u0430\u0432\u0438\u0441\u0438\u0442 \u043e\u0442 \u043e\u043a\u0440\u0443\u0433\u0430', 'textEl': '\u0395\u03be\u03b1\u03c1\u03c4\u03ac\u03c4\u03b1\u03b9 \u03b1\u03c0\u03cc \u03c4\u03b7\u03bd \u03b5\u03c0\u03b1\u03c1\u03c7\u03af\u03b1'},
        {'textEn': 'Center', 'textRu': '\u041f\u043e \u0446\u0435\u043d\u0442\u0440\u0443', 'textEl': '\u039a\u03ad\u03bd\u03c4\u03c1\u03bf'},
      ],
      'correctIndex': 1,
      'category': 'daily_life',
      'difficulty': 'easy',
      'explanation': {'en': 'Cyprus drives on the left side of the road, a legacy of British colonial rule.', 'ru': '\u041d\u0430 \u041a\u0438\u043f\u0440\u0435 \u0435\u0437\u0434\u044f\u0442 \u043f\u043e \u043b\u0435\u0432\u043e\u0439 \u0441\u0442\u043e\u0440\u043e\u043d\u0435 \u0434\u043e\u0440\u043e\u0433\u0438.', 'el': '\u03a3\u03c4\u03b7\u03bd \u039a\u03cd\u03c0\u03c1\u03bf \u03bf\u03b4\u03b7\u03b3\u03bf\u03cd\u03bd \u03b1\u03c0\u03cc \u03c4\u03b7\u03bd \u03b1\u03c1\u03b9\u03c3\u03c4\u03b5\u03c1\u03ae \u03c0\u03bb\u03b5\u03c5\u03c1\u03ac.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What is the national healthcare system in Cyprus called?',
      'textRu': '\u041a\u0430\u043a \u043d\u0430\u0437\u044b\u0432\u0430\u0435\u0442\u0441\u044f \u043d\u0430\u0446\u0438\u043e\u043d\u0430\u043b\u044c\u043d\u0430\u044f \u0441\u0438\u0441\u0442\u0435\u043c\u0430 \u0437\u0434\u0440\u0430\u0432\u043e\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u0438\u044f \u041a\u0438\u043f\u0440\u0430?',
      'textEl': '\u03a0\u03ce\u03c2 \u03bf\u03bd\u03bf\u03bc\u03ac\u03b6\u03b5\u03c4\u03b1\u03b9 \u03c4\u03bf \u03b5\u03b8\u03bd\u03b9\u03ba\u03cc \u03c3\u03cd\u03c3\u03c4\u03b7\u03bc\u03b1 \u03c5\u03b3\u03b5\u03af\u03b1\u03c2;',
      'options': [
        {'textEn': 'NHS', 'textRu': 'NHS', 'textEl': 'NHS'},
        {'textEn': 'GESY (GHS)', 'textRu': '\u0413\u0415\u0421\u0418 (GHS)', 'textEl': '\u0393\u0395\u03a3\u03a5'},
        {'textEn': 'SUS', 'textRu': 'SUS', 'textEl': 'SUS'},
        {'textEn': 'Medicare', 'textRu': 'Medicare', 'textEl': 'Medicare'},
      ],
      'correctIndex': 1,
      'category': 'daily_life',
      'difficulty': 'medium',
      'explanation': {'en': 'GESY (General Healthcare System) was introduced in 2019, providing universal healthcare.', 'ru': '\u0413\u0415\u0421\u0418 (\u041e\u0431\u0449\u0430\u044f \u0441\u0438\u0441\u0442\u0435\u043c\u0430 \u0437\u0434\u0440\u0430\u0432\u043e\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u0438\u044f) \u0432\u0432\u0435\u0434\u0435\u043d\u0430 \u0432 2019 \u0433\u043e\u0434\u0443.', 'el': '\u03a4\u03bf \u0393\u0395\u03a3\u03a5 \u03b5\u03b9\u03c3\u03ae\u03c7\u03b8\u03b7 \u03c4\u03bf 2019.'},
      'source': 'visitcyprus.com',
    },
    {
      'textEn': 'What currency is used in Cyprus?',
      'textRu': '\u041a\u0430\u043a\u0430\u044f \u0432\u0430\u043b\u044e\u0442\u0430 \u0438\u0441\u043f\u043e\u043b\u044c\u0437\u0443\u0435\u0442\u0441\u044f \u043d\u0430 \u041a\u0438\u043f\u0440\u0435?',
      'textEl': '\u03a0\u03bf\u03b9\u03bf \u03bd\u03cc\u03bc\u03b9\u03c3\u03bc\u03b1 \u03c7\u03c1\u03b7\u03c3\u03b9\u03bc\u03bf\u03c0\u03bf\u03b9\u03b5\u03af\u03c4\u03b1\u03b9 \u03c3\u03c4\u03b7\u03bd \u039a\u03cd\u03c0\u03c1\u03bf;',
      'options': [
        {'textEn': 'Cyprus Pound', 'textRu': '\u041a\u0438\u043f\u0440\u0441\u043a\u0438\u0439 \u0444\u0443\u043d\u0442', 'textEl': '\u039a\u03c5\u03c0\u03c1\u03b9\u03b1\u03ba\u03ae \u039b\u03af\u03c1\u03b1'},
        {'textEn': 'Euro', 'textRu': '\u0415\u0432\u0440\u043e', 'textEl': '\u0395\u03c5\u03c1\u03ce'},
        {'textEn': 'US Dollar', 'textRu': '\u0414\u043e\u043b\u043b\u0430\u0440 \u0421\u0428\u0410', 'textEl': '\u0394\u03bf\u03bb\u03ac\u03c1\u03b9\u03bf \u0397\u03a0\u0391'},
        {'textEn': 'British Pound', 'textRu': '\u0411\u0440\u0438\u0442\u0430\u043d\u0441\u043a\u0438\u0439 \u0444\u0443\u043d\u0442', 'textEl': '\u0392\u03c1\u03b5\u03c4\u03b1\u03bd\u03b9\u03ba\u03ae \u039b\u03af\u03c1\u03b1'},
      ],
      'correctIndex': 1,
      'category': 'daily_life',
      'difficulty': 'easy',
      'explanation': {'en': 'Cyprus uses the Euro since 1 January 2008.', 'ru': '\u041a\u0438\u043f\u0440 \u0438\u0441\u043f\u043e\u043b\u044c\u0437\u0443\u0435\u0442 \u0435\u0432\u0440\u043e \u0441 1 \u044f\u043d\u0432\u0430\u0440\u044f 2008 \u0433\u043e\u0434\u0430.', 'el': '\u0397 \u039a\u03cd\u03c0\u03c1\u03bf\u03c2 \u03c7\u03c1\u03b7\u03c3\u03b9\u03bc\u03bf\u03c0\u03bf\u03b9\u03b5\u03af \u03c4\u03bf \u03b5\u03c5\u03c1\u03ce \u03b1\u03c0\u03cc \u03c4\u03bf 2008.'},
      'source': 'visitcyprus.com',
    },
  ];

  // ── Exam Dates ──
  static final List<Map<String, dynamic>> examDates = [
    {
      'date': Timestamp.fromDate(DateTime(2026, 7, 4)),
      'registrationOpen': Timestamp.fromDate(DateTime(2026, 5, 18)),
      'registrationClose': Timestamp.fromDate(DateTime(2026, 6, 1)),
      'centers': [
        {
          'name': 'Nicosia Exam Center',
          'address': 'Achaion & Arsinois, Nicosia',
          'lat': 35.1856,
          'lng': 33.3823,
          'district': 'Nicosia',
        },
        {
          'name': 'Limassol Exam Center',
          'address': 'Limassol Grammar School, Limassol',
          'lat': 34.6786,
          'lng': 33.0413,
          'district': 'Limassol',
        },
        {
          'name': 'Larnaca Exam Center',
          'address': 'Larnaca Lyceum, Larnaca',
          'lat': 34.9182,
          'lng': 33.6232,
          'district': 'Larnaca',
        },
        {
          'name': 'Paphos Exam Center',
          'address': 'Paphos Lyceum, Paphos',
          'lat': 34.7720,
          'lng': 32.4297,
          'district': 'Paphos',
        },
      ],
      'year': 2026,
      'session': 'july',
    },
    {
      'date': Timestamp.fromDate(DateTime(2027, 2, 6)),
      'registrationOpen': Timestamp.fromDate(DateTime(2026, 12, 14)),
      'registrationClose': Timestamp.fromDate(DateTime(2027, 1, 4)),
      'centers': [
        {
          'name': 'Nicosia Exam Center',
          'address': 'Achaion & Arsinois, Nicosia',
          'lat': 35.1856,
          'lng': 33.3823,
          'district': 'Nicosia',
        },
        {
          'name': 'Limassol Exam Center',
          'address': 'Limassol Grammar School, Limassol',
          'lat': 34.6786,
          'lng': 33.0413,
          'district': 'Limassol',
        },
      ],
      'year': 2027,
      'session': 'february',
    },
  ];

  // ── Keep Learning Courses ──
  static final List<Map<String, dynamic>> courses = [
    {
      'titleEn': 'Cyprus Culture & Politics Intensive',
      'titleRu': '\u0418\u043d\u0442\u0435\u043d\u0441\u0438\u0432 \u043f\u043e \u043a\u0443\u043b\u044c\u0442\u0443\u0440\u0435 \u0438 \u043f\u043e\u043b\u0438\u0442\u0438\u043a\u0435 \u041a\u0438\u043f\u0440\u0430',
      'titleEl': '\u0395\u03bd\u03c4\u03b1\u03c4\u03b9\u03ba\u03cc \u03a0\u03bf\u03bb\u03b9\u03c4\u03b9\u03c3\u03bc\u03bf\u03cd & \u03a0\u03bf\u03bb\u03b9\u03c4\u03b9\u03ba\u03ae\u03c2 \u039a\u03cd\u03c0\u03c1\u03bf\u03c5',
      'description': {
        'en': '4-week intensive course covering all exam topics with practice tests and Q&A sessions.',
        'ru': '4-\u043d\u0435\u0434\u0435\u043b\u044c\u043d\u044b\u0439 \u0438\u043d\u0442\u0435\u043d\u0441\u0438\u0432\u043d\u044b\u0439 \u043a\u0443\u0440\u0441 \u043f\u043e \u0432\u0441\u0435\u043c \u0442\u0435\u043c\u0430\u043c \u044d\u043a\u0437\u0430\u043c\u0435\u043d\u0430.',
        'el': '4 \u03b5\u03b2\u03b4\u03bf\u03bc\u03ac\u03b4\u03b5\u03c2 \u03b5\u03bd\u03c4\u03b1\u03c4\u03b9\u03ba\u03bf\u03cd \u03bc\u03b1\u03b8\u03ae\u03bc\u03b1\u03c4\u03bf\u03c2.',
      },
      'bookingUrl': 'https://keeplearning.cy/culture-course',
      'price': 150,
      'type': 'online',
    },
    {
      'titleEn': 'Greek Language B1 Preparation',
      'titleRu': '\u041f\u043e\u0434\u0433\u043e\u0442\u043e\u0432\u043a\u0430 \u043a \u0433\u0440\u0435\u0447\u0435\u0441\u043a\u043e\u043c\u0443 B1',
      'titleEl': '\u03a0\u03c1\u03bf\u03b5\u03c4\u03bf\u03b9\u03bc\u03b1\u03c3\u03af\u03b1 \u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ce\u03bd B1',
      'description': {
        'en': '8-week Greek language course to reach B1 level. Includes speaking, listening, and exam practice.',
        'ru': '8-\u043d\u0435\u0434\u0435\u043b\u044c\u043d\u044b\u0439 \u043a\u0443\u0440\u0441 \u0433\u0440\u0435\u0447\u0435\u0441\u043a\u043e\u0433\u043e \u044f\u0437\u044b\u043a\u0430 \u0434\u043e \u0443\u0440\u043e\u0432\u043d\u044f B1.',
        'el': '8 \u03b5\u03b2\u03b4\u03bf\u03bc\u03ac\u03b4\u03b5\u03c2 \u03bc\u03b1\u03b8\u03b7\u03bc\u03ac\u03c4\u03c9\u03bd \u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ce\u03bd \u03b3\u03b9\u03b1 \u03b5\u03c0\u03af\u03c0\u03b5\u03b4\u03bf B1.',
      },
      'bookingUrl': 'https://keeplearning.cy/greek-b1',
      'price': 250,
      'type': 'in-person',
    },
    {
      'titleEn': 'Exam Crash Course (Weekend)',
      'titleRu': '\u042d\u043a\u0441\u043f\u0440\u0435\u0441\u0441-\u043a\u0443\u0440\u0441 (\u0432\u044b\u0445\u043e\u0434\u043d\u044b\u0435)',
      'titleEl': '\u0395\u03bd\u03c4\u03b1\u03c4\u03b9\u03ba\u03cc \u03a3\u03b1\u03b2\u03b2\u03b1\u03c4\u03bf\u03ba\u03cd\u03c1\u03b9\u03b1\u03ba\u03bf',
      'description': {
        'en': '2-day weekend crash course with mock exams and key topic review. Perfect for last-minute preparation.',
        'ru': '2-\u0434\u043d\u0435\u0432\u043d\u044b\u0439 \u044d\u043a\u0441\u043f\u0440\u0435\u0441\u0441-\u043a\u0443\u0440\u0441 \u0441 \u043f\u0440\u043e\u0431\u043d\u044b\u043c\u0438 \u044d\u043a\u0437\u0430\u043c\u0435\u043d\u0430\u043c\u0438.',
        'el': '2\u03ae\u03bc\u03b5\u03c1\u03bf \u03b5\u03bd\u03c4\u03b1\u03c4\u03b9\u03ba\u03cc \u03bc\u03b5 \u03c0\u03c1\u03bf\u03c3\u03bf\u03bc\u03bf\u03b9\u03ce\u03c3\u03b5\u03b9\u03c2 \u03b5\u03be\u03b5\u03c4\u03ac\u03c3\u03b5\u03c9\u03bd.',
      },
      'bookingUrl': 'https://keeplearning.cy/crash-course',
      'price': 80,
      'type': 'in-person',
    },
  ];
}
