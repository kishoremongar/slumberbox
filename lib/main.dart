import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SlumberBoxApp());
}

class SlumberBoxApp extends StatelessWidget {
  const SlumberBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlumberBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1B26),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF2A2B36),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFCDCFD9),
        ),

        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: const Color(0xFFCDCFD9),
          displayColor: const Color(0xFFCDCFD9),
        ),

        appBarTheme: AppBarTheme(
          color: const Color(0xFF2A2B36),
          elevation: 2,
          iconTheme: const IconThemeData(color: Color(0xFFCDCFD9)),
          titleTextStyle: GoogleFonts.nunito(
            color: const Color(0xFFCDCFD9),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: CardTheme(
          color: const Color(0xFF2A2B36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),

        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF3B82F6),
          inactiveTrackColor: const Color(0xFF1F2937),
          thumbColor: const Color(0xFF3B82F6),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            return states.contains(WidgetState.selected)
                ? const Color(0xFF3B82F6)
                : const Color(0xFFCDCFD9);
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            return states.contains(WidgetState.selected)
                ? const Color(0x803B82F6) // 50% alpha on 3B82F6
                : const Color(0xFF1F2937);
          }),
        ),

        bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFF2A2B36)),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
