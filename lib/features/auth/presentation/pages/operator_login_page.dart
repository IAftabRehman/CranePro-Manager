import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';

class OperatorLoginPage extends StatefulWidget {
  const OperatorLoginPage({super.key});

  @override
  State<OperatorLoginPage> createState() => _OperatorLoginPageState();
}

class _OperatorLoginPageState extends State<OperatorLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      bool authenticated = false;
      String role = 'operator';
      String fullName = '';
      String docId = '';
      bool isBlocked = false;

      // 1. Fetch user from Firestore by ID (username)
      var doc = await firestore.collection('users').doc(username).get();
      if (!doc.exists) {
        // 2. Query by userName
        final queryUserName = await firestore
            .collection('users')
            .where('userName', isEqualTo: username)
            .limit(1)
            .get();
        if (queryUserName.docs.isNotEmpty) {
          doc = queryUserName.docs.first;
        }
      }
      if (!doc.exists) {
        // 3. Fallback: Query by email
        final queryEmail = await firestore
            .collection('users')
            .where('email', isEqualTo: username)
            .limit(1)
            .get();
        if (queryEmail.docs.isNotEmpty) {
          doc = queryEmail.docs.first;
        }
      }
      if (!doc.exists) {
        // 4. Fallback: Query by fullName
        final queryName = await firestore
            .collection('users')
            .where('fullName', isEqualTo: username)
            .limit(1)
            .get();
        if (queryName.docs.isNotEmpty) {
          doc = queryName.docs.first;
        }
      }

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final dbPassword = data['password']?.toString() ?? '';
        if (dbPassword == password) {
          authenticated = true;
          role = data['role']?.toString() ?? 'operator';
          fullName = data['fullName']?.toString() ?? username;
          docId = doc.id;
          isBlocked =
              (data['isBlocked'] == true || data['userStatus'] == 'blocked');
        }
      }

      // Check hardcoded developer fallback if not authenticated via Firestore
      if (!authenticated && username == 'admin' && password == 'admin123') {
        authenticated = true;
        role = 'admin';
        fullName = 'Admin (Local)';
        docId = 'admin';
        isBlocked = false;
      }

      if (authenticated) {
        if (isBlocked) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This account is blocked by the administrator.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', role);
        await prefs.setString('operator_name', fullName);
        await prefs.setString('operator_id', docId);
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('login_password', password);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainDashboard()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid username or password'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  size: Responsive.scale(context, 80),
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Operator Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to manage operations',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: Colors.blueAccent),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.blueAccent),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.blueAccent,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
