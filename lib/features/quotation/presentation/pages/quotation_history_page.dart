import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../auth/presentation/controllers/login_notifier.dart';
import '../../data/models/quotation_model.dart';
import '../../data/repositories/quotation_repository.dart';
import 'quotation_detail_page.dart';

class QuotationHistoryPage extends ConsumerWidget {
  const QuotationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Level 1 (Riverpod Precision): Watch only userId to avoid rebuilding the
    // entire page when other user profile fields change.
    final userId = ref.watch(
      currentUserProvider.select((u) => u.asData?.value?.id),
    );

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
                    'Quotation History',
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
                child: userId == null
                    ? const RepaintBoundary(
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                      )
                    : StreamBuilder<List<QuotationModel>>(
                        stream: ref.read(quotationRepositoryProvider).getMyQuotations(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const RepaintBoundary(
                              child: Center(
                                child: CircularProgressIndicator(color: Colors.amber),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            );
                          }

                          final quotations = snapshot.data ?? [];
                          if (quotations.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    size: 80,
                                    color: Color(0x80FFFFFF),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Quotations Found',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: quotations.length,
                            itemBuilder: (context, index) {
                              return QuotationHistoryCard(q: quotations[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuotationHistoryCard extends StatelessWidget {
  final QuotationModel q;

  const QuotationHistoryCard({super.key, required this.q});

  @override
  Widget build(BuildContext context) {
    final statusColor = q.status == 'completed'
        ? Colors.green
        : (q.status == 'cancelled' ? Colors.red : Colors.orange);
    final dateStr = DateFormat('MMM dd, yyyy').format(q.workDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x1AFFFFFF)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuotationDetailPage(quotation: q),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      q.clientName.isEmpty ? 'Quotation' : q.clientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 0.5),
                    ),
                    child: Text(
                      q.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      q.siteLocation.isEmpty ? 'N/A' : q.siteLocation,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Value',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  Text(
                    'AED ${q.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
