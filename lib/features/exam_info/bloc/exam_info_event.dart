import 'package:equatable/equatable.dart';

abstract class ExamInfoEvent extends Equatable {
  const ExamInfoEvent();

  @override
  List<Object?> get props => [];
}

class LoadExamDates extends ExamInfoEvent {
  const LoadExamDates();
}
