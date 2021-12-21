import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'dart:convert';
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:cornext_mobile/services/forgotpasswordservices/forgotpasswordservice.dart';
import 'package:cornext_mobile/models/forgotpasswordmodel.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:flutter/services.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  ForgotPasswordScreen createState() => ForgotPasswordScreen();
}

class ForgotPasswordScreen extends State<ForgotPasswordPage> {
  final passwordController = TextEditingController();
  final mobileNoController = TextEditingController();
  final forgotPasswordHomeKey = GlobalKey<FormState>();
  final ApiErros apiErros = ApiErros();

  // All form field keys
  final mobileNokey = GlobalKey<FormFieldState>();
  // All focusnode keys
  final FocusNode mobileNoFocus = FocusNode();
  bool onLoading = false;
  final scafFoldkey = GlobalKey<ScaffoldState>();
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    setState(() {
      checkFormValidOrNot();
    });
    super.initState();
  }

  //initialization of validations.
  checkFormValidOrNot() {
    GlobalValidations().validateCurrentFieldValidOrNot(mobileNoFocus, mobileNokey);
    // GlobalValidations()
    //     .validateCurrentFieldValidOrNot(passwordFocus, passwordFormKey);
  }

  //creating otp.
  createOtp() {
    final Map requestObj = {
      "countryCode": 91,
      "mobileNo": mobileNoController.text.trim()
    };

    ForgotPasswordService().getOtp(requestObj).then((res) {
      final data = json.decode(res.body);
      // print(data);
      // print('satyaaa');

      if (data != null && data == 'SUCCESS') {
        forgotpassworddetails['mobileno'] = mobileNoController.text.trim();
        // print(mobileNoController.text.trim());
        // showSuccessNotifications(SuccessMessages().otpSentMessage, context);
        Navigator.pushNamed(context, '/otpvalidationforforgotpassword');
      } else if (data != null && data == 'USERDOESNOTEXIST') {
        showErrorNotifications(ErrorMessages().forgotPasswordUserDoesNotExistError, context, scafFoldkey);
      } else if (data != null && data == 'MOBILENUMBERINVALID') {
        showErrorNotifications(ErrorMessages().forgotPasswordUserMobileNumberinvalid, context, scafFoldkey);
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldkey);
      }
      setState(() {
        onLoading = false;
      });
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/forgotpassword', scafFoldkey);
      setState(() {
        onLoading = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: scafFoldkey,
        appBar: plainAppBarWidget,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(cornextBackgroundImagePath), fit: BoxFit.cover)),
            child: Center(
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
              Card(
                  margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Form(
                      key: forgotPasswordHomeKey,
                      child: Container(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                          child: Column(children: <Widget>[
                            Text('$forgotPasswordHeaderName', style: appFonts.getTextStyle('forgot_passwords_screen_heading_styles')),
                            AppStyles().customPadding(8),
                            TextFormField(
                              cursorColor: mainAppColor,
                              validator: (value) => GlobalValidations().mobileValidations(value),
                              decoration: InputDecoration(
                                errorMaxLines: 2,
                                labelText: mobileNumberLabelName + " *",
                                counterText: "",
                                // alignLabelWithHint: true,
                                border: AppStyles().inputBorder,
                                prefix: Text("+91 "),
                                contentPadding: AppStyles().contentPaddingForInput,
                                focusedBorder: AppStyles().focusedInputBorder,
                              ),
                              controller: mobileNoController,
                              key: mobileNokey,
                              focusNode: mobileNoFocus,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            !onLoading
                                ? RaisedButton(
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                                    onPressed: () {
                                      clearErrorMessages(scafFoldkey);
                                      if (forgotPasswordHomeKey.currentState.validate()) {
                                        setState(() {
                                          onLoading = true;
                                        });
                                        createOtp();
                                      }
                                    },
                                    color: mainAppColor,
                                    // shape: ,
                                    // clipBehavior: Clip.antiAlias,
                                    child: Text("Generate OTP", style: appFonts.getTextStyle('button_text_color_white')),
                                  )
                                : loadingButtonWidget(context),
                          ]))))
            ]))),
          ),
        ));
  }
}
