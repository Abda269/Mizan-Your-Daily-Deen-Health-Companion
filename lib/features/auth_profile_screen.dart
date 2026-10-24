import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui'; // Required for ImageFilter.blur

class AuthProfileScreen extends StatefulWidget {
  const AuthProfileScreen({super.key});

  @override
  State<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends State<AuthProfileScreen> {
  // CSS Palette from HTML Prototype
  final Color primaryColor = const Color(0xFF0F4C3A);
  final Color accentColor = const Color(0xFFD4AF37);
  final Color textMain = const Color(0xFF1C2833);
  final Color textMuted = const Color(0xFF7F8C8D);
  final Color inputBg = const Color(0xFFF8FAFC);
  final Color inputBorder = const Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _waterGoalController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;
  final String _selectedCategory = 'Student';

  @override
  void initState() {
    super.initState();
    _waterGoalController.text = '2.5';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'email': _emailController.text.trim(),
          'userCategory': _selectedCategory,
          'waterGoal': double.tryParse(_waterGoalController.text) ?? 2.5,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication Error'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Matches HTML --bg
      body: Stack(
        children: [
          // 1. Photographic Header Background (From HTML .header-bg)
          Positioned(
            top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1564507004663-b6dfb3c824d5?q=80&w=800&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0F4C3A).withOpacity(0.90), const Color(0xFF1A6B54).withOpacity(0.95)],
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                child: Column(
                  children: [
                    // --- WELCOME GRAPHICS (From HTML #welcome) ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 25, offset: const Offset(0, 10))],
                          ),
                          child: Icon(Icons.mosque_rounded, size: 55, color: accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Mizan',
                      style: TextStyle(
                        fontFamily: 'Georgia', 
                        fontSize: 42, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 2, 
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Your Daily Deen & Health Companion',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 35),

                    // --- LOGIN CARD (From HTML #login .card) ---
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card Header
                            Container(
                              width: 60, height: 60,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                              child: Icon(Icons.mosque_rounded, size: 32, color: primaryColor),
                            ),
                            Text(
                              _isLoginMode ? 'Welcome Back' : 'Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryColor),
                            ),
                            Text(
                              _isLoginMode ? 'Sign in to your Deen & Health companion.' : 'Register for cloud sync',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: textMuted),
                            ),
                            const SizedBox(height: 25),
                            
                            // Exact HTML Input Styling
                            _buildInputLabel('Email'),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 14),
                              decoration: _buildInputDecoration('user@example.com'),
                              validator: (val) => val != null && val.contains('@') ? null : 'Provide a valid email address.',
                            ),
                            const SizedBox(height: 15),
                            
                            _buildInputLabel('Password'),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(fontSize: 14),
                              decoration: _buildInputDecoration('••••••••'),
                              validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters.',
                            ),
                            
                            if (!_isLoginMode) ...[
                              const SizedBox(height: 15),
                              _buildInputLabel('Daily Water Goal (Liters)'),
                              TextFormField(
                                controller: _waterGoalController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 14),
                                decoration: _buildInputDecoration('2.5'),
                                validator: (val) => double.tryParse(val ?? '') != null ? null : 'Enter a valid decimal value.',
                              ),
                            ],
                            const SizedBox(height: 25),
                            
                            // Submit Button
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor, 
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: _isLoading ? null : _handleSubmit,
                                child: _isLoading 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      _isLoginMode ? 'Sign In' : 'Register Account', 
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                                    ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Toggle Mode Button
                            TextButton(
                              onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                              child: Text(
                                _isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login",
                                style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable label to match HTML <p> tags
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text, 
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMain)
      ),
    );
  }

  // Reusable input decoration to match HTML inputs
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textMuted.withOpacity(0.5)),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: inputBorder, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: inputBorder, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
    );
  }
}