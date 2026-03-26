import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/pdf_preview_page.dart';

class AddQuotationStep3 extends StatefulWidget {
  // Ideally passed from Step 2
  final double subtotal;

  const AddQuotationStep3({super.key, this.subtotal = 5500.0});

  @override
  State<AddQuotationStep3> createState() => _AddQuotationStep3State();
}

class _AddQuotationStep3State extends State<AddQuotationStep3> {
  final _formKey = GlobalKey<FormState>();
  
  bool _applyVat = false;
  
  final _commissionController = TextEditingController();
  final _discountController = TextEditingController();
  final _otherChargesController = TextEditingController();
  final _vatDisplayController = TextEditingController();

  double _commission = 0.0;
  double _discount = 0.0;
  double _otherCharges = 0.0;
  double _vatAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _commissionController.addListener(_recalculate);
    _discountController.addListener(_recalculate);
    _otherChargesController.addListener(_recalculate);
    _recalculate();
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _discountController.dispose();
    _otherChargesController.dispose();
    _vatDisplayController.dispose();
    super.dispose();
  }

  void _recalculate() {
    setState(() {
      _commission = double.tryParse(_commissionController.text) ?? 0.0;
      _discount = double.tryParse(_discountController.text) ?? 0.0;
      _otherCharges = double.tryParse(_otherChargesController.text) ?? 0.0;
      
      final taxableAmount = widget.subtotal + _otherCharges - _discount;
      _vatAmount = _applyVat ? (taxableAmount * 0.05) : 0.0;
      _vatDisplayController.text = _vatAmount.toStringAsFixed(2);
    });
  }

  double get _finalPayable {
    return widget.subtotal + _otherCharges - _discount + _vatAmount - _commission;
  }

  void _onGenerate() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PdfPreviewPage()),
    );
  }

  void _onBack() {
    Navigator.pop(context);
  }

  Widget _buildSummaryRow(String label, double amount, ThemeData theme, {bool isSubtract = false, bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color ?? Colors.white70,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isSubtract ? "(-) " : "(+) "}${amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A), // Very Dark Navy Base
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Grand Total Breakdown',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 8),
          
          _buildSummaryRow('Subtotal', widget.subtotal, theme),
          _buildSummaryRow('Other Charges', _otherCharges, theme),
          _buildSummaryRow('Discount', _discount, theme, isSubtract: true),
          _buildSummaryRow('VAT (5%)', _vatAmount, theme),
          _buildSummaryRow('Commission', _commission, theme, isSubtract: true, color: Colors.redAccent),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Final Payable',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.surface,
                  fontSize: 18,
                ),
              ),
              Text(
                'AED ${_finalPayable.toStringAsFixed(2)}',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme, bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Taxes & Deductions', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18)),
              ],
            ),
          ),
          
          SwitchListTile(
            title: Text(
              'Apply VAT (5%)',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Government Value Added Tax',
              style: theme.textTheme.labelSmall,
            ),
            value: _applyVat,
            activeTrackColor: theme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                _applyVat = val;
                _recalculate();
              });
            },
          ),
          
          if (_applyVat) ...[
            const SizedBox(height: 12),
            CraneInput(
              controller: _vatDisplayController,
              hintText: 'Calculated VAT',
              readOnly: true,
              suffixIcon: const Icon(Icons.percent),
            ),
          ],

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Commissions & Extras', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18)),
              ],
            ),
          ),

          if (isTablet)
            Row(
              children: [
                Expanded(
                  child: CraneInput(
                    controller: _commissionController,
                    hintText: 'Commission (Middle-man)',
                    keyboardType: TextInputType.number,
                    suffixIcon: const Icon(Icons.money_off),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CraneInput(
                    controller: _discountController,
                    hintText: 'Discount (Optional)',
                    keyboardType: TextInputType.number,
                    suffixIcon: const Icon(Icons.local_offer),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                CraneInput(
                  controller: _commissionController,
                  hintText: 'Commission (Middle-man)',
                  keyboardType: TextInputType.number,
                  suffixIcon: const Icon(Icons.money_off),
                ),
                const SizedBox(height: 16),
                CraneInput(
                  controller: _discountController,
                  hintText: 'Discount (Optional)',
                  keyboardType: TextInputType.number,
                  suffixIcon: const Icon(Icons.local_offer),
                ),
              ],
            ),
            
          const SizedBox(height: 16),
          CraneInput(
            controller: _otherChargesController,
            hintText: 'Other Charges (Diesel, Permit, etc.)',
            keyboardType: TextInputType.number,
            suffixIcon: const Icon(Icons.add_shopping_cart),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = Responsive.screenWidth(context);
    final isTablet = Responsive.isTablet(context);
    final useSidePanel = screenWidth > 900;

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
                          'Step 3 of 3',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Final Review & Save',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                      color: theme.colorScheme.secondary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              // Main Review Area below

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: useSidePanel ? 1200 : 700),
                    child: useSidePanel 
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Side: Form
                            Expanded(
                              flex: 5,
                              child: _buildFormContent(theme, isTablet),
                            ),
                            const SizedBox(width: 32),
                            // Right Side: Summary Panel
                            Expanded(
                                flex: 4,
                                child: _buildGrandTotalCard(theme),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFormContent(theme, isTablet),
                              const SizedBox(height: 32),
                              _buildGrandTotalCard(theme),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
              
              // Bottom Sticky Actions
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
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
                        flex: 4,
                        child: CraneButton(
                          text: 'Generate PDF',
                          icon: Icons.picture_as_pdf,
                          onPressed: _onGenerate,
                        ),
                      ),
                    ],
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
