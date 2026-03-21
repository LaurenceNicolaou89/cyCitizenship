import 'package:equatable/equatable.dart';

class CategoryStat extends Equatable {
  final String category;
  final int totalAnswered;
  final int totalCorrect;
  final int scorePercent;

  const CategoryStat({
    required this.category,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.scorePercent,
  });

  @override
  List<Object?> get props => [category, totalAnswered, totalCorrect, scorePercent];
}

abstract class HeatmapState extends Equatable {
  const HeatmapState();

  @override
  List<Object?> get props => [];
}

class HeatmapInitial extends HeatmapState {
  const HeatmapInitial();
}

class HeatmapLoading extends HeatmapState {
  const HeatmapLoading();
}

class HeatmapLoaded extends HeatmapState {
  final List<CategoryStat> categoryStats;

  const HeatmapLoaded({required this.categoryStats});

  @override
  List<Object?> get props => [categoryStats];
}

class HeatmapError extends HeatmapState {
  final String message;

  const HeatmapError(this.message);

  @override
  List<Object?> get props => [message];
}
