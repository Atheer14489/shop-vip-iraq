import 'cart_item.dart';

// Define order statuses with Arabic labels
enum OrderStatus { pending, shipped, delivered, canceled }

extension OrderStatusArabic on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد المراجعة';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم الوصول';
      case OrderStatus.canceled:
        return 'ملغي';
    }
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final DateTime date;
  OrderStatus status;
  final String customerName;
  final String customerPhone;
  final String customerProvince;
  final String customerArea;
  final String customerAddress;

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

  /// Returns a copy of this order with the specified fields replaced.
  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? shipping,
    double? total,
    DateTime? date,
    OrderStatus? status,
    String? customerName,
    String? customerPhone,
    String? customerProvince,
    String? customerArea,
    String? customerAddress,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? List<CartItem>.from(this.items),
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      date: date ?? this.date,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerProvince: customerProvince ?? this.customerProvince,
      customerArea: customerArea ?? this.customerArea,
      customerAddress: customerAddress ?? this.customerAddress,
    );
  }
}
