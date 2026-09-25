import 'package:dartz/dartz.dart';
import '../repositories/home_repository.dart';

class GetAdsUseCase {
  final HomeRepository repository;
  GetAdsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call() {
    return repository.getAds();
  }
}

class GetPinnedChatUseCase {
  final HomeRepository repository;
  GetPinnedChatUseCase(this.repository);

  Future<Either<String, dynamic>> call() {
    return repository.getPinnedChat();
  }
}

class GetRecentChatsUseCase {
  final HomeRepository repository;
  GetRecentChatsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({int page = 1, int perPage = 15}) {
    return repository.getRecentChats(page: page, perPage: perPage);
  }
}

class GetSystemChatsUseCase {
  final HomeRepository repository;
  GetSystemChatsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({int page = 1, int perPage = 8}) {
    return repository.getSystemChats(page: page, perPage: perPage);
  }
}

class GetUserChatsUseCase {
  final HomeRepository repository;
  GetUserChatsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({int page = 1, int perPage = 15}) {
    return repository.getUserChats(page: page, perPage: perPage);
  }
}
