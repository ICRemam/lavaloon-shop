enum BusinessExceptionType {
  inputValuesIsMissingOrIncorrect(code: 1, message: 'Please fill in all required fields.'),
  invalidCredentials(code: 2, message: 'Invalid username or password.'),
  sessionExpired(code: 3, message: 'Your session has expired. Please log in again.'),
  noActiveUser(code: 4, message: 'No signed in user.'),
  quantityMustBePositive(code: 5, message: 'Quantity must be a positive whole number.'),
  productOutOfStock(code: 6, message: 'This product is out of stock.'),
  quantityExceedsStock(code: 7, message: 'Only {0} available in stock.'),
  cartIsEmpty(code: 8, message: 'Your cart is empty.'),
  productNotFound(code: 9, message: 'Product not found.'),
  noCachedData(code: 10, message: 'No cached data available. Check your connection and try again.'),
  processingError(code: 11, message: 'Something went wrong while processing your request.')
  ;

  final int code;
  final String message;
  const BusinessExceptionType({required this.code, required this.message});
}

class BusinessException implements Exception {
  final BusinessExceptionType type;
  final String? customMessage;
  final List<Object> args;

  const BusinessException(this.type, {this.customMessage, this.args = const []});

  String get message {
    var text = customMessage ?? type.message;
    for (var i = 0; i < args.length; i++) {
      text = text.replaceAll('{$i}', args[i].toString());
    }
    return text;
  }

  @override
  String toString() => 'BusinessException(${type.name}): $message';
}
