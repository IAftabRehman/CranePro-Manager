import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/auth/data/models/user_model.dart';

class AdminApprovalView extends StatefulWidget {
  final List<UserModel> users;
  final Function(UserModel) onApprove;
  final Function(UserModel) onReject;
  final Function(UserModel, bool) onToggleBlock;

  const AdminApprovalView({
    super.key,
    required this.users,
    required this.onApprove,
    required this.onReject,
    required this.onToggleBlock,
  });

  @override
  State<AdminApprovalView> createState() => _AdminApprovalViewState();
}

class _AdminApprovalViewState extends State<AdminApprovalView> {
  @override
  Widget build(BuildContext context) {
    final pendingUsers = widget.users.where((u) => !u.isAdminApproved).toList();

    if (pendingUsers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) => _buildUser3DCard(pendingUsers[index]),
    );
  }

  Widget _buildUser3DCard(UserModel user) {
    return AnimatedUserCard(
      user: user,
      onApprove: () => widget.onApprove(user),
      onReject: () => widget.onReject(user),
      onToggleBlock: (val) => widget.onToggleBlock(user, val),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, size: 80, color: AppTheme.deepNavyBlue.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'All Clear! No Pending Requests',
            style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class AnimatedUserCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final Function(bool) onToggleBlock;

  const AnimatedUserCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
    required this.onToggleBlock,
  });

  @override
  State<AnimatedUserCard> createState() => _AnimatedUserCardState();
}

class _AnimatedUserCardState extends State<AnimatedUserCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.user.isAdminApproved ? Colors.green : (widget.user.rejectionReason != null ? Colors.red : Colors.yellow);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 20),
                blurRadius: 40,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.deepNavyBlue.withValues(alpha: 0.1),
                          child: Text(
                            widget.user.fullName[0],
                            style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.fullName.toUpperCase(),
                                style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                widget.user.email,
                                style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.user.role.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SIGNUP DATE',
                              style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              widget.user.createdAt != null 
                                ? '${widget.user.createdAt!.day}/${widget.user.createdAt!.month}/${widget.user.createdAt!.year}'
                                : 'N/A',
                              style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        if (widget.user.rejectionReason != null)
                          Text(
                            'REJECTED',
                            style: TextStyle(color: Colors.red.shade900, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onReject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onApprove,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
