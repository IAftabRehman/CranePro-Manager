import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';

class AdminControlPage extends StatefulWidget {
  const AdminControlPage({super.key});

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Dummy data
  final List<Map<String, dynamic>> _users = [
    {'name': 'Aftab Rehman', 'company': 'CranePro Admin', 'role': 'Admin', 'status': 'Active'},
    {'name': 'John Doe', 'company': 'Al-Fajr Cranes', 'role': 'Operator / Owner', 'status': 'Active'},
    {'name': 'Jane Smith', 'company': 'Emaar Sites', 'role': 'Viewer / Client', 'status': 'Active'},
    {'name': 'Ali Khan', 'company': 'Binladin Group', 'role': 'Operator / Owner', 'status': 'Deactivated'},
  ];

  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(_users);
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user['name'].toString().toLowerCase().contains(query) ||
               user['company'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showRoleUpdateSheet(BuildContext context, Map<String, dynamic> user) {
    String selectedRole = user['role'];
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: Responsive.scale(context, 24).clamp(16.0, 32.0),
            right: Responsive.scale(context, 24).clamp(16.0, 32.0),
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Manage User: ${user['name']}',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: ['Admin', 'Operator / Owner', 'Viewer / Client']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
              ),
              const SizedBox(height: 32),
              CraneButton(
                text: 'Update Role',
                onPressed: () {
                  setState(() {
                    user['role'] = selectedRole;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    user['status'] = 'Deactivated';
                  });
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Deactivate User', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, ThemeData theme) {
    Color roleColor;
    switch (user['role']) {
      case 'Admin':
        roleColor = theme.colorScheme.secondary;
        break;
      case 'Viewer / Client':
        roleColor = Colors.green;
        break;
      default:
        roleColor = theme.colorScheme.primary;
    }

    final avatarSize = (Responsive.screenWidth(context) * 0.1).clamp(40.0, 70.0);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.scale(context, 16).clamp(16.0, 24.0),
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: roleColor.withValues(alpha: 0.1),
          child: Text(
            user['name'][0],
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.bold,
              fontSize: avatarSize * 0.4,
            ),
          ),
        ),
        title: Text(
          user['name'],
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: Responsive.scale(context, 16).clamp(14.0, 18.0),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user['company'], style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user['status'] == 'Deactivated' 
                    ? theme.colorScheme.tertiary.withValues(alpha: 0.1) 
                    : roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['status'] == 'Deactivated' ? 'Deactivated' : user['role'],
                style: TextStyle(
                  color: user['status'] == 'Deactivated' ? theme.colorScheme.tertiary : roleColor,
                  fontSize: Responsive.scale(context, 10).clamp(10.0, 12.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.settings, color: theme.colorScheme.primary),
          onPressed: () => _showRoleUpdateSheet(context, user),
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 700;
            final crossAxisCount = constraints.maxWidth > 1000 ? 3 : 2;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  elevation: 2,
                  backgroundColor: theme.colorScheme.surface,
                  title: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: CraneInput(
                        controller: _searchController,
                        hintText: 'Search Users...',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(16),
                    child: Container(),
                  ),
                ),
                if (_filteredUsers.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80, color: theme.colorScheme.tertiary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: Responsive.padding(context, horizontal: 16, vertical: 16).clamp(
                      const EdgeInsets.all(16.0),
                      const EdgeInsets.all(24.0),
                    ),
                    sliver: isTablet
                        ? SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.5, // Keep cards somewhat horizontal like tiles
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildUserCard(_filteredUsers[index], theme),
                              childCount: _filteredUsers.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildUserCard(_filteredUsers[index], theme),
                              childCount: _filteredUsers.length,
                            ),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    ));
  }
}
