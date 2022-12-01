
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PreviewImage extends StatelessWidget {
  const PreviewImage({Key? key, required this.file}) : super(key: key);
  final File file ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context,file);
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: kIsWeb ? Image.network(file.path)  : Image.file(File(file.path),fit: BoxFit.fill,),
      )
    );
  }
}
