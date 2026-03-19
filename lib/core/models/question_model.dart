import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class QuestionOption extends Equatable {
  final String textEn;
  final String textRu;
  final String textEl;

  const QuestionOption({
    required this.textEn,
    required this.textRu,
    required this.textEl,
  });

  String getText(String locale) {
    switch (locale) {
      case 'ru':
        return textRu;
      case 'el':
        return textEl;
      default:
        return textEn;
    }
  }

  factory QuestionOption.fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      textEn: map['textEn'] ?? '',
      textRu: map['textRu'] ?? '',
      textEl: map['textEl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'textEn': textEn,
        'textRu': textRu,
        'textEl': textEl,
      };

  @override
  List<Object?> get props => [textEn, textRu, textEl];
}

class QuestionModel extends Equatable {
  final String id;
  final String textEn;
  final String textRu;
  final String textEl;
  final List<QuestionOption> options;
  final int correctIndex;
  final String category;
  final String difficulty;
  final Map<String, String> explanation;
  final String source;
  final DateTime? updatedAt;

  const QuestionModel({
    required this.id,
    required this.textEn,
    required this.textRu,
    required this.textEl,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.difficulty,
    required this.explanation,
    required this.source,
    this.updatedAt,
  });

  String getText(String locale) {
    switch (locale) {
      case 'ru':
        return textRu;
      case 'el':
        return textEl;
      default:
        return textEn;
    }
  }

  String getExplanation(String locale) {
    return explanation[locale] ?? explanation['en'] ?? '';
  }

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      textEn: data['textEn'] ?? '',
      textRu: data['textRu'] ?? '',
      textEl: data['textEl'] ?? '',
      options: (data['options'] as List<dynamic>?)
              ?.map((o) => QuestionOption.fromMap(o as Map<String, dynamic>))
              .toList() ??
          [],
      correctIndex: data['correctIndex'] ?? 0,
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      explanation: Map<String, String>.from(data['explanation'] ?? {}),
      source: data['source'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'textEn': textEn,
        'textRu': textRu,
        'textEl': textEl,
        'options': options.map((o) => o.toMap()).toList(),
        'correctIndex': correctIndex,
        'category': category,
        'difficulty': difficulty,
        'explanation': explanation,
        'source': source,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  @override
  List<Object?> get props => [id, textEn, category, difficulty];
}
