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

  bool _isSaving = false;

  void _showEditUserSheet(UserModel user) {
    String currentRole = user.role;
    bool isApproved = user.isAdminApproved;
    bool isBlocked = user.isBlocked;
    final reasonController = TextEditingController(text: user.rejectionReason ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.deepNavyBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EDIT USER ACCESS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.person, 'Full Name', user.fullName),
                _buildDetailRow(Icons.email, 'Email', user.email),
                _buildDetailRow(Icons.phone, 'Phone', user.phoneNumber ?? 'Not provided'),
                const Divider(color: Colors.white24, height: 32),
                
                const Text(
                  'ASSIGN ROLE',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: currentRole,
                  dropdownColor: AppTheme.deepNavyBlue,
                  isExpanded: true,
                  underline: Container(height: 2, color: Colors.amber),
                  items: ['operator', 'viewer'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => currentRole = val!),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ADMIN APPROVAL',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isApproved,
                      activeColor: Colors.green,
                      onChanged: (val) => setModalState(() => isApproved = val),
                    ),
                  ],
                ),
                
                if (!isApproved) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'REJECTION REASON (OPTIONAL)',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      hintText: 'Enter reason for rejection...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BLOCK ACCOUNT',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isBlocked,
                      activeColor: Colors.redAccent,
                      onChanged: (val) => setModalState(() => isBlocked = val),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : () async {
                      setState(() => _isSaving = true);
                      Navigator.pop(context);
                      
                      try {
                        // 1. Update general status and role
                        await ref.read(adminRepositoryProvider).updateUserStatus(
                          user.id, 
                          isApproved, 
                          currentRole,
                        );
                        
                        // 2. Update rejection reason if rejected
                        if (!isApproved && reasonController.text.isNotEmpty) {
                          await ref.read(adminRepositoryProvider).rejectUser(
                            user.id, 
                            reasonController.text.trim(),
                          );
                        }

                        // 3. Update block status
                        await ref.read(adminRepositoryProvider).toggleBlockUser(
                          user.id, 
                          isBlocked,
                        );
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User profile updated successfully!'),
                              backgroundColor: AppTheme.deepNavyBlue,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error updating user: $e')),
                          );
                        }
                      } finally {
                        setState(() => _isSaving = false);
                      }
                    },
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: AppTheme.deepNavyBlue)
                      : const Text(
                          'SAVE ALL CHANGES',
                          style: TextStyle(color: AppTheme.deepNavyBlue, fontWeight: FontWeight.w900),
                        ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);

    return RoleGuard(
      allowedRoles: const ['admin'],
      child: Stack(
        children: [
          Scaffold(
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
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            ),
        ],
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
        side: BorderSide(color: Colors.white),
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
          onPressed: () => _showEditUserSheet(user),
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
