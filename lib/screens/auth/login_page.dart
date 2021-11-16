import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:feednext/sidebar.dart';
import 'package:feednext/pages/products_page.dart';
import 'package:feednext/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting, _obscureText = true;
  String _email, _password;

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
