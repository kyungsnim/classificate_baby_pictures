import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_helpers/firebase_helpers.dart';

class CurrentUser extends DatabaseItem {
  String id;
  String userName;
  String profileName;
  String url;
  int randomNumber;
  int grade;
  String inbodyScore;
  String email;
  String role;
  String isValidated;
  DateTime createdAt;
  DateTime updatedAt;
  String loginType;
  bool validateByAdmin;
  DateTime imageDownloadAt;
  DateTime pdfUploadAt;

  CurrentUser({
    this.id,
    this.userName,
    this.profileName,
    this.url,
    this.randomNumber,
    this.grade,
    this.inbodyScore,
    this.email,
    this.role,
    this.isValidated,
    this.createdAt,
    this.updatedAt,
    this.loginType,
    this.validateByAdmin,
    this.imageDownloadAt,
    this.pdfUploadAt
  }) : super(id);

  factory CurrentUser.fromDocument(DocumentSnapshot doc) {
    Map getDocs = doc.data();
    return CurrentUser(
      id: doc.id,
      email: getDocs["email"],
      userName: getDocs["userName"],
      url: getDocs["url"],
      randomNumber: getDocs["randomNumber"],
      grade: getDocs["grade"],
      inbodyScore: getDocs["inbodyScore"],
      role: getDocs["role"],
      isValidated: getDocs["isValidated"],
      profileName: getDocs["profileName"],
      createdAt: getDocs["createdAt"].toDate(),
      updatedAt: getDocs["updatedAt"].toDate(),
      loginType: getDocs["loginType"],
      validateByAdmin: getDocs["validateByAdmin"],
    );
  }
}
