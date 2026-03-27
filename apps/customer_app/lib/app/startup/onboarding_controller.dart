import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:shared_core/shared_core.dart';


class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  final PageController pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> nextPage() async {
    if (currentPageIndex.value == 3) {
      await StorageService.setFirstRunDone();
      //final storage = GetStorage();
      //storage.write('IsFirstTime', false);
      Get.offAllNamed(AppRoutes.welcome);
    } else {
      final nextIndex = currentPageIndex.value + 1;
      pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipPage() {
    currentPageIndex.value = 3;
    pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}















