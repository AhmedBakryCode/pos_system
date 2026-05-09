import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/reports_cubit.dart';
import '../bloc/reports_state.dart';

class ProfitReportPage extends StatefulWidget {
  const ProfitReportPage({super.key});

  @override
  State<ProfitReportPage> createState() => _ProfitReportPageState();
}

class _ProfitReportPageState extends State<ProfitReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadProfitReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الأرباح')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportsStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'خطأ في جلب البيانات'));
          }

          if (state.profitReport.isEmpty) {
            return const Center(child: Text('لا توجد بيانات للأرباح حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.profitReport.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = state.profitReport[index];
              return _ProfitItemTile(reportItem: item);
            },
          );
        },
      ),
    );
  }
}

class _ProfitItemTile extends StatelessWidget {
  const _ProfitItemTile({required this.reportItem});

  final dynamic reportItem;

  @override
  Widget build(BuildContext context) {
    final profitValue = double.tryParse(reportItem.profit) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: const Icon(Icons.receipt_long, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب رقم: ${reportItem.orderId}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'الإيراد: ${reportItem.revenue} | التكلفة: ${reportItem.cost}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${reportItem.profit} ج.م',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: profitValue >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const Text(
                'صافي الربح',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
