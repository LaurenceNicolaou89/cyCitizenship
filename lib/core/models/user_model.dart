import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String language;
  final bool isPremium;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final int streak;
  final DateTime? lastStudyDate;
  final List<String> badges;
  final String examTarget;
  final Map<String, bool> checklist;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.language = 'en',
    this.isPremium = false,
    this.purchaseDate,
    required this.createdAt,
    this.streak = 0,
    this.lastStudyDate,
    this.badges = const [],
    this.examTarget = 'general',
    this.checklist = const {},
  });

  UserModel copyWith({
    String? displayName,
    String? language,
    bool? isPremium,
    DateTime? purchaseDate,
    int? streak,
    DateTime? lastStudyDate,
    List<String>? badges,
    String? examTarget,
    Map<String, bool>? checklist,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      language: language ?? this.language,
      isPremium: isPremium ?? this.isPremium,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      badges: badges ?? this.badges,
      examTarget: examTarget ?? this.examTarget,
      checklist: checklist ?? this.checklist,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      language: data['language'] ?? 'en',
      isPremium: data['isPremium'] ?? false,
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      streak: data['streak'] ?? 0,
      lastStudyDate: (data['lastStudyDate'] as Timestamp?)?.toDate(),
      badges: List<String>.from(data['badges'] ?? []),
      examTarget: data['examTarget'] ?? 'general',
      checklist: Map<String, bool>.from(data['checklist'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'language': language,
        'isPremium': isPremium,
        'purchaseDate': purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'streak': streak,
        'lastStudyDate': lastStudyDate != null ? Timestamp.fromDate(lastStudyDate!) : null,
        'badges': badges,
        'examTarget': examTarget,
        'checklist': checklist,
      };

  factory UserModel.newUser({
    required String id,
    required String email,
    String displayName = '',
    String language = 'en',
    String examTarget = 'general',
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      language: language,
      createdAt: DateTime.now(),
      examTarget: examTarget,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        language,
        isPremium,
        purchaseDate,
        createdAt,
        streak,
        lastStudyDate,
        badges,
        examTarget,
        checklist,
      ];
}
