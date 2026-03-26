import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';

class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});

  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Gallery'),
        centerTitle: true,
      ),
      // Use SingleChildScrollView to prevent overflow
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scale(context, 24).clamp(16.0, 48.0),
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Responsive UI Components',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: Responsive.scale(context, 24).clamp(20.0, 36.0),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Active Device: ${Responsive.isMobile(context) ? "Mobile" : "Tablet/Desktop"}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Test Flexible and Expanded inside a Row
              Row(
                children: [
                  Expanded(
                    child: CraneInput(
                      controller: _firstNameController,
                      hintText: 'First Name',
                    ),
                  ),
                  SizedBox(width: Responsive.scale(context, 16)),
                  Flexible(
                    child: CraneInput(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CraneInput(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              CraneInput(
                controller: _passwordController,
                hintText: 'Enter your password',
                obscureText: true,
              ),
              const SizedBox(height: 48),

              Center(
                child: CraneButton(
                  text: 'Simulate Login Action',
                  isLoading: _isLoading,
                  onPressed: _simulateLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
