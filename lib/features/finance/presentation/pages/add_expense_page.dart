import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/global_widgets/custom_button.dart';
import '../../../../shared/global_widgets/custom_text_field.dart';
import '../../../../shared/global_widgets/premium_background.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/finance_repository.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Fuel';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _categories = ['Fuel', 'Maintenance', 'Salary', 'Other'];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentGold,
              onPrimary: AppTheme.primaryNavy,
              surface: AppTheme.primaryNavy,
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
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authorized operator found');

      final expense = ExpenseModel(
        id: '', // Firestore generates this
        operatorId: user.uid,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
      );

      await ref.read(financeRepositoryProvider).addExpense(expense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Record Daily Expense'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorize Outward Cashflow',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Dropdown
                  const Text('Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        dropdownColor: AppTheme.primaryNavy,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedCategory = newValue);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Amount Field
                  const Text('Amount (AED)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CraneInput(
                    controller: _amountController,
                    hintText: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount is required';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Date Picker Field
                  const Text('Date of Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const Icon(Icons.calendar_month_outlined, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text('Description / Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CraneInput(
                    controller: _descriptionController,
                    hintText: 'What was this for?',
                    maxLines: 3,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: CraneButton(
                      text: 'Record Expense',
                      onPressed: _handleSave,
                      isLoading: _isSaving,
                      backgroundColor: AppTheme.deepNavyBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
