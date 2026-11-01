import 'package:dio/dio.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/login_params.dart';
import 'package:lavaloon_assessment/data/abstract/handle_request_excp_mixin.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/constants/app_constants.dart';
import 'package:lavaloon_assessment/data/constants/endpoints.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/order_result.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/data/models/products_page.dart';

class DummyJsonIntegrator with HandleRequestException implements Integrator {
  final Dio client;

  DummyJsonIntegrator({Dio? client}) : client = client ?? _createClient();

  static Dio _createClient() {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
  }

  @override
  Future<AuthResponse> login(LoginParams params) async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.post(EndpointsRoutes.loginEndpoint.path, data: params.toJson());

        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.get(
          EndpointsRoutes.currentUserEndpoint.path,
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );

        return AuthUser.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<ProductsPage> getProducts({required int skip, required int limit}) async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.get(EndpointsRoutes.productsEndpoint.path, queryParameters: {'limit': limit, 'skip': skip});

        return ProductsPage.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<ProductsPage> searchProducts({required String query, required int skip, required int limit}) async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.get(
          EndpointsRoutes.searchProductsEndpoint.path,
          queryParameters: {'q': query, 'limit': limit, 'skip': skip},
        );

        return ProductsPage.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<ProductsPage> getProductsByCategory({required String slug, required int skip, required int limit}) async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.get(
          EndpointsRoutes.productsByCategoryEndpoint.withSegment(Uri.encodeComponent(slug)),
          queryParameters: {'limit': limit, 'skip': skip},
        );

        return ProductsPage.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<Product> getProduct(int id) async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.get(EndpointsRoutes.productsEndpoint.withSegment(id));

        return Product.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.get(EndpointsRoutes.categoriesEndpoint.path);

        return (response.data as List).map((json) {
          if (json is String) return ProductCategory.fromSlug(json);
          return ProductCategory.fromJson(json as Map<String, dynamic>);
        }).toList();
      },
    );
  }

  @override
  Future<OrderResult> submitCart({required int userId, required List<CartItem> items}) async {
    return handleRequestExceptions(
      method: () async {
        final response = await client.post(
          EndpointsRoutes.submitCartEndpoint.path,
          data: {
            'userId': userId,
            'products': [
              for (final item in items) {'id': item.product.id, 'quantity': item.quantity},
            ],
          },
        );

        return OrderResult.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }
}
