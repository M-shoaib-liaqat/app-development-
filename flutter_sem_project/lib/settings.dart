import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _localAuth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();

  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _hasFingerprintSupport = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final enabled = await _secureStorage.read(key: 'biometric_enabled') == 'true';
    final hasBiometrics = await _localAuth.canCheckBiometrics;
    setState(() {
      _biometricEnabled = enabled;
      _hasFingerprintSupport = hasBiometrics;
    });
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled) {
      try {
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        final availableBiometrics = await _localAuth.getAvailableBiometrics();

        if (!canCheckBiometrics || !isDeviceSupported || availableBiometrics.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No fingerprint enrolled. Redirecting to settings...')),
          );

          const intent = AndroidIntent(
            action: 'android.settings.SECURITY_SETTINGS',
          );
          await intent.launch();
          return;
        }

        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Enable fingerprint authentication',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          await _secureStorage.write(key: 'biometric_enabled', value: 'true');
          setState(() => _biometricEnabled = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric authentication failed')),
          );
        }
      } on PlatformException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric error: ${e.message}')),
        );
      }
    } else {
      await _secureStorage.delete(key: 'biometric_enabled');
      setState(() => _biometricEnabled = false);
    }
  }

  Future<void> _setPin() async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text == confirmController.text && controller.text.length >= 4) {
                await _secureStorage.write(key: 'user_pin', value: controller.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN set successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match or are too short')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app theme'),
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Enable/disable notifications'),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              // Optional: Save this preference
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Enable Fingerprint Login'),
            subtitle: _hasFingerprintSupport
                ? const Text('Use fingerprint to login')
                : const Text('Fingerprint not supported'),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: _hasFingerprintSupport ? _toggleBiometric : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Set PIN'),
            subtitle: const Text('Set a secure login PIN'),
            onTap: _setPin,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('App information'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'University Events',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 BGNU',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('View privacy policy'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const Text('Your data is secure and only used for event management.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
