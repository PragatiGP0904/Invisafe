/// App-wide constants and the canonical list of integrated modules.
class AppConstants {
  AppConstants._();

  static const String appName = 'Invisafe';
  static const String tagline = 'Multi-Modal Vision Intelligence';

  // How long the simulated scan / inference takes (matches the demo flows
  // from the original native apps).
  static const Duration scanDuration = Duration(seconds: 3);
}
