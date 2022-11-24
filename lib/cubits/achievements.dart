import 'package:flutter_request_bloc/flutter_request_bloc.dart';

import '../models/index.dart';
import '../repositories/index.dart';

/// Cubit that holds a list of all achievements scored in SpaceX history.
class AchievementsCubit
    extends RequestCubit<AchievementsRepository, List<Achievement>> {
  AchievementsCubit(AchievementsRepository repository) : super(repository);

  @override
  Future<void> loadData() async {
    emit(RequestState.loading(state.value));

    try {
      repository
          .fetchData()
          .then((value) => emit(RequestState.loaded(value)))
          .catchError((e) => emit(RequestState.error(e.toString())));
    } catch (e) {
      emit(RequestState.error(e.toString()));
    }
  }
}
