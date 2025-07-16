import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HostelPaymentTrackerApp());
}

class HostelPaymentTrackerApp extends StatelessWidget {
  const HostelPaymentTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'Hostel Payment Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1976D2),
          hintColor: const Color(0xFF42A5F5),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}