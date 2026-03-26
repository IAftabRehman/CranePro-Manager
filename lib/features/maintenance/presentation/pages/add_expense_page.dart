import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/expense_analysis_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  final List<String> _categories = ['Fuel', 'Maintenance', 'Permit', 'Salary', 'Others'];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MMM dd, yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      _dateController.text = DateFormat('MMM dd, yyyy').format(pickedDate);
    }
  }

  void _applyQuickTag(String tag, String category) {
    setState(() {
      _titleController.text = tag;
      _selectedCategory = category;
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Saved Successfully')));
    Navigator.pop(context);
  }

  Widget _buildImagePlaceholder(ThemeData theme, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: DashedRectPainter(color: theme.colorScheme.primary, strokeWidth: 2, gap: 5.0),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image Picker Triggered')));
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              Text(
                'Upload Receipt / Photo',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('PNG, JPG up to 5MB', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);

    Widget formInputs = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Expense Details', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('+ Diesel Refill'),
                backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: theme.colorScheme.tertiary, fontWeight: FontWeight.bold),
                onPressed: () => _applyQuickTag('Diesel Refill', 'Fuel'),
              ),
              ActionChip(
                label: const Text('+ Crane Service'),
                backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: theme.colorScheme.tertiary, fontWeight: FontWeight.bold),
                onPressed: () => _applyQuickTag('Crane Standard Service', 'Maintenance'),
              ),
              ActionChip(
                 label: const Text('+ RTA Permit'),
                 backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                 labelStyle: TextStyle(color: theme.colorScheme.tertiary, fontWeight: FontWeight.bold),
                 onPressed: () => _applyQuickTag('RTA Road Permit', 'Permit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          CraneInput(
            controller: _titleController,
            hintText: 'Expense Title',
            suffixIcon: const Icon(Icons.receipt_long),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          
          // Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
            decoration: InputDecoration(
              hintText: 'Select Category',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCategory = val;
              });
            },
          ),
          
          const SizedBox(height: 16),
          CraneInput(
            controller: _amountController,
            hintText: 'Amount',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixIcon: const Icon(Icons.attach_money),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          CraneInput(
            controller: _dateController,
            hintText: 'Date of Expense',
            readOnly: true,
            onTap: _pickDate,
            suffixIcon: const Icon(Icons.calendar_today),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Expense Summary Card
                  Card(
                    elevation: 5,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Expense this Month', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                              const SizedBox(height: 8),
                              Text('AED 1,450.00', style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: Responsive.scale(context, 24).clamp(20.0, 32.0))),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseAnalysisPage())),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('View Analysis', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  if (isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: formInputs),
                        const SizedBox(width: 32),
                        Expanded(flex: 4, child: _buildImagePlaceholder(theme, Responsive.screenHeight(context) * 0.4)),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        formInputs,
                        const SizedBox(height: 24),
                        _buildImagePlaceholder(theme, Responsive.screenHeight(context) * 0.25),
                      ],
                    ),
                    
                  SizedBox(height: Responsive.screenHeight(context) * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: CraneButton(
                    text: 'Save Expense',
                    icon: Icons.save,
                    onPressed: _onSave,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, required this.strokeWidth, required this.gap});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)));

    PathMetrics pathMetrics = path.computeMetrics();
    Path dashedPath = Path();

    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
