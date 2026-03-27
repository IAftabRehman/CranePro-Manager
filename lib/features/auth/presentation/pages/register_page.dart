import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedCapacity;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final List<String> _capacities = ['50 Ton', '100 Ton', '150 Ton', '200+ Ton'];

  @override
  void dispose() {
    _businessNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return;
    }
    if (_selectedCapacity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Primary Crane Capacity')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PremiumScaffold(
        appBar: AppBar(
          title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Business Identity', Icons.business_center, theme),
                      
                      CraneInput(
                        controller: _businessNameController,
                        hintText: 'Business Name (e.g. Al-Fajr Cranes)',
                        suffixIcon: const Icon(Icons.apartment),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      CraneInput(
                        controller: _fullNameController,
                        hintText: 'Full Name',
                        suffixIcon: const Icon(Icons.person),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader('Fleet Specifications', Icons.precision_manufacturing, theme),
                      
                      Text(
                        'Primary Crane Capacity',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _capacities.map((cap) => ChoiceChip(
                          label: Text(cap, style: TextStyle(fontWeight: FontWeight.bold, color: _selectedCapacity == cap ? theme.colorScheme.primary : Colors.white)),
                          selected: _selectedCapacity == cap,
                          onSelected: (val) {
                            if(val) setState(() => _selectedCapacity = cap);
                          },
                          selectedColor: theme.colorScheme.secondary,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          checkmarkColor: theme.colorScheme.primary,
                          side: BorderSide(color: _selectedCapacity == cap ? theme.colorScheme.secondary : Colors.white.withValues(alpha: 0.1)),
                        )).toList(),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader('Account Credentials', Icons.lock_person, theme),
                      
                      CraneInput(
                        controller: _emailController,
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: const Icon(Icons.email),
                        validator: (val) => val == null || !val.contains('@') ? 'Invalid Email' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      CraneInput(
                        controller: _passwordController,
                        hintText: 'Password (min 6 chars)',
                        obscureText: true,
                        suffixIcon: const Icon(Icons.lock),
                        validator: (val) => val == null || val.length < 6 ? 'Too short' : null,
                      ),

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            activeColor: theme.colorScheme.secondary,
                            checkColor: theme.colorScheme.primary,
                            side: const BorderSide(color: Colors.white70),
                            onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the Terms & Conditions and Privacy Policy of CranePro.',
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      CraneButton(
                        text: 'Create Business Account',
                        onPressed: _handleRegister,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Already have an account? Login',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
