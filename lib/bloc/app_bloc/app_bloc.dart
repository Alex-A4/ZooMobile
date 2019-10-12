import 'package:zoo_mobile/bloc/bloc.dart';

import 'app.dart';

class AppBloc extends Bloc<AppBlocEvent, AppBlocState> {
  @override
  AppBlocState get initialState => AppEmptyState();

  @override
  Stream<AppBlocState> mapEventToState(AppBlocEvent event) async* {}
}
