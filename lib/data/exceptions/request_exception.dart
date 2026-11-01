import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';

class RequestException implements Exception {
  final String message;
  final String? stackTrace;
  final RequestErrorType type;

  const RequestException(this.type, this.message, [this.stackTrace]);

  @override
  String toString() => 'RequestException(${type.name}): $message';
}
