import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import '../providers/business_profile_provider.dart';
import 'dart:ui';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(businessProfileProvider);
    _nameController = TextEditingController(text: profile.businessName);
    _emailController = TextEditingController(text: profile.email);
    _websiteController = TextEditingController(text: profile.website);
    _addressController = TextEditingController(text: profile.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final currentProfile = ref.read(businessProfileProvider);
    ref
        .read(businessProfileProvider.notifier)
        .updateProfile(
          currentProfile.copyWith(
            businessName: _nameController.text,
            email: _emailController.text,
            website: _websiteController.text,
            address: _addressController.text,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Business Profile Updated!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only watch businessName specifically to prevent rebuilds on other profile field updates
    final businessName = ref.watch(
      businessProfileProvider.select((p) => p.businessName),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SettingsAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scale(context, 24).clamp(16.0, 32.0),
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Component Extraction: Extracted BusinessCard
                      BusinessCardWidget(
                        businessName: businessName,
                      ),
                      const SizedBox(height: 15),
                      // Component Extraction & Reusability: Extracted EditableFieldWidget
                      EditableFieldWidget(
                        label: 'Business Name',
                        controller: _nameController,
                        icon: Icons.business_rounded,
                      ),
                      EditableFieldWidget(
                        label: 'Email Address',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                      ),
                      EditableFieldWidget(
                        label: 'Official Website',
                        controller: _websiteController,
                        icon: Icons.language_rounded,
                      ),
                      EditableFieldWidget(
                        label: 'Office Address',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 15),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepNavyBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(fontWeight: FontWeight.w900),
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
    );
  }
}

// Extracted Settings App Bar component with const constructor
class SettingsAppBar extends StatelessWidget {
  const SettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.deepNavyBlue,
              size: 15,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Business Profile',
              style: TextStyle(
                color: AppTheme.deepNavyBlue,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// Extracted Business Card component with const constructor
class BusinessCardWidget extends StatelessWidget {
  final String businessName;

  const BusinessCardWidget({
    super.key,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x59FFFFFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0x80FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 20),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Image.asset(
                "assets/images/logo.png",
                height: 100,
                // Level 4 (Image/Memory): Limit decode size to 2× display
                // height to save GPU texture memory.
                cacheHeight: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            businessName,
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Extracted and highly reusable EditableField component with const constructor
class EditableFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  const EditableFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0x80FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border(
          top: BorderSide(color: Color(0x4DFFFFFF)),
          bottom: BorderSide(color: Color(0x4DFFFFFF)),
          left: BorderSide(color: Color(0x4DFFFFFF)),
          right: BorderSide(color: Color(0x4DFFFFFF)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xB20D1B3E), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0x800D1B3E),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    fillColor: Colors.white54,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
