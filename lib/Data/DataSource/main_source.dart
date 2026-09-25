import 'package:live_chat/core/Class/api.dart';
import 'package:live_chat/core/Constant/app_api.dart';
import 'package:live_chat/main.dart';

class MainRemoteData {
  final Api api; // إضافة final

  String get deviceId => sharedPreferences!.getString("deviceId") ?? "";

  MainRemoteData({
    required this.api,
  });
//new
  getAds() async {
    var response = await api.getData(
        "${AppApi.getAds}?device_id=$deviceId"
   );
    return response.fold((l) => l, (r) => r);
  }
}