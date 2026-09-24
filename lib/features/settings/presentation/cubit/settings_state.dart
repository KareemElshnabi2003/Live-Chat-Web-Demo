abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class ProfileLoaded extends SettingsState {
  final Map<String, dynamic> userProfile;

  ProfileLoaded({required this.userProfile});
}

class ProfileUpdateSuccess extends SettingsState {
  final Map<String, dynamic> userProfile;

  ProfileUpdateSuccess({required this.userProfile});
}

class StaticContentLoaded extends SettingsState {
  final String content;

  StaticContentLoaded({required this.content});
}

class AccountDeletedSuccess extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;

  SettingsError({required this.message});
}
