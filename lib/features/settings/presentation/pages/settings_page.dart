import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import '../providers/business_profile_provider.dart';
import '../../data/models/business_profile.dart';

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
    if (widget.isViewer) return;
    
    final currentProfile = ref.read(businessProfileProvider);
    ref.read(businessProfileProvider.notifier).updateProfile(currentProfile.copyWith(
          businessName: _nameController.text,
          email: _emailController.text,
          website: _websiteController.text,
          address: _addressController.text,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business Profile Updated!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(businessProfileProvider);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Business Identity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!widget.isViewer)
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.amber),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scale(context, 24).clamp(16.0, 32.0),
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Business Card Header
              _buildBusinessCard(theme, profile),
              const SizedBox(height: 32),

              // Editable Fields (Admin Only) or View Only (Viewer)
              _buildSectionHeader('Official Details', theme),
              const SizedBox(height: 12),
              _buildEditableField('Business Name', _nameController, Icons.business_rounded),
              _buildEditableField('Email Address', _emailController, Icons.email_outlined),
              _buildEditableField('Official Website', _websiteController, Icons.language_rounded),
              _buildEditableField('Office Address', _addressController, Icons.location_on_outlined, maxLines: 2),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Branding Assets', theme),
              const SizedBox(height: 12),
              _buildLogoUploadSection(theme, profile),
              
              const SizedBox(height: 48),
              if (!widget.isViewer)
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                  ),
                  child: const Text('SAVE IDENTITY CARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessCard(ThemeData theme, BusinessProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.amber.withOpacity(0.1),
            child: const Icon(Icons.account_balance_rounded, size: 50, color: Colors.amber),
          ),
          const SizedBox(height: 16),
          Text(
            profile.businessName,
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 22, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Primary Business Profile',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCardStat(Icons.verified_user_rounded, 'Verified'),
              _buildCardStat(Icons.security_rounded, 'Encrypted'),
              _buildCardStat(Icons.cloud_upload_rounded, 'Synced'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          CraneInput(
            controller: controller,
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, color: Colors.amber.withOpacity(0.7), size: 20),
            maxLines: maxLines,
            readOnly: widget.isViewer,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoUploadSection(ThemeData theme, BusinessProfile profile) {
    return InkWell(
      onTap: widget.isViewer ? null : () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo upload coming soon!')));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image_search_rounded, color: Colors.white38),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Business Logo (High Res)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    widget.isViewer ? 'Logo management restricted' : 'Tap to upload PNG/JPG for PDF headers',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!widget.isViewer)
              const Icon(Icons.cloud_upload_rounded, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white),
    );
  }
}
