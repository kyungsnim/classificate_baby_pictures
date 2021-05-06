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
    var existAlbum = false;
    print('targetPathList : ${targetPathList.length}');
    for(int i = 0; i < durationMonths; i++) {

      existAlbum = false;

      // 기존 폴더 돌면서 아기 개월수 폴더 있는지 체크
      for(int j = 0; j < targetPathList.length; j++) {
        if(targetPathList[j].name == "$i months" || targetPathList[j].name == "$i month(s)") {
          existAlbum = true;
        }
      }
      print('$i : $existAlbum');
      // 폴더가 없었다면 만들기
      if(!existAlbum) {
        if(i == 0) saveBabyAlbums.add(await PhotoManager.editor.iOS.createAlbum("$i month",));
        else saveBabyAlbums.add(await PhotoManager.editor.iOS.createAlbum("$i month(s)",));

        // 앨범 생성 후 기본 이미지 1개 넣어주기 (앨범에 사진 하나도 없으면 targetPathList에 잡히지 않는다.
        final AssetEntity imageEntity = new AssetEntity();
        // await PhotoManager.editor.copyAssetToPath(asset: imageEntity, pathEntity: saveBabyAlbums[i]);
        // 빈 앨범에 사진 한장 넣어주고 싶은데......... 잘 안됨
      }
    }

    // 복사할 AssetPathList 다시 얻기
    PhotoManager.getAssetPathList(hasAll: true).then((value) {
      this.targetPathList = value;
      setState(() {});
    });

    if (!mounted) return;

    // 사용자가 실제로 고른 사진 목록으로 기존 앨범 사진 검색
    for (int i = 0; i < resultList.length; i++) {
      print('resultList[i].identifier : ${resultList[i].identifier}');
      print('resultList[i].name : ${resultList[i].name}');

      // 아이폰의 경우 identifier로 찾을 수 있고 안드로이드의 경우 filename으로 매칭시킬 수 있다.
      for (var asset in media) {
        // Platform.isIOS ? print('iOS id : ${asset.id}') : print('android title : ${asset.title}');

        // 아이폰사진의 경우 내가 고른사진의 id와 앨범의 id가 일치한다면
        if(resultList[i].identifier == asset.id) {
          // 해당 사진의 개월수 계산
          var durationMonths = (asset.createDateTime.difference(birthday).inDays / 30).floor();
          print('>>> durationMonths : $durationMonths');
          // final AssetEntity imageEntity = await PhotoManager.editor.s(asset: null, pathEntity: null)
          // 개월수 계산된 앨범에 복사
          await PhotoManager.editor.copyAssetToPath(asset: asset, pathEntity: saveBabyAlbums[durationMonths]); //

          // 기존 앨범에서 삭제를 위해 삭제목록에 추가
          deleteId.add(asset.id);

        }
      }

      // await PhotoManager.editor.deleteWithIds(deleteId);
    }

    setState(() {
      imageList = resultList;
    });
  }

}
