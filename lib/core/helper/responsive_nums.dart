import 'package:flutter/widgets.dart';

extension CustomResponsiveNums on num {
  static double get _screenWidth {
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final width = view.physicalSize.width / view.devicePixelRatio;
      return (width > 800) ? 800 : width;
    } catch (_) {
      return 400.0;
    }
  }

  static double get _screenHeight {
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final height = view.physicalSize.height / view.devicePixelRatio;
      return (height > 1200) ? 1200 : height;
    } catch (_) {
      return 800.0;
    }
  }

  double get w => (this / 100) * _screenWidth;
  double get h => (this / 100) * _screenHeight;
  double get sp => (this / 100) * _screenWidth;
}
