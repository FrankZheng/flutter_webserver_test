import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_ip/get_ip.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'web_server.dart';
import 'package:get_ip/get_ip.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void init() async {
    //copy all the files from static/ to document dir web/static in debug mode
    List<String> files = [
      'index.html',
      'main.js',
      'style.css',
      'countdown_video.mp4',
      'endcard.zip',
    ];
    String documentDir = (await getApplicationDocumentsDirectory()).path;
    print('$documentDir');
    String webDirPath = p.join(documentDir, 'web');
    String uploadDirPath = p.join(webDirPath, 'upload');

    //create web dir and upload dir
    Directory webDir = await Directory(webDirPath).create(recursive: true);
    Directory uploadDir =
        await Directory(uploadDirPath).create(recursive: true);
    print('$webDir, $uploadDir');

    for (String filename in files) {
      String targetFilePath = p.join(webDirPath, filename);
      print('$targetFilePath');
      var bytes = await rootBundle.load("static/$filename");
      await writeToFile(bytes, targetFilePath);
    }

    String localIp = await GetIp.ipAddress;
    print('local ip: $localIp');

    var indexFile = File(p.join(webDirPath, 'index.html'));
    String adsJson = await rootBundle.loadString("static/ads.json");
    String configJson = await rootBundle.loadString("static/config.json");

    startWebServer(webDirPath, indexFile, adsJson, configJson);
  }

  //write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  void initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'hello',
            ),
          ],
        ),
      ),
    );
  }
}
