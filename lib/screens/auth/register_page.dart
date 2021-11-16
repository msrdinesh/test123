import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecommerce_int2/screens/auth/sidebar.dart';
import 'package:ecommerce_int2/screens/auth/login_page.dart';
import 'package:ecommerce_int2/screens/auth/products_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting, _obscureText = true;
  String _firstname, _lastname, _mobileNumber, _alternateMobileNumber, _email, _password, _houseNumber, _street, _city, _state, _pincode;
  bool _sameDelivery;

  Widget _showTitle() {
    return Text('Create Account');
  }

  Widget _showFirstNameInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _firstname = val, validator: (val) => val.length < 3 ? 'Firstname too short' : null, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'First Name *', hintText: 'First Name *')));
  }

  Widget _showLastNameInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _lastname = val, validator: (val) => val.length < 2 ? 'Lastname too short' : null, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Last Name', hintText: 'Last Name')));
  }

  Widget _showConfirmPasswordInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _lastname = val, validator: (val) => val == _password ? null : 'Password is not matching', decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Confirm Password *', hintText: 'Confirm Password *')));
  }

  Widget _showMobileNumberInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _mobileNumber = val,
            validator: (val) => val.length != 10 ? 'Enter a valid mobile number' : null,
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
            validator: (val) => !val.contains('@') ? 'Enter a valid mobile number' : null,
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
            validator: (val) => val.length < 6 ? 'Username too short' : null,
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
          _isSubmitting == true ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor)) : RaisedButton(child: Text('Continue', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black)), elevation: 8.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), color: Theme.of(context).primaryColor, onPressed: _submit),
          FlatButton(child: Text('Existing user? Login'), onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage())))
        ]));
  }

  void _submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      // _registerUser();
      _redirectUser();
    }
  }

  void _registerUser() async {
    setState(() => _isSubmitting = true);
    http.Response response = await http.post('http://localhost:1337/auth/local/register', body: {
      "mobileNumber": _mobileNumber,
      "password": _password
    });
    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() => _isSubmitting = false);
      _showSuccessSnack();
      _redirectUser();
      print(responseData);
    } else {
      setState(() => _isSubmitting = false);
      final String errorMsg = responseData['message'];
      _showErrorSnack(errorMsg);
    }
  }

  void _showSuccessSnack() {
    final snackbar = SnackBar(content: Text('User $_mobileNumber successfully created!', style: TextStyle(color: Colors.green)));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    _formKey.currentState.reset();
  }

  void _showErrorSnack(String errorMsg) {
    final snackbar = SnackBar(content: Text(errorMsg, style: TextStyle(color: Colors.red)));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    throw Exception('Error registering: $errorMsg');
  }

  void _redirectUser() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new ProductsPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: <TextSpan>[
                  TextSpan(text: "Feed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40)),
                  TextSpan(text: "Next", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 40)),
                ])),
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage())),
            )),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
                child: SingleChildScrollView(
                    child: Form(
                        key: _formKey,
                        child: Column(children: [
                          _showTitle(),
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
                        ]))))));
  }
}
