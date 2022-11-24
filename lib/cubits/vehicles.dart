import 'package:flutter_request_bloc/flutter_request_bloc.dart';

import '../models/index.dart';
import '../repositories/index.dart';

/// Cubit that holds a list of SpaceX vehicles.
class VehiclesCubit extends RequestCubit<VehiclesRepository, List<Vehicle>> {
  VehiclesCubit(VehiclesRepository repository) : super(repository);

  @override
  Future<void> loadData() async {
    emit(RequestState.loading(state.value));

    try {
      repository
          .fetchData()
          .then((value) {
            print(value);
            emit(RequestState.loaded(value));
          })
          .catchError((e) => emit(RequestState.error(e.toString())))
          .timeout(Duration(seconds: 5));
    } catch (e) {
      emit(RequestState.error(e.toString()));
    }
  }

  Vehicle getVehicle(String id) {
    if (state.status == RequestStatus.loaded) {
      return state.value.where((l) => l.id == id).single;
    } else {
      return null;
    }
  }
}
