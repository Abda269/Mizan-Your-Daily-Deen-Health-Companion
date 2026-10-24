import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../main.dart'; 

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Color primaryColor = const Color(0xFF0F4C3A);
  final Color accentColor = const Color(0xFFD4AF37);
  final Color textMain = const Color(0xFF1C2833);
  final Color textMuted = const Color(0xFF7F8C8D);
  final Color surfaceColor = const Color(0xFFFFFFFF);

  late Timer _timer;
  late DateTime _now;
  
  String _nextPrayerName = "";
  DateTime? _nextPrayerTime;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _calculateNextPrayer(); 
    
    // REAL TIME TICKING TIMER
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          _calculateNextPrayer(); 
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); 
    super.dispose();
  }

  // --- SMART PRAYER TIMING LOGIC ---
  void _calculateNextPrayer() {
    final now = DateTime.now();
    // Updated to match Ampang Jaya / accurate KL timings from your screenshot
    final schedule = {
      'Subuh': DateTime(now.year, now.month, now.day, 5, 52),
      'Zuhur': DateTime(now.year, now.month, now.day, 13, 25),
      'Asar': DateTime(now.year, now.month, now.day, 16, 45),
      'Maghrib': DateTime(now.year, now.month, now.day, 19, 24),
      'Ishaa': DateTime(now.year, now.month, now.day, 20, 41), // Corrected to 08:41 PM
    };

    for (var entry in schedule.entries) {
      if (entry.value.isAfter(now)) {
        _nextPrayerName = entry.key;
        _nextPrayerTime = entry.value;
        return;
      }
    }
    // If it is past Ishaa, target Subuh for tomorrow
    _nextPrayerName = 'Subuh';
    _nextPrayerTime = schedule['Subuh']!.add(const Duration(days: 1));
  }

  String _getLiveCountdown() {
    if (_nextPrayerTime == null) return "00:00:00";
    final difference = _nextPrayerTime!.difference(_now);
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  void _showFeatureAction(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $featureName feature...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentHydration = ref.watch(hydrationProvider);
    final checklist = ref.watch(checklistProvider);
    
    final String formattedDate = DateFormat('dd MMMM yyyy').format(_now); 

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER DATE 
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 15),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: accentColor),
                  const SizedBox(width: 4),
                  Text(
                    'Ampang Jaya • $formattedDate', 
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500)
                  ),
                ],
              ),
            ),

            // 2. HERO PRAYER CARD
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: textMuted),
                          const SizedBox(width: 4),
                          Text('NEXT: ${_nextPrayerName.toUpperCase()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted)),
                        ],
                      ),
                      Text('Live Countdown', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryColor)),
                    ],
                  ),
                  
                  // LIVE TICKING CLOCK
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _getLiveCountdown(),
                      style: TextStyle(color: textMain, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      'Target: ${DateFormat('hh:mm a').format(_nextPrayerTime!)}', 
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: textMain)
                    ),
                  ),

                  const SizedBox(height: 15),
                  // ALL 6 TIMINGS INCLUDED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniPrayer('Subuh', '05:52', _nextPrayerName == 'Subuh', Icons.nights_stay_rounded),
                      _buildMiniPrayer('Syuruk', '07:05', false, Icons.wb_sunny_rounded),
                      _buildMiniPrayer('Zuhur', '13:25', _nextPrayerName == 'Zuhur', Icons.light_mode_rounded),
                      _buildMiniPrayer('Asar', '16:45', _nextPrayerName == 'Asar', Icons.cloud_rounded),
                      _buildMiniPrayer('Maghrib', '19:24', _nextPrayerName == 'Maghrib', Icons.wb_twilight_rounded),
                      _buildMiniPrayer('Ishaa', '20:41', _nextPrayerName == 'Ishaa', Icons.bedtime_rounded), // Corrected to 20:41
                    ],
                  )
                ],
              ),
            ),

            // 3. QUICK ACTIONS GRID
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildQuickAction(Icons.menu_book_rounded, 'Quran', () => _showFeatureAction('Al-Quran')),
                _buildQuickAction(Icons.volunteer_activism_rounded, 'Dua', () => _showFeatureAction('Daily Dua')),
                _buildQuickAction(Icons.radio_button_checked_rounded, 'Tasbih', () => _showFeatureAction('Digital Tasbih')),
                _buildQuickAction(Icons.explore_rounded, 'Qibla', () => _showFeatureAction('Qibla Compass')),
              ],
            ),
            const SizedBox(height: 15),

            // 4. BISMILLAH CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border(left: BorderSide(color: accentColor, width: 4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
              ),
              child: Column(
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 
                    style: TextStyle(fontSize: 32, color: accentColor, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"Take benefit of five before five: Your youth before your old age, your health before your sickness..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: textMain, fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ],
              ),
            ),

            // 5. LIVE HYDRATION CARD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.water_drop_rounded, color: Color(0xFF0284c7), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hydration Progress', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textMain)),
                          Text('${currentHydration.toStringAsFixed(2)}L / 2.5L', style: TextStyle(fontSize: 11, color: textMuted)),
                        ],
                      )
                    ],
                  ),
                  Icon(Icons.chevron_right_rounded, color: textMuted),
                ],
              ),
            ),

            // 6. LIVE CHECKLIST CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(Icons.checklist_rounded, 'Checklist'),
                  
                  _buildChecklistRow(
                    'Prayed Current Prayer', 
                    checklist['prayer'] ?? false, 
                    () => ref.read(checklistProvider.notifier).togglePrayer()
                  ),
                  const SizedBox(height: 8),
                  
                  _buildChecklistRow(
                    'Read Daily Qur’an Portion', 
                    checklist['quran'] ?? false, 
                    () => ref.read(checklistProvider.notifier).toggleQuran()
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPrayer(String label, String time, bool isActive, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: isActive ? primaryColor : textMuted.withOpacity(0.4)),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? primaryColor : textMuted)),
        Text(label, style: TextStyle(fontSize: 9, color: isActive ? primaryColor : textMuted.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textMain)),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistRow(String title, bool isChecked, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isChecked ? primaryColor.withOpacity(0.3) : const Color(0xFFF1F5F9))
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: isChecked ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isChecked ? primaryColor : const Color(0xFFCBD5E1), width: 2)
              ),
              child: isChecked ? const Icon(Icons.done, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textMain))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textMuted),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(color: textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }
}