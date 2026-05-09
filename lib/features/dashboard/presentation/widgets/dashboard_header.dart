import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_cubit.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
    //    final compact = constraints.maxWidth < 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final user = state.user;
                return Row(
                  children: [
                    if (user?.profileImage != null)
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(user!.profileImage!),
                      )
                    else
                      const CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.person, size: 32),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null ? 'مرحباً، ${user.fname}' : title,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                      icon: const Badge(
                        label: Text('2'),
                        child: Icon(Icons.notifications_none_rounded, size: 28),
                      ),
                      tooltip: 'الإشعارات',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Wrap(
            //   spacing: 12,
            //   runSpacing: 12,
            //   children: [
            //     const _HeaderPill(label: 'الفرع الرئيسي'),
            //     const _HeaderPill(label: 'مخزن أ'),
            //     if (!compact) const _HeaderPill(label: 'مزامنة سليمة'),
            //   ],
            // ),
          ],
        );
      },
    );
  }
}

// class _HeaderPill extends StatelessWidget {
//   const _HeaderPill({required this.label});

//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: theme.colorScheme.outlineVariant),
//       ),
//       child: Text(label, style: theme.textTheme.labelLarge),
//     );
//   }
// }
