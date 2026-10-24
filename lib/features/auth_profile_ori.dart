import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProfileScreen extends StatefulWidget {
  const AuthProfileScreen({super.key});

  @override
  State<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends State<AuthProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _waterGoalController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;
  User? _currentUser;
  String _selectedCategory = 'Student';

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _waterGoalController.text = (data['waterGoal'] ?? '2.5').toString();
          _selectedCategory = data['userCategory'] ?? 'Student';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isLoginMode) {
        UserCredential creds = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() => _currentUser = creds.user);
        await _loadUserProfile();
      } else {
        UserCredential creds = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() => _currentUser = creds.user);
        
        await _firestore.collection('users').doc(creds.user!.uid).set({
          'email': creds.user!.email,
          'userCategory': _selectedCategory,
          'waterGoal': double.tryParse(_waterGoalController.text) ?? 2.5,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Authentication Failed')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'userCategory': _selectedCategory,
        'waterGoal': double.tryParse(_waterGoalController.text) ?? 2.5,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally { // Fixed: Changed 'send' to 'finally'
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Fixed: Removed the incorrect 'appTheme' assignment
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _currentUser == null ? _buildAuthForm() : _buildProfileDashboard(),
            ),
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.account_circle, size: 80, color: Colors.teal),
          const SizedBox(height: 10),
          Text(
            _isLoginMode ? 'Welcome to Mizan' : 'Create Account',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            validator: (val) => val != null && val.contains('@') ? null : 'Provide a valid email address.',
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters.',
          ),
          if (!_isLoginMode) ...[
            const SizedBox(height: 15),
            TextFormField(
              controller: _waterGoalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Daily Water Goal (Liters)', border: OutlineInputBorder()),
              validator: (val) => double.tryParse(val ?? '') != null ? null : 'Enter a valid target decimal value.',
            ),
          ],
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: _handleSubmit,
            child: Text(_isLoginMode ? 'Login' : 'Register Account', style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
          TextButton(
            onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
            child: Text(_isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('User Assistance Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
        const Divider(thickness: 1.5),
        const SizedBox(height: 15),
        Text('Logged in as: ${_currentUser!.email}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 25),
        const Text('User Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: ['Student', 'Working Adult', 'Elderly'].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val ?? 'Student'),
        ),
        const SizedBox(height: 20),
        const Text('Adjust Daily Health Metric Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _waterGoalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Target Water Intake (L)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: _updateProfile,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Save Changes', style: TextStyle(color: Colors.white)), // Fixed: StringText changed to Text
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () async {
                  await _auth.signOut();
                  setState(() {
                    _currentUser = null;
                    _emailController.clear();
                    _passwordController.clear();
                  });
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}