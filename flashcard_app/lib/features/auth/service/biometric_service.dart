import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<(bool, String?)> authenticate() async {
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Xác thực để tiếp tục đăng nhập',
        biometricOnly: false,
      );
      return (result, null);
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noCredentialsSet:
          return (false, 'Chưa cài đặt sinh trắc học trên thiết bị.');
        case LocalAuthExceptionCode.biometricLockout:
          return (false, 'Quá nhiều lần thất bại. Vui lòng thử lại sau.');
        case LocalAuthExceptionCode.userCanceled:
          return (false, 'Bạn đã huỷ xác thực.');
        default:
          return (false, 'Xác thực thất bại. Code: ${e.code}');
      }
    } on PlatformException catch (e) {
      // Bắt lỗi channel iOS/Android
      if (e.code == 'channel-error') {
        return (false, 'Thiết bị chưa cấu hình sinh trắc học hoặc thiếu permission.');
      }
      return (false, 'Lỗi hệ thống: ${e.code}');
    } catch (e) {
      return (false, 'Lỗi: $e');
    }
  }
}