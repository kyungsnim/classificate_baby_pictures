import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:classificate_baby_pictures/model/CurrentUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:toast/toast.dart';

import '../FileModel.dart';
import 'BabyImage.dart';

CurrentUser currentUser;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var birthday = DateTime(2020, 2, 28);
  List<Asset> imageList = List<Asset>();
  List<File> fileImageArray = [];
  List<String> f = List();
  String imagePath = "";

  List<AssetPathEntity> targetPathList = []; // 복사될 타겟 앨범
  AssetPathEntity target;

  List<AssetPathEntity> albums;
  List<AssetEntity> media;
  List<AssetPathEntity> saveBabyAlbums = new List<AssetPathEntity>();

  List<String> deleteId = new List<String>(); // 복사 후 삭제할 리스트

  @override
  void initState() {
    super.initState();
    fetchMedia();

    // 복사될 타겟 앨범 셋팅
    PhotoManager.getAssetPathList(hasAll: true).then((value) {
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
          // BabyImage(),
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
    ));
  }

  fetchMedia() async {
    albums = await PhotoManager.getAssetPathList(onlyAll: true);
    // print(albums);
    media = await albums[0].getAssetListPaged(0, 50000);
  }

  Future<File> imageToFile(String imageName) async {
    var bytes = await rootBundle.load('$imageName');
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/profile.png');
    await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return file;
  }

  getImage() async {
    List<Asset> resultList = List<Asset>();
    resultList = await MultiImagePicker.pickImages(
        maxImages: 500,
        // enableCamera: true,
        // selectedAssets: imageList
    );
    saveBabyAlbums = new List<AssetPathEntity>();

    // 폴더 생성하기 (오늘자 ~ 태어난날로 계산)
    var durationMonths =
        (DateTime.now().difference(birthday).inDays / 30).ceil();
    var existAlbum = false;
    print('targetPathList : ${targetPathList.length}');

    // 기본사진 만들지 여부 판단 후 기존 앨범 없으면 기본사진 만들기
    final File file =
        await imageToFile('assets/images/back.png'); // Your file object
    final Uint8List byteData = await file.readAsBytes(); // Convert to Uint8List
    AssetEntity imageEntity;

    for (int i = 0; i < durationMonths; i++) {
      existAlbum = false;

      // 기존 폴더 돌면서 아기 개월수 폴더 있는지 체크
      for (int j = 0; j < targetPathList.length; j++) {
        if (targetPathList[j].name == "$i month" ||
            targetPathList[j].name == "$i month(s)") {
          existAlbum = true;
        }
      }
    }
    // 폴더가 없었다면 만들기
    if (!existAlbum) {
      imageEntity =
      await PhotoManager.editor.saveImage(byteData);
    }

    for (int i = 0; i < durationMonths; i++) {
      existAlbum = false;

      // 기존 폴더 돌면서 아기 개월수 폴더 있는지 체크
      for (int j = 0; j < targetPathList.length; j++) {
        if (targetPathList[j].name == "$i month" ||
            targetPathList[j].name == "$i month(s)") {
          existAlbum = true;
        }
      }
      // 폴더가 없었다면 만들기
      if (!existAlbum) {
        if (i == 0)
          saveBabyAlbums.add(await PhotoManager.editor.iOS.createAlbum(
            "$i month",
          ));
        else
          saveBabyAlbums.add(await PhotoManager.editor.iOS.createAlbum(
            "$i month(s)",
          ));
        await PhotoManager.editor.copyAssetToPath(
            asset: imageEntity, pathEntity: saveBabyAlbums[i]);
      }
    }

    // 복사할 AssetPathList 다시 얻기
    PhotoManager.getAssetPathList(hasAll: true).then((value) {
      this.targetPathList = value;
      setState(() {});
    });

    for (int i = 0; i < targetPathList.length; i++) {
      for (int j = 0; j < durationMonths; j++) {
        if ((targetPathList[i].name == "$j month" ||
            targetPathList[i].name == "$j month(s)")) {
          saveBabyAlbums.add(targetPathList[i]);
        }
      }
    }

    print('saveBabyAlbums.length : ${saveBabyAlbums.length}');
    if (!mounted) return;

    // 사용자가 실제로 고른 사진 목록으로 기존 앨범 사진 검색
    for (int i = 0; i < resultList.length; i++) {
      print('resultList[i].identifier : ${resultList[i].identifier}');
      print('resultList[i].name : ${resultList[i].name}');

      // 아이폰의 경우 identifier로 찾을 수 있고 안드로이드의 경우 filename으로 매칭시킬 수 있다.
      for (var asset in media) {
        // Platform.isIOS ? print('iOS id : ${asset.id}') : print('android title : ${asset.title}');

        // 아이폰사진의 경우 내가 고른사진의 id와 앨범의 id가 일치한다면
        if (resultList[i].identifier == asset.id) {
          // 해당 사진의 개월수 계산
          var durationMonths =
              (asset.createDateTime.difference(birthday).inDays / 30).floor();
          print('>>> durationMonths : $durationMonths');
          // final AssetEntity imageEntity = await PhotoManager.editor.s(asset: null, pathEntity: null)

          AssetEntity tmpAsset = AssetEntity(id: asset.id);

          // 복사한 사진 이동
          PhotoManager.editor.copyAssetToPath(
              asset: tmpAsset, pathEntity: saveBabyAlbums[durationMonths]).then((_) {
            showToast("${resultList.length} images Complete to moved", duration: 2);
          });
        }
      }
    }
    showToast("${resultList.length} images Complete to moved", duration: 2);
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
