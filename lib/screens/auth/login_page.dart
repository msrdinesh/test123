import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ecommerce_int2/screens/auth/sidebar.dart';
import 'package:ecommerce_int2/screens/auth/products_page.dart';
import 'package:ecommerce_int2/screens/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false, _obscureText = true;
  String? _email = "", _password = "";

  Widget _showTitle() {
    return Text('Login', style: Theme.of(context).textTheme.headline1);
  }

  Widget _showEmailInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: TextFormField(onSaved: (val) => _email = val, validator: (val) => val?.length != 10 ? 'Invalid Mobile Number' : null, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Mobile Number *', hintText: 'Mobile Number *', icon: Icon(Icons.mail, color: Colors.grey))));
  }

  Widget _showPasswordInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _password = val,
            validator: (val) => val == null
                ? "null"
                : val.length < 6
                    ? 'Password too short'
                    : null,
            obscureText: _obscureText,
            decoration: InputDecoration(
                suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                    child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off)),
                border: OutlineInputBorder(),
                labelText: 'Password *',
                hintText: 'Password *',
                icon: Icon(Icons.lock, color: Colors.grey))));
  }

  Widget _showFormActions() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(children: [
          _isSubmitting == true ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor)) : RaisedButton(child: Text('Submit', style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.black)), elevation: 8.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), color: Theme.of(context).accentColor, onPressed: _submit),
          FlatButton(child: Text('New user? Register'), onPressed: () => {})
        ]));
  }

  void _submit() {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      // _registerUser();
      _redirectUser();
    }
  }

  void _registerUser() async {
    setState(() => _isSubmitting = true);
    http.Response response = await http.post(Uri.parse('http://localhost:1337/auth/local'), body: {
      "identifier": _email,
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
    final snackbar = SnackBar(content: Text('User successfully logged in!', style: TextStyle(color: Colors.green)));
    _scaffoldKey.currentState?.showSnackBar(snackbar);
    _formKey.currentState?.reset();
  }

  void _showErrorSnack(String errorMsg) {
    final snackbar = SnackBar(content: Text(errorMsg, style: TextStyle(color: Colors.red)));
    _scaffoldKey.currentState?.showSnackBar(snackbar);
    throw Exception('Error logging in: $errorMsg');
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
            onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new ProductsPage())),
          )),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
              child: SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: Column(children: [
                        _showTitle(),
                        _showEmailInput(),
                        _showPasswordInput(),
                        _showFormActions()
                      ]))))),
    );
  }
}