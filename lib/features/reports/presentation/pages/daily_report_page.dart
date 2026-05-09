import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/reports_cubit.dart';
import '../bloc/reports_state.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadDailyReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقرير اليومي')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportsStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'خطأ في جلب البيانات'));
          }

          final report = state.dailyReport;

          if (report == null) {
            return const Center(child: Text('لا توجد بيانات متاحة حالياً'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _ReportSummaryCard(
                  title: 'إجمالي المبيعات',
                  value: report.sales,
                  icon: Icons.point_of_sale,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _ReportSummaryCard(
                  title: 'إجمالي التكلفة',
                  value: report.cost,
                  icon: Icons.payments_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _ReportSummaryCard(
                  title: 'صافي الربح',
                  value: report.profit,
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _ReportSummaryCard(
                  title: 'إجمالي الهالك',
                  value: report.waste,
                  icon: Icons.delete_sweep_outlined,
                  color: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value ج.م',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
