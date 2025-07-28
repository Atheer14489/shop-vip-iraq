import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/coupon.dart';
import '../models/order.dart';
import '../providers/app_state.dart';

/// Administrative dashboard for managing products, coupons and orders. This
/// screen should only be accessible to users with administrator privileges.
class AdminDashboardPage extends StatefulWidget {
  static const routeName = '/admin';

  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Controllers for product creation form
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productImageUrlController = TextEditingController();

  // Controllers for coupon creation form
  final _couponCodeController = TextEditingController();
  final _couponDiscountController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productImageUrlController.dispose();
    _couponCodeController.dispose();
    _couponDiscountController.dispose();
    super.dispose();
  }

  /// Helper to clear all product form fields after submission.
  void _clearProductFields() {
    _productNameController.clear();
    _productDescriptionController.clear();
    _productPriceController.clear();
    _productImageUrlController.clear();
  }

  /// Helper to clear all coupon form fields after submission.
  void _clearCouponFields() {
    _couponCodeController.clear();
    _couponDiscountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Redirect if not admin
    if (appState.user?.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم')),
        body: const Center(
          child: Text('ليس لديك صلاحية الوصول إلى هذه الصفحة.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المسؤول'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'المنتجات'),
                Tab(text: 'القسائم'),
                Tab(text: 'الطلبات'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProductsTab(appState),
                  _buildCouponsTab(appState),
                  _buildOrdersTab(appState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the products management tab allowing administrators to add new
  /// products and view existing ones.
  Widget _buildProductsTab(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إضافة منتج جديد',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _productNameController,
            decoration: const InputDecoration(labelText: 'اسم المنتج'),
          ),
          TextField(
            controller: _productDescriptionController,
            decoration: const InputDecoration(labelText: 'وصف المنتج'),
          ),
          TextField(
            controller: _productPriceController,
            decoration: const InputDecoration(labelText: 'السعر'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _productImageUrlController,
            decoration: const InputDecoration(labelText: 'رابط الصورة'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final name = _productNameController.text.trim();
              final desc = _productDescriptionController.text.trim();
              final priceString = _productPriceController.text.trim();
              final imageUrl = _productImageUrlController.text.trim();
              if (name.isEmpty || desc.isEmpty || priceString.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                );
                return;
              }
              final price = double.tryParse(priceString);
              if (price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سعر غير صالح')),
                );
                return;
              }
              final newProduct = Product(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                description: desc,
                price: price,
                imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150',
              );
              appState.products.add(newProduct);
              appState.notifyListeners();
              _clearProductFields();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إضافة المنتج $name')),
              );
            },
            child: const Text('إضافة المنتج'),
          ),
          const Divider(height: 32),
          const Text(
            'قائمة المنتجات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (appState.products.isEmpty)
            const Text('لا توجد منتجات.')
          else
            for (final product in appState.products)
              ListTile(
                title: Text(product.name),
                subtitle: Text('السعر: ${product.price.toStringAsFixed(2)} د.ع'),
              ),
        ],
      ),
    );
  }

  /// Builds the coupons management tab where administrators can add new
  /// discount coupons and view existing ones.
  Widget _buildCouponsTab(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إضافة قسيمة جديدة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _couponCodeController,
            decoration: const InputDecoration(labelText: 'رمز القسيمة'),
          ),
          TextField(
            controller: _couponDiscountController,
            decoration: const InputDecoration(labelText: 'نسبة الخصم (%)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final code = _couponCodeController.text.trim();
              final discountString = _couponDiscountController.text.trim();
              if (code.isEmpty || discountString.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                );
                return;
              }
              final discount = double.tryParse(discountString);
              if (discount == null || discount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('نسبة خصم غير صالحة')),
                );
                return;
              }
              final coupon = Coupon(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                code: code,
                discountPercent: discount,
                validUntil: DateTime.now().add(const Duration(days: 30)),
              );
              appState.addCoupon(coupon);
              _clearCouponFields();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إضافة القسيمة $code')),
              );
            },
            child: const Text('إضافة القسيمة'),
          ),
          const Divider(height: 32),
          const Text(
            'القسائم المتاحة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (appState.coupons.isEmpty)
            const Text('لا توجد قسائم.')
          else
            for (final coupon in appState.coupons)
              ListTile(
                title: Text('رمز: ${coupon.code}'),
                subtitle: Text('خصم: ${coupon.discountPercent.toStringAsFixed(0)}%'),
              ),
        ],
      ),
    );
  }

  /// Builds the orders management tab. Administrators can view all orders and
  /// update their statuses.
  Widget _buildOrdersTab(AppState appState) {
    final orders = appState.orders;
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text('طلب رقم ${order.id}'),
            subtitle: Text('العميل: ${order.user.name}\nالحالة: ${order.status.label}'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المحتويات:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    for (final item in order.items)
                      Text('- ${item.product.name} x ${item.quantity}'),
                    const SizedBox(height: 8),
                    DropdownButton<OrderStatus>(
                      value: order.status,
                      onChanged: (newStatus) {
                        if (newStatus == null) return;
                        setState(() {
                          final updatedOrder = order.copyWith(status: newStatus);
                          orders[index] = updatedOrder;
                        });
                        appState.notifyListeners();
                      },
                      items: OrderStatus.values
                          .map(
                            (status) => DropdownMenuItem<OrderStatus>(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
