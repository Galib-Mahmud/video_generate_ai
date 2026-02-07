import 'package:get/get.dart';

class AppDrawerController extends GetxController {
  Function? _openDrawer;
  Function? _closeDrawer;

  void setDrawerFunctions({
    required Function open,
    required Function close,
  }) {
    _openDrawer = open;
    _closeDrawer = close;
  }

  void open() {
    _openDrawer?.call();
  }

  void close() {
    _closeDrawer?.call();
  }
}