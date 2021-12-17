import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
// import 'package:cornext_mobile/services/ordersummaryservice/ordersummaryservice.dart';

class OrderCreationFailedPage extends StatefulWidget {
  @override
  OrderCreationFailedScreen createState() => OrderCreationFailedScreen();
}

class OrderCreationFailedScreen extends State<OrderCreationFailedPage> {
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
                Icon(
                  Icons.check_circle,
                  color: mainAppColor,
                  size: 50,
                ),
                Text(
                  'Payment Success',
                  style: appFonts.getTextStyle(
                      'ordercreationfailed_screen_payment_success_style'),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 8, left: 20, right: 10),
                    child: Text(
                        'It seems like your order is not generated yet. It will be generated soon',
                        style: appFonts.getTextStyle(
                            'ordercreationfailed_screen_error_text_style'))),
                Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', ModalRoute.withName('/home'));
                      },
                      child: Text('Buy More Products'),
                      color: mainYellowColor,
                    ))
              ],
            ),
          )),
        ));
  }
}
