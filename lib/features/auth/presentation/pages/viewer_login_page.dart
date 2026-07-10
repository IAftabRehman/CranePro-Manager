import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';

class ViewerLoginPage extends StatefulWidget {
  const ViewerLoginPage({super.key});

  @override
  State<ViewerLoginPage> createState() => _ViewerLoginPageState();
}

class _ViewerLoginPageState extends State<ViewerLoginPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      // 1. Fetch user from Firestore by ID (name)
      var doc = await firestore.collection('users').doc(name).get();
      if (!doc.exists) {
        // 2. Query by fullName
        final queryName = await firestore.collection('users').where('fullName', isEqualTo: name).limit(1).get();
        if (queryName.docs.isNotEmpty) {
          doc = queryName.docs.first;
        }
      }
      if (!doc.exists) {
        // 3. Query by userName
        final queryUser = await firestore.collection('users').where('userName', isEqualTo: name).limit(1).get();
        if (queryUser.docs.isNotEmpty) {
          doc = queryUser.docs.first;
        }
      }

      if (doc.exists) {
        final data = doc.data();
        final status = data?['userStatus'] ?? 'active';
        if (status == 'blocked') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This viewer is blocked by the administrator.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }
      } else {
        await firestore.collection('users').doc(name).set({
          'id': name,
          'fullName': name,
          'role': 'viewer',
          'userStatus': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'viewer');
      await prefs.setString('viewer_name', doc.exists ? doc.id : name);
      await prefs.setBool('is_logged_in', true);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainDashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving session: $e')),
        );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.visibility_rounded,
                size: Responsive.scale(context, 80),
                color: Colors.tealAccent.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'Viewer Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your name to access the dashboard',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: TextStyle(color: Colors.tealAccent.shade400),
                  prefixIcon: Icon(Icons.person, color: Colors.tealAccent.shade400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.tealAccent.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade400,
                  foregroundColor: Colors.black,
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
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continue to Dashboard',
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
    );
  }
}
