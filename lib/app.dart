import 'package:flutter/material.dart';

import 'screens/history_screen.dart';
import 'theme/app_theme.dart';
import 'screens/landing_screen.dart';

class GabAIApp extends StatelessWidget {
  const GabAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gab-AI',
      debugShowCheckedModeBanner: false,
      routes: {'/history': (_) => const HistoryScreen()},
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ).copyWith(primary: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.primaryLight,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textMuted,
            );
          }),
        ),
      ),
      home: const LandingPage(),
    );
  }
}