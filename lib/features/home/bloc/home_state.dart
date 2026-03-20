import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final int streak;
  final double averageScore;
  final DateTime? nextExamDate;
  final int daysUntilExam;
  final int questionsAnsweredToday;
  final bool isPremium;

  const HomeLoaded({
    required this.streak,
    required this.averageScore,
    this.nextExamDate,
    required this.daysUntilExam,
    required this.questionsAnsweredToday,
    required this.isPremium,
  });

  @override
  List<Object?> get props => [
        streak,
        averageScore,
        nextExamDate,
        daysUntilExam,
        questionsAnsweredToday,
        isPremium,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
