import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../constant/app_constant.dart';
import '../helper/cache_helper.dart';
import '../routing/app_router.dart';
import '../routing/routes.dart';

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    final String lang = CacheHelper.getData(key: AppConstants.langKey) ?? 'ar';
    options.headers['Lang'] = lang == 'en' ? 'en' : 'ar';

    final String? token = CacheHelper.getData(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty && token != 'null') {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await CacheHelper.removeData(key: AppConstants.tokenKey);

      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        context.go(Routes.startPageScreen);
      }
    }

    super.onError(err, handler);
  }
}