import 'package:local_auth/local_auth.dart';

class BiometricAuthHelper {
  static final LocalAuthentication auth = LocalAuthentication();

  static Future<bool> canCheckBiometrics() async {
    return await auth.canCheckBiometrics;
  }

  static Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
