import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../quotation/presentation/pages/quotation_detail_page.dart';
import '../providers/report_filter_providers.dart';
import '../../../quotation/data/models/quotation_model.dart';
import '../../../finance/data/models/expense_model.dart';

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Component Extraction & Riverpod Optimization: 
          // FilterHeaderSection watches date range and search/status states locally,
          // avoiding parent rebuilds on key input or filter changes.
          FilterHeaderSection(),
          TabBar(
            tabs: [
              Tab(text: 'Quotations'),
              Tab(text: 'Expenses'),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorColor: AppTheme.lavenderPrimary,
            indicatorWeight: 3,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _QuotationsReportList(),
                _ExpensesReportList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted FilterHeaderSection widget (ConsumerWidget with const constructor)
class FilterHeaderSection extends ConsumerWidget {
  const FilterHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(reportDateRangeProvider);
    final statusFilter = ref.watch(reportStatusFilterProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        if (isWide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: const BoxDecoration(
                  color: Color(0x0DFFFFFF),
                  border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
                ),
                child: Row(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: TextField(
                        onChanged: (val) => ref.read(reportSearchQueryProvider.notifier).state = val,
                        decoration: InputDecoration(
                          hintText: 'Search client, crane, or category...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0x1AFFFFFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _pickDateRange(context, ref, dateRange),
                          icon: Icon(
                            Icons.calendar_month,
                            color: dateRange != null ? AppTheme.lavenderPrimary : Colors.white,
                          ),
                          tooltip: 'Select Date Range',
                        ),
                        if (dateRange != null) ...[
                          const SizedBox(width: 4),
                          Chip(
                            label: Text(
                              '${DateFormat('MMM d').format(dateRange.start)} - ${DateFormat('MMM d').format(dateRange.end)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: () => ref.read(reportDateRangeProvider.notifier).state = null,
                            backgroundColor: const Color(0x33E6E6FA),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['All', 'Pending', 'Completed', 'Cancelled'].map((status) {
                        final isSelected = statusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) ref.read(reportStatusFilterProvider.notifier).state = status;
                            },
                            selectedColor: AppTheme.bluePrimary,
                            backgroundColor: const Color(0x1AFFFFFF),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0x0DFFFFFF),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => ref.read(reportSearchQueryProvider.notifier).state = val,
                      decoration: InputDecoration(
                        hintText: 'Search client, crane, or category...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0x1AFFFFFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _pickDateRange(context, ref, dateRange),
                    icon: Icon(
                      Icons.calendar_month,
                      color: dateRange != null ? AppTheme.lavenderPrimary : Colors.white,
                    ),
                    tooltip: 'Select Date Range',
                  ),
                ],
              ),
              if (dateRange != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        '${DateFormat('MMM d').format(dateRange.start)} - ${DateFormat('MMM d').format(dateRange.end)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: () => ref.read(reportDateRangeProvider.notifier).state = null,
                      backgroundColor: const Color(0x33E6E6FA),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Pending', 'Completed', 'Cancelled'].map((status) {
                    final isSelected = statusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) ref.read(reportStatusFilterProvider.notifier).state = status;
                        },
                        selectedColor: AppTheme.bluePrimary,
                        backgroundColor: const Color(0x1AFFFFFF),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref, DateTimeRange? dateRange) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.lavenderPrimary,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(reportDateRangeProvider.notifier).state = picked;
    }
  }
}

class _QuotationsReportList extends ConsumerWidget {
  const _QuotationsReportList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredQuotations = ref.watch(filteredQuotationsProvider);

    return filteredQuotations.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('No matching quotations found.'));
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
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final q = list[index];
                      return _QuotationReportCard(quotation: q);
                    },
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final q = list[index];
                  return _QuotationReportCard(quotation: q);
                },
              );
            }
          }
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _ExpensesReportList extends ConsumerWidget {
  const _ExpensesReportList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExpenses = ref.watch(filteredExpensesProvider);

    return filteredExpenses.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('No matching expenses found.'));
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
                      childAspectRatio: 2.8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final e = list[index];
                      return _ExpenseReportCard(expense: e);
                    },
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final e = list[index];
                  return _ExpenseReportCard(expense: e);
                },
              );
            }
          }
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _QuotationReportCard extends StatelessWidget {
  final QuotationModel quotation;
  const _QuotationReportCard({required this.quotation});

  @override
  Widget build(BuildContext context) {
    final statusColor = quotation.status == 'completed' ? Colors.green : (quotation.status == 'cancelled' ? Colors.red : Colors.orange);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0x0DFFFFFF),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuotationDetailPage(quotation: quotation)),
        ),
        title: Text(quotation.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${DateFormat('MMM dd, yyyy').format(quotation.workDate)} • ${quotation.serviceType}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('AED ${quotation.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.lavenderPrimary)),
            Text(quotation.status.toUpperCase(), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ExpenseReportCard extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseReportCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0x0DFFFFFF),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x33E6E6FA),
          child: Icon(Icons.receipt_long, color: AppTheme.lavenderPrimary, size: 20),
        ),
        title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${DateFormat('MMM dd, yyyy').format(expense.date)} • ${expense.description}'),
        trailing: Text('AED ${expense.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
      ),
    );
  }
}
