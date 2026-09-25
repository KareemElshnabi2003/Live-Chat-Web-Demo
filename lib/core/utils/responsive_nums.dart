import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

extension CustomResponsiveNums on num {
  static double get _screenWidth {
    try {
      final views = ui.PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final view = views.first;
        final physicalWidth = view.physicalSize.width;
        final pixelRatio = view.devicePixelRatio;
        final logicalWidth = physicalWidth / (pixelRatio > 0 ? pixelRatio : 1);
        return kIsWeb && logicalWidth > 800 ? 800 : logicalWidth;
      }
    } catch (_) {}
    return 400.0;
  }

  static double get _screenHeight {
    try {
      final views = ui.PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final view = views.first;
        final physicalHeight = view.physicalSize.height;
        final pixelRatio = view.devicePixelRatio;
        final logicalHeight = physicalHeight / (pixelRatio > 0 ? pixelRatio : 1);
        return kIsWeb && logicalHeight > 1200 ? 1200 : logicalHeight;
      }
    } catch (_) {}
    return 800.0;
  }

  double get w => (this / 100) * _screenWidth;
  double get h => (this / 100) * _screenHeight;
  double get sp => (this / 100) * _screenWidth;
}
