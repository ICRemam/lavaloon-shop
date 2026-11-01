import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

class CartValidator {
  const CartValidator();

  void validateQuantity(int quantity) {
    if (quantity <= 0) {
      throw const BusinessException(BusinessExceptionType.quantityMustBePositive);
    }
  }

  void validateStock(Product product, int totalQuantity) {
    if (product.stock <= 0) {
      throw const BusinessException(BusinessExceptionType.productOutOfStock);
    }

    if (totalQuantity > product.stock) {
      throw BusinessException(BusinessExceptionType.quantityExceedsStock, args: [product.stock]);
    }
  }

  void validateCanAdd(Product product, {required int currentQuantity, required int quantityToAdd}) {
    validateQuantity(quantityToAdd);
    validateStock(product, currentQuantity + quantityToAdd);
  }

  void validateCanUpdate(Product product, {required int newQuantity}) {
    validateQuantity(newQuantity);
    validateStock(product, newQuantity);
  }
}
