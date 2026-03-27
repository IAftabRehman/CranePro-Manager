import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

enum WorkStatus { working, pending, noWork }

class DailyLogPage extends StatefulWidget {
  const DailyLogPage({super.key});

  @override
  State<DailyLogPage> createState() => _DailyLogPageState();
}

class _DailyLogPageState extends State<DailyLogPage> {
  final _formKey = GlobalKey<FormState>();
  WorkStatus _selectedStatus = WorkStatus.working;
  
  // Working fields
  final _hoursController = TextEditingController();
  final _commissionController = TextEditingController();
  final _expensesController = TextEditingController();
  
  // Pending fields
  final _reasonController = TextEditingController();
  final _resumeDateController = TextEditingController();
  
  @override
  void dispose() {
    _hoursController.dispose();
    _commissionController.dispose();
    _expensesController.dispose();
    _reasonController.dispose();
    _resumeDateController.dispose();
    super.dispose();
  }

  Future<void> _pickResumeDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      _resumeDateController.text = DateFormat('MMM dd, yyyy').format(pickedDate);
    }
  }

  void _onUpdate() {
    if (_selectedStatus != WorkStatus.noWork && !_formKey.currentState!.validate()) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated: ${_selectedStatus.name.toUpperCase()}')),
    );
    Navigator.pop(context);
  }

  Widget _buildStatusCard({
    required WorkStatus status,
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isSelected = _selectedStatus == status;
    
    Color getActiveColor() {
      switch (status) {
        case WorkStatus.working:
          return theme.colorScheme.secondary; // Amber
        case WorkStatus.noWork:
          return theme.colorScheme.tertiary; // Steel Grey
        case WorkStatus.pending:
          return Colors.orangeAccent;
      }
    }

    final cardColor = isSelected ? getActiveColor() : Colors.white.withValues(alpha: 0.05);
    final textColor = isSelected 
        ? (status == WorkStatus.working || status == WorkStatus.pending ? theme.colorScheme.primary : Colors.white) 
        : Colors.white;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? getActiveColor() : Colors.white.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: getActiveColor().withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 6))]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: Responsive.scale(context, 40).clamp(32.0, 56.0),
              color: textColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: Responsive.scale(context, 14).clamp(12.0, 18.0),
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields(ThemeData theme) {
    if (_selectedStatus == WorkStatus.noWork) {
      return Container(
        key: const ValueKey('noWork'),
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.weekend, size: 64, color: theme.colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              'Enjoy the day off!',
              style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.secondary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No financial inputs required for today.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    
    if (_selectedStatus == WorkStatus.working) {
      return Column(
        key: const ValueKey('working'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Operations Data', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CraneInput(
            controller: _hoursController,
            hintText: 'Hours Worked (e.g. 8)',
            keyboardType: TextInputType.number,
            suffixIcon: const Icon(Icons.timer),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          CraneInput(
            controller: _commissionController,
            hintText: 'Commission Cut (AED/PKR)',
            keyboardType: TextInputType.number,
            suffixIcon: const Icon(Icons.money_off),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          CraneInput(
            controller: _expensesController,
            hintText: 'Fuel / Expenses (Optional)',
            keyboardType: TextInputType.number,
            suffixIcon: const Icon(Icons.local_gas_station),
          ),
        ],
      );
    }
    
    // Pending
    return Column(
      key: const ValueKey('pending'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Delay Information', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        CraneInput(
          controller: _reasonController,
          hintText: 'Reason for Delay',
          maxLines: 4,
          suffixIcon: const Icon(Icons.warning_amber),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        CraneInput(
          controller: _resumeDateController,
          hintText: 'Expected Resume Date',
          readOnly: true,
          onTap: _pickResumeDate,
          suffixIcon: const Icon(Icons.calendar_month),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);
    
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    final statusSelectionContent = isTablet
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStatusCard(status: WorkStatus.working, title: 'Working Today', icon: Icons.precision_manufacturing, theme: theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusCard(status: WorkStatus.pending, title: 'Pending / Delay', icon: Icons.timer, theme: theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusCard(status: WorkStatus.noWork, title: 'No Work', icon: Icons.event_busy, theme: theme)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(status: WorkStatus.working, title: 'Working Today', icon: Icons.precision_manufacturing, theme: theme),
              const SizedBox(height: 12),
              _buildStatusCard(status: WorkStatus.pending, title: 'Pending / Delay', icon: Icons.timer, theme: theme),
              const SizedBox(height: 12),
              _buildStatusCard(status: WorkStatus.noWork, title: 'No Work', icon: Icons.event_busy, theme: theme),
            ],
          );

    Widget formContent = Form(
      key: _formKey,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildInputFields(theme),
      ),
    );

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Daily Work Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000), // Max width for iPad Side-by-side
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date Header
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.today, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status for Today',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                              Text(
                                formattedDate,
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: Responsive.scale(context, 18).clamp(16.0, 22.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Layout
                  if (isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Select Status', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              statusSelectionContent,
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 1,
                          child: formContent,
                        ),
                      ],
                    )
                  else 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Select Status', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        statusSelectionContent,
                        const SizedBox(height: 32),
                        formContent,
                      ],
                    ),

                  SizedBox(height: Responsive.screenHeight(context) * 0.05),
                  Center(
                    child: CraneButton(
                      text: 'Update Log',
                      icon: Icons.sync,
                      onPressed: _onUpdate,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
