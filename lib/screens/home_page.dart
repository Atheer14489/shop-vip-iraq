import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

/// Main landing page of the application displaying a list of products and
/// shortcuts to the cart and, if authorised, the admin dashboard. Users can
/// add products to their cart from here.
class HomePage extends StatelessWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final products = appState.products;
    final cartLength = appState.cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          // Show admin dashboard button only for administrators
          if (appState.user?.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.dashboard),
              tooltip: 'لوحة التحكم',
              onPressed: () {
                Navigator.of(context).pushNamed('/admin');
              },
            ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'سلة المشتريات',
                onPressed: () {
                  // Navigate to a cart page if implemented. For now show a dialog.
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('السلة'),
                      content: cartLength == 0
                          ? const Text('السلة فارغة')
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: appState.cartItems.length,
                                itemBuilder: (context, index) {
                                  final CartItem item = appState.cartItems[index];
                                  return ListTile(
                                    title: Text(item.product.name),
                                    subtitle: Text('الكمية: ${item.quantity}'),
                                    trailing: Text('السعر: ${(item.product.price * item.quantity).toStringAsFixed(2)} د.ع'),
                                  );
                                },
                              ),
                            ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إغلاق'),
                        ),
                        if (cartLength > 0)
                          ElevatedButton(
                            onPressed: () {
                              appState.placeOrder();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إتمام الطلب بنجاح')),
                              );
                            },
                            child: const Text('إتمام الطلب'),
                          ),
                      ],
                    ),
                  );
                },
              ),
              if (cartLength > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    cartLength.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: products.isEmpty
          ? _buildEmptyCatalogue(context, appState)
          : _buildProductList(context, products, appState),
    );
  }

  /// Displays a simple prompt and button when the product catalogue is empty.
  Widget _buildEmptyCatalogue(BuildContext context, AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'لا توجد منتجات متاحة حالياً.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Populate with some sample products for demonstration.
              final demoProducts = [
                Product(
                  id: 'p1',
                  name: 'جهاز محمول',
                  description: 'جهاز محمول حديث',
                  price: 500.0,
                  imageUrl: 'https://via.placeholder.com/150',
                ),
                Product(
                  id: 'p2',
                  name: 'سماعات لاسلكية',
                  description: 'سماعات ذات جودة صوت عالية',
                  price: 150.0,
                  imageUrl: 'https://via.placeholder.com/150',
                ),
                Product(
                  id: 'p3',
                  name: 'ساعة ذكية',
                  description: 'ساعة لمتابعة نشاطك اليومي',
                  price: 200.0,
                  imageUrl: 'https://via.placeholder.com/150',
                ),
              ];
              appState
                ..products.addAll(demoProducts)
                ..notifyListeners();
            },
            child: const Text('إضافة منتجات تجريبية'),
          ),
        ],
      ),
    );
  }

  /// Builds the list of products using a [ListView.builder]. Each card shows
  /// product details and an add‑to‑cart button.
  Widget _buildProductList(BuildContext context, List<Product> products, AppState appState) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Image.network(
              product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${product.price.toStringAsFixed(2)} د.ع'),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  tooltip: 'إضافة إلى السلة',
                  onPressed: () {
                    appState.addProductToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم إضافة ${product.name} إلى السلة'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
