import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/login_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  int? _selectedRoleIndex;

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Operator / Owner',
      'subtitle': 'Full Access to manage quotes and operations.',
      'icon': Icons.admin_panel_settings,
    },
    {
      'title': 'Viewer / Client',
      'subtitle': 'Read Only access to view quotes and status.',
      'icon': Icons.visibility,
    },
    {
      'title': 'Admin Role',
      'subtitle': 'Management of users and overall system config.',
      'icon': Icons.manage_accounts,
    },
  ];

  void _navigateToLogin() {
    if (_selectedRoleIndex == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          roleTitle: _roles[_selectedRoleIndex!]['title'],
        ),
      ),
    );
  }

  Widget _buildRoleCard(int index, Map<String, dynamic> role) {
    final isSelected = _selectedRoleIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRoleIndex = index;
        });
        // Feedback delay
        Future.delayed(const Duration(milliseconds: 300), _navigateToLogin);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.tertiary.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              role['icon'],
              size: Responsive.scale(context, 32).clamp(24.0, 48.0),
              color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              role['title'],
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: Responsive.scale(context, 18).clamp(16.0, 24.0),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role['subtitle'],
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: Responsive.scale(context, 12).clamp(11.0, 16.0),
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scale(context, 24).clamp(16.0, 48.0),
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome to CranePro',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: Responsive.scale(context, 28).clamp(24.0, 40.0),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.screenHeight(context) * 0.02),
                  Text(
                    'Please select your role to continue onboarding.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.screenHeight(context) * 0.05),
                  if (isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _roles.asMap().entries.map((entry) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: entry.key != _roles.length - 1 ? 16.0 : 0.0,
                            ),
                            child: _buildRoleCard(entry.key, entry.value),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Column(
                      children: _roles.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildRoleCard(entry.key, entry.value),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
