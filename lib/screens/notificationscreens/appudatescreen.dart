import 'package:flutter/material.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appconstants.dart';

class AppUpdatePage extends StatefulWidget {
  @override
  AppUpdateScreen createState() => AppUpdateScreen();
}

class AppUpdateScreen extends State<AppUpdatePage> {
  final AppFonts appFonts = AppFonts();

  void initState() {
    super.initState();
  }

  Future<bool> onBackButtonPressed() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: plainAppBarWidgetWithoutBackButton,
        body: WillPopScope(
          onWillPop: onBackButtonPressed,
          child: Center(
              child: Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'FeedNext Unavailable',
                    style: appFonts.getTextStyle('app_update_heading_style'),
                  ),
                ),
                Container(
                    child: Text(
                  manditoryAppUpdateMessage,
                  textAlign: TextAlign.justify,
                  style: appFonts.getTextStyle('app_update_content_style'),
                ))
              ],
            ),
          )),
        ));
  }
}
