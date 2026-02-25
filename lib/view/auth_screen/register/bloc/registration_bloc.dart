import 'package:exness_clone/view/auth_screen/register/bloc/registration_event.dart';
import 'package:exness_clone/view/auth_screen/register/bloc/registration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../network/api_service.dart';
import '../model/register.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    on<RegisterUser>(_onRegisterUser);
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());

    try {
      final userData = {
        'fullName': event.fullName,
        'email': event.email,
        'password': event.password,
        'phone': event.phone,
      };

      if (event.referedBy != null && event.referedBy!.isNotEmpty) {
        userData['referedBy'] = event.referedBy!;
      }

      final response = await ApiService.register(userData);

      if (response.success && response.data != null) {
        final registerResponse = Register.fromJson(response.data!);
        emit(RegistrationSuccess(
          registerResponse: registerResponse,
          navigatorPage: registerResponse.navigatorPage,
        ));
      } else {
        emit(RegistrationFailure(
          message: response.message ?? 'Registration failed. Please try again.',
        ));
      }
    } catch (e) {
      emit(RegistrationFailure(
        message: 'An unexpected error occurred. Please try again.',
      ));
    }
  }
}
