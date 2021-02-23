import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:http_mock_adapter/src/history.dart';
import 'package:http_mock_adapter/src/request.dart';
import 'package:http_mock_adapter/src/response.dart';
import 'package:meta/meta.dart';

/// [DioInterceptor] is a class for mocking the [Dio] requests with interceptors.
///
/// This means you can mock any request of [Dio] by adding the
/// instance of [DioInterceptor] inside the original [Dio]'s interceptors' list.
///
/// Usage:
/// ```dart
/// // Create Dio instance
/// Dio dio = Dio()
/// // Create instance of our([DioInterceptor]) Interceptor
/// DioInterceptor interceptor = DioInterceptor()
/// // Adding routes and their mocked responses as chains
/// interceptor
/// .onGet("/route-1")
/// .reply("response for route 1")
/// .onPost("/route-2")
/// .reply("response for route 2")
/// .onPatch("/route-3")
/// .reply("response for route 3")
/// // adding interceptor inside the [Dio]'s interceptors
/// dio.interceptors.add(interceptor);
/// ```
/// If you now make request like this `dio.get("/route-1");`
/// Your response will be `Response(data:"response for route 1",........)`
class DioInterceptor extends Interceptor with Tracked, RequestRouted {
  /// Takes in route, request, sets corresponding [RequestHandler],
  /// adds an instance of [RequestMatcher] in [History.data].
  @override
  void onRoute(
    dynamic route, {
    Request request = const Request(),
    @required void Function(RequestHandler response) handler,
  }) {
    final requestHandler = RequestHandler<DioInterceptor>();
    handler(requestHandler);

    history.data.add(
      RequestMatcher(
        Request(
          route: route,
          method: request.method,
          data: request.data,
          queryParameters: request.queryParameters,
          headers: request.headers,
        ),
        requestHandler,
      ),
    );
  }

  /// Dio [Interceptor]`s [onRequest] configuration intended to catch and return
  /// mocked request and data respectively.
  @override
  Future<Response<dynamic>> onRequest(options) async {
    final response = history.responseBody(options);

    // Throws error if response type is DioError.
    throwError(response);

    AdapterResponse responseBody = response;

    responseBody.headers = responseBody.headers ??
        const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        };

    return Response(
      data: await DefaultTransformer().transformResponse(options, responseBody),
      headers: Headers.fromMap(responseBody.headers),
      isRedirect: responseBody.isRedirect,
      redirects: responseBody.redirects ?? [],
      request: options,
      statusCode: responseBody.statusCode,
      statusMessage: responseBody.statusMessage,
    );
  }
}
