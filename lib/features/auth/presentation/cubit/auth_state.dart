abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCodeSent extends AuthState {
  final String email;
  final bool isRegister;
  AuthCodeSent({required this.email, required this.isRegister});
}

class AuthSuccess extends AuthState {
  final Map<String, dynamic>? userData;
  AuthSuccess({this.userData});
}

class AuthGuestSuccess extends AuthState {
  final Map<String, dynamic>? guestData;
  AuthGuestSuccess({this.guestData});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class AuthLoggedOut extends AuthState {}
