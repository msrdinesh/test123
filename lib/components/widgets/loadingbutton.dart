import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

// BuildContext context;
Widget loadingButtonWidget(context) {
  return Container(
      padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 6, 0,
          MediaQuery.of(context).size.width / 6, 0),
      child: RaisedButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(0.0)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SpinKitFadingCircle(color: Colors.white, size: 30),
          Text(
            "Loading",
            style: AppFonts().getTextStyle('button_text_color_white'),
          )
        ]),
        onPressed: null,
      ));
}

Widget circularLoadingIcon() {
  return SpinKitFadingCircle(color: mainAppColor, size: 50);
}

Widget circularLoadingIconWithColor(Color color) {
  return SpinKitFadingCircle(color: color, size: 50);
}

Widget customizedCircularLoadingIcon(double size) {
  return SpinKitFadingCircle(color: mainAppColor, size: size);
}

Widget customizedCircularLoadingIconWithColorAndSize(double size, Color color) {
  return SpinKitFadingCircle(color: color, size: size);
}

Widget loadingButtonForLinks() {
  return SpinKitFadingCircle(
    color: mainAppColor,
    size: 20,
    // controller: AnimationController(
    //   vsync:
    // ),
  );
}
