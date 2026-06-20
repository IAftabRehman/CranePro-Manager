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
  late final TabController _tabController;
  bool _isSaving = false;

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

  void _saveChanges(
    BuildContext sheetContext,
    UserModel user,
    String currentRole,
    bool isApproved,
    bool isBlocked,
    TextEditingController reasonController,
  ) async {
    setState(() => _isSaving = true);
    Navigator.pop(sheetContext);
    
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showEditUserSheet(UserModel user) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    if (isWide) {
      showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 480,
            decoration: BoxDecoration(
              color: AppTheme.deepNavyBlue,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: _EditUserSheetContent(
              user: user,
              isSaving: _isSaving,
              onSave: (role, approved, blocked, rejectionReason) {
                final reasonController = TextEditingController(text: rejectionReason);
                _saveChanges(
                  dialogContext,
                  user,
                  role,
                  approved,
                  blocked,
                  reasonController,
                );
              },
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.deepNavyBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _EditUserSheetContent(
            user: user,
            isSaving: _isSaving,
            onSave: (role, approved, blocked, rejectionReason) {
              final reasonController = TextEditingController(text: rejectionReason);
              _saveChanges(
                sheetContext,
                user,
                role,
                approved,
                blocked,
                reasonController,
              );
            },
          ),
        ),
      );
    }
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
                isScrollable: true,
                tabAlignment: TabAlignment.center,
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
                      _UserList(
                        users: users.where((u) => !u.isAdminApproved).toList(),
                        onEdit: _showEditUserSheet,
                      ),
                      _UserList(
                        users: users.where((u) => u.isAdminApproved).toList(),
                        onEdit: _showEditUserSheet,
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
                ),
                error: (err, stack) => Center(
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
}

// Extracted UserList to prevent entire screen updates on state toggles
class _UserList extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;

  const _UserList({required this.users, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found in this category.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        if (isWide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GridView.builder(
                padding: const EdgeInsets.all(32),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 2.5,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return UserCard(user: users[index], onEdit: onEdit);
                },
              ),
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return UserCard(user: users[index], onEdit: onEdit);
            },
          );
        }
      }
    );
  }
}

// Extracted UserCard component with const constructor
class UserCard extends StatelessWidget {
  final UserModel user;
  final Function(UserModel) onEdit;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = user.createdAt != null 
        ? DateFormat('MMM dd, yyyy').format(user.createdAt!) 
        : 'Unknown';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white24),
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
            StatusChip(isApproved: user.isAdminApproved),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.settings_suggest_rounded, color: Colors.amber),
          onPressed: () => onEdit(user),
        ),
      ),
    );
  }
}

// Extracted StatusChip component with const constructor
class StatusChip extends StatelessWidget {
  final bool isApproved;

  const StatusChip({super.key, required this.isApproved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved 
            ? const Color(0x334CAF50) 
            : const Color(0x33FFC107),
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

// Extracted DetailRow component with const constructor
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _EditUserSheetContent extends StatefulWidget {
  final UserModel user;
  final bool isSaving;
  final Function(
    String currentRole,
    bool isApproved,
    bool isBlocked,
    String rejectionReason,
  ) onSave;

  const _EditUserSheetContent({
    required this.user,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<_EditUserSheetContent> createState() => _EditUserSheetContentState();
}

class _EditUserSheetContentState extends State<_EditUserSheetContent> {
  late String _currentRole;
  late bool _isApproved;
  late bool _isBlocked;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.user.role;
    _isApproved = widget.user.isAdminApproved;
    _isBlocked = widget.user.isBlocked;
    _reasonController = TextEditingController(text: widget.user.rejectionReason ?? '');
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            DetailRow(icon: Icons.person, label: 'Full Name', value: widget.user.fullName),
            DetailRow(icon: Icons.email, label: 'Email', value: widget.user.email),
            DetailRow(icon: Icons.phone, label: 'Phone', value: widget.user.phoneNumber ?? 'Not provided'),
            const Divider(color: Colors.white24, height: 32),
            
            const Text(
              'ASSIGN ROLE',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _currentRole,
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
              onChanged: (val) {
                if (val != null) {
                  setState(() => _currentRole = val);
                }
              },
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
                  value: _isApproved,
                  activeThumbColor: Colors.green,
                  onChanged: (val) => setState(() => _isApproved = val),
                ),
              ],
            ),
            
            if (!_isApproved) ...[
              const SizedBox(height: 16),
              const Text(
                'REJECTION REASON (OPTIONAL)',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0x0DFFFFFF),
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
                  value: _isBlocked,
                  activeThumbColor: Colors.redAccent,
                  onChanged: (val) => setState(() => _isBlocked = val),
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
                onPressed: widget.isSaving
                    ? null
                    : () {
                        widget.onSave(
                          _currentRole,
                          _isApproved,
                          _isBlocked,
                          _reasonController.text.trim(),
                        );
                      },
                child: widget.isSaving 
                  ? const CircularProgressIndicator(color: AppTheme.deepNavyBlue)
                  : const Text(
                      'SAVE ALL CHANGES',
                      style: TextStyle(color: AppTheme.deepNavyBlue, fontWeight: FontWeight.w900),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
