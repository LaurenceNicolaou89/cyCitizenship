import 'package:equatable/equatable.dart';

import '../../../core/models/exam_date_model.dart';

abstract class ExamInfoState extends Equatable {
  const ExamInfoState();

  @override
  List<Object?> get props => [];
}

class ExamInfoInitial extends ExamInfoState {
  const ExamInfoInitial();
}

class ExamInfoLoading extends ExamInfoState {
  const ExamInfoLoading();
}

class ExamInfoLoaded extends ExamInfoState {
  final List<ExamDateModel> examDates;

  const ExamInfoLoaded({required this.examDates});

  @override
  List<Object?> get props => [examDates];
}

class ExamInfoError extends ExamInfoState {
  final String message;

  const ExamInfoError(this.message);

  @override
  List<Object?> get props => [message];
}
