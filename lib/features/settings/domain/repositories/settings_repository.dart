import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<String, Map<String, dynamic>>> getProfile();
  Future<Either<String, Map<String, dynamic>>> updateProfile({
    required String name,
    required String bio,
    required String username,
    required String email,
    required String phone,
    required String age,
    required String gender,
    List<int>? imageBytes,
    String? imageName,
  });
  Future<Either<String, dynamic>> deleteAccount();
  Future<Either<String, dynamic>> changeMobileTheme({required String theme});
  Future<Either<String, String>> getPrivacyPolicy();
  Future<Either<String, String>> getTerms();
  Future<Either<String, String>> getAdsWithUs();
}
