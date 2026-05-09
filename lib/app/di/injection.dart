import 'package:get_it/get_it.dart';

import '../../core/offline/in_memory_sync_service.dart';
import '../../core/offline/sync_service.dart';
import '../../features/audit_reports/data/repositories/audit_repository_impl.dart';
import '../../features/audit_reports/domain/repositories/audit_repository.dart';
import '../../features/audit_reports/domain/usecases/get_audit_kpis.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/inventory_tracking/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory_tracking/domain/repositories/inventory_repository.dart';
import '../../features/inventory_tracking/domain/usecases/get_inventory_summary.dart';
import '../../features/pos_integration/data/repositories/pos_repository_impl.dart';
import '../../features/pos_integration/domain/repositories/pos_repository.dart';
import '../../features/pos_integration/domain/usecases/get_pos_sync_status.dart';
import '../../features/purchase_orders/data/repositories/purchase_order_repository_impl.dart';
import '../../features/purchase_orders/domain/repositories/purchase_order_repository.dart';
import '../../features/purchase_orders/domain/usecases/get_purchase_order_summary.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../features/shared/domain/services/dashboard_metrics_service.dart';
import '../../features/shared/domain/services/dashboard_metrics_service_impl.dart';
import '../../features/shared/domain/services/inventory_event_factory.dart';
import '../../features/shared/domain/services/inventory_policy_service.dart';
import '../../features/transactions/data/repositories/mock_transaction_repository.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/approve_transaction.dart'
    as transaction_usecases;
import '../../features/transactions/domain/usecases/create_transaction.dart'
    as transaction_usecases;
import '../../features/transactions/domain/usecases/post_transaction.dart'
    as transaction_usecases;
import '../../features/transactions/domain/usecases/update_transaction.dart'
    as transaction_usecases;
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/shared_preferences_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/products/data/repositories/attributes_repository_impl.dart';
import '../../features/products/data/repositories/item_repository_impl.dart';
import '../../features/products/domain/repositories/attributes_repository.dart';
import '../../features/products/domain/repositories/item_repository.dart';
import '../../features/products/presentation/bloc/categories_cubit.dart';
import '../../features/products/presentation/bloc/items_cubit.dart';
import '../../features/products/presentation/bloc/units_cubit.dart';
import '../../features/goods_receipt_notes/data/repositories/grn_repository_impl.dart';
import '../../features/goods_receipt_notes/domain/repositories/grn_repository.dart';
import '../../features/goods_receipt_notes/presentation/bloc/grn_cubit.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/presentation/bloc/order_cubit.dart';
import '../../features/production_management/data/repositories/production_repository_impl.dart';
import '../../features/production_management/domain/repositories/production_repository.dart';
import '../../features/production_management/presentation/bloc/production_cubit.dart';
import '../../features/stock_counting/data/repositories/stock_count_repository_impl.dart';
import '../../features/stock_counting/domain/repositories/stock_count_repository.dart';
import '../../features/stock_counting/presentation/bloc/stock_count_cubit.dart';
import '../../features/waste_management/data/repositories/waste_repository_impl.dart';
import '../../features/waste_management/domain/repositories/waste_repository.dart';
import '../../features/waste_management/presentation/bloc/waste_cubit.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/presentation/bloc/reports_cubit.dart';
import '../../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../../features/recipes/domain/repositories/recipe_repository.dart';
import '../../features/recipes/presentation/bloc/recipe_cubit.dart';
import '../../features/purchase_orders/data/repositories/purchases_repository_impl.dart';
import '../../features/purchase_orders/domain/repositories/purchases_repository.dart';
import '../../features/purchase_orders/presentation/bloc/purchases_cubit.dart';
import '../../features/purchase_orders/presentation/bloc/suppliers_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<SharedPreferencesService>(() => SharedPreferencesService(sl()));
  
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl(), sl()));
  
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<AttributesRepository>(() => AttributesRepositoryImpl(sl()));
  sl.registerLazySingleton<ItemRepository>(() => ItemRepositoryImpl(sl()));
  sl.registerLazySingleton<PurchasesRepository>(() => PurchasesRepositoryImpl(sl()));
  sl.registerLazySingleton<GRNRepository>(() => GRNRepositoryImpl(sl()));
  sl.registerLazySingleton<RecipeRepository>(() => RecipeRepositoryImpl(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  sl.registerLazySingleton<ProductionRepository>(() => ProductionRepositoryImpl(sl()));
  sl.registerLazySingleton<StockCountRepository>(() => StockCountRepositoryImpl(sl()));
  sl.registerLazySingleton<WasteRepository>(() => WasteRepositoryImpl(sl()));
  sl.registerLazySingleton<ReportsRepository>(() => ReportsRepositoryImpl(sl()));

  sl
    ..registerLazySingleton<SyncService>(InMemorySyncService.new)
    ..registerLazySingleton<InventoryRepository>(InventoryRepositoryImpl.new)
    ..registerLazySingleton<PurchaseOrderRepository>(
      PurchaseOrderRepositoryImpl.new,
    )
    ..registerLazySingleton<PosRepository>(PosRepositoryImpl.new)
    ..registerLazySingleton<AuditRepository>(AuditRepositoryImpl.new)
    ..registerLazySingleton(InventoryPolicyService.new)
    ..registerLazySingleton(InventoryEventFactory.new)
    ..registerLazySingleton(() => GetInventorySummary(sl()))
    ..registerLazySingleton(() => GetPurchaseOrderSummary(sl()))
    ..registerLazySingleton(() => GetPosSyncStatus(sl()))
    ..registerLazySingleton(() => GetAuditKpis(sl()))
    ..registerLazySingleton<ProductLocalDatasource>(ProductLocalDatasource.new)
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl()),
    )
    ..registerFactory(() => ProductBloc(sl()))
    ..registerLazySingleton<DashboardMetricsService>(
      () => DashboardMetricsServiceImpl(
        getInventorySummary: sl(),
        getPurchaseOrderSummary: sl(),
        getPosSyncStatus: sl(),
        getAuditKpis: sl(),
        syncService: sl(),
      ),
    )
    ..registerLazySingleton<TransactionRepository>(
      () => MockTransactionRepository(
        inventoryPolicyService: sl(),
        inventoryEventFactory: sl(),
      ),
    )
    ..registerLazySingleton(
      () => transaction_usecases.CreateTransaction(sl()),
    )
    ..registerLazySingleton(
      () => transaction_usecases.UpdateTransaction(sl()),
    )
    ..registerLazySingleton(
      () => transaction_usecases.ApproveTransaction(sl()),
    )
    ..registerLazySingleton(
      () => transaction_usecases.PostTransaction(sl()),
    )
    ..registerFactory(() => DashboardCubit(sl()))
    ..registerFactory(() => AuthCubit(sl()))
    ..registerFactory(() => UnitsCubit(sl()))
    ..registerFactory(() => CategoriesCubit(sl()))
    ..registerFactory(() => ItemsCubit(sl()))
    ..registerFactory(() => PurchasesCubit(sl()))
    ..registerFactory(() => SuppliersCubit(sl()))
    ..registerFactory(() => GRNCubit(sl()))
    ..registerFactory(() => RecipeCubit(sl()))
    ..registerFactory(() => OrderCubit(sl()))
    ..registerFactory(() => ProductionCubit(sl()))
    ..registerFactory(() => StockCountCubit(sl()))
    ..registerFactory(() => WasteCubit(sl()))
    ..registerFactory(() => ReportsCubit(sl()))
    ..registerFactory(
      () => TransactionBloc(
        createTransaction: sl(),
        updateTransaction: sl(),
        approveTransaction: sl(),
        postTransaction: sl(),
      ),
    );
}
