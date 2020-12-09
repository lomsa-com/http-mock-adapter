import 'package:dio/dio.dart';
import 'package:http_mock_adapter/src/interfaces.dart';

/// [RequestHandlerException] is thrown when, Request Handler method
/// is called with genreic type paramter.
/// available types are: DioInterceptor and DioAdapter
class RequestHandlerException implements Exception {
  final dynamic message;

  RequestHandlerException(
      [this.message =
          'Request handler should have generic type DioAdapter or DioInterceptor']);

  @override
  String toString() {
    if (message == null) return 'Provide the message inside the exception';
    return 'RequestHandlerException: $message';
  }
}

/// This Exception is thrown when throws gets wrong type of argument
/// in the place of the DioError.
class ThrowsException implements Exception {
  final dynamic message;

  ThrowsException(
      [this.message = 'Error Should be eithier `DioError` or `AdapterError`']);

  @override
  String toString() {
    if (message == null) return 'Provide the message inside the exception';
    return 'throws()-Exception: $message';
  }
}

/// wrapper of [Dio]'s [DioError] Exception
class AdapterError extends DioError implements Responsable {
  AdapterError({
    RequestOptions request,
    Response response,
    DioErrorType type = DioErrorType.DEFAULT,
    dynamic error,
  }) : super(
          request: request,
          response: response,
          type: type,
          error: error,
        );
  static AdapterError from(DioError dioError) {
    return AdapterError(
      request: dioError?.request,
      response: dioError?.response,
      type: dioError?.type,
      error: dioError?.error,
    );
  }
}
