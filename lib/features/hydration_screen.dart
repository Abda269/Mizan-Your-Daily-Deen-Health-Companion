import 'package:flutter/material.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  final Color primaryColor = const Color(0xFF0F4C3A);
  final Color textMain = const Color(0xFF1C2833);
  final Color textMuted = const Color(0xFF7F8C8D);
  final Color surfaceColor = const Color(0xFFFFFFFF);

  double currentHydration = 1.2;
  final double goalHydration = 2.5;

  void _addWater() {
    setState(() {
      if (currentHydration < goalHydration) currentHydration += 0.25;
    });
  }

  void _removeWater() {
    setState(() {
      if (currentHydration > 0) currentHydration -= 0.25;
    });
  }

  Widget _buildSectionTitle(IconData icon, String title, {MainAxisAlignment alignment = MainAxisAlignment.start}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: alignment,
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

  @override
  Widget build(BuildContext context) {
    double progress = (currentHydration / goalHydration).clamp(0.0, 1.0);
    int percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // --- Hydration Card ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(Icons.water_drop_rounded, 'Hydration'),
                          Text('Goal: ${goalHydration}L', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textMuted)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                        child: Text('$percentage%', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 13)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  RichText(
                    text: TextSpan(
                      text: currentHydration.toStringAsFixed(1),
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: textMain),
                      children: [
                        TextSpan(text: ' L', style: TextStyle(fontSize: 16, color: textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Custom Gradient Progress Bar
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Add/Remove Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _removeWater,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.remove_rounded, color: textMuted),
                        ),
                      ),
                      Column(
                        children: [
                          Text('250ml', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textMain)),
                          Text('Glass Size', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textMuted)),
                        ],
                      ),
                      GestureDetector(
                        onTap: _addWater,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: primaryColor, 
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))]
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Sleep & Energy Grid ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44, height: 44, margin: const EdgeInsets.only(bottom: 10),
                          decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
                          child: const Icon(Icons.bedtime_rounded, color: Color(0xFFD4AF37)),
                        ),
                        _buildSectionTitle(Icons.nights_stay_rounded, 'Sleep', alignment: MainAxisAlignment.center),
                        RichText(
                          text: TextSpan(
                            text: '6.5',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textMain),
                            children: [TextSpan(text: 'h', style: TextStyle(fontSize: 12, color: textMuted))],
                          ),
                        ),
                      ],
                    ),
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44, height: 44, margin: const EdgeInsets.only(bottom: 10),
                          decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
                          child: Icon(Icons.bolt_rounded, color: primaryColor),
                        ),
                        _buildSectionTitle(Icons.flash_on_rounded, 'Energy', alignment: MainAxisAlignment.center),
                        Text('Moderate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primaryColor)),
                      ],
                    ),
                  )
                ),
              ],
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}