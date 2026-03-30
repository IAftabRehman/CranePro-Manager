import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/auth/data/models/user_model.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';

class AdminDirectoryView extends StatefulWidget {
  final List<UserModel> users;
  final Function(UserModel, bool) onToggleBlock;

  const AdminDirectoryView({
    super.key,
    required this.users,
    required this.onToggleBlock,
  });

  @override
  State<AdminDirectoryView> createState() => _AdminDirectoryViewState();
}

class _AdminDirectoryViewState extends State<AdminDirectoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _getFilteredUsers(UserRole role) {
    return widget.users.where((u) {
      final matchesRole = u.role == role.name;
      final matchesSearch =
          u.fullName.toLowerCase().contains(_searchQuery) ||
          u.email.toLowerCase().contains(_searchQuery);
      return matchesRole && matchesSearch && u.isAdminApproved;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Text(
              "Check History\nOf Any Operator or Viewer",
              style: TextStyle(
                color: Color(0xFFFFB300),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Operators'),
              Tab(text: 'Viewers'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUserList(UserRole.operator),
                _buildUserList(UserRole.viewer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(UserRole role) {
    final filteredUsers = _getFilteredUsers(role);

    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No ${role.name}s Found',
          style: TextStyle(
            color: AppTheme.deepNavyBlue.withValues(alpha: 0.5),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) =>
          _buildDirectoryTile(filteredUsers[index]),
    );
  }

  Widget _buildDirectoryTile(UserModel user) {
    return Dismissible(
      key: Key(user.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: user.isBlocked
              ? Colors.green.shade900
              : Colors.orange.shade900,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          user.isBlocked ? Icons.lock_open : Icons.block,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Confirm Deletion
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Delete User?',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Text(
                'Are you sure you want to permanently remove ${user.fullName}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          );
        } else {
          widget.onToggleBlock(user, !user.isBlocked);
          return false;
        }
      },
      child: GestureDetector(
        onTap: () => _showUserStats(user),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.deepNavyBlue.withValues(alpha: 0.1),
                child: Text(
                  user.fullName[0],
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: AppTheme.deepNavyBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: AppTheme.deepNavyBlue.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: user.isBlocked ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (user.isBlocked ? Colors.red : Colors.green)
                          .withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserStats(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 32),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.deepNavyBlue.withValues(alpha: 0.1),
                child: Text(
                  user.fullName[0],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.deepNavyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.deepNavyBlue,
                ),
              ),
              Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    user.role == UserRole.operator.name
                        ? 'TOTAL QUOTATIONS'
                        : 'LAST LOGIN',
                    user.role == UserRole.operator.name
                        ? '${user.totalQuotations}'
                        : (user.lastLogin != null
                              ? '${user.lastLogin!.day}/${user.lastLogin!.month}'
                              : 'N/A'),
                    Icons.trending_up,
                  ),
                  _buildStatItem(
                    'STATUS',
                    user.isBlocked ? 'SUSPENDED' : 'ACTIVE',
                    user.isBlocked ? Icons.block : Icons.check_circle,
                    isDestructive: user.isBlocked,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              CraneButton(
                text: 'Close Summary',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.deepNavyBlue,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDestructive ? Colors.red : AppTheme.deepNavyBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
