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
  bool _isSubmitting = false;
  String _firstName = "";
  String _lastName = "";
  String _phoneNumber = "";
  String _email = "";
  String _address = "";
  String _photoUrl = "empty";

  saveContact(BuildContext context) async {
    if (this._firstName.isNotEmpty && this._lastName.isNotEmpty && this._phoneNumber.isNotEmpty && this._email.isNotEmpty && this._address.isNotEmpty) {
      print(this._firstName.isNotEmpty);
      print(this._lastName.isNotEmpty);
      print(this._phoneNumber.isNotEmpty);
      print(this._email.isNotEmpty);
      print(this._address.isNotEmpty);
      Contact contact = Contact(_firstName, _lastName, _phoneNumber, _email, _address, _photoUrl);
      print("here");
      setState(() => _isSubmitting = true);
      await _databaseReferance.push().set(contact.toJson());
      setState(() => _isSubmitting = false);
      print("here1");
      navigateToLastScreen(context);
      print("here2");
    } else {
      print(this._firstName.isNotEmpty);
      print(this._lastName.isNotEmpty);
      print(this._phoneNumber.isNotEmpty);
      print(this._email.isNotEmpty);
      print(this._address.isNotEmpty);
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
    storageReference.putFile(file).whenComplete(() async {
      var downloadUrl = await storageReference.getDownloadURL();

      setState(() {
        _photoUrl = downloadUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE9ECEF),
        appBar: AppBar(title: Text("Add contact")),
        body: Container(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: ListView(children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: GestureDetector(
                          onTap: () {
                            this.pickImage();
                          },
                          child: Center(
                            child: Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: _photoUrl == "empty" ? AssetImage("assets/logo.png") : NetworkImage(_photoUrl) as ImageProvider,
                                    ))),
                          ))),
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _firstName = value;
                            });
                          },
                          decoration: InputDecoration(labelText: "First Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))))),
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _lastName = value;
                            });
                          },
                          decoration: InputDecoration(labelText: "Last Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))))),
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _phoneNumber = value;
                            });
                          },
                          decoration: InputDecoration(labelText: "Phone number", border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))))),
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                          decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))))),
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _address = value;
                            });
                          },
                          decoration: InputDecoration(labelText: "Address", border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))))),
                  Container(
                      padding: EdgeInsets.only(top: 20.0),
                      child: _isSubmitting == true
                          ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor))
                          : RaisedButton(
                              padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
                              onPressed: () {
                                saveContact(context);
                              },
                              color: Colors.red,
                              child: Text("Save", style: TextStyle(fontSize: 20.0, color: Colors.white))))
                ]))));
  }
}
