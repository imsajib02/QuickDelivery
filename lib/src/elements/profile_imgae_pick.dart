import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../generated/l10n.dart';

class ProfileImagePickerWidget extends StatefulWidget {

  final ProfileController con;

  ProfileImagePickerWidget({Key key, this.con}) : super(key: key);

  @override
  _ProfileImagePickerWidgetState createState() => _ProfileImagePickerWidgetState();
}

class _ProfileImagePickerWidgetState extends State<ProfileImagePickerWidget> {

  File _file;
  FileImage _image;

  @override
  Widget build(BuildContext context) {

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Text(S.of(context).profileImage, style: Theme.of(context).textTheme.headline4.copyWith(color: Theme.of(context).accentColor),),

            SizedBox(height: 20,),

            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: CircleAvatar(
                radius: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(300)),
                  child: Icon(Icons.camera_alt, size: 65, color: _image == null ? Colors.white : Colors.transparent,),
                ),
                backgroundImage: _image,
              ),
            ),

            SizedBox(height: 25,),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: Text(S.of(context).cancel, style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),),
                    ),
                  ),
                ),

                SizedBox(width: 10,),

                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.con.updateProfileImage(_file);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      color: Theme.of(context).accentColor,
                      child: Text(S.of(context).save, style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _pickImage() async {

    try {

      var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
      _file = await _compressFile(File(pickedFile.path));

      setState(() {
        _image = FileImage(_file);
      });

    } catch(error) {

      print(error);
    }
  }

  Future<File> _compressFile(File file) async {

    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, outPath,
      quality: 5,
    );

    return result;
  }
}