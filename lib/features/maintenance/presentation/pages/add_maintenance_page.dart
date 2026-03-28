import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';

class AddMaintenancePage extends StatefulWidget {
  const AddMaintenancePage({super.key});

  @override
  State<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends State<AddMaintenancePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.amber,
                  onPrimary: Colors.black,
                  surface: const Color(0xFF1A1A2E),
                  onSurface: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate);
      });
    }
  }

  void _saveMaintenance() {
    if (_formKey.currentState!.validate()) {
      // Mock save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maintenance Entry Saved!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text(
          'Add Maintenance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                
                // Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.build_circle_rounded, color: Colors.amber, size: 50),
                  ),
                ),
                const SizedBox(height: 32),

                // Amount Field
                const Text(
                  'Amount in AED',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        'AED',
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: CraneInput(
                        controller: _amountController,
                        hintText: 'Enter amount (e.g. 500)',
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description Field
                const Text(
                  'Description / Reason',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                CraneInput(
                  controller: _reasonController,
                  hintText: 'e.g. Engine Oil Change, Tyre Repair',
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter a reason' : null,
                ),
                const SizedBox(height: 24),

                // Date Picker (Auto-filled but editable)
                const Text(
                  'Date (Auto-filled)',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: IgnorePointer(
                    child: CraneInput(
                      controller: _dateController,
                      hintText: 'Select Date',
                      suffixIcon: const Icon(Icons.edit_calendar, color: Colors.amber),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),

                // Save Button
                CraneButton(
                  text: 'Save Entry',
                  icon: Icons.check_circle_outline,
                  onPressed: _saveMaintenance,
                  // color: Colors.amber,
                ),
                
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
