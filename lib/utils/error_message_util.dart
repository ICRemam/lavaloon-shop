import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';

class ErrorMessageUtil {
  static String fromError(Object error) {
    if (error is BusinessException) return error.message;

    if (error is RequestException) {
      switch (error.type) {
        case RequestErrorType.requestTimeout:
          return 'The connection timed out. Please try again.';
        case RequestErrorType.cannotConnectToServer:
        case RequestErrorType.networkError:
        case RequestErrorType.certificateError:
          return 'No internet connection. Please check your network and try again.';
        case RequestErrorType.serverError:
          return 'The server is having problems. Please try again later.';
        case RequestErrorType.unAuthorized:
          return BusinessExceptionType.sessionExpired.message;
        case RequestErrorType.badRequest:
          return 'The request could not be processed.';
        case RequestErrorType.requestCancelled:
        case RequestErrorType.unknownError:
          return BusinessExceptionType.processingError.message;
      }
    }

    return BusinessExceptionType.processingError.message;
  }
}
