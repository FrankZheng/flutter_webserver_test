import 'dart:async';
import 'dart:io';
import 'package:http_server/http_server.dart';

Future startWebServer() async {
  runZoned(() async {
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8091);
    print('server listen on ${server.address}');
    await for (HttpRequest request in server) {
      request.response.write("hello world");
      await request.response.close();
    }
  });
}
