import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import '../providers/business_profile_provider.dart';
import '../../data/models/business_profile.dart';
import 'dart:ui';

class SettingsPage extends ConsumerStatefulWidget {
  final bool isViewer;

  const SettingsPage({super.key, this.isViewer = false});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(businessProfileProvider);
    _nameController = TextEditingController(
      text: widget.isViewer ? 'Bahadar Transport and Crane Services' : profile.businessName
    );
    _emailController = TextEditingController(
      text: widget.isViewer ? 'official@bahadartransport.ae' : profile.email
    );
    _websiteController = TextEditingController(
      text: widget.isViewer ? 'www.bahadartransport.ae' : profile.website
    );
    _addressController = TextEditingController(
      text: widget.isViewer ? 'Dubai Industrial City, Dubai, UAE' : profile.address
    );
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
    if (widget.isViewer) return;

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
    final theme = Theme.of(context);
    final profile = ref.watch(businessProfileProvider);

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
              _buildAppBar(context),
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
                      _buildBusinessCard(theme, profile),
                      const SizedBox(height: 15),
                      _buildReadOnlyField('Business Name', _nameController, Icons.business_rounded),
                      _buildReadOnlyField('Email Address', _emailController, Icons.email_outlined),
                      _buildReadOnlyField('Official Website', _websiteController, Icons.language_rounded),
                      _buildReadOnlyField('Office Address', _addressController, Icons.location_on_outlined, maxLines: 2),
                      const SizedBox(height: 15),

                      const SizedBox(height: 12),

                      if (!widget.isViewer)
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
                            style: TextStyle(fontWeight: FontWeight.w900,),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.deepNavyBlue, size: 15,),
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

  Widget _buildBusinessCard(ThemeData theme, BusinessProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 20),
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
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.isViewer ? 'Bahadar Transport & Crane Services' : profile.businessName,
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

  Widget _buildReadOnlyField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryNavy.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  controller.text,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
