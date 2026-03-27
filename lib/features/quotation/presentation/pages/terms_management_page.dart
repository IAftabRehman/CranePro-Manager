import 'package:flutter/material.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

class TermsManagementPage extends StatefulWidget {
  final List<String> initialTerms;

  const TermsManagementPage({super.key, required this.initialTerms});

  @override
  State<TermsManagementPage> createState() => _TermsManagementPageState();
}

class _TermsManagementPageState extends State<TermsManagementPage> {
  late List<String> _terms;

  @override
  void initState() {
    super.initState();
    // Create a local copy for editing
    _terms = List.from(widget.initialTerms);
    if (_terms.isEmpty) {
      _terms.add('');
    }
  }

  void _addTerm() {
    setState(() {
      _terms.add('');
    });
  }

  void _removeTerm(int index) {
    setState(() {
      _terms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Return filtered list (no empty terms)
              Navigator.pop(context, _terms.where((t) => t.trim().isNotEmpty).toList());
            },
            child: Text('SAVE', style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manage Quotation Terms', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('These points will appear at the bottom of your PDF.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: _terms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CraneInput(
                        hintText: 'e.g. Fuel provided by client',
                        initialValue: _terms[index],
                        onChanged: (val) => _terms[index] = val,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeTerm(index),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: _addTerm,
              icon: const Icon(Icons.add),
              label: const Text('ADD NEW TERM POINT', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
