import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/coupon.dart';

/// Centralised application state using the [ChangeNotifier] pattern.
///
/// This class manages the currently authenticated user, catalogue of products,
/// contents of the shopping cart, orders, available coupons and the selected
/// location information.  It exposes convenience getters and methods to
/// update state and notifies listeners when mutations occur.  The intent is
/// to keep business logic out of the UI and make it easier to test.
class AppState extends ChangeNotifier {
  /// The current authenticated user. When null the user is considered
  /// unauthenticated.
  User? _user;

  /// In‑memory list of all available products. In a real application this
  /// would likely be fetched from a back‑end service or database.
  final List<Product> _products = [];

  /// Items currently in the shopping cart.
  final List<CartItem> _cartItems = [];

  /// Orders placed by the user.
  final List<Order> _orders = [];

  /// Available coupons loaded into the system. This list can be used to
  /// validate and apply discounts during checkout.
 
  final List<Coupon> _coupons = [];

  /// Hierarchical location data loaded from assets. Each entry represents a
  /// governorate with its districts and optional subdistricts. Use
  /// [loadLocations] to initialise this field.
  List<Map<String, dynamic>> _locations = [];

  /// Hard‑coded credentials for demonstration purposes. In a real
  /// application you would fetch users from a back‑end or database and
  /// securely verify passwords. The keys are usernames (e.g. email
  /// addresses) and the values hold the password, display name and an
  /// `isAdmin` flag indicating whether the account has administrative
  /// privileges.
  final Map<String, Map<String, dynamic>> _users = {
    'admin@shopvipiraq.com': {
      'password': 'admin1234',
      'name': 'المدير',
      'isAdmin': true,
    },
    'user@shopvipiraq.com': {
      'password': 'user1234',
      'name': 'مستخدم',
      'isAdmin': false,
    },
  };

  /// Returns the currently authenticated user or null if no user is logged in.
  User? get user => _user;

  /// True if a user is logged in.
  bool get isAuthenticated => _user != null;

  /// Unmodifiable view of the product catalogue.
  List<Product> get products => List.unmodifiable(_products);

  
  /// Unmodifiable view of the shopping cart.
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  /// Unmodifiable view of orders placed.
  List<Order> get orders => List.unmodifiable(_orders);

  /// Unmodifiable view of available coupons.
  List<Coupon> get coupons => List.unmodifiable(_coupons);

  /// Unmodifiable view of loaded locations.
  List<Map<String, dynamic>> get locations => List.unmodifiable(_locations);

  /// Logs a user into the application. A new [User] instance should be
  /// provided, typically after validating credentials. This will notify
  /// listeners so any dependent widgets can rebuild.
  void login(User user) {
    _user = user;
    notifyListeners();
  }

  /// Authenticates the provided [username] and [password] against the
  /// internally defined [_users] map. If the credentials match an
  /// entry, a [User] is created with the corresponding name and
  /// `isAdmin` flag. The method returns `true` on success and
  /// `false` otherwise. This simulates a basic login system.
  Future<bool> authenticate(String username, String password) async {
    // Simulate a network/database delay
    await Future.delayed(const Duration(milliseconds: 500));
    final entry = _users[username];
    if (entry != null && entry['password'] == password) {
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: entry['name'] as String,
        email: username,
        isAdmin: entry['isAdmin'] as bool,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Logs out the current user and clears the cart. All other state such
  /// as product catalogue and coupons remain intact. Listeners are notified
  /// about the change.
  void logout() {
    _user = null;
    _cartItems.clear();
    notifyListeners();
  }

  /// Adds [product] to the shopping cart. If the product already exists in
  /// the cart its quantity is increased by [quantity]. After mutation the
  /// [notifyListeners] method is called.
  void addProductToCart(Product product, {int quantity = 1}) {
    final existing = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    if (existing.quantity == 0) {
      _cartItems.add(existing);
    }
    existing.quantity += quantity;
    notifyListeners();
  }

  /// Decreases the quantity of [product] in the cart by one. If the quantity
  /// reaches zero the item is removed entirely. Does nothing if the product
  /// is not present in the cart. After mutation listeners are notified.
  void removeSingleFromCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex == -1) return;
    final existing = _cartItems[existingIndex];
    existing.quantity -= 1;
    if (existing.quantity <= 0) {
      _cartItems.removeAt(existingIndex);
    }
    notifyListeners();
  }

  /// Removes an entire [CartItem] from the cart regardless of quantity.
  void removeItemFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  /// Clears all items from the cart.
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Computes the total cost of the cart by summing each item price multiplied
  /// by its quantity. If products have been updated with discounts this
  /// calculation will reflect the latest values.
  double get cartTotal {
    return _cartItems.fold(0.0, (total, item) => total + item.product.price * item.quantity);
  }

  /// Places an order using the current cart contents. An [Order] object is
  /// created and appended to the orders list. Afterwards the cart is
  /// cleared. If no user is logged in the operation is ignored.
  void placeOrder() {
    if (!isAuthenticated || _cartItems.isEmpty) return;
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: _user!,
      items: List.from(_cartItems),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.add(order);
    clearCart();
    notifyListeners();
  }

  /// Adds a new coupon to the list of available coupons. This could be
  /// triggered from an admin interface. You may implement validation logic
  /// here if you need to avoid duplicate codes.
  void addCoupon(Coupon coupon) {
    _coupons.add(coupon);
    notifyListeners();
  }

  /// Loads the hierarchical locations from the JSON file in assets. The file
  /// should be declared in `pubspec.yaml` under the assets section. Upon
  /// successful parsing the internal list is updated and listeners are
  /// notified. Errors are silently swallowed but printed in debug mode.
  Future<void> loadLocations() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/locations.json');
      final decoded = json.decode(jsonString) as List<dynamic>;
      _locations = decoded.cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load locations: $e');
      }
    }
  }
}
