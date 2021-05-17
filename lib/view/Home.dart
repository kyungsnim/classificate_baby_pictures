import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:classificate_baby_pictures/model/CurrentUser.dart';
import 'package:file_picker/file_picker.dart';
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
  bool _isLoading;
  DateTime _babyBirthday;
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

  List<Asset> resultList = List<Asset>();

  TextEditingController _babyNameEditingController = TextEditingController();
  String _babyName;

  @override
  void initState() {
    super.initState();
    fetchMedia();
    setState(() {
      _isLoading = false;
    });
    // 복사될 타겟 앨범 셋팅
    PhotoManager.getAssetPathList(hasAll: true, type: RequestType.all).then((value) {
      this.targetPathList = value;
      setState(() {});
    });

    _babyNameEditingController = TextEditingController(text: '황제이');
    _babyName = _babyNameEditingController.text;
    _babyBirthday = DateTime(2020,2,28);
  }

  @override
  void dispose() {
    super.dispose();
    PhotoManager.clearFileCache();
    _babyNameEditingController.dispose();
  }

  babyNameInputArea(hintText) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border:
          Border.all(color: Colors.yellow.withOpacity(0.5), width: 5),
          borderRadius: BorderRadius.circular(10),
          color: Colors.yellow.shade600,
          boxShadow: [
            BoxShadow(
                offset: Offset(1, 1),
                blurRadius: 5,
                color: Colors.white24)
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          controller: _babyNameEditingController,
          decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(Icons.person, color: Colors.indigo),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 15)),
          onChanged: (val) {
            _babyName = val;
          },
        ),
      ),
    );
  }

  babyNameInputAreaWithListTile() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(
                      color: Colors.black54, width: 0.5))),
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _babyNameEditingController,
            cursorColor: Colors.black,
            validator: (val) {
              if (val.isEmpty) {
                return '내용을 입력하세요';
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '아이의 이름을 입력하세요.',
                hintStyle: TextStyle(
                    fontFamily: 'Nanum', fontSize: 15)),
            onChanged: (val) {
              setState(() {
                _babyName = val;
              });
            },
          ),
        ),
      ]),
    );
  }

  babyBirthDaySelectArea() {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(
                  color: Colors.black54, width: 0.5))),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListTile(
              title: Row(
                children: [
                  Text(
                      "${_babyBirthday.year}-${_babyBirthday.month}-${_babyBirthday.day}"),
                  SizedBox(width: 10),
                  Icon(Icons.calendar_today,
                      color: Colors.black)
                ],
              ),
              onTap: () async {
                DateTime picked = (await showDatePicker(
                  context: context,
                  initialDate: _babyBirthday,
                  firstDate: DateTime(_babyBirthday.year - 30),
                  lastDate: DateTime(_babyBirthday.year + 1),
                  builder:
                      (BuildContext context, Widget child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme:
                        ColorScheme.light().copyWith(
                          primary: Colors.black,
                        ),
                        buttonTheme: ButtonThemeData(
                            textTheme:
                            ButtonTextTheme.primary),
                      ),
                      child: child,
                    );
                  },
                ));

                if(picked != null) {
                  setState(() {
                    _babyBirthday = picked;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  inputAreaTitle(titleText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            child: Text(titleText,
                style: TextStyle(
                    fontFamily: 'Nanum',
                    color: Colors.black,
                    fontWeight: FontWeight.bold))),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('우리아기 사진정리',
        style: TextStyle(
          color: Colors.indigo,
          fontSize: MediaQuery.of(context).size.width * 0.05,
          fontWeight: FontWeight.bold
        ),),
      ),
        body: _isLoading ? Center(child: CircularProgressIndicator()) : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
      child: ListView(
          children: [
            // BabyImage(),
            inputAreaTitle('아이 이름'),
            babyNameInputAreaWithListTile(),
            SizedBox(height: 20),
            inputAreaTitle('아이 생일'),
            babyBirthDaySelectArea(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: getBabyMonthImageWithBabyAlbum,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: Colors.indigo,
                      child: Text('사진선택'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: getBabyMonthImageWithFilePicker,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: Colors.indigo,
                      child: Center(child: Text('영상 선택',
                      style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
              ],
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

  getBabyMonthImageWithFilePicker() async {
    setState(() {
      _isLoading = true;
    });
    FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.video);

    var existBabyAlbum = false;
    var babyAlbumIndex = 0;
    // 기존 폴더 돌면서 아기 이름으로 된 앨범 있는지 체크
    for (int j = 0; j < targetPathList.length; j++) {
      if (targetPathList[j].name == "$_babyName") {
        existBabyAlbum = true;
        babyAlbumIndex = j;
      }
    }

    // 아기 이름 앨범 없으면 만들어 줄 것
    if(!existBabyAlbum) {
      targetPathList.add(await PhotoManager.editor.iOS.createFolder(
        "$_babyName",
      ));
      babyAlbumIndex = targetPathList.length - 1;
    }

    // 사용자가 실제로 고른 사진 목록으로 기존 앨범 사진 검색
    for (int i = 0; i < result.count; i++) {
      // 아이폰의 경우 identifier로 찾을 수 있고 안드로이드의 경우 filename으로 매칭시킬 수 있다.
      List<String> splitResultData = result.files[i].path.split('/');
      var resultFileName = splitResultData[splitResultData.length - 1];
      print(resultFileName);
      for (var asset in media) {
        // Platform.isIOS ? print('iOS id : ${asset.id}') : print('android title : ${asset.title}');
        // 아이폰사진의 경우 내가 고른사진의 id와 앨범의 id가 일치한다면

        List<String> splitAssetData = (await asset.file).path.split('/');
        var assetFileName = splitAssetData[splitAssetData.length - 1];
        print(assetFileName);
        // File tmpFile = await asset.file;
        bool now = false;
        // path가 좌측은 /IMG_XXXX.mp4 이고 우측은 ./video/IMG_XXXX.mp4 여서 다름....
        // media_picker 1.3.5 사용하는거 고려해볼 것..... 이미지 영상 동시에 선택
        // result.files[i].path == (await asset.file).path ? now = true : now = false;
        resultFileName == assetFileName ? now = true : now = false;

        if (now) {
          print(2);
          // 해당 사진의 개월수 계산
          var babyMonths =
          (asset.createDateTime.difference(_babyBirthday).inDays / 30).floor();

          // print('>>>>>>>>> babyMonths : $babyMonths');
          AssetEntity tmpAsset = AssetEntity(id: asset.id);

          var existAlbum = false;

          // 기존 폴더 돌면서 아기 개월수 폴더 있는지 체크
          for (int j = 0; j < targetPathList.length; j++) {
            if (targetPathList[j].name == "$babyMonths month" ||
                targetPathList[j].name == "$babyMonths month(s)") {
              // 해당 개월의 폴더 안에 사진 이동
              await PhotoManager.editor.copyAssetToPath(
                  asset: tmpAsset, pathEntity: targetPathList[j]);
              existAlbum = true;
            }
          }

          // 모든 앨범 찾아봤는데 해당 개월수의 앨범이 없는 경우 앨범 만들어준 후에 파일 복사해야 함
          if (!existAlbum) {
            // print('>>>>>>>> before targetPathList : ${targetPathList.length}');
            if (babyMonths == 0)
              targetPathList.add(await PhotoManager.editor.iOS.createAlbum(
                "$babyMonths month", parent: targetPathList[babyAlbumIndex]
              ));
            else
              targetPathList.add(await PhotoManager.editor.iOS.createAlbum(
                "$babyMonths months", parent: targetPathList[babyAlbumIndex]
              ));
            // print('>>>>>>>> after targetPathList : ${targetPathList.length}');
            // 바로 위에서 추가한 앨범에 개월수 사진 넣어주기
            await PhotoManager.editor.copyAssetToPath(
                asset: tmpAsset, pathEntity: targetPathList[targetPathList.length-1]);
            // print('******** targetPathList.length-1 : ${targetPathList.length-1}');
          }
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
    showToast("${result.count} images complete to moved", duration: 2);
  }

  // getBabyMonthImage() async {
  //   // 사진 고르기
  //   resultList = await MultiImagePicker.pickImages(
  //     maxImages: 500,
  //   );
  //
  //   // 만일 4, 6, 7개월때 사진을 골랐다면...
  //   // 사용자가 실제로 고른 사진 목록으로 기존 앨범 사진 검색
  //   for (int i = 0; i < resultList.length; i++) {
  //     // 아이폰의 경우 identifier로 찾을 수 있고 안드로이드의 경우 filename으로 매칭시킬 수 있다.
  //     for (var asset in media) {
  //       // Platform.isIOS ? print('iOS id : ${asset.id}') : print('android title : ${asset.title}');
  //
  //       // 아이폰사진의 경우 내가 고른사진의 id와 앨범의 id가 일치한다면
  //       if (resultList[i].identifier == asset.id) {
  //         // 해당 사진의 개월수 계산
  //         var babyMonths =
  //         (asset.createDateTime.difference(_babyBirthday).inDays / 30).floor();
  //
  //         AssetEntity tmpAsset = AssetEntity(id: asset.id);
  //
  //         var existAlbum = false;
  //
  //         // 기존 폴더 돌면서 아기 개월수 폴더 있는지 체크
  //         for (int j = 0; j < targetPathList.length; j++) {
  //           if (targetPathList[j].name == "$babyMonths month" ||
  //               targetPathList[j].name == "$babyMonths month(s)") {
  //             // 해당 개월의 폴더 안에 사진 이동
  //             await PhotoManager.editor.copyAssetToPath(
  //                 asset: tmpAsset, pathEntity: targetPathList[j]);
  //             existAlbum = true;
  //           }
  //         }
  //
  //         // 모든 앨범 찾아봤는데 해당 개월수의 앨범이 없는 경우 앨범 만들어준 후에 파일 복사해야 함
  //         if (!existAlbum) {
  //           print('>>>>>>>> before targetPathList : ${targetPathList.length}');
  //           if (babyMonths == 0)
  //             targetPathList.add(await PhotoManager.editor.iOS.createAlbum(
  //               "$babyMonths month",
  //             ));
  //           else
  //             targetPathList.add(await PhotoManager.editor.iOS.createAlbum(
  //               "$babyMonths month(s)",
  //             ));
  //
  //           // 바로 위에서 추가한 앨범에 개월수 사진 넣어주기
  //           await PhotoManager.editor.copyAssetToPath(
  //               asset: tmpAsset, pathEntity: targetPathList[targetPathList.length-1]);
  //         }
  //       }
  //     }
  //   }
  //   showToast("${resultList.length} images complete to moved", duration: 2);
  // }

  getBabyMonthImageWithBabyAlbum() async {
    setState(() {
      _isLoading = true;
    });
    // 사진 고르기
    resultList = await MultiImagePicker.pickImages(
      maxImages: 500,
    );

    var existBabyAlbum = false;
    var babyAlbumIndex = 0;
    // 기존 폴더 돌면서 아기 이름으로 된 앨범 있는지 체크
    for (int j = 0; j < targetPathList.length; j++) {
      if (targetPathList[j].name == "$_babyName") {
        existBabyAlbum = true;
        babyAlbumIndex = j;
      }
    }

    // 아기 이름 앨범 없으면 만들어 줄 것
    if(!existBabyAlbum) {
      targetPathList.add(await PhotoManager.editor.iOS.createFolder(
        "$_babyName",
      ));
      babyAlbumIndex = targetPathList.length - 1;
    }

    for(int j = 0; j < targetPathList.length; j++ ) {
      print(targetPathList[j].name);
    }

    List<AssetPathEntity> targetSubPathList = new List();
    // targetSubPathList = await targetPathList[babyAlbumIndex].getSubPathList();

    // 만일 4, 6, 7개월때 사진을 골랐다면...
    // 사용자가 실제로 고른 사진 목록으로 기존 앨범 사진 검색
    for (int i = 0; i < resultList.length; i++) {
      // 아이폰의 경우 identifier로 찾을 수 있고 안드로이드의 경우 filename으로 매칭시킬 수 있다.
      for (var asset in media) {
        // Platform.isIOS ? print('iOS id : ${asset.id}') : print('android title : ${asset.title}');

        // 아이폰사진의 경우 내가 고른사진의 id와 앨범의 id가 일치한다면
        if (resultList[i].identifier == asset.id) {
          // 해당 사진의 개월수 계산
          var babyMonths =
          (asset.createDateTime.difference(_babyBirthday).inDays / 30).floor();

          AssetEntity tmpAsset = AssetEntity(id: asset.id);

          var existAlbum = false;

          // 기존 폴더 돌면서 아기 개월수 폴더 있는지 체크
          for (int j = 0; j < targetPathList.length; j++) {
            if (targetPathList[j].name == "$babyMonths month" ||
                targetPathList[j].name == "$babyMonths month(s)") {
              // 해당 개월의 폴더 안에 사진 이동
              await PhotoManager.editor.copyAssetToPath(
                  asset: tmpAsset, pathEntity: targetPathList[j]);
              existAlbum = true;
            }
          }

          // 모든 앨범 찾아봤는데 해당 개월수의 앨범이 없는 경우 앨범 만들어준 후에 파일 복사해야 함
          if (!existAlbum) {
            if (babyMonths == 0)
              targetPathList.add(await PhotoManager.editor.iOS.createAlbum(
                "$babyMonths month", parent: targetPathList[babyAlbumIndex]
              ));
            else
              targetPathList.add(await PhotoManager.editor.iOS.createAlbum(
                "$babyMonths month(s)", parent: targetPathList[babyAlbumIndex]
              ));

            // 바로 위에서 추가한 앨범에 개월수 사진 넣어주기
            await PhotoManager.editor.copyAssetToPath(
                asset: tmpAsset, pathEntity: targetPathList[targetPathList.length-1]);
          }
        }
      }
    }
    for(int j = 0; j < targetPathList.length; j++){
      print(targetPathList[j].name);
    }
    setState(() {
      _isLoading = false;
    });
    showToast("${resultList.length} images complete to moved", duration: 2);
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
