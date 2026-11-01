import 'package:lavaloon_assessment/data/abstract/base_mapper.dart';
import 'package:lavaloon_assessment/business_layer/entities/cart_item_entity.dart';
import 'package:lavaloon_assessment/data/mappers/product_mapper.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';

class CartItemMapper extends BaseMapper<CartItem, CartItemEntity> {
  final ProductMapper _productMapper;

  CartItemMapper({ProductMapper? productMapper}) : _productMapper = productMapper ?? ProductMapper();

  @override
  CartItemEntity convert(CartItem obj) {
    return CartItemEntity(userId: 0, product: _productMapper.convert(obj.product), quantity: obj.quantity);
  }

  @override
  CartItem convertBack(CartItemEntity obj) {
    return CartItem(product: _productMapper.convertBack(obj.product), quantity: obj.quantity);
  }
}
