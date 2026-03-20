import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHome>(_onLoadHome);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    try {
      // TODO: Replace with actual Firestore data once auth is wired
      // For now, use placeholder data for incremental development
      await Future.delayed(const Duration(milliseconds: 300));

      final nextExam = DateTime(2026, 6, 14);
      final daysUntil = nextExam.difference(DateTime.now()).inDays;

      emit(HomeLoaded(
        streak: 5,
        averageScore: 72.0,
        nextExamDate: nextExam,
        daysUntilExam: daysUntil > 0 ? daysUntil : 0,
        questionsAnsweredToday: 3,
        isPremium: false,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
