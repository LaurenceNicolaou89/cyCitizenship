import 'package:flutter_test/flutter_test.dart';
import 'package:cy_citizenship/core/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('newUser creates correct defaults', () {
      final user = UserModel.newUser(
        id: 'uid123',
        email: 'test@test.com',
        displayName: 'Test User',
      );

      expect(user.id, 'uid123');
      expect(user.email, 'test@test.com');
      expect(user.displayName, 'Test User');
      expect(user.language, 'en');
      expect(user.isPremium, false);
      expect(user.streak, 0);
      expect(user.badges, isEmpty);
      expect(user.examTarget, 'general');
      expect(user.checklist, isEmpty);
    });

    test('newUser accepts custom language and examTarget', () {
      final user = UserModel.newUser(
        id: 'uid123',
        email: 'test@test.com',
        language: 'ru',
        examTarget: 'fast-track',
      );

      expect(user.language, 'ru');
      expect(user.examTarget, 'fast-track');
    });

    test('copyWith updates only specified fields', () {
      final user = UserModel.newUser(
        id: 'uid123',
        email: 'test@test.com',
      );

      final updated = user.copyWith(
        isPremium: true,
        streak: 5,
        language: 'ru',
      );

      expect(updated.isPremium, true);
      expect(updated.streak, 5);
      expect(updated.language, 'ru');
      expect(updated.id, 'uid123'); // unchanged
      expect(updated.email, 'test@test.com'); // unchanged
    });

    test('copyWith preserves createdAt', () {
      final user = UserModel.newUser(
        id: 'uid123',
        email: 'test@test.com',
      );
      final createdAt = user.createdAt;

      final updated = user.copyWith(streak: 10);
      expect(updated.createdAt, createdAt);
    });

    test('copyWith updates badges', () {
      final user = UserModel.newUser(
        id: 'uid123',
        email: 'test@test.com',
      );

      final updated = user.copyWith(badges: ['first_exam', 'streak_7']);
      expect(updated.badges, ['first_exam', 'streak_7']);
    });

    test('toFirestore produces valid map', () {
      final user = UserModel.newUser(
        id: 'uid123',
        email: 'test@test.com',
        displayName: 'Test',
        examTarget: 'fast-track',
      );

      final map = user.toFirestore();
      expect(map['email'], 'test@test.com');
      expect(map['displayName'], 'Test');
      expect(map['isPremium'], false);
      expect(map['examTarget'], 'fast-track');
      expect(map['streak'], 0);
      expect(map['badges'], isEmpty);
    });

    test('equatable works on id and key fields', () {
      final user1 = UserModel.newUser(id: 'uid123', email: 'a@a.com');
      final user2 = UserModel.newUser(id: 'uid123', email: 'a@a.com');
      expect(user1, equals(user2));
    });

    test('equatable detects differences in key props', () {
      final user1 = UserModel.newUser(id: 'uid123', email: 'a@a.com');
      final user2 = UserModel.newUser(id: 'uid456', email: 'a@a.com');
      expect(user1, isNot(equals(user2)));
    });
  });
}
