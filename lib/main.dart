import 'package:flutter/material.dart';
import 'package:konnectrent/core/di/injection.dart';
import 'package:konnectrent/core/router/app_router.dart';
import 'package:konnectrent/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const KonnectRentApp());
}

class KonnectRentApp extends StatelessWidget {
  const KonnectRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KonnectRent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
