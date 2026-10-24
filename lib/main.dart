import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED FOR LOGIN WALL
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import 'firebase_options.dart'; 
import 'features/auth_profile_screen.dart';
import 'features/dashboard_screen.dart';
import 'features/prayer_qibla_screen.dart';
import 'features/hydration_screen.dart';
import 'features/meal_finder_screen.dart';

// ==========================================================================
// CENTRAL STATE MANAGEMENT 
// ==========================================================================

final hydrationProvider = StateNotifierProvider<HydrationNotifier, double>((ref) => HydrationNotifier());
class HydrationNotifier extends StateNotifier<double> {
  HydrationNotifier() : super(0.0);
  final double dailyGoal = 2.5;
  void addWater() => state = (state + 0.25).clamp(0.0, dailyGoal);
  void removeWater() => state = (state > 0) ? (state - 0.25).clamp(0.0, dailyGoal) : 0.0;
}

final checklistProvider = StateNotifierProvider<ChecklistNotifier, Map<String, bool>>((ref) => ChecklistNotifier());
class ChecklistNotifier extends StateNotifier<Map<String, bool>> {
  ChecklistNotifier() : super({'prayer': false, 'quran': false});
  void togglePrayer() => state = {...state, 'prayer': !state['prayer']!};
  void toggleQuran() => state = {...state, 'quran': !state['quran']!};
}

// ==========================================================================
// MAIN APP INITIALIZATION
// ==========================================================================

void main() async {
  // 1. Ensure Flutter bindings are ready
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 2. Only initialize Firebase if no apps exist yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // This catches any sneaky background initialization errors safely
    print("Firebase initialization notice: $e");
  }
  
  // 3. Launch your app
  runApp(const ProviderScope(child: MizanApp()));
}

class MizanApp extends StatelessWidget {
  const MizanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mizan: Daily Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '.SF Pro Display',
        primaryColor: const Color(0xFF0F4C3A),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // THE LOGIN WALL: Checks if user is logged in before showing the app!
        '/': (context) => const AuthGate(),
        '/recipe_detail': (context) => const RecipeDetailScreen(),
      },
    );
  }
}

// ==========================================================================
// THE AUTH GATE (Checks Login Status)
// ==========================================================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If Firebase is checking, show a loading circle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // If user has a valid token, skip login and go to the app
        if (snapshot.hasData) {
          return const UniversalNavigationHub();
        }
        // Otherwise, show the Login screen
        return const AuthProfileScreen();
      },
    );
  }
}

// ==========================================================================
// MAIN APP NAVIGATION
// ==========================================================================
class UniversalNavigationHub extends StatefulWidget {
  const UniversalNavigationHub({super.key});

  @override
  State<UniversalNavigationHub> createState() => _UniversalNavigationHubState();
}

class _UniversalNavigationHubState extends State<UniversalNavigationHub> {
  int _currentIndex = 0; // Starts at 0 (Dashboard)

  // Auth screen removed! Only the 4 main app features remain.
  final List<Widget> _screens = const [
    DashboardScreen(),
    PrayerQiblaScreen(),
    HydrationScreen(),
    MealFinderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      extendBody: true, 
      body: Stack(
        children: [
          // 1. Photographic Header
          Positioned(
            top: 0, left: 0, right: 0, height: 240,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1564507004663-b6dfb3c824d5?q=80&w=800&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0F4C3A).withOpacity(0.90), const Color(0xFF1A6B54).withOpacity(0.95)],
                ),
              ),
            ),
          ),
          
          // 2. Main Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeaderDetails(),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // 3. Floating Bottom Navigation (Auth tab removed)
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.white.withOpacity(0.95),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dash'),
                NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Qibla'),
                NavigationDestination(icon: Icon(Icons.water_drop_outlined), selectedIcon: Icon(Icons.water_drop), label: 'Health'),
                NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Meals'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mizan App', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w900, fontSize: 16)),
              Text('Your Daily Companion', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ],
          ),
          // NEW SIGN OUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 28),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // When this triggers, the AuthGate will instantly push them back to the login screen!
            },
          ),
        ],
      ),
    );
  }
}