import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import '../models/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  DatabaseReference _databaseReferance = FirebaseDatabase.instance.reference();
  String _firstName = "";
  String _lastName = "";
  String _phoneNumber = "";
  String _email = "";
  String _address = "";
  String _photoUrl = "empty";

  saveContact(BuildContext context) async {
    if (this._firstName.isNotEmpty && this._lastName.isNotEmpty && this._phoneNumber.isNotEmpty && this._email.isNotEmpty && this._address.isNotEmpty) {
      Contact contact = Contact(_firstName, _lastName, _phoneNumber, _email, _address, _photoUrl);
      await _databaseReferance.push().set(contact.toJson());
      navigateToLastScreen(context);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(title: Text("Field required"), content: Text("All fields are required"), actions: <Widget>[
              FlatButton(
                  child: Text("closer"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ]);
          });
    }
  }

  navigateToLastScreen(context) {
    Navigator.of(context).pop();
  }

  Future pickImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
    String fileName = basename(file.path);
    uploadImage(file, fileName);
  }

  void uploadImage(File file, String fileName) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
    storageReference.putFile(file).whenComplete((firebaseFile) async {
      var downloadUrl = await firebaseFile.ref.getDownloadURL();

      setState(() {
        _photoUrl = downloadUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
