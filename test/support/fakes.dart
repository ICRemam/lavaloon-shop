import 'package:lavaloon_assessment/business_layer/controllers/shared_preference_controller.dart';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/repositories/category_repository.dart';
import 'package:lavaloon_assessment/business_layer/repositories/product_repository.dart';
import 'package:lavaloon_assessment/business_layer/repositories/user_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/login_params.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/data/models/auth_session.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/order_result.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/data/models/products_page.dart';
import 'package:lavaloon_assessment/data_access/storage/session_storage.dart';

class MemorySessionStorage implements SessionStorage {
  AuthSession? session;

  @override
  Future<void> saveSession(AuthSession value) async {
    session = value;
  }

  @override
  Future<AuthSession?> getSession() async => session;

  @override
  Future<void> clearSession() async {
    session = null;
  }
}

class MemoryUserRepository implements UserRepository {
  AuthUser? user;

  @override
  Future<void> saveUser(AuthUser value) async {
    user = value;
  }

  @override
  Future<AuthUser?> getCachedUser(int userId) async {
    if (user?.id != userId) return null;
    return user;
  }

  @override
  Future<void> clearUser() async {
    user = null;
  }
}

class MemoryCartRepository implements CartRepository {
  final Map<int, Map<int, CartItem>> _items = {};

  @override
  Future<List<CartItem>> getItems(int userId) async {
    return List<CartItem>.from(_items[userId]?.values ?? const []);
  }

  @override
  Future<CartItem?> getItem(int userId, int productId) async {
    return _items[userId]?[productId];
  }

  @override
  Future<void> saveItem(int userId, CartItem item) async {
    final cart = _items.putIfAbsent(userId, () => {});
    cart[item.product.id] = item;
  }

  @override
  Future<void> removeItem(int userId, int productId) async {
    _items[userId]?.remove(productId);
  }

  @override
  Future<void> clear(int userId) async {
    _items.remove(userId);
  }
}

class MemoryProductRepository implements ProductRepository {
  final Map<int, Product> _products = {};
  final Map<int, int> _positions = {};

  @override
  Future<void> upsertProducts(List<Product> products, {int? startPosition}) async {
    for (var index = 0; index < products.length; index++) {
      final product = products[index];
      _products[product.id] = product;
      if (startPosition != null) {
        _positions[product.id] = startPosition + index;
      } else {
        _positions.putIfAbsent(product.id, () => (1 << 30) + product.id);
      }
    }
  }

  @override
  Future<List<Product>> getProducts({required int skip, required int limit, String? query, String? categorySlug}) async {
    final matched = _matching(query, categorySlug);
    if (skip >= matched.length) return [];

    final end = skip + limit;
    return matched.sublist(skip, end > matched.length ? matched.length : end);
  }

  @override
  Future<int> countProducts({String? query, String? categorySlug}) async {
    return _matching(query, categorySlug).length;
  }

  @override
  Future<Product?> getProductById(int id) async => _products[id];

  List<Product> _matching(String? query, String? categorySlug) {
    final trimmed = query?.trim().toLowerCase() ?? '';
    final matched = _products.values.where((product) {
      final matchesQuery = trimmed.isEmpty || product.title.toLowerCase().contains(trimmed);
      final matchesCategory = categorySlug == null || categorySlug.isEmpty || product.category == categorySlug;
      return matchesQuery && matchesCategory;
    }).toList();

    matched.sort((left, right) {
      final byPosition = (_positions[left.id] ?? 0).compareTo(_positions[right.id] ?? 0);
      if (byPosition != 0) return byPosition;
      return left.id.compareTo(right.id);
    });

    return matched;
  }
}

class MemoryCategoryRepository implements CategoryRepository {
  List<ProductCategory> categories = [];

  @override
  Future<void> replaceCategories(List<ProductCategory> values) async {
    categories = List<ProductCategory>.from(values);
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    return List<ProductCategory>.from(categories);
  }
}

class MemoryPreferences implements SharedPreferenceController {
  final Map<String, String> values = {};

  @override
  Future<String?> getString({required String key}) async => values[key];

  @override
  Future<void> setString({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> remove({required String key}) async {
    values.remove(key);
  }
}

class FakeIntegrator implements Integrator {
  AuthResponse? loginResponse;
  RequestException? loginError;
  Future<AuthResponse>? pendingLogin;
  AuthUser? currentUser;
  RequestException? currentUserError;
  ProductsPage productsPage = const ProductsPage();
  ProductsPage Function(int skip)? productsForSkip;
  RequestException? productsError;
  Product? product;
  RequestException? productError;
  List<ProductCategory> categories = const [];
  RequestException? categoriesError;
  OrderResult order = const OrderResult(id: 50, userId: 1, totalProducts: 1, totalQuantity: 1);
  RequestException? submitError;
  int loginCalls = 0;
  int submitCalls = 0;

  @override
  Future<AuthResponse> login(LoginParams params) async {
    loginCalls++;
    final pending = pendingLogin;
    if (pending != null) return pending;
    final error = loginError;
    if (error != null) throw error;
    return loginResponse!;
  }

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async {
    final error = currentUserError;
    if (error != null) throw error;
    return currentUser!;
  }

  @override
  Future<ProductsPage> getProducts({required int skip, required int limit}) {
    return _products(skip);
  }

  @override
  Future<ProductsPage> searchProducts({required String query, required int skip, required int limit}) {
    return _products(skip);
  }

  @override
  Future<ProductsPage> getProductsByCategory({required String slug, required int skip, required int limit}) {
    return _products(skip);
  }

  Future<ProductsPage> _products(int skip) async {
    final error = productsError;
    if (error != null) throw error;
    final paged = productsForSkip;
    if (paged != null) return paged(skip);
    return productsPage;
  }

  @override
  Future<Product> getProduct(int id) async {
    final error = productError;
    if (error != null) throw error;
    return product!;
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    final error = categoriesError;
    if (error != null) throw error;
    return categories;
  }

  @override
  Future<OrderResult> submitCart({required int userId, required List<CartItem> items}) async {
    submitCalls++;
    final error = submitError;
    if (error != null) throw error;
    return order;
  }
}
