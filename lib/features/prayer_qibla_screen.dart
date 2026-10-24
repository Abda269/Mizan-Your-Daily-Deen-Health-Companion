import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// ==========================================================================
// FEATURE 3: Prayer Times & Qibla Compass
// Premium UI Update based on HTML Prototype
// ==========================================================================

class PrayerQiblaScreen extends StatefulWidget {
  const PrayerQiblaScreen({super.key});

  @override
  State<PrayerQiblaScreen> createState() => _PrayerQiblaScreenState();
}

class _PrayerQiblaScreenState extends State<PrayerQiblaScreen> {
  // --- Exact Colors from HTML Prototype ---
  final Color primaryColor = const Color(0xFF0F4C3A);
  final Color accentColor = const Color(0xFFD4AF37);
  final Color bgColor = const Color(0xFFF0F4F8);
  final Color textMain = const Color(0xFF1C2833);
  final Color textMuted = const Color(0xFF7F8C8D);
  final Color surfaceColor = const Color(0xFFFFFFFF);

  // Static context setup targeting local capital coordinates (Kuala Lumpur)
  final double latitude = 3.1390;
  final double longitude = 101.6869;
  
  late PrayerTimes _prayerTimes;
  double? _compassHeading = 0;
  double _qiblaDirection = 0;

  @override
  void initState() {
    super.initState();
    _calculatePrayerTimes();
    _calculateQiblaBearing();
    _initCompassStream();
  }

  void _calculatePrayerTimes() {
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;
    
    _prayerTimes = PrayerTimes.today(coordinates, params);
  }

  void _calculateQiblaBearing() {
    final coordinates = Coordinates(latitude, longitude);
    _qiblaDirection = Qibla(coordinates).direction;
  }

  void _initCompassStream() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          _compassHeading = event.heading;
        });
      }
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time.toLocal());
  }

  // --- Helper Widget: Matches HTML .section-title ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double compassNeedleDirection = 0;
    if (_compassHeading != null) {
      compassNeedleDirection = (_qiblaDirection - _compassHeading!) * (math.pi / 180 * -1);
    }

    // Determine the next prayer for dynamic highlighting
    Prayer nextPrayer = _prayerTimes.nextPrayer();

    // Data structure for the grid
    final List<Map<String, dynamic>> prayerData = [
      {'name': 'Fajr', 'time': _prayerTimes.fajr, 'enum': Prayer.fajr, 'icon': Icons.nights_stay_rounded, 'color': const Color(0xFF64748B)},
      {'name': 'Sunrise', 'time': _prayerTimes.sunrise, 'enum': Prayer.sunrise, 'icon': Icons.light_mode_rounded, 'color': const Color(0xFFEAB308)},
      {'name': 'Dhuhr', 'time': _prayerTimes.dhuhr, 'enum': Prayer.dhuhr, 'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFFF59E0B)},
      {'name': 'Asr', 'time': _prayerTimes.asr, 'enum': Prayer.asr, 'icon': Icons.cloud_rounded, 'color': accentColor},
      {'name': 'Maghrib', 'time': _prayerTimes.maghrib, 'enum': Prayer.maghrib, 'icon': Icons.wb_twilight_rounded, 'color': const Color(0xFFF43F5E)},
      {'name': 'Isha', 'time': _prayerTimes.isha, 'enum': Prayer.isha, 'icon': Icons.bedtime_rounded, 'color': const Color(0xFF3B82F6)},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Let main.dart background show through
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- QIBLA COMPASS CARD (Matches HTML prototype) ---
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.8)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qibla Compass',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_qiblaDirection.toStringAsFixed(0)}° NW',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textMuted),
                      ),
                    ],
                  ),
                  
                  // Premium SVG-style Compass Built with Flutter Stack
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Ring
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bgColor,
                            border: Border.all(color: accentColor, width: 3),
                          ),
                        ),
                        // Inner Ring (Dashed approximation)
                        Container(
                          height: 40, width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                          ),
                        ),
                        // The Rotating Needle
                        Transform.rotate(
                          angle: compassNeedleDirection,
                          child: Icon(Icons.navigation_rounded, color: primaryColor, size: 35),
                        ),
                        // Center dot
                        Container(
                          height: 8, width: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('Takwim Schedule'),
            
            // --- PRAYER TIMES GRID (Matches HTML prototype) ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disables grid scroll, lets SingleChildScrollView handle it
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4, // Adjusts the height of the grid cards
              ),
              itemCount: prayerData.length,
              itemBuilder: (context, index) {
                final prayer = prayerData[index];
                final bool isActive = nextPrayer == prayer['enum'];

                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor : surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
                      else
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        prayer['icon'],
                        color: isActive ? accentColor : prayer['color'],
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prayer['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isActive ? Colors.white.withOpacity(0.8) : textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(prayer['time']),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isActive ? Colors.white : textMain,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 90), // Mobile padding so the bottom nav bar doesn't block the last row
          ],
        ),
      ),
    );
  }
}