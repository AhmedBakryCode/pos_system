import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/presentation/pages/products_list_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AppShell(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  title: Text('المنتجات'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_statsLabels[index]),
                              const Spacer(),
                              Text(
                                _getStatValue(state, index),
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: 4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.35,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProductBloc>(),
                              child: const ProductsListPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('إدارة المنتجات'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const _statsLabels = [
    'إجمالي المنتجات',
    'منخفضة المخزون',
    'نشطة',
    'موقوفة',
  ];

  String _getStatValue(ProductState state, int index) {
    switch (index) {
      case 0:
        return '${state.totalProducts}';
      case 1:
        return '${state.lowStockCount}';
      case 2:
        return '${state.products.where((p) => p.isActive ?? false).length}';
      case 3:
        return '${state.products.where((p) => !(p.isActive ?? false)).length}';
      default:
        return '0';
    }
  }
}

class _AppShell extends StatelessWidget {
  final Widget child;

  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}