import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  Dio dio;

  const data = {'message': 'Test!'};
  const path = 'https://example.com';

  Response<dynamic> response;
  const statusCode = 200;

  group('DioInterceptor', () {
    DioInterceptor dioInterceptor;

    setUpAll(() {
      dio = Dio();

      dioInterceptor = DioInterceptor();

      dio.interceptors.add(dioInterceptor);
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
        const type = DioErrorType.RESPONSE;
        final response = Response(statusCode: 500);
        const error = 'Some beautiful error';

        // Building request to throw the DioError exception
        // on onGet for the specific path.
        dioInterceptor.onGet(path).throws(
              500,
              AdapterError(
                type: type,
                response: response,
                error: error,
              ),
            );

        // Checking that exception type can match `AdapterError` type too.
        expect(() async => await dio.get(path),
            throwsA(TypeMatcher<AdapterError>()));

        // Checking that exception type can match `DioError` type too.
        expect(
            () async => await dio.get(path), throwsA(TypeMatcher<DioError>()));

        // Checking the type and the message of the exception.
        expect(
            () async => await dio.get(path),
            throwsA(predicate(
                (DioError e) => e is DioError && e.message == error)));
      });

      test('mocks requests via onRoute() as intended', () async {
        dioInterceptor.onRoute(path).reply(statusCode, data);

        await _testDioInterceptor(() => dio.get(path), data);
      });

      test('mocks requests via onGet() as intended', () async {
        dioInterceptor.onGet(path).reply(statusCode, data);

        await _testDioInterceptor(() => dio.get(path), data);
      });

      test('mocks requests via onHead() as intended', () async {
        dioInterceptor.onHead(path).reply(statusCode, data);

        await _testDioInterceptor(() => dio.head(path), data);
      });

      test('mocks requests via onPost() as intended', () async {
        dioInterceptor.onPost(path).reply(statusCode, data);

        await _testDioInterceptor(() => dio.post(path), data);
      });

      test('mocks requests via onPut() as intended', () async {
        dioInterceptor.onPut(path).reply(statusCode, data);

        await _testDioInterceptor(() => dio.put(path), data);
      });

      test('mocks requests via onDelete() as intended', () async {
        dioInterceptor.onDelete(path).reply(statusCode, data);

        await _testDioInterceptor(() => dio.delete(path), data);
      });

      test('mocks requests via onPatch() as intended', () async {
        dioInterceptor.onPatch(path).reply(statusCode, data);

        await _testDioInterceptor(() => dio.patch(path), data);
      });
    });

    test('mocks multiple requests sequantially by method chaining', () async {
      final dio = Dio();

      final dioInterceptor = DioInterceptor();

      dioInterceptor
          .onGet(path)
          .reply(statusCode, data)
          .onPost(path)
          .reply(statusCode, data)
          .onPatch(path)
          .reply(statusCode, data);

      dio.interceptors.add(dioInterceptor);

      response = await dio.get(path);
      expect(response.data, data);

      response = await dio.post(path);
      expect(response.data, data);

      response = await dio.patch(path);
      expect(response.data, data);
    });
  });
}
