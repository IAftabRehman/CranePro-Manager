import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_step2.dart';

class AddQuotationStep1 extends StatefulWidget {
  const AddQuotationStep1({super.key});

  @override
  State<AddQuotationStep1> createState() => _AddQuotationStep1State();
}

class _AddQuotationStep1State extends State<AddQuotationStep1> {
  final _formKey = GlobalKey<FormState>();

  final _clientNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _clientEmailController = TextEditingController();

  final _siteAddressController = TextEditingController();
  final _jobDescController = TextEditingController();
  final _dateTimeController = TextEditingController();

  @override
  void dispose() {
    _clientNameController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _clientEmailController.dispose();
    _siteAddressController.dispose();
    _jobDescController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme
                .of(context)
                .colorScheme
                .copyWith(
              primary: Theme
                  .of(context)
                  .colorScheme
                  .secondary,
              onPrimary: Theme
                  .of(context)
                  .colorScheme
                  .primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 8, minute: 0),
      );

      if (pickedTime != null) {
        setState(() {
          final dt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
              pickedTime.hour, pickedTime.minute);
          _dateTimeController.text =
              DateFormat('MMM dd, yyyy - hh:mm a').format(dt);
        });
      }
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddQuotationStep2()),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Text(title,
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);

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
                          'Step 1 of 3',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Client & Site Info',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.33,
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
                            _buildSectionHeader('Client Information', Icons.business_center, theme),
                            
                            if (isTablet)
                              Row(
                                children: [
                                  Expanded(
                                    child: CraneInput(
                                      controller: _clientNameController,
                                      hintText: 'Company / Client Name',
                                      suffixIcon: const Icon(Icons.business),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CraneInput(
                                      controller: _contactPersonController,
                                      hintText: 'Contact Person (Optional)',
                                      suffixIcon: const Icon(Icons.person_outline),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  CraneInput(
                                    controller: _clientNameController,
                                    hintText: 'Company / Client Name',
                                    suffixIcon: const Icon(Icons.business),
                                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  CraneInput(
                                    controller: _contactPersonController,
                                    hintText: 'Contact Person (Optional)',
                                    suffixIcon: const Icon(Icons.person_outline),
                                  ),
                                ],
                              ),
                              
                            const SizedBox(height: 16),
                            if (isTablet)
                              Row(
                                children: [
                                  Expanded(
                                    child: CraneInput(
                                      controller: _contactNumberController,
                                      hintText: 'Contact Number',
                                      keyboardType: TextInputType.phone,
                                      suffixIcon: const Icon(Icons.phone),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CraneInput(
                                      controller: _clientEmailController,
                                      hintText: 'Email Address (Optional)',
                                      keyboardType: TextInputType.emailAddress,
                                      suffixIcon: const Icon(Icons.email_outlined),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  CraneInput(
                                    controller: _contactNumberController,
                                    hintText: 'Contact Number',
                                    keyboardType: TextInputType.phone,
                                    suffixIcon: const Icon(Icons.phone),
                                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  CraneInput(
                                    controller: _clientEmailController,
                                    hintText: 'Email Address (Optional)',
                                    keyboardType: TextInputType.emailAddress,
                                    suffixIcon: const Icon(Icons.email_outlined),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 24),
                            _buildSectionHeader('Site & Location Details', Icons.location_on, theme),
                            
                            CraneInput(
                              controller: _siteAddressController,
                              hintText: 'Site Address / Location',
                              maxLines: 3,
                              suffixIcon: const Icon(Icons.map_outlined),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            CraneInput(
                              controller: _jobDescController,
                              hintText: 'Job Description (e.g. Shifting 50-ton Gen)',
                              maxLines: 2,
                              suffixIcon: const Icon(Icons.description_outlined),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            CraneInput(
                              controller: _dateTimeController,
                              hintText: 'Expected Date & Time',
                              readOnly: true,
                              onTap: _pickDateTime,
                              suffixIcon: const Icon(Icons.calendar_month),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),

                            // Keyboard scroll safety buffer
                            SizedBox(height: Responsive.screenHeight(context) * 0.1),
                            
                            Center(
                              child: CraneButton(
                                text: 'Next: Crane Details',
                                onPressed: _onNext,
                              ),
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
