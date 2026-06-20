import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';

class WorkEntryDetailsPage extends StatelessWidget {
  final bool isOwnCrane;
  final String client;
  final String location;
  final double total;
  final double deduction;
  final String deductionLabel;

  const WorkEntryDetailsPage({
    super.key,
    required this.isOwnCrane,
    required this.client,
    required this.location,
    required this.total,
    required this.deduction,
    required this.deductionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final net = total - deduction;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent.shade200,
        elevation: 5,
        shadowColor: Colors.blue,
        title: const Text(
          "Entry Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // Header Card
                      EntryHeaderCard(client: client, isOwnCrane: isOwnCrane),
                      const SizedBox(height: 24),

                      // Section 1: Work Identity
                      EntryDetailSection(
                        title: 'Work Identity',
                        children: [
                          EntryDetailRow(
                            icon: Icons.precision_manufacturing_rounded,
                            label: 'Service Type',
                            value: isOwnCrane ? 'Own 25T Crane' : 'Commission/Outsourced',
                          ),
                          const EntryDetailRow(
                            icon: Icons.calendar_month_rounded,
                            label: 'Work Date',
                            value: 'March 29, 2026',
                          ),
                        ],
                      ),

                      // Section 2: Location Details
                      EntryDetailSection(
                        title: 'Location Details',
                        children: [
                          EntryDetailRow(
                            icon: Icons.location_on_rounded,
                            label: 'Worksite',
                            value: location,
                          ),
                          const EntryDetailRow(
                            icon: Icons.map_rounded,
                            label: 'Region',
                            value: 'Dubai, UAE',
                          ),
                        ],
                      ),

                      // Section 3: Financial Breakdown
                      EntryDetailSection(
                        title: 'Financial Breakdown',
                        children: [
                          EntryFinancialRow(
                            label: 'Total Received',
                            amount: total,
                            color: AppTheme.deepNavyBlue,
                          ),
                          EntryFinancialRow(
                            label: deductionLabel,
                            amount: deduction,
                            color: Colors.red.shade900,
                            isDeduction: true,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.white38, thickness: 1),
                          ),
                          EntryFinancialRow(
                            label: 'Profit Commission',
                            amount: net,
                            color: Colors.green.shade900,
                            isNet: true,
                          ),
                        ],
                      ),

                      // Section 4: Status History
                      const EntryDetailSection(
                        title: 'Status History',
                        children: [
                          EntryStatusHistoryRow(
                            status: 'Quotation Generated',
                            time: '09:30 AM',
                            icon: Icons.description_rounded,
                            completed: true,
                          ),
                          EntryStatusHistoryRow(
                            status: 'Marked as Completed',
                            time: '04:45 PM',
                            icon: Icons.check_circle_rounded,
                            completed: true,
                            isLast: true,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
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

class EntryHeaderCard extends StatelessWidget {
  final String client;
  final bool isOwnCrane;

  const EntryHeaderCard({
    super.key,
    required this.client,
    required this.isOwnCrane,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0x59FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border(
          top: BorderSide(color: Color(0x80FFFFFF)),
          bottom: BorderSide(color: Color(0x80FFFFFF)),
          left: BorderSide(color: Color(0x80FFFFFF)),
          right: BorderSide(color: Color(0x80FFFFFF)),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 50,
            // Level 4: Limit GPU texture decode size to 2× display height.
            cacheHeight: 100,
          ),
          const SizedBox(height: 10),
          Text(
            client.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0x1A0A1931),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              isOwnCrane ? 'Own Crane Details' : 'Commission Details',
              style: const TextStyle(
                color: AppTheme.deepNavyBlue,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EntryDetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const EntryDetailSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const BoxDecoration(
        color: Color(0x33FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border(
          top: BorderSide(color: Color(0x40FFFFFF)),
          bottom: BorderSide(color: Color(0x40FFFFFF)),
          left: BorderSide(color: Color(0x40FFFFFF)),
          right: BorderSide(color: Color(0x40FFFFFF)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class EntryDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const EntryDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0x990A1931), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0x800A1931),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EntryFinancialRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isDeduction;
  final bool isNet;

  const EntryFinancialRow({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    this.isDeduction = false,
    this.isNet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xB20A1931),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${isDeduction ? "-" : ""} AED ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: isNet ? 20 : 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class EntryStatusHistoryRow extends StatelessWidget {
  final String status;
  final String time;
  final IconData icon;
  final bool completed;
  final bool isLast;

  const EntryStatusHistoryRow({
    super.key,
    required this.status,
    required this.time,
    required this.icon,
    this.completed = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: completed ? AppTheme.deepNavyBlue : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white38,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      color: AppTheme.deepNavyBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0x800A1931),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
