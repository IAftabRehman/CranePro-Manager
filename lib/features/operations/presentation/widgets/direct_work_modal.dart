import 'package:flutter/material.dart';
import '../../../../shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';

class DirectWorkModal extends StatefulWidget {
  const DirectWorkModal({super.key});

  @override
  State<DirectWorkModal> createState() => _DirectWorkModalState();
}

class _DirectWorkModalState extends State<DirectWorkModal> {
  final _clientController = TextEditingController();
  final _serviceController = TextEditingController(text: '25 Ton Crane');
  final _locationController = TextEditingController();
  final _earningsController = TextEditingController();
  final _expenseController = TextEditingController(); // Fuel or Partner Payment
  
  bool _isOwnCrane = true; // Mode selection
  double _commission = 0.0;

  @override
  void initState() {
    super.initState();
    // Logic for real-time commission calculation
    _earningsController.addListener(_calculateCommission);
    _expenseController.addListener(_calculateCommission);
  }

  void _calculateCommission() {
    if (!_isOwnCrane) {
      final total = double.tryParse(_earningsController.text) ?? 0.0;
      final paid = double.tryParse(_expenseController.text) ?? 0.0;
      setState(() {
        _commission = (total - paid).clamp(0, double.infinity);
      });
    }
  }

  @override
  void dispose() {
    _clientController.dispose();
    _serviceController.dispose();
    _locationController.dispose();
    _earningsController.dispose();
    _expenseController.dispose();
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
        gradient: AppTheme.premiumGradient, // TASK 3: Premium Branding
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            
            // TASK 1: Selection Mode
            Row(
              children: [
                Expanded(
                  child: _buildModeToggle(
                    'Own 25T Crane', 
                    Icons.engineering, 
                    _isOwnCrane, 
                    () => setState(() => _isOwnCrane = true)
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeToggle(
                    'Outsource', 
                    Icons.handshake_outlined, 
                    !_isOwnCrane, 
                    () => setState(() {
                      _isOwnCrane = false;
                      _calculateCommission();
                    })
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildLabel('CLIENT NAME (OPTIONAL)'),
            CraneInput(
              controller: _clientController,
              hintText: 'e.g. Street Client',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: Colors.white70),
            ),
            
            const SizedBox(height: 20),
            _buildLabel('SERVICE TYPE'),
            CraneInput(
              controller: _serviceController,
              hintText: 'e.g. 25 Ton Crane',
              prefixIcon: const Icon(Icons.build_outlined, size: 20, color: Colors.white70),
            ),
            
            const SizedBox(height: 20),
            _buildLabel('LOCATION'),
            CraneInput(
              controller: _locationController,
              hintText: 'e.g. Musaffah M-12',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: Colors.white70),
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('TOTAL RECEIVED (AED)'),
                      CraneInput(
                        controller: _earningsController,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                          child: Text('AED', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(_isOwnCrane ? 'FUEL EXPENSE (AED)' : 'PAID TO PARTNER (AED)'),
                      CraneInput(
                        controller: _expenseController,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                          child: Text('AED', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // TASK 2: My Commission (Read-only for Outsource mode)
            if (!_isOwnCrane) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('MY COMMISSION:', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('AED ${_commission.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 40),
            
            // TASK 3: Save Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Direct Work Entry Saved! Report Updated.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
              ),
              child: const Text('SAVE ENTRY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(String text, IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.amber : Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? Colors.amber : Colors.white38, size: 24),
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
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    );
  }
}
