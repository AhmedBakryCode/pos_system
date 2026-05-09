import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<SalesOrder>> getOrders({int page = 1});
  
  Future<SalesOrder> createOrder({
    required List<OrderItemInput> items,
  });

  Future<void> deleteOrder(int id);
}
