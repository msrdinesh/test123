import 'package:cornext_mobile/services/registrationservices/registrationservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/signinservices/signinservice.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
// import 'package:flushbar/flushbar.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/services/sqflitedbservice/sqllitedbservice.dart';
import 'package:cornext_mobile/services/cartservice/cartservice.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:flutter/services.dart';
// import 'dart:async';

class LanguagesPage extends StatefulWidget {
  @override
  SignIn createState() => SignIn();
}

class SignIn extends State<LanguagesPage> {
  @override
  void initState() {}

  Widget build(BuildContext context) {
    return Scaffold(body: Text("Chooose your language", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
  }
}
