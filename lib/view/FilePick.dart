// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
//
// class FilePick extends StatefulWidget {
//   @override
//   _FilePickState createState() => _FilePickState();
// }
//
// class _FilePickState extends State<FilePick> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: Text('1234')
//       ),
//     );
//   }
//
//   pickFiles() async {
//     FilePickerResult result = await FilePicker.platform.pickFiles();
//
//     if(result != null) {
//       PlatformFile file = result.files.first;
//
//       print(file.name);
//       print(file.bytes);
//       print(file.size);
//       print(file.extension);
//       print(file.path);
//     } else {
//       // User canceled the picker
//     }
//   }
// }
