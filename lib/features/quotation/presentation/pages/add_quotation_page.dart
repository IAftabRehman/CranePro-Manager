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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amber, // Header aur selected date ka color
              onPrimary: Colors.black, // Header text ka color
              surface: Color(0xFF1A1F3D), // Calendar background (Premium Gradient se match karne ke liye)
              onSurface: Colors.white, // Dates aur days ka text color
              secondary: Colors.amber, // "Save" aur "Cancel" buttons ka text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
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
      appBar: AppBar(
        title: Text("Quotation Generator", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.blue.withAlpha(41),
        elevation: 10,
        shadowColor: Colors.blue,
      ),
      body: Column(
        children: [
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
                      const _SectionLabel('Client Information'),
                      CraneInput(
                        controller: _clientController,
                        hintText: 'Client or Company Name (Optional)',
                        prefixIcon: const Icon(Icons.business_outlined, size: 20),
                      ),

                      const SizedBox(height: 30),
                      const _SectionLabel('Service Entries'),
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
                        label: const Text('Add Another Services', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 50),
                      const _SectionLabel('Terms and Conditions'),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                                      Text('Click below to edit or add more points.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, color: Colors.white10),
                            ElevatedButton(
                              onPressed: _navigateToTerms,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.05),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white.withOpacity(0.05))),
                              ),
                              child: Text('Manage Terms and Conditions', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 0.2, wordSpacing: 2)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      // Grand Total Card (AED)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.1)),
                          boxShadow: [BoxShadow(color: theme.colorScheme.secondary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Total', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 15)),
                            Text(
                              'AED ${_totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(color: theme.colorScheme.secondary, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          final data = QuotationModel(
                            quotationId: DateTime.now().millisecondsSinceEpoch.toString(),
                            operatorId: 'mock_operator_id', // TODO: Get from Auth
                            clientName: _clientController.text,
                            siteLocation: _entries.isNotEmpty ? _entries.first.location : '',
                            serviceType: _entries.isNotEmpty ? _entries.first.serviceName : '',
                            totalAmount: _totalPrice,
                            balanceAmount: _totalPrice,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                            workDate: _entries.isNotEmpty ? _entries.first.startDate : DateTime.now(),
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                        ),
                        child: const Text('Generate PDF', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
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
      padding: const EdgeInsets.only(bottom: 10, left: 4),
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
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.07), blurRadius: 10, offset: const Offset(7, 7)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Entry No. ${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
              IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 26)),
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
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
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 0.5)),
    );
  }
}

