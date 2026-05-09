import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_shell.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

import '../widgets/module_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    this.onQuickActionTap,
    this.onModuleTap,
  });

  final ValueChanged<String>? onQuickActionTap;
  final ValueChanged<String>? onModuleTap;







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return AppShell(
            child: switch (state.status) {
              DashboardStatus.loading || DashboardStatus.initial => const Center(
                child: CircularProgressIndicator(),
              ),
              DashboardStatus.failure => Center(
                child: Text(state.errorMessage ?? 'خطأ غير متوقع'),
              ),
              DashboardStatus.loaded => CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: _ModulesPreview(
                        modules: state.modules.cast(),
                        onModuleTap: onModuleTap,
                      ),
                    ),
                  ),
                ],
              ),
            },
          );
        },
      ),
    );
  }
}



class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ModulesPreview extends StatelessWidget {
  const _ModulesPreview({
    required this.modules,
    this.onModuleTap,
  });

  final List modules;
  final ValueChanged<String>? onModuleTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 760 ? 2 : 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: 'الرئيسية',
              subtitle: 'نظام إدارة المتجر والمخزون',
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth < 760 ? 0.92 : 1.18,
              ),
              itemBuilder: (context, index) {
                final module = modules[index];
                return ModuleCard(
                  module: module,
                  onTap: () => onModuleTap?.call(module.title as String),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
