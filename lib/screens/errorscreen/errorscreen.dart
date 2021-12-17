import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:cornext_mobile/services/connectivityservice/connectivityservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

// import 'package:cornext_mobile/constants/errormessages.dart';
class ErrorScreenPage extends StatefulWidget {
  @override
  ErrorScreen createState() => ErrorScreen();
}

class ErrorScreen extends State<ErrorScreenPage> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final ConnectivityService connectivityService = ConnectivityService();
  final AppFonts appFonts = AppFonts();

  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        getConnectionStatus(result);
      });
    });
  }

  initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
    }

    return getConnectionStatus(result);
  }

  getConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        break;
      case ConnectivityResult.mobile:
        // Navigator.popAndPushNamed(context, previousScreenRouteName);
        Navigator.of(context).popAndPushNamed(previousScreenRouteName);
        break;
      case ConnectivityResult.wifi:
        Navigator.of(context).popAndPushNamed(previousScreenRouteName);
        break;
      default:
        break;
    }
  }

  void dispose() {
    if (_connectivitySubscription != null) {
      _connectivitySubscription.cancel();
    }
    super.dispose();
  }

  Future<bool> onBackButtonPressed() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: plainAppBarWidgetWithoutBackButton,
        body: WillPopScope(
          onWillPop: onBackButtonPressed,
          child: Center(
              child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.signal_wifi_off,
                  size: 70,
                ),
                Text(
                  'No internet connection',
                  style:
                      appFonts.getTextStyle('no_internet_error_screen_style'),
                )
              ],
            ),
          )),
        ));
  }
}
