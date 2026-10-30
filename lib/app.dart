import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/events/presentation/screens/event_list_screen.dart';

class CrewSyncApp extends ConsumerWidget {
  const CrewSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.charcoalBlack,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.skyBlue,
          surface: AppColors.slateGray,
          onPrimary: AppColors.charcoalBlack,
          onSurface: AppColors.pureWhite,
          error: AppColors.crimsonRed,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.pureWhite,
          displayColor: AppColors.pureWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.charcoalBlack,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.slateGray,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.skyBlue,
            foregroundColor: AppColors.charcoalBlack,
            minimumSize: const Size.fromHeight(52),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.slateGray,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: GoogleFonts.poppins(
            color: AppColors.softGray,
            fontSize: 14,
          ),
          labelStyle: GoogleFonts.poppins(
            color: AppColors.softGray,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.skyBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.crimsonRed),
          ),
        ),
      ),
      home: authState.when(
        data: (user) => user != null ? const EventListScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          backgroundColor: AppColors.charcoalBlack,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.skyBlue),
          ),
        ),
        error: (error, stackTrace) => const LoginScreen(),
      ),
    );
  }
}
