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
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Quotation Terms',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These terms and condition will appear at the bottom of your Quotation PDF.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(15),
              physics: const BouncingScrollPhysics(),
              itemCount: _terms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 25,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildElevatedButton(
                  theme,
                  _addTerm,
                  Icons.add_box,
                  "Add New Line",
                ),
                buildElevatedButton(
                  theme,
                  () {
                    Navigator.pop(
                      context,
                      _terms.where((t) => t.trim().isNotEmpty).toList(),
                    );
                  },
                  Icons.save_as,
                  "Save",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton buildElevatedButton(
    ThemeData theme,
    GestureDragCancelCallback onTap,
    IconData icon,
    String name,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(name),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

