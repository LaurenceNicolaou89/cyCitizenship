import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import 'heatmap_event.dart';
import 'heatmap_state.dart';

class HeatmapBloc extends Bloc<HeatmapEvent, HeatmapState> {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  HeatmapBloc({
    required FirestoreService firestoreService,
    required AuthService authService,
  })  : _firestoreService = firestoreService,
        _authService = authService,
        super(const HeatmapInitial()) {
    on<LoadHeatmapData>(_onLoadHeatmapData);
  }

  Future<void> _onLoadHeatmapData(
    LoadHeatmapData event,
    Emitter<HeatmapState> emit,
  ) async {
    emit(const HeatmapLoading());

    try {
      final user = _authService.currentUser;
      if (user == null) {
        emit(const HeatmapError('You must be signed in to view stats.'));
        return;
      }

      final snapshot = await _firestoreService.getCategoryStats(user.uid);
      final stats = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final totalAnswered = (data['totalAnswered'] as num?)?.toInt() ?? 0;
        final totalCorrect = (data['totalCorrect'] as num?)?.toInt() ?? 0;
        final scorePercent = totalAnswered > 0
            ? (totalCorrect / totalAnswered * 100).round()
            : 0;

        return CategoryStat(
          category: doc.id,
          totalAnswered: totalAnswered,
          totalCorrect: totalCorrect,
          scorePercent: scorePercent,
        );
      }).toList();

      emit(HeatmapLoaded(categoryStats: stats));
    } catch (e) {
      emit(HeatmapError(e.toString()));
    }
  }
}
