import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/features/auth/data/repositories/user_repository.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/quotation/data/repositories/quotation_repository.dart';
import 'package:extend_crane_services/features/work_order/data/repositories/work_repository.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
class UnifiedHistoryItem {
  final String id;
  final String type;
  final DateTime date;
  final String clientName;
  final String location;
  final String duration;
  final double price;
  final double netProfit;
  final String status;
  final String paymentStatus; // 'received', 'pending', or ''
  final double commission;

  final double balanceAmount;
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
    this.paymentStatus = '',
    required this.commission,

    required this.balanceAmount,
    required this.originalData,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
class AllWorkHistoryPage extends ConsumerWidget {
  final bool isPendingScreen;
  final bool isEmbedded;

  const AllWorkHistoryPage({
    super.key,
    this.isPendingScreen = false,
    this.isEmbedded = false,
  });

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
              if (!isEmbedded) _buildAppBar(context),
              Expanded(
                child: quotationsAsync.when(
                  data: (quotations) => workOrdersAsync.when(
                    data: (workOrders) {
                      final List<UnifiedHistoryItem> allItems = [];

                      for (var q in quotations) {
                        final status = q.status.toLowerCase();
                        final isDone =
                            status == 'completed' || status == 'cancelled';
                        if (isPendingScreen && isDone) continue;

                        String loc = q.siteLocation;
                        if (loc.isEmpty && q.entries.isNotEmpty) {
                          loc = q.entries.first.location;
                        }
                        if (loc.isEmpty) loc = 'N/A';
                        String dur = 'N/A';
                        if (q.entries.isNotEmpty &&
                            q.entries.first.duration.isNotEmpty) {
                          dur = q.entries.first.duration;
                        }

                        allItems.add(
                          UnifiedHistoryItem(
                            id: q.id,
                            type: 'Quotation',
                            date: q.workDate,
                            clientName: q.clientName.isEmpty
                                ? 'Unknown'
                                : q.clientName,
                            location: loc,
                            duration: dur,
                            price: q.totalAmount,
                            netProfit: q.totalAmount - q.commission,
                            status: q.status,
                            paymentStatus: q.paymentStatus,
                            commission: q.commission,

                            balanceAmount: q.balanceAmount,
                            originalData: q,
                          ),
                        );
                      }

                      for (var w in workOrders) {
                        final status = w.status.toLowerCase();
                        final isDone =
                            status == 'completed' || status == 'cancelled';
                        if (isPendingScreen && isDone) continue;
                        final net = w.netEarnings > 0
                            ? w.netEarnings
                            : (w.totalPrice - w.workCommission);
                        allItems.add(
                          UnifiedHistoryItem(
                            id: w.id,
                            type: 'Direct Work',
                            date: w.createdAt,
                            clientName: w.clientName.isEmpty
                                ? 'Unknown'
                                : w.clientName,
                            location: w.siteLocation.isEmpty
                                ? 'N/A'
                                : w.siteLocation,
                            duration: 'Instant',
                            price: w.totalPrice,
                            netProfit: net,
                            status: w.status,
                            paymentStatus: w.paymentStatus,
                            commission: w.workCommission,

                            balanceAmount: 0.0,
                            originalData: w,
                          ),
                        );
                      }

                      allItems.sort((a, b) => b.date.compareTo(a.date));
                      if (allItems.isEmpty) return _buildEmptyState();
                      if (isPendingScreen) {
                        return _buildPendingList(context, ref, allItems);
                      }
                      return _buildExcelTable(context, ref, allItems);
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Error: $e',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar (no ledger badge) ────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          Text(
            isPendingScreen ? 'Pending Tasks' : 'Work History',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isPendingScreen
              ? Icons.hourglass_empty_rounded
              : Icons.history_edu_outlined,
          color: Colors.white24,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          isPendingScreen ? 'No pending tasks.' : 'No work history found.',
          style: const TextStyle(color: Colors.white38, fontSize: 16),
        ),
      ],
    ),
  );

  // ── Excel / Ledger Table ─────────────────────────────────────────────────
  Widget _buildExcelTable(
    BuildContext context,
    WidgetRef ref,
    List<UnifiedHistoryItem> items,
  ) {
    final roleAsync = ref.watch(userRoleProvider);
    final role = roleAsync.value ?? 'operator';
    final isViewer = role == 'viewer';

    const colEdit = 40.0;
    const colSno = 40.0;
    const colDate = 84.0;
    const colClient = 110.0;
    const colWork = 106.0;
    const colLocation = 110.0;
    const colTotal = 90.0;
    const colComm = 88.0;
    const colOpBalance = 114.0;
    const colPending = 88.0;
    const colReceived = 88.0;
    const colStatus = 98.0;
    const rowH = 54.0;
    const headH = 44.0;

    const headStyle = TextStyle(
      color: Colors.white,
      fontSize: 11.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
    );
    final dateFmt = DateFormat('dd/MM/yy');

    // Soft but clearly visible row tint
    Color rowTint(String s) {
      switch (s.toLowerCase()) {
        case 'completed':
          return const Color(0x4000FF00); // Soft green
        case 'cancelled':
          return const Color(0x60FF2C2C); // Soft red
        default:
          return const Color(0x60ffff00); // Soft yellow
      }
    }

    String statusLabel(String s) {
      switch (s.toLowerCase()) {
        case 'completed':
          return '✔️ Done';
        case 'cancelled':
          return '❌ Cancelled';
        default:
          return '⌛ Pending';
      }
    }

    // Header cell
    Widget hCell(String t, double w) => Container(
      width: w,
      height: headH,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: Text(t, textAlign: TextAlign.center, style: headStyle),
    );

    // Data cell
    Widget dCell(
      String t,
      double w, {
      TextStyle? style,
      Alignment align = Alignment.center,
    }) => Container(
      width: w,
      height: rowH,
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Text(
        t,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: style ?? const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0C0C2C), Color(0xFF1A1A48)],
                ),
              ),
              child: Row(
                children: [
                  if (!isViewer) hCell('✎', colEdit),
                  hCell('#', colSno),
                  hCell('Date', colDate),
                  hCell('Client', colClient),
                  hCell('Work\nDetails', colWork),
                  hCell('Location', colLocation),
                  hCell('Total\nPrice', colTotal),
                  hCell('Commission', colComm),
                  hCell('Operator\nBalance', colOpBalance),
                  hCell('Payment\nStatus', colPending),
                  hCell('Received', colReceived),
                  hCell('Status', colStatus),
                ],
              ),
            ),

            // Data rows
            ...List.generate(items.length, (i) {
              final item = items[i];
              final tint = rowTint(item.status);
              final altBase = i.isEven
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.transparent;
              final statusLower = item.status.toLowerCase();
              final isPendingOrCancelled =
                  statusLower == 'pending' ||
                  statusLower == 'pending_approval' ||
                  statusLower == 'in progress' ||
                  statusLower == 'cancelled';
              final isPendingStatus = statusLower == 'pending' || statusLower == 'pending_approval' || statusLower == 'in progress';
              final received = isPendingStatus || item.paymentStatus.isEmpty ? 0.0 : item.price;
              final opBal = item.price - item.commission;
              final balLabel = isPendingOrCancelled
                  ? '—'
                  : (item.commission > 0
                        ? '${item.price.toStringAsFixed(0)}-${item.commission.toStringAsFixed(0)}\n= AED ${opBal.toStringAsFixed(0)}'
                        : 'AED ${opBal.toStringAsFixed(0)}');

              return GestureDetector(
                onLongPress: isViewer ? null : () => _showDeleteDialog(context, ref, item),
                child: Container(
                  color: Color.alphaBlend(tint, altBase),
                  child: Row(
                    children: [
                      // Edit icon
                      if (!isViewer)
                        GestureDetector(
                          onTap: () => _showEditSheet(context, ref, item),
                          child: Container(
                            width: colEdit,
                            height: rowH,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                        ),
                      dCell(
                        '${i + 1}',
                        colSno,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      dCell(
                        dateFmt.format(item.date),
                        colDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      // Client column (separate)
                      dCell(
                        item.clientName,
                        colClient,
                        align: Alignment.centerLeft,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Work details column (separate)
                      dCell(
                        item.type,
                        colWork,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      dCell(
                        item.location,
                        colLocation,
                        align: Alignment.centerLeft,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      // Total price of work (commission included)
                      dCell(
                        'AED ${item.price.toStringAsFixed(0)}',
                        colTotal,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      // Commission only
                      dCell(
                        item.commission > 0
                            ? 'AED ${item.commission.toStringAsFixed(0)}'
                            : '—',
                        colComm,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      // Operator Balance: exactly earned math
                      dCell(
                        balLabel,
                        colOpBalance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      dCell(
                        isPendingOrCancelled || item.paymentStatus.isEmpty
                            ? '—'
                            : item.paymentStatus[0].toUpperCase() +
                                  item.paymentStatus.substring(1).toLowerCase(),
                        colPending,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      dCell(
                        isPendingOrCancelled
                            ? '—'
                            : (item.paymentStatus.toLowerCase() == 'received'
                                  ? 'AED ${item.price.toStringAsFixed(0)}'
                                  : (item.paymentStatus.toLowerCase() ==
                                            'cancelled'
                                        ? '—'
                                        : (received > 0
                                              ? 'AED ${received.toStringAsFixed(0)}'
                                              : '—'))),
                        colReceived,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      // Status chip
                      Container(
                        width: colStatus,
                        height: rowH,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Text(
                          statusLabel(item.status),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Edit sheet launcher ──────────────────────────────────────────────────
  void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    UnifiedHistoryItem item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditRecordSheet(item: item, widgetRef: ref),
    );
  }

  // ── Pending list ─────────────────────────────────────────────────────────
  Widget _buildPendingList(
    BuildContext context,
    WidgetRef ref,
    List<UnifiedHistoryItem> items,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildPendingCard(ctx, ref, items[i]),
    );
  }

  Widget _buildPendingCard(
    BuildContext context,
    WidgetRef ref,
    UnifiedHistoryItem item,
  ) {
    final roleAsync = ref.watch(userRoleProvider);
    final role = roleAsync.value ?? 'operator';
    final isViewer = role == 'viewer';

    final isQ = item.type == 'Quotation';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2240),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.clientName,
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(
                    isQ ? 'QUOTATION' : 'WORK ORDER',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isViewer)
                  IconButton(
                    onPressed: () {
                      if (isQ) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddQuotationPage(initialData: item.originalData),
                          ),
                        );
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              DirectWorkModal(initialData: item.originalData),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white54, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.lightBlueAccent,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM dd, yyyy  •  hh:mm a').format(item.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.lightBlueAccent,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white12, height: 1),
            ),
            Center(
              child: Text(
                'AED ${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF69F0AE),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (!isViewer) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isQ) {
                          await ref
                              .read(quotationRepositoryProvider)
                              .updateQuotationStatus(item.id, 'cancelled');
                        } else {
                          await ref
                              .read(workRepositoryProvider)
                              .updateWorkOrderStatus(item.id, 'cancelled');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showPaymentDialog(context, ref, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Complete Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Payment Dialog ──────────────────────────────────────────────────────
  Future<void> _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    UnifiedHistoryItem item,
  ) async {
    final isQ = item.type == 'Quotation';
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A3E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete Task for ${item.clientName}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AED ${item.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFF69F0AE),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Could you confirm if the payment has been received or if it is still pending',
              style: TextStyle(color: Colors.white60, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // Pending Payment
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (!ctx.mounted) return;
                      _doComplete(context, ref, item, isQ, 'pending');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC400).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFC400),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Pending\nPayment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFC400),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Received Payment
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (!ctx.mounted) return;
                      _doComplete(context, ref, item, isQ, 'received');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF00E676),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Received\nPayment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doComplete(
    BuildContext context,
    WidgetRef ref,
    UnifiedHistoryItem item,
    bool isQ,
    String paymentStatus,
  ) async {
    try {
      if (isQ) {
        await ref
            .read(quotationRepositoryProvider)
            .completeWithPayment(item.id, paymentStatus);
      } else {
        await ref
            .read(workRepositoryProvider)
            .completeWithPayment(item.id, paymentStatus);
      }
      if (!context.mounted) return;
      final msg = paymentStatus == 'received'
          ? 'Task completed ✓  Payment Received'
          : 'Task completed ✓  Payment is still Pending';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: paymentStatus == 'received'
              ? Colors.green
              : Colors.orange,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete Dialog
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _showDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  UnifiedHistoryItem item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E2240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete Record',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Delete "${item.clientName}"?\nThis cannot be undone.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(
            'Delete',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );
    try {
      if (item.type == 'Quotation') {
        await ref.read(quotationRepositoryProvider).deleteQuotation(item.id);
      } else {
        await ref.read(workRepositoryProvider).deleteWorkOrder(item.id);
      }
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record deleted.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Record Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _EditRecordSheet extends StatefulWidget {
  final UnifiedHistoryItem item;
  final WidgetRef widgetRef;

  const _EditRecordSheet({required this.item, required this.widgetRef});

  @override
  State<_EditRecordSheet> createState() => _EditRecordSheetState();
}

class _EditRecordSheetState extends State<_EditRecordSheet> {
  late TextEditingController _dateCtrl;
  late TextEditingController _clientCtrl;
  late TextEditingController _workCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _commCtrl;
  late TextEditingController _pendingCtrl;
  late TextEditingController _receivedCtrl;
  late String _status;
  late String _paymentStatus; // 'received', 'pending', 'cancelled', or ''
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final pending =
        (item.balanceAmount > 0
                ? item.balanceAmount
                : 0)
            .clamp(0.0, double.infinity);
    _dateCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(item.date),
    );
    _clientCtrl = TextEditingController(text: item.clientName);
    _workCtrl = TextEditingController(text: item.type);
    _locationCtrl = TextEditingController(
      text: item.location == 'N/A' ? '' : item.location,
    );
    _amountCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
    _commCtrl = TextEditingController(text: item.commission.toStringAsFixed(0));
    _pendingCtrl = TextEditingController(text: pending.toStringAsFixed(0));
    _receivedCtrl = TextEditingController(

    );
    _status = item.status;
    _paymentStatus = item.paymentStatus;
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _clientCtrl.dispose();
    _workCtrl.dispose();
    _locationCtrl.dispose();
    _amountCtrl.dispose();
    _commCtrl.dispose();
    _pendingCtrl.dispose();
    _receivedCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final isQ = widget.item.type == 'Quotation';
      // Update task status
      if (isQ) {
        await widget.widgetRef
            .read(quotationRepositoryProvider)
            .updateQuotationStatus(widget.item.id, _status);
      } else {
        await widget.widgetRef
            .read(workRepositoryProvider)
            .updateWorkOrderStatus(widget.item.id, _status);
      }
      // Update payment status if it was changed
      if (_paymentStatus.isNotEmpty) {
        if (isQ) {
          await widget.widgetRef
              .read(quotationRepositoryProvider)
              .updatePaymentStatus(widget.item.id, _paymentStatus);
        } else {
          await widget.widgetRef
              .read(workRepositoryProvider)
              .updatePaymentStatus(widget.item.id, _paymentStatus);
        }
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record updated.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final comm = double.tryParse(_commCtrl.text) ?? 0;
    final opBal = amount - comm;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A3E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: sc,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            // // Drag handle
            // Center(child: Container(width: 40, height: 4,
            //     decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)))),
            // const SizedBox(height: 10),
            // Title
            Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.amber,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Edit Record',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),

            _field('Date', _dateCtrl, Icons.calendar_today),
            _field('Client Name', _clientCtrl, Icons.person),
            _field('Work Details', _workCtrl, Icons.work_outline),
            _field('Location', _locationCtrl, Icons.location_on_outlined),
            _field(
              'Total Amount (AED)',
              _amountCtrl,
              Icons.attach_money,
              inputType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            _field(
              'Commission (AED)',
              _commCtrl,
              Icons.percent,
              inputType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),

            // Live balance preview
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF69F0AE).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF69F0AE).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Operator Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '${amount.toStringAsFixed(0)} - ${comm.toStringAsFixed(0)} = ${opBal.toStringAsFixed(0)} AED',
                    style: const TextStyle(
                      color: Color(0xFF69F0AE),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Task Status selector
            const SizedBox(height: 8),
            const Text(
              'Payment Status',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _paymentChip('cancelled', 'Cancelled', const Color(0xFFFF1744)),
                const SizedBox(width: 8),
                _paymentChip('pending', 'Pending', const Color(0xFFFFC400)),
                const SizedBox(width: 8),
                _paymentChip('received', 'Received', const Color(0xFF00E676)),
              ],
            ),

            const SizedBox(height: 16),
            // Payment Status selector (separate from task status)
            const Text(
              'Task Status',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                _statusChip('pending', 'Pending', const Color(0xFFFFC400)),
                const SizedBox(width: 8),
                _statusChip('completed', 'Completed', const Color(0xFF00E676)),
                const SizedBox(width: 8),
                _statusChip('cancelled', 'Cancelled', const Color(0xFFFF1744)),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? inputType,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            keyboardType: inputType,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white38, size: 18),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.amber),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label, Color color) {
    final sel = _status.toLowerCase() == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel
                ? color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? color : Colors.white.withValues(alpha: 0.15),
              width: sel ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: sel ? color : Colors.white38,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentChip(String value, String label, Color color) {
    final sel = _paymentStatus.toLowerCase() == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentStatus = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel
                ? color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? color : Colors.white.withValues(alpha: 0.15),
              width: sel ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: sel ? color : Colors.white38,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
