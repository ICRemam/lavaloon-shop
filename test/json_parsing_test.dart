import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/data/models/auth_session.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/order_result.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/data/models/products_page.dart';

import 'support/fixtures.dart';

void main() {
  test('product json fills missing fields with defaults', () {
    final product = Product.fromJson({'id': 7});

    expect(product.id, 7);
    expect(product.title, isEmpty);
    expect(product.price, 0);
    expect(product.discountPercentage, 0);
    expect(product.stock, 0);
    expect(product.images, isEmpty);
    expect(product.mainImage, isNull);
  });

  test('product json without an id cannot be read', () {
    expect(() => Product.fromJson({}), throwsA(isA<TypeError>()));
  });

  test('an empty products page stays empty', () {
    final page = ProductsPage.fromJson({});

    expect(page.products, isEmpty);
    expect(page.total, 0);
    expect(page.skip, 0);
    expect(page.limit, 0);
  });

  test('a category without a name keeps the slug', () {
    final category = ProductCategory.fromJson({'slug': 'home-decoration'});

    expect(category.name, isEmpty);
    expect(category.displayName, 'Home Decoration');
  });

  test('a user without a name falls back to the id', () {
    final user = AuthUser.fromJson({'id': 4});

    expect(user.username, isNull);
    expect(user.email, isNull);
    expect(user.fullName, 'User 4');
  });

  test('login json accepts accessToken and token', () {
    final fromAccessToken = AuthResponse.fromJson({'id': 1, 'accessToken': 'access', 'refreshToken': 'refresh'});
    final fromToken = AuthResponse.fromJson({'id': 1, 'token': 'legacy'});

    expect(fromAccessToken.accessToken, 'access');
    expect(fromAccessToken.refreshToken, 'refresh');
    expect(fromAccessToken.user.id, 1);
    expect(fromToken.accessToken, 'legacy');
  });

  test('login json without a token is rejected', () {
    expect(() => AuthResponse.fromJson({'id': 1}), throwsA(isA<FormatException>()));
  });

  test('an order can be read when the server omits fields', () {
    final order = OrderResult.fromJson({});

    expect(order.id, isNull);
    expect(order.userId, isNull);
    expect(order.totalProducts, isNull);
    expect(order.totalQuantity, isNull);
  });

  test('a cart line and a session survive a json round trip', () {
    final item = CartItem(product: sampleProduct(), quantity: 2);
    final restoredItem = CartItem.fromJson(item.toJson());
    final expiry = DateTime.utc(2026, 11, 2, 10);
    final session = AuthSession(userId: emily.id, accessToken: 'token', refreshToken: 'refresh', expiresAt: expiry);
    final restoredSession = AuthSession.fromJson(session.toJson());

    expect(restoredItem.product.id, item.product.id);
    expect(restoredItem.quantity, 2);
    expect(restoredSession.userId, emily.id);
    expect(restoredSession.accessToken, 'token');
    expect(restoredSession.refreshToken, 'refresh');
    expect(restoredSession.expiresAt, expiry);
  });
}
