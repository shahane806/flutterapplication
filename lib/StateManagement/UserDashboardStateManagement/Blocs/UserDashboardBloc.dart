import 'package:flutter_bloc/flutter_bloc.dart';

import '../Events/UserDashboardEvent.dart';
import '../States/UserDashboardState.dart';

class UserDashboardBloc extends Bloc<UserDashboardEvent, UserDashboardState> {
  UserDashboardBloc() : super(UserDashboardState.initial()) {}
}
