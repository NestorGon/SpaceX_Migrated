import 'package:flutter_request_bloc/flutter_request_bloc.dart';

import '../models/index.dart';
import '../repositories/index.dart';
import '../utils/index.dart';

/// Cubit that holds a list of launches.
class LaunchesCubit
    extends RequestCubit<LaunchesRepository, List<List<Launch>>> {
  LaunchesCubit(LaunchesRepository repository) : super(repository);

  @override
  Future<void> loadData() async {
    emit(RequestState.loading(state.value));

    try {
      repository
          .fetchData()
          .then((value) => emit(RequestState.loaded(value)))
          .catchError((e) => emit(RequestState.error(e.toString())))
          .timeout(Duration(seconds: 5));
    } catch (e) {
      emit(RequestState.error(e.toString()));
    }
  }

  Launch getLaunch(String id) {
    if (state.status == RequestStatus.loaded) {
      return LaunchUtils.getAllLaunches(state.value)
          .where((l) => l.id == id)
          .single;
    } else {
      return null;
    }
  }
}
