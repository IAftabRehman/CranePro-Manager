import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/auth/presentation/widgets/role_guard.dart';
import 'package:extend_crane_services/features/auth/data/models/user_model.dart';
import '../controllers/admin_controller.dart';
import 'package:intl/intl.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);

    return RoleGuard(
      allowedRoles: const ['admin'],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.deepNavyBlue,
          title: const Text(
            'USER MANAGEMENT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'PENDING'),
              Tab(text: 'APPROVED'),
            ],
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.lavenderBlueGradient,
          ),
          child: usersAsync.when(
            data: (users) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList(users.where((u) => !u.isAdminApproved).toList()),
                  _buildUserList(users.where((u) => u.isAdminApproved).toList()),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
            ),
            error: (err, _) => Center(
              child: Text(
                'Error loading users: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found in this category.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final theme = Theme.of(context);
    final String formattedDate = user.createdAt != null 
        ? DateFormat('MMM dd, yyyy').format(user.createdAt!) 
        : 'Unknown';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.deepNavyBlue,
          child: Text(
            user.fullName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.role.toUpperCase()} • Joined: $formattedDate',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(user.isAdminApproved),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.settings_suggest_rounded, color: Colors.amber),
          onPressed: () {
            // Future: Show detailed user management modal
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isApproved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved 
            ? Colors.green.withOpacity(0.2) 
            : Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved ? Colors.green : Colors.amber,
          width: 1,
        ),
      ),
      child: Text(
        isApproved ? 'APPROVED' : 'PENDING',
        style: TextStyle(
          color: isApproved ? Colors.green : Colors.amber,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
