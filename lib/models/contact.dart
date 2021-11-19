import 'package:firebase_database/firebase_database.dart';

class Contact{
  String _id="";
  String _firstName;
  String _lastName;
  String _phoneNumber;
  String _email;
  String _address;
  String _photoUrl;



  //contructor for add
Contact(this._firstName,this._lastName,this._phoneNumber,this._email,this._address,this._photoUrl){

}
//constructor for edit
Contact.withId(this._id,this._firstName,this._lastName,this._phoneNumber,this._email,this._address,this._photoUrl);

//getters
String get id => this._id;
String get firstName => this._firstName;
String get lastName => this._lastName;
String get phoneNumber => this._phoneNumber;
String get email => this._email;
String get address => this._address;
String get photo => this._photoUrl;


//setters
set firstName(String firstName){
  this._firstName = firstName;
}

set lastName(String lastName){
  this._lastName = lastName;
}
set phoneNumber(String phoneNumber){
  this._phoneNumber = phoneNumber;
}

set email(String email){
  this._email = email;
}

set address(String address){
  this._address = address;
}

set photoUrl(String photoUrl){
  this._photoUrl = photoUrl;
}

Contact.fromSnapshot(DataSnapshot snapshot){
this._id = snapshot.key;
this._firstName = snapshot.value['firstName'];
this._lastName = snapshot.value['lastName'];
this._phoneNumber = snapshot.value['phoneNumber'];
this._email = snapshot.value['email'];
this._address = snapshot.value['address'];
this._photoUrl = snapshot.value['photoUrl'];
}

Map<String,dynamic> toJson(){
  return {
    "firstName": _firstName,
    "lastName": _lastName,
    "phoneNumber": _phoneNumber,
    "email": _email,
    "address":_address,
    "photoUrl":_photoUrl
  }
}



}