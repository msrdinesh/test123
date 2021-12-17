import 'package:flutter/material.dart';
// import 'package:flushbar/flushbar.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

// Flushbar flushBar;
// Flushbar errorFlushBar;
// Flushbar successFlushBar;
// showErrorNotifications(message, context) {
//   // BuildContext context;
//   flushBar = Flushbar(
//     flushbarPosition: FlushbarPosition.BOTTOM,
//     icon: Container(
//         margin: EdgeInsets.only(left: 15),
//         child: Icon(
//           Icons.info_outline,
//           color: Colors.red,
//         )),
//     // title: val,
//     margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
//     backgroundColor: Colors.grey[200],
//     flushbarStyle: FlushbarStyle.FLOATING,
//     duration: Duration(seconds: 5),
//     // title: val,
//     animationDuration: Duration(milliseconds: 500),
//     // isDismissible: false,
//     // duration: Duration(seconds: 8),
//     maxWidth: 250,
//     // margin: EdgeInsets.only(top: 55),
//     borderRadius: 5,
//     dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//     // message: val,
//     messageText: Text(
//       message,
//       style: TextStyle(color: Colors.red),
//       textAlign: TextAlign.center,
//     ),
//   )..show(context);
//   return flushBar;
// }

// showSuccessNotifications(message, context) {
//   successFlushBar = Flushbar(
//     flushbarPosition: FlushbarPosition.BOTTOM,
//     icon: Container(
//         margin: EdgeInsets.only(left: 15),
//         child: Icon(
//           Icons.check_circle_outline,
//           color: mainAppColor,
//         )),
//     // title: val,
//     margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
//     backgroundColor: Colors.grey[200],
//     flushbarStyle: FlushbarStyle.FLOATING,
//     dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//     // title: val,
//     duration: Duration(seconds: 2),
//     maxWidth: 250,
//     animationDuration: Duration(milliseconds: 500),
//     // margin: EdgeInsets.only(top: 55),
//     borderRadius: 5,
//     // message: val,
//     messageText: Text(
//       message,
//       style: TextStyle(color: mainAppColor),
//       textAlign: TextAlign.center,
//     ),
//   )..show(context);
//   return successFlushBar;
// }

// closeNotifications() {
//   if (flushBar != null) {
//     flushBar.dismiss();
//   }
// }

// showErrorMessages(message, context) {
//   // BuildContext context;
//   errorFlushBar = Flushbar(
//     flushbarPosition: FlushbarPosition.BOTTOM,
//     icon: Container(
//         margin: EdgeInsets.only(left: 15),
//         child: Icon(
//           Icons.info_outline,
//           color: Colors.red,
//         )),
//     // title: val,
//     margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
//     backgroundColor: Colors.grey[200],
//     flushbarStyle: FlushbarStyle.FLOATING,
//     animationDuration: Duration(milliseconds: 500),
//     isDismissible: true,
//     // duration: Duration(seconds: 8),
//     maxWidth: 250,
//     duration: Duration(seconds: 3),
//     // margin: EdgeInsets.only(top: 55),
//     borderRadius: 2,
//     dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//     // message: val,
//     messageText: Text(
//       message,
//       style: TextStyle(color: Colors.red),
//       textAlign: TextAlign.center,
//     ),
//   )..show(context);
//   return flushBar;
// }

// showErrorMessagesAlongWithTime(message, context, int timeInSeconds) {
//   // BuildContext context;
//   errorFlushBar = Flushbar(
//     flushbarPosition: FlushbarPosition.BOTTOM,
//     icon: Container(
//         margin: EdgeInsets.only(left: 15),
//         child: Icon(
//           Icons.info_outline,
//           color: Colors.red,
//         )),
//     // title: val,
//     margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
//     backgroundColor: Colors.grey[200],
//     flushbarStyle: FlushbarStyle.FLOATING,
//     animationDuration: Duration(milliseconds: 500),
//     // isDismissible: false,
//     // duration: Duration(seconds: 8),
//     maxWidth: 250,
//     duration: Duration(seconds: timeInSeconds),
//     // margin: EdgeInsets.only(top: 55),
//     borderRadius: 2,
//     dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//     // message: val,
//     messageText: Text(
//       message,
//       style: TextStyle(color: Colors.red),
//       textAlign: TextAlign.center,
//     ),
//   )..show(context);
//   return flushBar;
// }

clearErrorMessages(GlobalKey<ScaffoldState> scaffoldKey) {
  if (scaffoldKey != null && scaffoldKey.currentState != null) {
    // errorFlushBar.dismiss();
    scaffoldKey.currentState.hideCurrentSnackBar();
  }
}

clearSuccessNotifications(GlobalKey<ScaffoldState> scafFlodKey) {
  // if (successFlushBar != null) {
  //   successFlushBar.dismiss();
  // }
  if (scafFlodKey != null && scafFlodKey.currentState != null) {
    scafFlodKey.currentState.hideCurrentSnackBar();
  }
}

showErrorNotifications(message, context, GlobalKey<ScaffoldState> scafFlodKey) {
  final snackBar = SnackBar(
    backgroundColor: Colors.grey[100],
    // shape: ,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
    content: Text(message,
        textAlign: TextAlign.center,
        style: AppFonts().getTextStyle('error_notifications_text_style')),
    duration: Duration(seconds: 3),
  );

  // Find the Scaffold in the widget tree and use
  // it to show a SnackBar.
  if (scafFlodKey != null && scafFlodKey.currentState != null) {
    scafFlodKey.currentState.showSnackBar(snackBar);
  }
}

showSuccessNotifications(
    message, context, GlobalKey<ScaffoldState> scafFlodKey) {
  final snackBar = SnackBar(
    backgroundColor: Colors.grey[100],
    // shape: ,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
    content: Text(message,
        textAlign: TextAlign.center,
        style: AppFonts().getTextStyle('success_notifications_text_style')),
    duration: Duration(seconds: 3),
  );

  // Find the Scaffold in the widget tree and use
  // it to show a SnackBar.
  if (scafFlodKey != null && scafFlodKey.currentState != null) {
    scafFlodKey.currentState.showSnackBar(snackBar);
  }
}
