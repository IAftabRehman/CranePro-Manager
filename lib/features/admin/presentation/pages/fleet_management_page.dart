import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../fleet/data/models/crane_model.dart';
import '../../../fleet/data/repositories/fleet_repository.dart';

class FleetManagementPage extends ConsumerStatefulWidget {
  const FleetManagementPage({super.key});

  @override
  ConsumerState<FleetManagementPage> createState() => _FleetManagementPageState();
}

class _FleetManagementPageState extends ConsumerState<FleetManagementPage> {
  @override
  Widget build(BuildContext context) {
    final cranesAsync = ref.watch(cranesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.lavenderBlueGradient,
          ),
        ),
      ),
      body: cranesAsync.when(
        data: (cranes) {
          if (cranes.isEmpty) {
            return const Center(
              child: Text('No cranes in the fleet yet. Add one below.'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: cranes.length,
            itemBuilder: (context, index) {
              final crane = cranes[index];
              return _CraneCard(crane: crane);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCraneDialog(context),
        label: const Text('Add Crane'),
        icon: const Icon(Icons.add_road),
        backgroundColor: AppTheme.lavenderPrimary,
      ),
    );
  }

  void _showAddCraneDialog(BuildContext context) {
    final numberController = TextEditingController();
    final modelController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Crane'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Crane Number (e.g. ABC-123)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model (e.g. Kato 50 Ton)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity (Tonnes)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (numberController.text.isEmpty ||
                  modelController.text.isEmpty ||
                  capacityController.text.isEmpty) {
                return;
              }

              final newCrane = CraneModel(
                id: '', // Firestore sets this
                craneNumber: numberController.text.trim(),
                model: modelController.text.trim(),
                capacity: double.tryParse(capacityController.text) ?? 10.0,
              );

              try {
                await ref.read(fleetRepositoryProvider).addCrane(newCrane);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crane added successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _CraneCard extends ConsumerWidget {
  final CraneModel crane;

  const _CraneCard({required this.crane});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color statusColor = crane.status == 'Active'
        ? Colors.green
        : (crane.status == 'Under Repair' ? Colors.orange : Colors.red);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.construction, color: AppTheme.lavenderPrimary),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    crane.status,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              crane.craneNumber,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              crane.model,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${crane.capacity} Tons',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showAssignmentSheet(context, ref),
                child: const Text('Manage', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CraneManagementSheet(crane: crane);
      },
    );
  }
}

class _CraneManagementSheet extends ConsumerWidget {
  final CraneModel crane;

  const _CraneManagementSheet({required this.crane});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operatorsAsync = ref.watch(approvedOperatorsProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Crane: ${crane.craneNumber}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Active', 'Under Repair', 'Out of Service'].map((status) {
              final isSelected = crane.status == status;
              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (val) {
                  if (val) {
                    ref.read(fleetRepositoryProvider).updateCrane(
                          crane.copyWith(status: status),
                        );
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Assign Operator:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          operatorsAsync.when(
            data: (operators) {
              return DropdownButtonFormField<String>(
                value: crane.assignedOperatorId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                hint: const Text('No Operator Assigned'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Clear Assignment'),
                  ),
                  ...operators.map((op) => DropdownMenuItem(
                        value: op.id,
                        child: Text(op.fullName),
                      )),
                ],
                onChanged: (val) async {
                  await ref.read(fleetRepositoryProvider).updateCrane(
                        crane.copyWith(assignedOperatorId: val),
                      );
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Error loading operators: $e'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
