import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../network/api_service.dart';
import '../model/user.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<LoginState> emit,
      ) async {
    try {
      emit(LoginLoading());

      final response = await ApiService.login(event.email, event.password);

      if (response.success && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data!);

        emit(LoginSuccess(loginResponse: loginResponse));
      } else {
        emit(LoginFailure(
          error: response.message ?? 'Login failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      emit(LoginFailure(
        error: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }
}
