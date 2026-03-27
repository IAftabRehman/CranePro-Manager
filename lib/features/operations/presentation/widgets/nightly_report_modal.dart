import 'package:flutter/material.dart';
import '../../data/models/daily_report_model.dart';
import '../../../../shared/global_widgets/custom_text_field.dart';

import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';

class NightlyReportModal extends StatefulWidget {
  final DateTime date;
  final QuotationData? quotation;
  const NightlyReportModal({super.key, required this.date, this.quotation});

  @override
  State<NightlyReportModal> createState() => _NightlyReportModalState();
}

class _NightlyReportModalState extends State<NightlyReportModal> {
  DailyReportStatus _status = DailyReportStatus.completed;
  ExecutionType _executionType = ExecutionType.ownCrane;
  
  final _fuelController = TextEditingController();
  final _commissionController = TextEditingController();
  final _partnerPaymentController = TextEditingController();
  final _reasonController = TextEditingController();

  // Calculated Profit
  double get _calculatedProfit {
    final totalValue = widget.quotation?.totalPrice ?? 0.0;
    if (_executionType == ExecutionType.ownCrane) {
      final fuel = double.tryParse(_fuelController.text) ?? 0.0;
      return totalValue - fuel;
    } else {
      final partnerPay = double.tryParse(_partnerPaymentController.text) ?? 0.0;
      return totalValue - partnerPay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E), // Matching premium dark theme
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 24),
            Text(
              widget.quotation != null 
                ? 'Work Update: ${widget.quotation!.clientName}' 
                : 'Nightly Report: ${widget.date.day}/${widget.date.month}/${widget.date.year}',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (widget.quotation?.entries.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(
                'Location: ${widget.quotation!.entries.first.location}',
                style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Please provide the final outcome of the scheduled work.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 32),
            
            _buildLabel('WORK STATUS'),
            Row(
              children: DailyReportStatus.values.map((s) {
                final isSelected = _status == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(s.name.toUpperCase()),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _status = s),
                      selectedColor: theme.colorScheme.secondary,
                      labelStyle: TextStyle(
                        color: isSelected ? theme.colorScheme.primary : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            if (_status == DailyReportStatus.completed) ...[
              const SizedBox(height: 24),
              _buildLabel('EXECUTION METHOD'),
              Row(
                children: ExecutionType.values.map((t) {
                  final isSelected = _executionType == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(t == ExecutionType.ownCrane ? 'OWN CRANE' : 'OUTSOURCED'),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _executionType = t),
                        selectedColor: Colors.blueAccent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              if (_executionType == ExecutionType.ownCrane) ...[
                _buildLabel('FUEL EXPENSE (AED)'),
                CraneInput(
                  controller: _fuelController,
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.local_gas_station_rounded, size: 20, color: Colors.white70),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('COMMISSION (AED)'),
                          CraneInput(
                            controller: _commissionController,
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('PARTNER PAY (AED)'),
                          CraneInput(
                            controller: _partnerPaymentController,
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              const SizedBox(height: 24),
              _buildLabel('REASON FOR NO-WORK'),
              CraneInput(
                controller: _reasonController,
                hintText: 'State the reason for delay/cancellation...',
                maxLines: 3,
                prefixIcon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white70),
              ),
            ],
            
            const SizedBox(height: 16),
            if (_status == DailyReportStatus.completed && widget.quotation != null) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('AUTOMATED PROFIT ESTIMATE', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'AED ${_calculatedProfit.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Daily Status Updated Successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: const Text('SUBMIT REPORT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
