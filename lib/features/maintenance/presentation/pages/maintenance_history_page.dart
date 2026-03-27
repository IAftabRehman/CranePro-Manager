import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/add_maintenance_page.dart';

class MaintenanceHistoryPage extends StatelessWidget {
  const MaintenanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final List<Map<String, dynamic>> maintenanceEntries = [
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'reason': 'Hydraulic Pipe Replacement', 'amount': 1200.0, 'category': 'Repair'},
      {'date': DateTime.now().subtract(const Duration(days: 5)), 'reason': 'Engine Oil & Filter Change', 'amount': 850.0, 'category': 'Service'},
      {'date': DateTime.now().subtract(const Duration(days: 12)), 'reason': 'Tyre Pressure Sensor Fix', 'amount': 300.0, 'category': 'Repair'},
      {'date': DateTime.now().subtract(const Duration(days: 20)), 'reason': 'Brake Pad Replacement', 'amount': 1500.0, 'category': 'Safety'},
    ];

    double monthlyTotal = maintenanceEntries.fold(0, (sum, item) => sum + (item['amount'] as double));

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text(
          'Maintenance History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMaintenancePage()),
        ),
        label: const Text('Add Maintenance', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Monthly Summary Card (Higher Priority for Viewer role)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent.withValues(alpha: 0.2), Colors.amber.withValues(alpha: 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total crane expenses',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AED ${monthlyTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'This Month (March)',
                          style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Recent Entries',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: maintenanceEntries.length,
                itemBuilder: (context, index) {
                  final entry = maintenanceEntries[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.build_circle_outlined, color: Colors.white),
                      ),
                      title: Text(
                        entry['reason'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(entry['date']),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry['category'],
                              style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        'AED ${entry['amount'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
