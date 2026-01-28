import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exness_clone/network/api_service.dart';
import '../model/performance_model.dart';

abstract class PerformanceState extends Equatable {
  const PerformanceState();
  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {}

class PerformanceLoading extends PerformanceState {}

class PerformanceLoaded extends PerformanceState {
  final List<Datum> data;

  const PerformanceLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class PerformanceError extends PerformanceState {
  final String message;
  const PerformanceError(this.message);
  @override
  List<Object?> get props => [message];
}

class PerformanceCubit extends Cubit<PerformanceState> {
  PerformanceCubit() : super(PerformanceInitial());

  Future<void> fetchPerformanceData() async {
    try {
      emit(PerformanceLoading());

      final response = await ApiService.getDashboard();

      if (response.success && response.data != null) {
        final performanceModel = PerformanceModel.fromJson(response.data!);

        emit(PerformanceLoaded(performanceModel.data));
      } else {
        emit(PerformanceError(
            response.message ?? "Failed to load dashboard data"));
      }
    } catch (e) {
      emit(PerformanceError(e.toString()));
    }
  }
}
