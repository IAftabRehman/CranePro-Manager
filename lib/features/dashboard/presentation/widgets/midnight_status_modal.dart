import 'package:flutter/material.dart';
import '../../../../shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';

class MidnightStatusModal extends StatefulWidget {
  final DateTime date;
  final QuotationModel quotation;

  const MidnightStatusModal({
    super.key,
    required this.date,
    required this.quotation,
  });

  @override
  State<MidnightStatusModal> createState() => _MidnightStatusModalState();
}

class _MidnightStatusModalState extends State<MidnightStatusModal> {
  final _expenseController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'Completed';

  @override
  void dispose() {
    _expenseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.premiumGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MIDNIGHT STATUS UPDATE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.quotation.clientName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildLabel('Job Status'),
            Row(
              children: [
                Expanded(
                  child: _buildStatusToggle(
                    'Completed',
                    Icons.check_circle_rounded,
                    _status == 'Completed',
                    () => setState(() => _status = 'Completed'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusToggle(
                    'In Progress',
                    Icons.pending_rounded,
                    _status == 'In Progress',
                    () => setState(() => _status = 'In Progress'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildLabel('Total Expenses (AED)'),
            CraneInput(
              controller: _expenseController,
              hintText: 'e.g. 500 (Fuel, Tolls, etc.)',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
            ),
            
            const SizedBox(height: 24),
            _buildLabel('Notes / Observations'),
            CraneInput(
              controller: _notesController,
              hintText: 'e.g. Crane performed well, minor hydraulic leak observed.',
              maxLines: 3,
              prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.white70, size: 20),
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status Updated Successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'SUBMIT UPDATE',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle(String text, IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.amber : Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? Colors.amber : Colors.white38),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
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

