import 'package:flutter_request_bloc/flutter_request_bloc.dart';

import '../models/index.dart';
import '../repositories/index.dart';

/// Cubit that holds information about SpaceX.
class CompanyCubit extends RequestCubit<CompanyRepository, CompanyInfo> {
  CompanyCubit(CompanyRepository repository) : super(repository);

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
