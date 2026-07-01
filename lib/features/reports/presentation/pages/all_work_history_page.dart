import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/quotation/data/repositories/quotation_repository.dart';
import 'package:extend_crane_services/features/work_order/data/repositories/work_repository.dart';


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
  });
}

class AllWorkHistoryPage extends ConsumerWidget {
  const AllWorkHistoryPage({super.key});

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
                  const Text(
                    'Work History',
                    style: TextStyle(
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
                        ));
                      }

                      // Add Work Orders
                      for (var w in workOrders) {
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
                                      Text(
                                        item.status.toUpperCase(),
                                        style: TextStyle(
                                          color: item.status == 'completed' ? Colors.greenAccent : Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
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
}
