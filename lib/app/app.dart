import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../features/dashboard/presentation/pages/notifications_page.dart';
import '../features/home/presentation/pages/main_navigation_page.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/products/presentation/bloc/product_bloc.dart';
import '../features/products/presentation/bloc/items_cubit.dart';
import '../features/reports/presentation/bloc/reports_cubit.dart';
import 'di/injection.dart';

class PosSystemApp extends StatelessWidget {
  const PosSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuth(),
        ),
        BlocProvider<DashboardCubit>(
          create: (_) => sl<DashboardCubit>()..loadModules(),
        ),
        BlocProvider<ProductBloc>(
          create: (_) => sl<ProductBloc>(),
        ),
        BlocProvider<ItemsCubit>(
          create: (_) => sl<ItemsCubit>()..loadItems(),
        ),
        BlocProvider<ReportsCubit>(
          create: (_) => sl<ReportsCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'نظام إدارة المخزون',
        theme: buildLightAppTheme(),
        darkTheme: buildDarkAppTheme(),
        themeMode: ThemeMode.system,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        routes: {
          '/notifications': (context) => const NotificationsPage(),
        },
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.loading || state.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == AuthStatus.authenticated) {
              return const MainNavigationPage();
            }
            return LoginPage(
              onLoginSuccess: () {},
            );
          },
        ),
      ),
    );
  }
}
