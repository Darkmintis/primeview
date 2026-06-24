import 'package:flutter/services.dart';

class PlatformChannels {
  PlatformChannels._();

  static const _channel = MethodChannel('com.primeview.app/pip');

  static Future<void> enterPip() async {
    try {
      await _channel.invokeMethod('enterPip');
    } catch (e) {
      // PiP not supported or not available
    }
  }
}
