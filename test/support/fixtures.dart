import 'dart:convert';

import 'package:lavaloon_assessment/data/models/auth_user.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

const emily = AuthUser(
  id: 1,
  username: 'emilys',
  email: 'emily.johnson@x.dummyjson.com',
  firstName: 'Emily',
  lastName: 'Johnson',
  image: 'https://dummyjson.com/icon/emilys/128',
);

const michael = AuthUser(id: 2, username: 'michaelw', firstName: 'Michael', lastName: 'Williams');

Product sampleProduct({
  int id = 1,
  String title = 'Essence Mascara Lash Princess',
  double price = 9.99,
  double discountPercentage = 10.48,
  int stock = 99,
  String category = 'beauty',
}) {
  return Product(
    id: id,
    title: title,
    price: price,
    discountPercentage: discountPercentage,
    stock: stock,
    category: category,
    thumbnail: 'https://cdn.dummyjson.com/product-images/$id/thumbnail.webp',
  );
}

String jwtExpiringAt(DateTime expiry) {
  final header = base64Url.encode(utf8.encode('{"alg":"none"}')).replaceAll('=', '');
  final seconds = expiry.millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url.encode(utf8.encode('{"exp":$seconds}')).replaceAll('=', '');

  return '$header.$payload.sig';
}
