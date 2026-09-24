import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsCubit({required this.settingsRepository}) : super(SettingsInitial());

  Future<void> getProfile() async {
    emit(SettingsLoading());
    final result = await settingsRepository.getProfile();
    result.fold(
      (error) => emit(SettingsError(message: error)),
      (profile) => emit(ProfileLoaded(userProfile: profile)),
    );
  }

  Future<void> updateProfile({
    required String name,
    required String bio,
    required String username,
    required String email,
    required String phone,
    required String age,
    required String gender,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    emit(SettingsLoading());
    final result = await settingsRepository.updateProfile(
      name: name,
      bio: bio,
      username: username,
      email: email,
      phone: phone,
      age: age,
      gender: gender,
      imageBytes: imageBytes,
      imageName: imageName,
    );
    result.fold(
      (error) => emit(SettingsError(message: error)),
      (profile) => emit(ProfileUpdateSuccess(userProfile: profile)),
    );
  }

  Future<void> deleteAccount() async {
    emit(SettingsLoading());
    final result = await settingsRepository.deleteAccount();
    result.fold(
      (error) => emit(SettingsError(message: error)),
      (_) => emit(AccountDeletedSuccess()),
    );
  }

  Future<void> getPrivacyPolicy() async {
    emit(SettingsLoading());
    final result = await settingsRepository.getPrivacyPolicy();
    result.fold(
      (error) => emit(SettingsError(message: error)),
      (content) => emit(StaticContentLoaded(content: content)),
    );
  }

  Future<void> getTerms() async {
    emit(SettingsLoading());
    final result = await settingsRepository.getTerms();
    result.fold(
      (error) => emit(SettingsError(message: error)),
      (content) => emit(StaticContentLoaded(content: content)),
    );
  }

  Future<void> getAdsWithUs() async {
    emit(SettingsLoading());
    final result = await settingsRepository.getAdsWithUs();
    result.fold(
      (error) => emit(SettingsError(message: error)),
      (content) => emit(StaticContentLoaded(content: content)),
    );
  }
}
