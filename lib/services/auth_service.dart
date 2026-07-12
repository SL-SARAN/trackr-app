import 'package:local_auth/local_auth.dart';

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

  /// Triggers the biometric prompt. Returns `true` on success.
  Future<bool> authenticate() async {
    try {
      final supported = await isDeviceSupported();
      if (!supported) return false;

      return await _auth.authenticate(
        localizedReason: 'Unlock Trackr to view your finances',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allows PIN/pattern as fallback
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
