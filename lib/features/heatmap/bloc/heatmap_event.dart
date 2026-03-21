import 'package:equatable/equatable.dart';

abstract class HeatmapEvent extends Equatable {
  const HeatmapEvent();

  @override
  List<Object?> get props => [];
}

class LoadHeatmapData extends HeatmapEvent {
  const LoadHeatmapData();
}
