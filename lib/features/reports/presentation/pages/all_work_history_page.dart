import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/quotation/data/repositories/quotation_repository.dart';
import 'package:extend_crane_services/features/work_order/data/repositories/work_repository.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';


class UnifiedHistoryItem {
  final String id;
  final String type; // 'Quotation' or 'Direct Work'
  final DateTime date;
  final String clientName;
  final String location;
  final String duration;
  final double price;
  final double netProfit;
  final String status;
  final dynamic originalData;

  UnifiedHistoryItem({
    required this.id,
    required this.type,
    required this.date,
    required this.clientName,
    required this.location,
    required this.duration,
    required this.price,
    required this.netProfit,
    required this.status,
    required this.originalData,
  });
}

class AllWorkHistoryPage extends ConsumerWidget {
  final bool isPendingScreen;
  const AllWorkHistoryPage({super.key, this.isPendingScreen = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(allQuotationsProvider);
    final workOrdersAsync = ref.watch(allWorkOrdersProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.lavenderBlueGradient,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isPendingScreen ? 'Pending Tasks' : 'Work History',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: quotationsAsync.when(
                  data: (quotations) => workOrdersAsync.when(
                    data: (workOrders) {
                      final List<UnifiedHistoryItem> allItems = [];

                      // Add Quotations
                      for (var q in quotations) {
                        final status = q.status.toLowerCase();
                        final isCompleted = status == 'completed' || status == 'cancelled';
                        if (isPendingScreen && isCompleted) continue;
                        if (!isPendingScreen && !isCompleted) continue;

                        String duration = 'N/A';
                        if (q.entries.isNotEmpty && q.entries.first.duration.isNotEmpty) {
                          duration = q.entries.first.duration;
                        }
                        
                        String location = q.siteLocation;
                        if (location.isEmpty && q.entries.isNotEmpty) {
                          location = q.entries.first.location;
                        }
                        if (location.isEmpty) location = 'N/A';

                        allItems.add(UnifiedHistoryItem(
                          id: q.id,
                          type: 'Quotation',
                          date: q.workDate,
                          clientName: q.clientName.isEmpty ? 'Unknown Client' : q.clientName,
                          location: location,
                          duration: duration,
                          price: q.totalAmount,
                          netProfit: q.totalAmount - q.commission,
                          status: q.status,
                          originalData: q,
                        ));
                      }

                      // Add Work Orders
                      for (var w in workOrders) {
                        final status = w.status.toLowerCase();
                        final isCompleted = status == 'completed' || status == 'cancelled';
                        if (isPendingScreen && isCompleted) continue;
                        if (!isPendingScreen && !isCompleted) continue;

                        allItems.add(UnifiedHistoryItem(
                          id: w.id,
                          type: 'Direct Work',
                          date: w.createdAt,
                          clientName: w.clientName.isEmpty ? 'Unknown Client' : w.clientName,
                          location: w.siteLocation.isEmpty ? 'N/A' : w.siteLocation,
                          duration: 'Instant Work', // Direct work doesn't store duration
                          price: w.totalPrice,
                          netProfit: w.netEarnings > 0 ? w.netEarnings : (w.totalPrice - w.expenseAmount),
                          status: w.status,
                          originalData: w,
                        ));
                      }

                      // Sort by date descending
                      allItems.sort((a, b) => b.date.compareTo(a.date));

                      if (allItems.isEmpty) {
                        return const Center(
                          child: Text(
                            'No work history found.',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final item = allItems[index];
                          if (isPendingScreen) {
                            return _buildPendingTaskCard(context, ref, item);
                          }

                          final isQuotation = item.type == 'Quotation';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0x33FFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0x66FFFFFF)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isQuotation ? Colors.blue.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isQuotation ? Colors.blue.shade200 : Colors.orange.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          item.type,
                                          style: TextStyle(
                                            color: isQuotation ? Colors.blue.shade100 : Colors.orange.shade100,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (isPendingScreen) ...[
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (item.type == 'Quotation') {
                                                  await ref.read(quotationRepositoryProvider).updateQuotationStatus(item.id, 'completed');
                                                } else {
                                                  await ref.read(workRepositoryProvider).updateWorkOrderStatus(item.id, 'completed');
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green.shade700,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                minimumSize: const Size(0, 28),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              child: const Text('Complete', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (item.type == 'Quotation') {
                                                  await ref.read(quotationRepositoryProvider).updateQuotationStatus(item.id, 'cancelled');
                                                } else {
                                                  await ref.read(workRepositoryProvider).updateWorkOrderStatus(item.id, 'cancelled');
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red.shade700,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                minimumSize: const Size(0, 28),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                          ] else ...[
                                            Text(
                                              item.status.toUpperCase(),
                                              style: TextStyle(
                                                color: item.status == 'completed' ? Colors.greenAccent : Colors.white70,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                _showDeleteDialog(context, ref, item);
                                              },
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  
                                  // Title Row
                                  Text(
                                    item.clientName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Details Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.location,
                                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.access_time, color: Colors.white70, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.duration,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, yyyy  hh:mm a').format(item.date),
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(color: Colors.white24, height: 1),
                                  ),
                                  
                                  // Pricing Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Total Value',
                                            style: TextStyle(color: Colors.white60, fontSize: 12),
                                          ),
                                          Text(
                                            'AED ${item.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            isQuotation ? 'Net Value' : 'Net Earnings',
                                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                                          ),
                                          Text(
                                            'AED ${item.netProfit.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                    error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                  error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingTaskCard(BuildContext context, WidgetRef ref, UnifiedHistoryItem item) {
    final isQuotation = item.type == 'Quotation';
    final badgeText = isQuotation ? 'QUOTATION' : 'WORK_ORDER';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2B304A), // Dark blue background similar to screenshot
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    isQuotation ? 'Quotation for\n${item.clientName}' : 'Direct Work for\n${item.clientName}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    if (item.type == 'Quotation') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddQuotationPage(initialData: item.originalData)));
                    } else {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => DirectWorkModal(initialData: item.originalData),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.lightBlueAccent, size: 14),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(item.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.lightBlueAccent, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white24, height: 1),
            ),
            Center(
              child: Text(
                'AED ${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (item.type == 'Quotation') {
                        await ref.read(quotationRepositoryProvider).updateQuotationStatus(item.id, 'cancelled');
                      } else {
                        await ref.read(workRepositoryProvider).updateWorkOrderStatus(item.id, 'cancelled');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935), // Red
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (item.type == 'Quotation') {
                        await ref.read(quotationRepositoryProvider).updateQuotationStatus(item.id, 'completed');
                      } else {
                        await ref.read(workRepositoryProvider).updateWorkOrderStatus(item.id, 'completed');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Complete Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, UnifiedHistoryItem item) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Delete Work', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this? Your amount will be deducted from your earnings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    if (!context.mounted) return;
    
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    try {
      if (item.type == 'Quotation') {
        await ref.read(quotationRepositoryProvider).deleteQuotation(item.id);
      } else {
        await ref.read(workRepositoryProvider).deleteWorkOrder(item.id);
      }
      
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }
}
