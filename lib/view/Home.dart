import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

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

  List<AssetPathEntity> targetPathList = []; // 복사될 타겟 앨범
  AssetPathEntity target;

  List<AssetPathEntity> albums;
  List<AssetEntity> media;
  List<AssetPathEntity> saveBabyAlbums = new List<AssetPathEntity>();

  @override
  void initState() {
    super.initState();
    fetchMedia();

    // 복사될 타겟 앨범 셋팅
    PhotoManager.getAssetPathList(hasAll: false).then((value) {
      this.targetPathList = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    PhotoManager.clearFileCache();
  }
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

  fetchMedia() async {
    albums =
    await PhotoManager.getAssetPathList(onlyAll: true);
    // print(albums);
    media =
    await albums[0].getAssetListPaged(0, 5000);
    // print(media);
  }

  getImage() async {
    List<Asset> resultList = List<Asset>();
    resultList =
    await MultiImagePicker.pickImages(
        maxImages: 500,
        // enableCamera: true,
        selectedAssets:imageList
    );

    // 폴더 생성하기 (오늘자 ~ 태어난날로 계산)
    var durationMonths = (DateTime.now().difference(birthday).inDays / 30).ceil();

    for(int i = 0; i < durationMonths; i++) {
      // 기존 폴더가 있는 경우엔 만들지 말고

      // 폴더가 없었다면 만들기
      if(i == 0) {
        saveBabyAlbums.add(await PhotoManager.editor.iOS.createAlbum(
          "$i month",
        ));
      } else {
        saveBabyAlbums.add(await PhotoManager.editor.iOS.createAlbum(
          "$i month(s)",
        ));
      }
    }


    if (!mounted) return;

    for (int i = 0; i < resultList.length; i++) {
      print('resultList[i].identifier : ${resultList[i].identifier}');
      print('resultList[i].name : ${resultList[i].name}');

      // 아이폰의 경우 identifier로 찾을 수 있고 안드로이드의 경우 filename으로 매칭시킬 수 있다.
      for (var asset in media) {
        Platform.isIOS ? print('iOS id : ${asset.id}') : print('android title : ${asset.title}');

        // 아이폰사진
        if(resultList[i].identifier == asset.id) {
          var durationMonths = (asset.createDateTime.difference(birthday).inDays / 30).ceil();
          // final AssetEntity imageEntity = await PhotoManager.editor.s(asset: null, pathEntity: null)
          await PhotoManager.editor.copyAssetToPath(asset: asset, pathEntity: saveBabyAlbums[durationMonths]); //
        }
      }
    }

    setState(() {
      imageList = resultList;
    });

  }

}
