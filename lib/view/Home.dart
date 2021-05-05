import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:storage_path/storage_path.dart';

import '../FileModel.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var birthday = DateTime(2020,2,28);
  List<Asset> imageList = List<Asset>();
  List<File> fileImageArray = [];
  List<String> f = List();
  String imagePath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(birthday.toString().substring(0, 10)),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                getImage();
                getImagesPath();
              },
              child: Text('사진선택'),
            ),
            imageList.isEmpty
                ? Container()
                : Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Asset asset = imageList[index];
                    return AssetThumb(
                        asset: asset, width: 300, height: 300);
                  }),
            ),
          ],
        ),
      )
    );
  }

  Future<void> getImagesPath() async {
    String imagespath = "";
    try {
      imagespath = await StoragePath.imagesPath;
      var response = jsonDecode(imagespath);
      print(response);
      var imageList = response as List;
      List<FileModel> list =
      imageList.map<FileModel>((json) => FileModel.fromJson(json)).toList();

      setState(() {
        imagePath = list[11].files[0];
      });
    } on PlatformException {
      imagespath = 'Failed to get path';
    }
    return imagespath;
  }

  getImage() async {
    List<Asset> resultList = List<Asset>();
    resultList =
    await MultiImagePicker.pickImages(
        maxImages: 100,
        enableCamera: true,
        selectedAssets:imageList
    );

    if (!mounted) return;

    for (int i = 0; i < resultList.length; i++) {
      var path =
      await FlutterAbsolutePath.getAbsolutePath(resultList[i].identifier);
      // print('>>>>>>>>>> time: ${File(path).c()}');
      print('>>>>>>>>>> path: $path');
    }

    setState(() {
      imageList = resultList;
    });

  }

  Future getImageSize(Image image) async {
    final Completer completer = Completer();

    image.image.resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    }));

    final Size size = await completer.future;

    return size ;
  }
}
