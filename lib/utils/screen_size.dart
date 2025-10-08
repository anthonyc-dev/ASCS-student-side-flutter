import 'package:flutter/widgets.dart';

class ScreenSizeUtil {
  Size getDesignSize() {
    if (WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .physicalSize
            .width >=
        1100) {
      return const Size(1440, 1024); // Desktop reference size
    } else if (WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .physicalSize
            .width >=
        650) {
      return const Size(834, 1194); // Tablet reference size (iPad)
    } else {
      return const Size(375, 812); // Mobile reference size (iPhone X)
    }
  }
}
