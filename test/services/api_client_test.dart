import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shike_guanjia/services/http/api_client.dart';

void main() {
  test('calls unauthorized handler on 401 responses', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    server.listen((request) {
      request.response
        ..statusCode = HttpStatus.unauthorized
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'error': {'code': 'UNAUTHORIZED', 'message': 'Session expired'},
          }),
        )
        ..close();
    });

    var unauthorizedCalled = false;
    final client = ApiClient(baseUrl: 'http://127.0.0.1:${server.port}');
    client.setToken('expired-token');
    client.setUnauthorizedHandler(() async {
      unauthorizedCalled = true;
    });

    await expectLater(
      client.getData<Map<String, dynamic>>('/protected'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.code, 'code', 'UNAUTHORIZED')
            .having((error) => error.message, 'message', 'Session expired'),
      ),
    );
    expect(unauthorizedCalled, isTrue);
    expect(client.token, isNull);
  });
}
