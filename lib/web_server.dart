import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http_server/http_server.dart';
import 'package:path/path.dart';

class WebServer {
  final String webDirPath;
  final File indexFile;
  final String adsJson;
  final String configJson;

  WebServer(
      {@required this.webDirPath,
      @required this.indexFile,
      @required this.configJson,
      @required this.adsJson});

  Future<void> start() async {}
}

Future startWebServer(String webDirPath, File indexFile, String adsJson,
    String configJson) async {
  runZoned(() async {
    int port = 8091;
    var server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('server listen on ${server.address}:$port');

    var staticFiles = VirtualDirectory(webDirPath);

    await for (HttpRequest request in server) {
      //handle GET "/" -> index.html
      print('method:${request.method}, uri:${request.uri}');
      var method = request.method;
      var uri = request.uri;

      //handle POST "/ads", "/config", "/ok"
      if (method == 'GET') {
        if (uri.path == '/') {
          //serve index.html
          staticFiles.serveFile(indexFile, request);
        } else {
          staticFiles.serveRequest(request);
        }
      } else if (method == 'POST') {
        if (uri.path == '/config' || uri.path == '/ads') {
          request.response.headers.contentType = ContentType.json;
          var json = uri.path == '/config' ? configJson : adsJson;
          request.response.write(json);
        } else {
          request.response.statusCode = HttpStatus.notFound;
          request.response.write("Unsupported request:$uri");
        }
        await request.response.close();
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write("Unsupported request: $method");
        await request.response.close();
      }
      //then handle static files

    }
  });
}
