import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(theme, context),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
                      vertical: 24,
                    ),
                    child: isTablet 
                      ? _buildTabletLayout(theme)
                      : _buildMobileLayout(theme),
                  ),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: TextButton.icon(
                      onPressed: () {
                        // Logout logic
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'Logout Account',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, BuildContext context) {
    final avatarSize = Responsive.scale(context, 80).clamp(60.0, 100.0);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: avatarSize * 0.6, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Aftab Ur Rehman',
            style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 20),
          ),
          Text(
            'Al-Fajr Crane Services',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Account Settings', theme),
        _buildGroup([
          _buildItem(Icons.person_outline, 'Edit Profile', theme),
          _buildItem(Icons.business_outlined, 'Business Details', theme),
          _buildItem(Icons.receipt_long_outlined, 'Tax Information', theme),
          _buildLogoUpload(theme),
        ]),
        const SizedBox(height: 32),
        _buildSectionHeader('App Preferences', theme),
        _buildGroup([
          SwitchListTile(
            value: _isDarkMode,
            onChanged: (v) => setState(() => _isDarkMode = v),
            title: Text('Dark Mode', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
            secondary: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.secondary),
            activeColor: theme.colorScheme.secondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          SwitchListTile(
            value: _notificationsOn,
            onChanged: (v) => setState(() => _notificationsOn = v),
            title: Text('Notifications', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
            secondary: Icon(Icons.notifications_outlined, color: theme.colorScheme.secondary),
            activeColor: theme.colorScheme.secondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildItem(Icons.translate, 'Language (English)', theme),
        ]),
        const SizedBox(height: 32),
        _buildSectionHeader('Support & Legal', theme),
        _buildGroup([
          _buildItem(Icons.help_outline, 'Help Center', theme),
          _buildItem(Icons.description_outlined, 'Privacy Policy', theme),
          _buildItem(Icons.info_outline, 'App Version 1.0.0', theme, showChevron: false),
        ]),
      ],
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildSectionHeader('Account Settings', theme),
                  _buildGroup([
                    _buildItem(Icons.person_outline, 'Edit Profile', theme),
                    _buildItem(Icons.business_outlined, 'Business Details', theme),
                    _buildItem(Icons.receipt_long_outlined, 'Tax Information', theme),
                    _buildLogoUpload(theme),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                children: [
                  _buildSectionHeader('App Preferences', theme),
                  _buildGroup([
                    SwitchListTile(
                      value: _isDarkMode,
                      onChanged: (v) => setState(() => _isDarkMode = v),
                      title: Text('Dark Mode', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      secondary: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    SwitchListTile(
                      value: _notificationsOn,
                      onChanged: (v) => setState(() => _notificationsOn = v),
                      title: Text('Notifications', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      secondary: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    _buildItem(Icons.translate, 'Language (English)', theme),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Support & Legal', theme),
                  _buildGroup([
                    _buildItem(Icons.help_outline, 'Help Center', theme),
                    _buildItem(Icons.description_outlined, 'Privacy Policy', theme),
                    _buildItem(Icons.info_outline, 'App Version 1.0.0', theme, showChevron: false),
                  ]),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white60,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildItem(IconData icon, String title, ThemeData theme, {bool showChevron = true}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: theme.colorScheme.secondary),
          title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
          trailing: showChevron ? const Icon(Icons.chevron_right, size: 20, color: Colors.white38) : null,
          onTap: () {},
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        if (showChevron) Divider(height: 1, indent: 56, color: Colors.white.withValues(alpha: 0.05)),
      ],
    );
  }

  Widget _buildLogoUpload(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Business Logo (for PDF)', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
          const SizedBox(height: 12),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.secondary),
                const SizedBox(width: 12),
                Text('Upload Logo', style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
