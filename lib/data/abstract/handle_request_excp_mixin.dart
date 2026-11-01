import 'package:dio/dio.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';

mixin HandleRequestException {
  Future<T> handleRequestExceptions<T>({required Future<T> Function() method}) async {
    try {
      return await method.call();
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.cancel) {
        throw RequestException(RequestErrorType.requestCancelled, 'Operation cancelled', st.toString());
      } else if (e.type == DioExceptionType.badCertificate) {
        throw RequestException(RequestErrorType.certificateError, e.toString(), st.toString());
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw RequestException(RequestErrorType.requestTimeout, 'Connection timed out', st.toString());
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final serverMessage = _serverMessage(e.response);

        if (statusCode == 400) {
          throw RequestException(RequestErrorType.badRequest, serverMessage ?? 'Bad request', st.toString());
        }

        if (statusCode == 401 || statusCode == 403 || _isTokenRejection(serverMessage)) {
          throw RequestException(RequestErrorType.unAuthorized, serverMessage ?? 'Unauthorized request', st.toString());
        }

        throw RequestException(RequestErrorType.serverError, serverMessage ?? 'Server error', st.toString());
      } else if (e.type == DioExceptionType.connectionError) {
        throw RequestException(RequestErrorType.cannotConnectToServer, 'Cannot connect to the server', st.toString());
      } else if (e.type == DioExceptionType.unknown) {
        throw RequestException(RequestErrorType.networkError, 'Network error', st.toString());
      } else {
        throw RequestException(RequestErrorType.unknownError, e.message ?? 'Unknown error', st.toString());
      }
    } on FormatException catch (e, st) {
      throw RequestException(RequestErrorType.unknownError, 'Unexpected server response: ${e.message}', st.toString());
    } on TypeError catch (e, st) {
      throw RequestException(RequestErrorType.unknownError, 'Unexpected server response: $e', st.toString());
    }
  }

  String? _serverMessage(Response? response) {
    final data = response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return null;
  }

  bool _isTokenRejection(String? message) {
    if (message == null) return false;
    final lower = message.toLowerCase();
    return lower.contains('token');
  }
}
