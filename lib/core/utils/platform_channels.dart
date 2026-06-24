import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class PlatformChannels {
  PlatformChannels._();

  static const _channel = MethodChannel('com.primeview.app/pip');

  static Future<void> enterPip() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('enterPip');
    } catch (_) {}
  }
}
