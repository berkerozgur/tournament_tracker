import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class AppWindowManager {
  static const Size _defaultWindowSize = Size(800, 600);
  static const Size _largeWindowSize = Size(1366, 768);

  static Future<void> setupMainWindow() async {
    const windowOptions = WindowOptions(
      center: true,
      maximumSize: _defaultWindowSize,
      minimumSize: _defaultWindowSize,
      size: _defaultWindowSize,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static Future<void> setupSubWindow({
    bool isResizable = false,
    Size size = _largeWindowSize,
  }) async {
    await windowManager.setResizable(isResizable);
    await windowManager.setSize(size);
    await windowManager.show();
  }
}
