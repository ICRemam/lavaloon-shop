import 'package:lavaloon_assessment/business_layer/useCases/params/login_params.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/order_result.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/data/models/products_page.dart';

abstract class Integrator {
  Future<AuthResponse> login(LoginParams params);

  Future<AuthUser> getCurrentUser(String accessToken);

  Future<ProductsPage> getProducts({required int skip, required int limit});

  Future<ProductsPage> searchProducts({required String query, required int skip, required int limit});

  Future<ProductsPage> getProductsByCategory({required String slug, required int skip, required int limit});

  Future<Product> getProduct(int id);

  Future<List<ProductCategory>> getCategories();

  Future<OrderResult> submitCart({required int userId, required List<CartItem> items});
}
