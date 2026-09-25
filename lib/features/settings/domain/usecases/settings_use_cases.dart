import 'package:dartz/dartz.dart';
import '../repositories/settings_repository.dart';

class GetProfileUseCase {
  final SettingsRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<String, Map<String, dynamic>>> call() {
    return repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final SettingsRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<String, Map<String, dynamic>>> call({
    required String name,
    required String bio,
    required String username,
    required String email,
    required String phone,
    required String age,
    required String gender,
    List<int>? imageBytes,
    String? imageName,
  }) {
    return repository.updateProfile(
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
  }
}

class DeleteAccountUseCase {
  final SettingsRepository repository;
  DeleteAccountUseCase(this.repository);

  Future<Either<String, dynamic>> call() {
    return repository.deleteAccount();
  }
}

class ChangeMobileThemeUseCase {
  final SettingsRepository repository;
  ChangeMobileThemeUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String theme}) {
    return repository.changeMobileTheme(theme: theme);
  }
}

class GetPrivacyPolicyUseCase {
  final SettingsRepository repository;
  GetPrivacyPolicyUseCase(this.repository);

  Future<Either<String, String>> call() {
    return repository.getPrivacyPolicy();
  }
}

class GetTermsUseCase {
  final SettingsRepository repository;
  GetTermsUseCase(this.repository);

  Future<Either<String, String>> call() {
    return repository.getTerms();
  }
}

class GetAdsWithUsUseCase {
  final SettingsRepository repository;
  GetAdsWithUsUseCase(this.repository);

  Future<Either<String, String>> call() {
    return repository.getAdsWithUs();
  }
}
