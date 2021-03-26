import 'dart:math';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  const path = 'https://example.com';

  setUpAll(() {
    dioAdapter = DioAdapter();
    dio = Dio()..httpClientAdapter = dioAdapter;
  });

  group('History', () {
    group('resets after each test call:', () {
      double data;
      Response<dynamic> response;

      tearDown(() => dioAdapter.history.reset());

      void expectRandomResponse() async {
        data = Random().nextDouble();

        dioAdapter.onGet(
          path,
          (request) => request.reply(200, data),
        );

        response = await dio.get(path);

        expect(data, response.data);

        // Affirm that the length of history's list is one due to reset.
        expect(dioAdapter.history.data.length, 1);
      }

      Iterable<int>.generate(10).forEach((index) => test(
            'Test #${index + 1}',
            () => expectRandomResponse(),
          ));
    });
  });
}
