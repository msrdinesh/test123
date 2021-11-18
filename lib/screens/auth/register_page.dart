import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/screens/auth/register_page.dart';
import 'package:ecommerce_int2/screens/auth/products_page.dart';
import 'package:ecommerce_int2/screens/intro_page.dart';
import 'package:ecommerce_int2/screens/auth/welcome_back_page.dart';
import 'package:ecommerce_int2/screens/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

class RegisterPage extends StatefulWidget {
  @override
  _WelcomeBackPageState createState() => _WelcomeBackPageState();
}

showError(String errorMessage, BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text("Error"), content: Text(errorMessage), actions: <Widget>[
          FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ]);
      });
}

class _WelcomeBackPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController(text: 'example@email.com');

  TextEditingController password = TextEditingController(text: '12345678');

  TextEditingController cmfPassword = TextEditingController(text: '12345678');
  bool _isSubmitting = false, _obscureText = true;
  String? _firstname = "", _lastname = "", _mobileNumber = "", _alternateMobileNumber = "", _email = "", _password = "", _houseNumber = "", _street = "", _city = "", _state = "", _pincode = "";
  bool _sameDelivery = false;

  Widget _showTitle() {
    return Text('Create Account');
  }

  Widget _showFirstNameInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _firstname = val, validator: (val) => val!.length < 3 ? 'Firstname too short' : null, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'First Name *', hintText: 'First Name *')));
  }

  Widget _showLastNameInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _lastname = val, validator: (val) => val!.length < 2 ? 'Lastname too short' : null, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Last Name', hintText: 'Last Name')));
  }

  Widget _showConfirmPasswordInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _lastname = val, validator: (val) => val == _password ? null : 'Password is not matching', decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Confirm Password *', hintText: 'Confirm Password *')));
  }

  Widget _showMobileNumberInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _mobileNumber = val,
            validator: (val) => val!.length != 10 ? 'Enter a valid mobile number' : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Mobile Number *',
              hintText: 'Mobile Number *',
            )));
  }

  Widget _showAlternateMobileNumberInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _mobileNumber = val,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Alternate Mobile Number',
              hintText: 'Alternate Mobile Number',
            )));
  }

  Widget _showEmailInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _mobileNumber = val,
            validator: (val) => !val!.contains('@') ? 'Enter a valid mobile number' : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email *',
              hintText: 'Email *',
            )));
  }

  Widget _showHouseNumberInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _houseNumber = val,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'House Number',
              hintText: 'House Number',
            )));
  }

  Widget _showStreetInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _street = val, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Street/Area', hintText: 'Street/Area')));
  }

  Widget _showCityInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _city = val, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'City/Town/Village *', hintText: 'City/Town/Village *')));
  }

  Widget _showStateInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _state = val, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'State *', hintText: 'State *')));
  }

  Widget _showPincodeInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _pincode = val, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Pincode *', hintText: 'Pincode *')));
  }

  Widget _showPasswordInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onChanged: (val) => _password = val,
            onSaved: (val) => _password = val,
            validator: (val) => val!.length < 6 ? 'Username too short' : null,
            obscureText: _obscureText,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                  child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off)),
              border: OutlineInputBorder(),
              labelText: 'Password',
              hintText: 'Enter password, min length 6',
            )));
  }

  Widget _showFormActions() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(children: [
          _isSubmitting == true ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor)) : RaisedButton(child: Text('Continue', style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black)), elevation: 8.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), color: Theme.of(context).primaryColor, onPressed: _submit),
          FlatButton(child: Text('Existing user? Login'), onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new WelcomeBackPage())))
        ]));
  }

  void _submit() {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      _registerUser();
      // _redirectUser();
    }
  }

  void _registerUser() async {
    setState(() => _isSubmitting = true);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }

    try {
      if ((defaultTargetPlatform == TargetPlatform.iOS) || (defaultTargetPlatform == TargetPlatform.android)) {
        // Some android/ios specific code

      } else if ((defaultTargetPlatform == TargetPlatform.linux) || (defaultTargetPlatform == TargetPlatform.macOS) || (defaultTargetPlatform == TargetPlatform.windows)) {
        // Some desktop specific code there
        print("dinnu thopu");
        print(_email.toString());
        print(_password.toString());

        print("here dinnu");
        print("here");
        print(_email.toString());
        print(_password.toString());
        UserCredential user = await _auth.createUserWithEmailAndPassword(email: _email.toString().trim(), password: _password.toString().trim());
        print("here i am there");
        if (user == null) {
          print("user is null");
        } else {
          print("non null");
          _redirectUser();
        }
      } else {
        // Some web specific code there

        print(_auth);
        print("here dinnu");
        print(_email.toString());
        print(_password.toString());
        UserCredential user = await _auth.signInWithEmailAndPassword(email: _email.toString().trim(), password: _password.toString().trim());
        print("here i am there");
        if (user == null) {
          print("user is null");
        } else {
          print("non null");
          _redirectUser();
        }
      }
    } catch (e) {
      // showError(e.message);
      print(e.toString());
      showError(e.toString(), context);
    }

    setState(() => _isSubmitting = false);
  }

  void _showSuccessSnack() {
    final snackbar = SnackBar(content: Text('User $_mobileNumber successfully created!', style: TextStyle(color: Colors.green)));
    if (_scaffoldKey != null) {
      _scaffoldKey.currentState?.showSnackBar(snackbar);
    }
    _formKey.currentState?.reset();
  }

  void _showErrorSnack(String errorMsg) {
    final snackbar = SnackBar(content: Text(errorMsg, style: TextStyle(color: Colors.red)));
    _scaffoldKey.currentState?.showSnackBar(snackbar);
    throw Exception('Error registering: $errorMsg');
  }

  void _redirectUser() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new MainPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff006400),
        appBar: AppBar(
            title: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: <TextSpan>[
                  TextSpan(text: "Feed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
                  TextSpan(text: "Next", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 30)),
                ])),
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new MainPage())),
            )),
        body: SingleChildScrollView(
          child: Stack(children: <Widget>[
            Container(
                color: Color(0x006600),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x336600),
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: Padding(
                                  padding: const EdgeInsets.only(left: 28.0),
                                  child: Form(
                                      key: _formKey,
                                      child: Column(children: [
                                        // _showTitle(),
                                        _showFirstNameInput(),
                                        _showLastNameInput(),
                                        _showMobileNumberInput(),
                                        _showAlternateMobileNumberInput(),
                                        _showEmailInput(),
                                        _showPasswordInput(),
                                        _showConfirmPasswordInput(),
                                        _showHouseNumberInput(),
                                        _showStreetInput(),
                                        _showCityInput(),
                                        _showStateInput(),
                                        _showPincodeInput(),
                                        _showFormActions()
                                      ])))))
                    ],
                  )
                ]))
          ]),
        ));
  }
}
