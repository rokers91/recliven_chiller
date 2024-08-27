import 'package:flutter/material.dart';
import 'package:get/get.dart';

//controlador que maneja el estado del tabbar
class MyTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  RxInt currentIndex = 1.obs;

  @override
  void onInit() {
    initTabBar();
    super.onInit();
  }

//para cuandos se cierra el tabbar
  @override
  void onClose() {
    super.onClose();
    tabController.dispose();
  }

  //inicializa el tabbar y se escuchan los cambios de indice
  initTabBar() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        // para cuando se da ontap
        onTabBarChange(tabController.index);
      } else if (tabController.index == tabController.animation!.value) {
        // asegura el swipe
        onTabBarChange(tabController.index);
      }
    });
  }

  //cambia el estado del index del tabbar
  onTabBarChange(int index) {
    currentIndex.value = index;
  }
}
