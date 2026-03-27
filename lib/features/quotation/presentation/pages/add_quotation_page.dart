import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/pdf_preview_page.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/terms_management_page.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';

class AddQuotationPage extends StatefulWidget {
  const AddQuotationPage({super.key});

  @override
  State<AddQuotationPage> createState() => _AddQuotationPageState();
}

class _AddQuotationPageState extends State<AddQuotationPage> {
  final _clientController = TextEditingController();
  final List<String> _terms = ['Diesel will be provided by client', '10-12 Hours shift duty'];
  final List<QuotationServiceEntry> _entries = [QuotationServiceEntry(
    serviceName: '',
    duration: '',
    location: '',
    price: 0.0,
  )];
  
  void _addEntry() {
    setState(() {
      _entries.add(QuotationServiceEntry(
        serviceName: '',
        duration: '',
        location: '',
        price: 0.0,
      ));
    });
  }

  void _removeEntry(int index) {
    if (_entries.length > 1) {
      setState(() {
        _entries.removeAt(index);
      });
    }
  }

  Future<void> _navigateToTerms() async {
    final updatedTerms = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => TermsManagementPage(initialTerms: _terms)),
    );
    if (updatedTerms != null) {
      setState(() {
        _terms.clear();
        _terms.addAll(updatedTerms);
      });
    }
  }

  double get _totalPrice => _entries.fold(0, (sum, item) => sum + item.price);

  Future<void> _selectDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _entries[index].startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _entries[index].startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = Responsive.screenHeight(context);

    return PremiumScaffold(
      body: Column(
        children: [
          // Premium Gradient Header with Logo
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to Admin Panel logic here (Simulated)
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: screenHeight * 0.08,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.architecture, color: Colors.white, size: 40),
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Final Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('BAHADAR TRANSPORT', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.2)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Single Full Width Client Input
                      const _SectionLabel('CLIENT INFORMATION'),
                      CraneInput(
                        controller: _clientController,
                        hintText: 'Client or Company Name (Optional)',
                        prefixIcon: const Icon(Icons.business_outlined, size: 20),
                      ),

                      const SizedBox(height: 32),
                      const _SectionLabel('SERVICE ENTRIES'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          return _ServiceCard(
                            index: index,
                            entry: _entries[index],
                            onRemove: () => _removeEntry(index),
                            onDateTap: () => _selectDate(index),
                            onPriceChanged: (val) {
                              setState(() {
                                _entries[index].price = double.tryParse(val) ?? 0.0;
                              });
                            },
                          );
                        },
                      ),

                      TextButton.icon(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.add_circle, size: 24),
                        label: const Text('Add Another Service', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const _SectionLabel('TERMS & CONDITIONS'),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.description_outlined, color: Colors.white70, size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${_terms.length} Terms Added', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                      Text('Click below to edit or add more points.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, color: Colors.white10),
                            ElevatedButton(
                              onPressed: _navigateToTerms,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.05),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                              ),
                              child: const Text('MANAGE TERMS & CONDITIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                      // Grand Total Card (AED)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                          boxShadow: [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Total', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text(
                              'AED ${_totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(color: theme.colorScheme.secondary, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          final data = QuotationData(
                            clientName: _clientController.text,
                            entries: _entries,
                            terms: _terms.where((t) => t.isNotEmpty).toList(),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PdfPreviewPage(data: data)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: const Text('GENERATE PDF QUOTATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Colors.white70)),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final int index;
  final QuotationServiceEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onDateTap;
  final Function(String) onPriceChanged;

  const _ServiceCard({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onDateTap,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ENTRY #${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
              IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 22)),
            ],
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          
          _FieldLabel('Service Type'),
          CraneInput(
            hintText: 'e.g., 50 Ton Crane Hire',
            onChanged: (val) => entry.serviceName = val,
          ),
          
          const SizedBox(height: 20),
          _FieldLabel('Duration'),
          CraneInput(
            hintText: 'e.g., 3 Days',
            onChanged: (val) => entry.duration = val,
          ),
          
          const SizedBox(height: 20),
          _FieldLabel('Price (AED)'),
          CraneInput(
            hintText: '0.00',
            prefixText: 'AED ',
            keyboardType: TextInputType.number,
            onChanged: onPriceChanged,
          ),
          
          const SizedBox(height: 20),
          _FieldLabel('Location'),
          CraneInput(
            hintText: 'Worksite location',
            onChanged: (val) => entry.location = val,
          ),
          
          const SizedBox(height: 20),
          _FieldLabel('Starting Date'),
          InkWell(
            onTap: onDateTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available, size: 18, color: Colors.white70),
                  const SizedBox(width: 12),
                  Text(entry.formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 0.5)),
    );
  }
}

