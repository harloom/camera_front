import 'dart:io';
import 'dart:math';

import 'package:camera_front/custom_camera.dart';
import 'package:flutter/material.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Front',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _size = "";

  File? file;

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () async {
           var resFile =  await CustomCamera.take(context, "Tempatkan Wajah pada yang di sediakan!");
           if(resFile != null){
             _size = await getFileSize(resFile.path, 1);
             file = resFile;
           }
           setState(() {
           });
          }, icon: const Icon(Icons.camera_alt))
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            file != null ? SizedBox(
              width: 300,
              height: 300,
              child: Image.file(file!),
            ) : Container(),
            const Text(
              'Size:',
            ),
            Text(
              _size,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
