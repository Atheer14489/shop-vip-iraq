import 'cart_item.dart';

enum OrderStatus { pending, shipped, delivered, canceled }

extension OrderStatusArabic on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'قيد المراجعة';
      case OrderStatus.shipped: return 'تم الشحن';
      case OrderStatus.delivered: return 'تم التوصيل';
      case OrderStatus.canceled: return 'ملغي';
    }
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal, discount, shipping, total;
  final DateTime date;
  OrderStatus status;
  final String customerName, customerPhone, customerProvince, customerArea, customerAddress;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.date,
    this.status = OrderStatus.pending,
    required this.customerName,
    required this.customerPhone,
    required this.customerProvince,
    required this.customerArea,
    required this.customerAddress,
  });
}
