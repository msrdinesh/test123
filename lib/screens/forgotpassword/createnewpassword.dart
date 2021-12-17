import 'dart:convert';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/services/forgotpasswordservices/forgotpasswordservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:cornext_mobile/models/forgotpasswordmodel.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:cornext_mobile/utils/utilities/utilities.dart';

class CreateNewPassswordInForgotPasswordPage extends StatefulWidget {
  @override
  CreateNewPassswordInForgotPassword createState() =>
      CreateNewPassswordInForgotPassword();
}

class CreateNewPassswordInForgotPassword
    extends State<CreateNewPassswordInForgotPasswordPage> {
  // @override
  final mobileNoController = TextEditingController();
  // final otpController = TextEditingController();
  bool showResendOtpButton = false;

  //Form keys
  final newpasswordFormKey = GlobalKey<FormState>();

  //All Formfield keys
  // final otpKey = GlobalKey<FormFieldState>();

  // All focusNodes
  // final FocusNode otpFocus = FocusNode();
  final ApiErros apiErros = ApiErros();

  final newpasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final Utilities _utilities = Utilities();

  // confirm password enable bool
  bool enableConfirmPassword = false;

  //Main Form Key

  // All Form field keys
  final passwordKey = GlobalKey<FormFieldState>();
  final confirmPasswordkey = GlobalKey<FormFieldState>();

  // All Focusnodes
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  // scaffold key
  final scafFoldkey = GlobalKey<ScaffoldState>();
  bool onLoading = false;

  // Show or hide password bools
  bool showOrHidePassword = true;
  bool showOrdHideConfirmPassword = true;
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    setState(() {
      // GlobalValidations().validateCurrentFieldValidOrNot(otpFocus, otpKey);
      checkCurrentFieldValidOrNot();
      mobileNoController.text = forgotpassworddetails['mobileno'];

      Future.delayed(Duration(seconds: 10), () {
        setState(() {
          showResendOtpButton = true;
        });
      });
    });
    super.initState();
  }

  // initialization of validatons.
  checkCurrentFieldValidOrNot() {
    GlobalValidations()
        .validateCurrentFieldValidOrNot(passwordFocus, passwordKey);
    GlobalValidations().validateCurrentFieldValidOrNot(
        confirmPasswordFocus, confirmPasswordkey);
  }

  //Navigate to sign in page.
  backToSignin() {
    // Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  }

  //sending otp to user.
  sendNewPassword() {
    final Map sendOtpObj = {
      'countryCode': 91,
      'mobileNo': forgotpassworddetails['mobileno'].toString(),
      "userPassword":
          _utilities.passwordEncode(newpasswordController.text.trim())
    };
    print(sendOtpObj);
    ForgotPasswordService().newpassword(sendOtpObj).then((res) {
      final data = json.decode(res.body);
      if (data != null && data == "SUCCESS") {
        // Navigator.popUntil(context, '/login');
        // Navigator.popAndPushNamed(context, '/login');
        // Navigator.popUntil(context, ModalRoute.withName('/login'));
        // Navigator.popAndPushNamed(context, '/login');
        // Navigator.pop(context);
        // setState(() {
        //   // AppVariables().isNewPassword = true;
        //   AppVariables().previousRouteNames['previousRouteName'] =
        //       '/newpassword';
        // });
        // Navigator.pushReplacementNamed(context, '/login');
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));

        // Navigator.of(context).popUntil((r)=> r.settings.name)
      } else if (data != null && data == "FAILED") {
        showErrorNotifications(ErrorMessages().forgotPasswordUserPasswordFailed,
            context, scafFoldkey);
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldkey);
      }
      setState(() {
        onLoading = false;
      });
    }, onError: (err) {
      ApiErros().apiErrorNotifications(
          err, context, '/CreateNewPassswordInForgotPasswordPage', scafFoldkey);
      setState(() {
        onLoading = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.popAndPushNamed(context, '/otpvalidationforforgotpassword');
          return Future.value(false);
        },
        child: Scaffold(
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
                              key: newpasswordFormKey,
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
                                        errorMaxLines: 3,
                                        border: AppStyles().inputBorder,
                                        // errorMaxLines: 3,
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
                                      controller: newpasswordController,
                                      // key: passwordFormKey,
                                      cursorColor: mainAppColor,
                                      decoration: InputDecoration(
                                          errorMaxLines: 3,
                                          labelText:
                                              newPasswordLabelName + " *",
                                          border: AppStyles().inputBorder,
                                          focusedBorder:
                                              AppStyles().focusedInputBorder,
                                          contentPadding: AppStyles()
                                              .contentPaddingForInput,
                                          suffixIcon: showOrHidePassword
                                              ? IconButton(
                                                  icon: Icon(
                                                      Icons.visibility_off),
                                                  onPressed: () {
                                                    setState(() {
                                                      showOrHidePassword =
                                                          !showOrHidePassword;
                                                    });
                                                  },
                                                  color: mainAppColor,
                                                )
                                              : IconButton(
                                                  icon: Icon(Icons.visibility),
                                                  onPressed: () {
                                                    setState(() {
                                                      showOrHidePassword =
                                                          !showOrHidePassword;
                                                    });
                                                  },
                                                  color: mainAppColor,
                                                )),
                                      obscureText: showOrHidePassword,
                                      enableInteractiveSelection: false,
                                      validator: (value) => GlobalValidations()
                                          .passwordValidations(
                                              value.trim(),
                                              confirmPasswordController,
                                              confirmPasswordkey),

                                      onChanged: (val) {
                                        setState(() {
                                          if (val.length > 0) {
                                            enableConfirmPassword = true;
                                          } else {
                                            enableConfirmPassword = false;
                                          }
                                        });
                                      },
                                      focusNode: passwordFocus,
                                      key: passwordKey,
                                    ),
                                    // Container(
                                    //     alignment: Alignment(1, 1),
                                    //     child: InkWell(
                                    //       child: Text(
                                    //         showOrHidePassword ? "Show" : "Hide",
                                    //         style: TextStyle(color: Colors.blue),
                                    //       ),
                                    //       hoverColor: Colors.grey[700],
                                    //       onTap: () {
                                    //         setState(() {
                                    //           showOrHidePassword =
                                    //               !showOrHidePassword;
                                    //         });
                                    //       },
                                    //     )),
                                    AppStyles().customPadding(5),
                                    TextFormField(
                                      controller: confirmPasswordController,
                                      enableInteractiveSelection: false,
                                      // key: passwordFormKey,
                                      cursorColor: mainAppColor,
                                      decoration: InputDecoration(
                                          errorMaxLines: 3,
                                          labelText:
                                              confirmPasswordLabelName + " *",
                                          border: AppStyles().inputBorder,
                                          focusedBorder:
                                              AppStyles().focusedInputBorder,
                                          contentPadding: AppStyles()
                                              .contentPaddingForInput,
                                          suffixIcon: showOrdHideConfirmPassword
                                              ? IconButton(
                                                  icon: Icon(
                                                      Icons.visibility_off),
                                                  onPressed: () {
                                                    setState(() {
                                                      showOrdHideConfirmPassword =
                                                          !showOrdHideConfirmPassword;
                                                    });
                                                  },
                                                  color: mainAppColor,
                                                )
                                              : IconButton(
                                                  icon: Icon(Icons.visibility),
                                                  onPressed: () {
                                                    setState(() {
                                                      showOrdHideConfirmPassword =
                                                          !showOrdHideConfirmPassword;
                                                    });
                                                  },
                                                  color: mainAppColor,
                                                )),
                                      obscureText: showOrdHideConfirmPassword,
                                      enabled: enableConfirmPassword,
                                      validator: (val) => GlobalValidations()
                                          .confirmPasswrodValidations(
                                              val.trim(),
                                              newpasswordController.text
                                                  .trim()),
                                      focusNode: confirmPasswordFocus,
                                      key: confirmPasswordkey,
                                    ),

                                    AppStyles().customPadding(5),
                                    Container(
                                      // margin: EdgeInsets.fromLTRB(100, 0, 100, 0),
                                      padding: EdgeInsets.all(10),

                                      child: !onLoading
                                          ? RaisedButton(
                                              shape: new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          0.0)),
                                              onPressed: () {
                                                clearErrorMessages(scafFoldkey);
                                                setState(() {
                                                  if (newpasswordFormKey
                                                      .currentState
                                                      .validate()) {
                                                    onLoading = true;
                                                    sendNewPassword();
                                                  }
                                                });
                                              },
                                              color: mainAppColor,
                                              child: Text(
                                                "Save",
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
                                          clearErrorMessages(scafFoldkey);
                                          backToSignin();
                                        },
                                      ),
                                    )
                                  ]))))
                    ]))),
              ),
            )));
  }
}
