import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, dynamic>> login({required String email}) async {
    try {
      final response = await remoteDataSource.login(email: email);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> register({
    required String name,
    required String userName,
    required String email,
  }) async {
    try {
      final response = await remoteDataSource.register(
        name: name,
        userName: userName,
        email: email,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> checkOTP({
    required String otp,
    required String email,
    String? fcmToken,
  }) async {
    try {
      final response = await remoteDataSource.checkOTP(
        otp: otp,
        email: email,
        fcmToken: fcmToken,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> sendOTP({required String email}) async {
    try {
      final response = await remoteDataSource.sendOTP(email: email);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> resendOTP({required String email}) async {
    try {
      final response = await remoteDataSource.resendOTP(email: email);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> verifyGuest() async {
    try {
      final response = await remoteDataSource.verifyGuest();
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> logOut() async {
    try {
      final response = await remoteDataSource.logOut();
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
