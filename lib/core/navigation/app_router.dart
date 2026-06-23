import 'package:flutter/material.dart';

import '../../models/module_info.dart';
import '../../modules/air_quality/air_quality_screen.dart';
import '../../modules/food/food_screen.dart';
import '../../modules/pipeline_monitoring/pipeline_screen.dart';
import '../../modules/road_monitoring/road_screen.dart';
import '../../modules/skin/skin_screen.dart';
import '../../modules/structural/structural_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/splash_screen.dart';
import '../theme/app_colors.dart';

/// Central navigation registry. Each of the six integrated modules is declared
/// once here (descriptor + screen builder), giving the app a single,
/// standardized routing table.
class AppRouter {
  AppRouter._();

  /// Initial route (branded splash). Kept distinct from [home] so navigating
  /// away from the splash does not rebuild the splash (which previously caused
  /// an infinite landing-page loop).
  static const String splash = '/';
  static const String home = '/home';

  /// The canonical list of integrated modules (drives the home grid).
  static const List<ModuleInfo> modules = [
    ModuleInfo(
      id: 'structural',
      title: 'STRUCTURAL',
      subtitle: 'Safety & Integrity Analysis',
      accentColor: AppColors.structuralCyan,
      icon: Icons.architecture,
      iconAsset: 'assets/icons/structural.png',
      routeName: '/structural',
    ),
    ModuleInfo(
      id: 'food',
      title: 'BIO-SAFETY',
      subtitle: 'Nutrition & Grade Check',
      accentColor: AppColors.bioSafetyGreen,
      icon: Icons.eco,
      iconAsset: 'assets/icons/biosafety.png',
      routeName: '/food',
    ),
    ModuleInfo(
      id: 'skin',
      title: 'DERMA-TECH',
      subtitle: 'Skin Health Assessment',
      accentColor: AppColors.dermaTechPurple,
      icon: Icons.face_retouching_natural,
      iconAsset: 'assets/icons/dermatech.png',
      routeName: '/skin',
    ),
    ModuleInfo(
      id: 'road',
      title: 'ROAD VISION',
      subtitle: 'Road Damage Monitoring',
      accentColor: AppColors.roadVisionOrange,
      icon: Icons.add_road,
      iconAsset: 'assets/icons/roadvision.png',
      routeName: '/road',
    ),
    ModuleInfo(
      id: 'pipeline',
      title: 'PIPELINE GUARD',
      subtitle: 'Leak & Utility Monitoring',
      accentColor: AppColors.pipelineTeal,
      icon: Icons.plumbing,
      iconAsset: 'assets/icons/pipeline.png',
      routeName: '/pipeline',
    ),
    ModuleInfo(
      id: 'air_quality',
      title: 'AIR SENTINEL',
      subtitle: 'Air Quality & Ventilation',
      accentColor: AppColors.airSentinelBlue,
      icon: Icons.air,
      iconAsset: 'assets/icons/airsentinel.png',
      routeName: '/air_quality',
    ),
  ];

  static final Map<String, WidgetBuilder> _builders = {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    '/structural': (_) => const StructuralScreen(),
    '/food': (_) => const FoodScreen(),
    '/skin': (_) => const SkinScreen(),
    '/road': (_) => const RoadScreen(),
    '/pipeline': (_) => const PipelineScreen(),
    '/air_quality': (_) => const AirQualityScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _builders[settings.name] ?? _builders[home]!;
    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
