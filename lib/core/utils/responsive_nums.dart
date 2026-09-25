import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

extension CustomResponsiveNums on num {
  double get w {
    try {
      double screenWidth = kIsWeb && Get.width > 800 ? 800 : Get.width;
      return (this / 100) * screenWidth;
    } catch (e) {
      return this.toDouble() * 4; // fallback 
    }
  }

  double get h {
    try {
      double screenHeight = kIsWeb && Get.height > 1200 ? 1200 : Get.height;
      return (this / 100) * screenHeight;
    } catch (e) {
      return this.toDouble() * 8; // fallback
    }
  }

  double get sp {
    try {
      double screenWidth = kIsWeb && Get.width > 800 ? 800 : Get.width;
      return (this / 100) * screenWidth;
    } catch (e) {
      return this.toDouble() * 4; // fallback 
    }
  }
}
