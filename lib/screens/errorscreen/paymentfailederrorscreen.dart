import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/services/ordersummaryservice/ordersummaryservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

class PaymentFailedErrorPage extends StatefulWidget {
  @override
  PaymentFailedErrorScreen createState() => PaymentFailedErrorScreen();
}

class PaymentFailedErrorScreen extends State<PaymentFailedErrorPage> {
  final AppFonts appFonts = AppFonts();

  Future<bool> onBackButtonPressed() async {
    return false;
  }

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
                // Icon(
                //   Icons.signal_wifi_off,
                //   size: 70,
                // ),
                Text(
                  'Payment Failed',
                  style:
                      appFonts.getTextStyle('no_internet_error_screen_style'),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popAndPushNamed(routeNameBeforePayment);
                      },
                      child: Text('Try Again'),
                      color: mainYellowColor,
                    ))
              ],
            ),
          )),
        ));
  }
}
