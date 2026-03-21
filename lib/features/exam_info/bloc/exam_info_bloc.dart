import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/exam_date_model.dart';
import '../../../core/services/firestore_service.dart';
import 'exam_info_event.dart';
import 'exam_info_state.dart';

class ExamInfoBloc extends Bloc<ExamInfoEvent, ExamInfoState> {
  final FirestoreService _firestoreService;

  ExamInfoBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(const ExamInfoInitial()) {
    on<LoadExamDates>(_onLoadExamDates);
  }

  Future<void> _onLoadExamDates(
    LoadExamDates event,
    Emitter<ExamInfoState> emit,
  ) async {
    emit(const ExamInfoLoading());

    try {
      final snapshot = await _firestoreService.getExamDates();
      final examDates = snapshot.docs
          .map((doc) => ExamDateModel.fromFirestore(doc))
          .toList();

      emit(ExamInfoLoaded(examDates: examDates));
    } catch (e) {
      emit(ExamInfoError(e.toString()));
    }
  }
}
