import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_step3.dart';

class AddQuotationStep2 extends StatefulWidget {
  const AddQuotationStep2({super.key});

  @override
  State<AddQuotationStep2> createState() => _AddQuotationStep2State();
}

class _AddQuotationStep2State extends State<AddQuotationStep2> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCapacity = '50 Ton';
  final List<String> _capacities = ['25 Ton', '50 Ton', '100 Ton', '200 Ton'];

  final _craneModelController = TextEditingController();
  final _baseRentController = TextEditingController();
  final _durationController = TextEditingController();
  final _overtimeRateController = TextEditingController();

  double _baseRent = 0.0;
  double _overtimeRate = 0.0;
  
  @override
  void initState() {
    super.initState();
    _baseRentController.addListener(_calculateTotal);
    _overtimeRateController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _craneModelController.dispose();
    _baseRentController.dispose();
    _durationController.dispose();
    _overtimeRateController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    setState(() {
      _baseRent = double.tryParse(_baseRentController.text) ?? 0.0;
      _overtimeRate = double.tryParse(_overtimeRateController.text) ?? 0.0;
    });
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuotationStep3(subtotal: _baseRent + _overtimeRate),
      ),
    );
  }

  void _onBack() {
    Navigator.pop(context);
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.displayLarge?.copyWith(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);

    double subtotal = _baseRent + _overtimeRate; // Dummy calculation: base + 1 hr overtime

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Quotation'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Linear Progress Indicator Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: theme.colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step 2 of 3',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Crane & Pricing Options',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.66,
                      backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                      color: theme.colorScheme.secondary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              // Main Form Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSectionHeader('Crane Specifications', Icons.precision_manufacturing, theme),
                            
                            Text('Select Required Capacity', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            // Responsive ChoiceChips
                            isTablet 
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: _capacities.map((cap) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: ChoiceChip(
                                        label: Center(child: Text(cap, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        selected: _selectedCapacity == cap,
                                        onSelected: (val) {
                                          if(val) setState(() => _selectedCapacity = cap);
                                        },
                                        selectedColor: theme.colorScheme.secondary,
                                        backgroundColor: theme.colorScheme.surface,
                                      ),
                                    ),
                                  )).toList(),
                                )
                              : Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _capacities.map((cap) => ChoiceChip(
                                    label: Text(cap, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    selected: _selectedCapacity == cap,
                                    onSelected: (val) {
                                      if(val) setState(() => _selectedCapacity = cap);
                                    },
                                    selectedColor: theme.colorScheme.secondary,
                                    backgroundColor: theme.colorScheme.surface,
                                  )).toList(),
                                ),
                            
                            const SizedBox(height: 16),
                            CraneInput(
                              controller: _craneModelController,
                              hintText: 'Crane Model / Number (Optional)',
                              suffixIcon: const Icon(Icons.settings_suggest),
                            ),

                            const SizedBox(height: 24),
                            _buildSectionHeader('Pricing & Duration', Icons.payments, theme),
                            
                            if (isTablet)
                              Row(
                                children: [
                                  Expanded(
                                    child: CraneInput(
                                      controller: _baseRentController,
                                      hintText: 'Base Rent Amount (AED/PKR)',
                                      keyboardType: TextInputType.number,
                                      suffixIcon: const Icon(Icons.attach_money),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CraneInput(
                                      controller: _durationController,
                                      hintText: 'Rental Duration (e.g. 8 Hours)',
                                      suffixIcon: const Icon(Icons.timer),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  CraneInput(
                                    controller: _baseRentController,
                                    hintText: 'Base Rent Amount (AED/PKR)',
                                    keyboardType: TextInputType.number,
                                    suffixIcon: const Icon(Icons.attach_money),
                                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  CraneInput(
                                    controller: _durationController,
                                    hintText: 'Rental Duration (e.g. 8 Hours)',
                                    suffixIcon: const Icon(Icons.timer),
                                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                              
                            const SizedBox(height: 16),
                            CraneInput(
                              controller: _overtimeRateController,
                              hintText: 'Overtime Rate per Hour',
                              keyboardType: TextInputType.number,
                              suffixIcon: const Icon(Icons.more_time),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),

                            const SizedBox(height: 32),
                            // Summary Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal Estimate\n(Base + 1hr OT)',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$subtotal',
                                    style: theme.textTheme.displayLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontSize: Responsive.scale(context, 24).clamp(20.0, 32.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: Responsive.screenHeight(context) * 0.05),
                            
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CraneButton(
                                    text: 'Back',
                                    isOutlined: true,
                                    onPressed: _onBack,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: CraneButton(
                                    text: 'Next: Tax & Comm.',
                                    onPressed: _onNext,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
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
}
