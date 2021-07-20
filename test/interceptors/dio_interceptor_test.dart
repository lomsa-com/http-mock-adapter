import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;

  const data = {'message': 'Test!'};
  const path = 'https://example.com';

  Response<dynamic> response;
  const statusCode = 200;

  group('DioInterceptor', () {
    late DioInterceptor dioInterceptor;

    setUpAll(() {
      dio = Dio();
      dioInterceptor = DioInterceptor(dio: dio);
    });

    Future<void> _testDioInterceptor<T>(
      Future<Response<T>> Function() request,
      actual,
    ) async {
      response = await request();

      expect(actual, response.data);
    }

    group('RequestRouted', () {
      test('Test that throws raises custom exception', () async {
        const type = DioErrorType.response;
        const error = 'Some beautiful error';

        // Building request to throw the DioError exception
        // on onGet for the specific path.
        dioInterceptor.onGet(
          path,
          (server) => server.throws(
            500,
            MockDioError(
              type: type,
              requestOptions: RequestOptions(path: path),
              response: Response(
                statusCode: 500,
                requestOptions: RequestOptions(path: path),
              ),
              error: error,
            ),
          ),
        );

        // Checking that exception type can match `MockDioError` type too.
        expect(() async => await dio.get(path),
            throwsA(const TypeMatcher<MockDioError>()));

        // Checking that exception type can match `DioError` type too.
        expect(() async => await dio.get(path),
            throwsA(const TypeMatcher<DioError>()));

        // Checking the type and the message of the exception.
        expect(
            () async => await dio.get(path),
            throwsA(predicate(
                (DioError e) => e is DioError && e.message == error)));
      });

      test('mocks requests via onRoute() as intended', () async {
        dioInterceptor.onRoute(
          path,
          (server) => server.reply(statusCode, data),
          request: const Request(),
        );

        await _testDioInterceptor(() => dio.get(path), data);
      });

      test('mocks requests via onGet() as intended', () async {
        dioInterceptor.onGet(
          path,
          (server) => server.reply(statusCode, data),
        );

        await _testDioInterceptor(() => dio.get(path), data);
      });

      test('mocks requests via onHead() as intended', () async {
        dioInterceptor.onHead(
          path,
          (server) => server.reply(statusCode, data),
        );

        await _testDioInterceptor(() => dio.head(path), data);
      });

      test('mocks requests via onPost() as intended', () async {
        dioInterceptor.onPost(
          path,
          (server) => server.reply(statusCode, data),
        );

        await _testDioInterceptor(() => dio.post(path), data);
      });

      test('mocks requests via onPut() as intended', () async {
        dioInterceptor.onPut(
          path,
          (server) => server.reply(statusCode, data),
        );

        await _testDioInterceptor(() => dio.put(path), data);
      });

      test('mocks requests via onDelete() as intended', () async {
        dioInterceptor.onDelete(
          path,
          (server) => server.reply(statusCode, data),
        );

        await _testDioInterceptor(() => dio.delete(path), data);
      });

      test('mocks requests via onPatch() as intended', () async {
        dioInterceptor.onPatch(
          path,
          (server) => server.reply(statusCode, data),
        );

        await _testDioInterceptor(() => dio.patch(path), data);
      });
    });

    test('mocks multiple requests sequentially by method chaining', () async {
      const sendData = 'foo';

      dioInterceptor
        ..onGet(
          path,
          (server) => server.reply(statusCode, data),
        )
        ..onPost(
          path,
          (server) => server.reply(statusCode, data),
          data: sendData,
        )
        ..onPatch(
          path,
          (server) => server.reply(statusCode, data),
          data: sendData,
        );

      dio.interceptors.add(dioInterceptor);

      response = await dio.get(path);
      expect(response.data, data);

      response = await dio.post(path, data: sendData);
      expect(response.data, data);

      response = await dio.patch(path, data: sendData);
      expect(response.data, data);
    });
  });
}
