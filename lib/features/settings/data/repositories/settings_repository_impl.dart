import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, Map<String, dynamic>>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      if (response != null && response is Map && response['data'] is Map) {
        return Right(Map<String, dynamic>.from(response['data']));
      }
      return const Right({});
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
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
  }) async {
    try {
      final response = await remoteDataSource.updateProfile(
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
      if (response != null && response is Map && response['data'] is Map) {
        return Right(Map<String, dynamic>.from(response['data']));
      }
      return const Right({});
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> deleteAccount() async {
    try {
      final response = await remoteDataSource.deleteAccount();
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> changeMobileTheme({required String theme}) async {
    try {
      final response = await remoteDataSource.changeMobileTheme(theme: theme);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> getPrivacyPolicy() async {
    try {
      final response = await remoteDataSource.getPrivacyPolicy();
      if (response != null && response is Map && response['data'] != null) {
        return Right(response['data'].toString());
      }
      return const Right('');
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> getTerms() async {
    try {
      final response = await remoteDataSource.getTerms();
      if (response != null && response is Map && response['data'] != null) {
        return Right(response['data'].toString());
      }
      return const Right('');
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> getAdsWithUs() async {
    try {
      final response = await remoteDataSource.getAdsWithUs();
      if (response != null && response is Map && response['data'] != null) {
        return Right(response['data'].toString());
      }
      return const Right('');
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
