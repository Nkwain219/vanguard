import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static DeviceService? _instance;
  static DeviceService get instance => _instance ??= DeviceService._();
  DeviceService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedDeviceId;

  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        _cachedDeviceId = info.id;
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        _cachedDeviceId = info.identifierForVendor ?? 'unknown';
      } else {
        _cachedDeviceId = 'unknown-${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      _cachedDeviceId = 'error-${DateTime.now().millisecondsSinceEpoch}';
    }

    return _cachedDeviceId!;
  }

  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.brand} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.name;
      }
    } catch (e) {}
    return 'Unknown Device';
  }
}
