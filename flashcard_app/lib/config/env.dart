import 'dart:io';

class Env {
  static const String _realDeviceIp = "192.168.1.52";

  const Env._();

  static String get _emulatorIp {
    // iOS Simulator
    if (Platform.isIOS) {
      return "127.0.0.1";
    }

    // android Emulator
    if (Platform.isAndroid) {
      return "10.0.2.2";
    }

    // physical device
    return _realDeviceIp;
  }

  static String get flashcardBaseUrl {
    const bool isEmulator = bool.fromEnvironment(
      "EMULATOR",
      defaultValue: false,
    );

    if (isEmulator) {
      return "http://$_emulatorIp:8000";
    }

    return "http://$_realDeviceIp:8000";
  }

  static String get roadmapBaseUrl {
    const bool isEmulator = bool.fromEnvironment(
      "EMULATOR",
      defaultValue: false,
    );

    if (isEmulator) {
      return "http://$_emulatorIp:8001";
    }

    return "http://$_realDeviceIp:8001";
  }

  static String get suggestBaseUrl {
    const bool isEmulator = bool.fromEnvironment(
      "EMULATOR",
      defaultValue: false,
    );

    if (isEmulator) {
      return "http://$_emulatorIp:8002";
    }

    return "http://$_realDeviceIp:8002";
  }
}
