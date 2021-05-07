// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:toast/toast.dart';
//
// class BabyImage extends StatefulWidget {
//   @override
//   _BabyImageState createState() => _BabyImageState();
// }
//
// class _BabyImageState extends State<BabyImage> {
//   PickedFile _imageFile;
//   File profileImage;
//   final ImagePicker _picker = ImagePicker();
//   var isLoading;
//
//   @override
//   void initState() {
//     super.initState();
//     // currentUser =
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () async {
//         changeProfileImage();
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Stack(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   // alignment: Alignment.center,
//                     height: MediaQuery.of(context).size.height * 0.15,
//                     width: MediaQuery.of(context).size.height * 0.15,
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                             offset: Offset(0, 0),
//                             blurRadius: 5,
//                             color: Colors.black38)
//                       ],
//                       borderRadius: BorderRadius.circular(90),
//                     ),
//                     child: currentUser.url != null &&
//                         currentUser.url != ""
//                         ? CachedNetworkImage(
//                       imageUrl: currentUser.url,
//                       imageBuilder: (context, imageProvider) =>
//                           Container(
//                               height: MediaQuery.of(context)
//                                   .size
//                                   .height *
//                                   0.15,
//                               width: MediaQuery.of(context)
//                                   .size
//                                   .height *
//                                   0.15,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 image: DecorationImage(
//                                     image: imageProvider,
//                                     fit: BoxFit.cover),
//                               )),
//                     )
//                         : Image.asset(
//                         'assets/images/animal/${currentUser.randomNumber}.png')),
//               ],
//             ),
//             Positioned(
//               bottom: 5,
//               right: MediaQuery.of(context).size.width * 0.35,
//               child: Center(
//                 child: Container(
//                   child: Icon(
//                     Icons.camera,
//                     color: Colors.black54,
//                     size: 35,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void changeProfileImage() async {
//     // 갤러리 사진으로 선택
//     final pickedFile = await _picker.getImage(source: ImageSource.gallery, imageQuality: 5);
//     setState(() {
//       _imageFile = pickedFile;
//       isLoading = true;
//     });
//
//     // 해당 경로로 파일 생성
//     profileImage = File(_imageFile.path);
//
//     // storage에 업로드
//     String fileName = '${currentUser.email}';
//
//     Reference firebaseStorageRef =
//     FirebaseStorage.instance.ref().child('profileImage/$fileName');
//
//     showToast("프로필사진을 업로드 중입니다.\n잠시 기다려주세요.");
//
//     // 위에서 생성해둔 파일로 업로드
//     UploadTask uploadTask = firebaseStorageRef.putFile(profileImage);
//     var _imageUrl;
//
//     uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//       print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
//     }, onError: (Object e) {
//       print(e);
//     });
//
//     // Future.delayed(Duration(seconds: 10));
//     // upload 완료된 경우 url 경로 저장해두기
//     uploadTask.then((TaskSnapshot taskSnapshot) {
//       taskSnapshot.ref.getDownloadURL().then((value) async {
//         setState(() {
//           _imageUrl = value;
//         });
//
//         // firestore에 이미지 정보 수정
//         WriteBatch writeBatch = FirebaseFirestore.instance.batch();
//
//         writeBatch.update(
//             FirebaseFirestore.instance.collection('users').doc(currentUser.id),
//             {
//               // currentUser.id 변경해야 함
//               'url': _imageUrl,
//               'updatedAt': DateTime.now(),
//             });
//
//         // batch end
//         writeBatch.commit();
//
//         showToast("프로필사진 변경 완료");
//
//         DocumentSnapshot documentSnapshot =
//         await userReference.doc(currentUser.id).get();
//
//         // 최초 로그인에 한해 푸쉬알림 전송을 위한 토큰 별도로 저장해두기 (애플 로그인)
//         // _saveDeviceToken(user.uid);
//
//         // 현재 유저정보에 값 셋팅하기
//         setState(() {
//           currentUser = CurrentUser.fromDocument(documentSnapshot);
//           isLoading = false;
//         });
//       });
//     });
//   }
//
//   showToast(String msg, {int duration, int gravity}) {
//     Toast.show(msg, context, duration: duration, gravity: gravity);
//   }
// }
