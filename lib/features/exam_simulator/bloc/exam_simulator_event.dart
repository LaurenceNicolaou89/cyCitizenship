import 'package:equatable/equatable.dart';

abstract class ExamSimulatorEvent extends Equatable {
  const ExamSimulatorEvent();

  @override
  List<Object?> get props => [];
}

class StartExam extends ExamSimulatorEvent {
  const StartExam();
}

class AnswerQuestion extends ExamSimulatorEvent {
  final int selectedIndex;

  const AnswerQuestion(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}

class NextQuestion extends ExamSimulatorEvent {
  const NextQuestion();
}

class SubmitExam extends ExamSimulatorEvent {
  const SubmitExam();
}

class TimerTick extends ExamSimulatorEvent {
  const TimerTick();
}
