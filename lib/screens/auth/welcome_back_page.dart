import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/screens/auth/register_page.dart';
import 'package:ecommerce_int2/screens/auth/products_page.dart';
import 'package:ecommerce_int2/screens/intro_page.dart';
import 'package:ecommerce_int2/screens/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'dart:convert';

class WelcomeBackPage extends StatefulWidget {
  @override
  _WelcomeBackPageState createState() => _WelcomeBackPageState();
}

class _WelcomeBackPageState extends State<WelcomeBackPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false, _obscureText = true;
  String? _email = "", _password = "";

  Widget _showTitle() {
    return Text('Login', style: TextStyle(fontSize: 25));
  }

  Widget _showEmailInput() {
    return Padding(padding: EdgeInsets.only(top: 20.0), child: Container(margin: const EdgeInsets.only(right: 10, left: 10), child: TextFormField(onSaved: (val) => _email = val, validator: (val) => val?.length != 10 ? 'Invalid Mobile Number' : null, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Mobile Number *', hintText: 'Mobile Number *'))));
  }

  Widget _showPasswordInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
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
                ))));
  }

  Widget _showFormActions() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(children: [
          _isSubmitting == true ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor)) : RaisedButton(child: Text('Submit', style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.black)), elevation: 8.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), color: Theme.of(context).accentColor, onPressed: _submit),
          FlatButton(
              child: Text('New user? Register'),
              onPressed: () => {
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => new RegisterPage()))
                  })
        ]));
  }

  void _submit() {
    final form = _formKey.currentState;
    print(form);
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
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new MainPage()));
    });
  }

  TextEditingController email = TextEditingController(text: 'example@email.com');

  TextEditingController password = TextEditingController(text: '12345678');

  @override
  Widget build(BuildContext context) {
    Widget welcomeBack = Text(
      'Welcome Back Roberto,',
      style: TextStyle(color: Colors.white, fontSize: 34.0, fontWeight: FontWeight.bold, shadows: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          offset: Offset(0, 5),
          blurRadius: 10.0,
        )
      ]),
    );

    Widget subTitle = Padding(
        padding: const EdgeInsets.only(right: 56.0),
        child: Text(
          'Login to your account using\nMobile number',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ));

    Widget loginButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 40,
      child: InkWell(
        onTap: () {},
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 80,
          child: Center(child: new Text("Log In", style: const TextStyle(color: const Color(0xfffefefe), fontWeight: FontWeight.w600, fontStyle: FontStyle.normal, fontSize: 20.0))),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromRGBO(236, 60, 3, 1),
                Color.fromRGBO(234, 60, 3, 1),
                Color.fromRGBO(216, 78, 16, 1),
              ], begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  offset: Offset(0, 5),
                  blurRadius: 10.0,
                )
              ],
              borderRadius: BorderRadius.circular(9.0)),
        ),
      ),
    );

    Widget loginForm = Container(
      height: 240,
      child: Stack(
        children: <Widget>[
          Container(
            height: 160,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 32.0, right: 12.0),
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.8), borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: email,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: password,
                    style: TextStyle(fontSize: 16.0),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ),
          loginButton,
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xff006400),
      appBar: AppBar(
          title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: <TextSpan>[
                TextSpan(text: "Feed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
                TextSpan(text: "Next", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 30)),
              ])),
          backgroundColor: Color(0x006600),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new MainPage())),
          )),
      body: Container(
          color: Color(0x006600),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: <TextSpan>[
                TextSpan(text: "India's 1st ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                TextSpan(text: "Feed & Fodder", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 25)),
                TextSpan(text: "buying App", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25))
              ]),
            ),
            SizedBox(height: 30),
            Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Color(0x336600),
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 300.0,
                        height: 300.0,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                                alignment: Alignment.center,
                                color: Colors.white,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 28.0),
                                    child: Form(
                                        key: _formKey,
                                        child: Column(children: [
                                          _showEmailInput(),
                                          _showPasswordInput(),
                                          _showFormActions()
                                        ])))))))
              ],
            )
          ])),
    );
  }
}
