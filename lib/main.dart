import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const InvisafeApp());
}

class InvisafeApp extends StatelessWidget {
  const InvisafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invisafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
