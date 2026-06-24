import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart';

class PlatformChannels {
  PlatformChannels._();

  static const _channel = MethodChannel('com.primeview.app/pip');

  static Future<void> enterPip() async {
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await _channel.invokeMethod('enterPip');
    } catch (_) {
      // PiP not available
    }
  }
}
