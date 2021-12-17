import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/services/forgotpasswordservices/forgotpasswordservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:cornext_mobile/models/forgotpasswordmodel.dart';
import 'dart:convert';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/successmessages.dart';
import 'dart:async';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:flutter/services.dart';

class ForgotPasswordOtpValidationPage extends StatefulWidget {
  @override
  ForgotPasswordOtpValidation createState() => ForgotPasswordOtpValidation();
}

class ForgotPasswordOtpValidation
    extends State<ForgotPasswordOtpValidationPage> {
  final mobileNoController = TextEditingController();
  final otpController = TextEditingController();
  bool showResendOtpButton = false;
  bool resendOtpLoadingBtn = false;
  final ApiErros apiErros = ApiErros();

  //Form keys
  final otpValidationFormKey = GlobalKey<FormState>();

  //All Formfield keys
  final otpKey = GlobalKey<FormFieldState>();

  // All focusNodes
  final FocusNode otpFocus = FocusNode();
  bool onLoading = false;
  Timer timer;
  final GlobalKey<ScaffoldState> scafFoldKey = GlobalKey<ScaffoldState>();
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    // setState(() {
    //   otpKey.currentState?.reset();
    //   // mobileNokey.currentState?.reset();
    //   // checkFormValidOrNot();
    // });
    setState(() {
      // print(customerRegistrationDetails['mobileNo']);
      // mobileNoController.text =
      //     customerRegistrationDetails['personalDetails']['mobileNo'].toString();

      // otpValidationFormKey.currentState.reset();

      GlobalValidations().validateCurrentFieldValidOrNot(otpFocus, otpKey);
      mobileNoController.text = forgotpassworddetails['mobileno'];
      timer = Timer(Duration(seconds: 10), () {
        setState(() {
          showResendOtpButton = true;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  // reset the focus nodes.
  reset() {
    otpFocus.unfocus();
    // Future.delayed(Duration(milliseconds: 10), () {
    setState(() {
      otpController.text = "";
      otpKey.currentState?.reset();
    });
    // });
  }

//sending otp to user.
  sendOtp() {
    final Map sendOtpObj = {
      'countryCode': 91,
      'mobileNo': forgotpassworddetails['mobileno'].toString(),
      "mobileOtp": otpController.text.trim()
    };
    ForgotPasswordService().validateOtp(sendOtpObj).then((res) {
      final data = json.decode(res.body);
      if (data != null && data == "VALIDOTP") {
        // setState(() {
        // reset();
        // otpController.text = "";
        // otpValidationFormKey.currentSta();

        // otpValidationFormKey.currentState?.reset();
        // });
        Navigator.popAndPushNamed(
            context, '/CreateNewPassswordInForgotPasswordPage');
      } else if (data != null && data == 'MOBILEOTPEXPIRED') {
        showErrorNotifications(
            ErrorMessages().forgotPasswordUserOtpExpired, context, scafFoldKey);
      } else if (data != null && data == 'INVALIDOTP') {
        showErrorNotifications(
            ErrorMessages().forgotPasswordInvalidOtp, context, scafFoldKey);
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldKey);
      }

      setState(() {
        onLoading = false;
      });
    }, onError: (err) {
      ApiErros().apiErrorNotifications(
          err, context, '/otpvalidationforforgotpassword', scafFoldKey);
      setState(() {
        onLoading = false;
      });
    });
  }

  //Navigate to sign in page.
  backToSignin() {
    // Navigator.popUntil(context, ModalRoute.withName('/'));
    // Navigator.
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  }

  //re-sending otp.
  resendOtp() {
    setState(() {
      onLoading = false;
    });
    final Map requestObj = {
      "countryCode": 91,
      "mobileNo": mobileNoController.text.trim()
    };

    ForgotPasswordService().getOtp(requestObj).then((res) {
      final data = json.decode(res.body);
      if (data != null && data == 'SUCCESS') {
        forgotpassworddetails['mobileno'] = mobileNoController.text.trim();
        showSuccessNotifications(
            SuccessMessages().otpSentMessage, context, scafFoldKey);
        // Navigator.pushNamed(context, '/otpvalidationforforgotpassword');
        // otpKey.currentState?.reset();
        // otpFocus.unfocus();
        // otpController.text = "";
        // otpController.clear();
      } else if (data != null && data == 'USERDOESNOTEXIST') {
        showErrorNotifications(
            ErrorMessages().forgotPasswordUserDoesNotExistError,
            context,
            scafFoldKey);
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldKey);
      }
      setState(() {
        resendOtpLoadingBtn = false;
      });
    }, onError: (err) {
      setState(() {
        resendOtpLoadingBtn = false;
      });
      ApiErros().apiErrorNotifications(
          err, context, '/otpvalidationforforgotpassword', scafFoldKey);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: scafFoldKey,
        appBar: plainAppBarWidget,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(cornextBackgroundImagePath),
                      fit: BoxFit.cover)),
              child: Center(
                  child: SingleChildScrollView(
                      child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                    Card(
                        margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Form(
                            key: otpValidationFormKey,
                            child: Container(
                                padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
                                child: Column(children: <Widget>[
                                  Text(
                                    '$forgotPasswordHeaderName',
                                    style: appFonts.getTextStyle(
                                        'forgot_passwords_screen_heading_styles'),
                                  ),
                                  AppStyles().customPadding(8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      border: AppStyles().inputBorder,
                                      errorMaxLines: 3,
                                      focusedBorder:
                                          AppStyles().focusedInputBorder,
                                      labelText: '$mobileNumberLabelName',
                                      prefixText: "+91 ",
                                      contentPadding:
                                          AppStyles().contentPaddingForInput,
                                      counterText: "",
                                    ),
                                    controller: mobileNoController,
                                    enabled: false,
                                  ),
                                  AppStyles().customPadding(5),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      border: AppStyles().inputBorder,
                                      errorMaxLines: 3,
                                      focusedBorder:
                                          AppStyles().focusedInputBorder,
                                      labelText: '$otpLabelName *',
                                      contentPadding:
                                          AppStyles().contentPaddingForInput,
                                      counterText: "",
                                    ),
                                    maxLength: 6,
                                    keyboardType: TextInputType.phone,
                                    controller: otpController,
                                    validator: (val) =>
                                        GlobalValidations().otpValidations(val),
                                    focusNode: otpFocus,
                                    key: otpKey,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                  AppStyles().customPadding(5),
                                  showResendOtpButton
                                      ? !resendOtpLoadingBtn
                                          ? Container(
                                              alignment: Alignment(1, 1),
                                              child: InkWell(
                                                child: Text(
                                                  "Resend OTP",
                                                  style: appFonts.getTextStyle(
                                                      'skip_link_style'),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    resendOtpLoadingBtn = true;
                                                  });
                                                  clearErrorMessages(
                                                      scafFoldKey);
                                                  resendOtp();
                                                },
                                              ),
                                            )
                                          : Container(
                                              alignment: Alignment(1, 1),
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      120),
                                              child: loadingButtonForLinks())
                                      : Container(),
                                  AppStyles().customPadding(5),
                                  Container(
                                    // margin: EdgeInsets.fromLTRB(100, 0, 100, 0),
                                    // MediaQuery.of(context).size.width / 14,
                                    padding: EdgeInsets.all(8),
                                    child: !onLoading
                                        ? RaisedButton(
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        0.0)),
                                            onPressed: () {
                                              clearErrorMessages(scafFoldKey);
                                              if (otpValidationFormKey
                                                  .currentState
                                                  .validate()) {
                                                setState(() {
                                                  onLoading = true;
                                                  sendOtp();
                                                });
                                              }
                                            },
                                            color: mainAppColor,
                                            child: Text(
                                              "Confirm",
                                              style: appFonts.getTextStyle(
                                                  'button_text_color_white'),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        : loadingButtonWidget(context),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: InkWell(
                                      child: Text(
                                        "Back to Sign In",
                                        style: appFonts
                                            .getTextStyle('skip_link_style'),
                                      ),
                                      onTap: () {
                                        clearErrorMessages(scafFoldKey);
                                        backToSignin();
                                      },
                                    ),
                                  )
                                ]))))
                  ]))),
            )));
  }
}
