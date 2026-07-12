import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Lightweight wrapper around [LocalAuthentication] for biometric auth.
class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns `true` if the device has biometric/credential support.
  Future<bool> isDeviceSupported() => _auth.isDeviceSupported();

  /// Returns `true` if biometrics are currently enrolled.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static const _channel = MethodChannel('com.trackr.trackr/security');

  /// Returns `true` only if the device has a PIN/pattern/biometric actually set up.
  /// This goes beyond `isDeviceSupported()` which only checks hardware capability.
  Future<bool> hasEnrolledCredentials() async {
    try {
      final isSecure = await _channel.invokeMethod<bool>('isDeviceSecure');
      return isSecure ?? false;
    } catch (_) {
      try {
        final canCheck = await _auth.canCheckBiometrics;
        final supported = await _auth.isDeviceSupported();
        if (!supported) return false;
        if (canCheck) {
          final enrolled = await _auth.getAvailableBiometrics();
          if (enrolled.isNotEmpty) return true;
        }
        return false;
      } catch (_) {
        return false;
      }
    }
  }

  /// Triggers the biometric prompt. Returns `true` on success, or if no lock is enrolled.
  Future<bool> authenticate() async {
    try {
      final supported = await isDeviceSupported();
      if (!supported) return true; // Bypass if device has no support at all

      return await _auth.authenticate(
        localizedReason: 'Unlock Trackr to view your finances',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allows PIN/pattern as fallback
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet ||
          e.code == auth_error.notAvailable) {
        return true; // Bypass lock since user has no screen lock set up
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

