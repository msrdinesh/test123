import 'package:cornext_mobile/services/registrationservices/registrationservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/signinservices/signinservice.dart';
import 'dart:convert';
import 'package:cornext_mobile/multilingual/localization/language/languages.dart';
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

class SignInPage extends StatefulWidget {
  @override
  SignIn createState() => SignIn();
}

class SignIn extends State<SignInPage> {
  final passwordController = TextEditingController();
  final mobileNoController = TextEditingController();
  final signInFormKey = GlobalKey<FormState>();

  // All form field keys
  final passwordFormKey = GlobalKey<FormFieldState>();
  final mobileNokey = GlobalKey<FormFieldState>();

  // All focusnode keys
  final FocusNode mobileNoFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool onLoading = false;
  bool showOrHidePassword = true;
  final ProductDetailsService productDetailsService = ProductDetailsService();
  final scafflodkey = GlobalKey<ScaffoldState>();
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    setState(() {
      signInFormKey.currentState?.reset();
      mobileNokey.currentState?.reset();
      checkFormValidOrNot();
    });
    super.initState();
    SqlLiteDataBase();
    // SqlLiteDataBase().createTables();
    // SqlLiteDataBase().createTablesInDataBase();
  }

  // @override
  // void dispose() {
  //   reset();
  //   super.dispose();
  // }

  reset() {
    mobileNoFocus.unfocus();
    passwordFocus.unfocus();
    // setState(() {
    //   // signInFormKey.currentState.setState(() {
    //   //   signInFormKey.currentState.initState();
    //   // });
    //   // signInFormKey.currentState.setState(() {
    //   // signInFormKey.currentState?.save();
    //   mobileNoController.clear();
    //   passwordController.clear();
    //   mobileNoController.text = '';

    //   signInFormKey.currentState?.reset();
    //   // signInFormKey.currentState.reset();
    //   // });
    // });
    Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        mobileNoController.text = "";
        passwordController.text = "";
        mobileNokey.currentState?.reset();
        passwordFormKey.currentState?.reset();
        signInFormKey.currentState.reset();
      });
    });
  }

  checkFormValidOrNot() {
    GlobalValidations().validateCurrentFieldValidOrNot(mobileNoFocus, mobileNokey);
    GlobalValidations().validateCurrentFieldValidOrNot(passwordFocus, passwordFormKey);
  }

  addProductDetailsIntoCart() {
    Map returnObj = {
      "cart": getCartProductsObject()
    };
    print(returnObj);
    productDetailsService.addProductIntoCart(returnObj).then((res) {
      print(res.body);
      // final data = json.decode(res.body);
      dynamic data;
      if (res.body != null && res.body == "FAILED") {
        data = res.body;
      } else {
        data = json.decode(res.body);
      }
      if (data.runtimeType == int && data > 0) {
        setState(() {
          noOfProductsAddedInCart = data;
          onLoading = false;
        });
        if (isNavigatedFromCartPage) {
          isNavigatedFromCartPage = false;
          storeCartDetails = [];
          isNavigatedFromSignInPage = true;
          Navigator.popAndPushNamed(context, "/cart");
        } else {
          storeCartDetails = [];
          Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'));
        }
      } else if (data == 'FAILED') {
        onLoading = false;
        setState(() {});
      } else if (data['error'] != null) {
        onLoading = false;
        setState(() {});
        ApiErros().apiLoggedErrors(data, context, scafflodkey);
      }
    }, onError: (err) {
      print(err);
      onLoading = false;
      setState(() {});
      ApiErros().apiErrorNotifications(err, context, '/login', scafflodkey);
    });
  }

  getCartProductsObject() {
    List returnObj = [];
    storeCartDetails.forEach((val) {
      Map obj = {
        'productId': val['productId'],
        'brandId': val['brandId'] != null ? val['brandId'] : null,
        'productTypeId': val['productTypeId'] != null ? val['productTypeId'] : null,
        'specificationId': val['specificationId'] != null ? val['specificationId'] : null,
        'priceId': val['priceId'] != null ? val['priceId'] : null,
        'quantity': val['quantity'] != null ? val['quantity'] : null,
        'isAppend': true
      };
      returnObj.add(obj);
    });
    return returnObj;
  }

  // DateTime currentBackPressTime;
  Future<bool> onBackButtonPressed() async {
    // print("enter");
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   // Fluttertoast.showToast(msg: exit_warning);
    //   return Future.value(false);
    // }
    // return Future.value(true);
    // print(AppVariables().previousRouteNames['previousRouteName']);
    // if (AppVariables().previousRouteNames['previousRouteName'] != '' &&
    //     (AppVariables().previousRouteNames['previousRouteName'] ==
    //             '/newpassword' ||
    //         AppVariables().previousRouteNames['previousRouteName'] ==
    //             '/otpvalidation')) {
    //   setState(() {
    //     // Navigator.pushNamedAndRemoveUntil(context, '', predicate)
    //     Navigator.pushNamed(context, "/home");
    //     return Future.value(true);
    //   });
    // }
    isNavigatedFromCartPage = false;
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onBackButtonPressed,
        child: Scaffold(
            key: scafflodkey,
            appBar: plainAppBarWidget,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(cornextBackgroundImagePath), fit: BoxFit.cover)),
                child: Center(
                    child: SingleChildScrollView(
                        child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                      Card(
                          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          child: Form(
                              key: signInFormKey,
                              child: Container(
                                  padding: EdgeInsets.fromLTRB(15, 30, 15, 15),
                                  child: Column(children: <Widget>[
                                    TextFormField(
                                      cursorColor: mainAppColor,
                                      validator: (value) => GlobalValidations().signInmobileValidations(value),
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: mainAppColor,
                                        ),
                                        labelText: mobileNumberLabelName + " *",
                                        labelStyle: AppFonts().getTextStyle('hint_style'),
                                        counterText: "",
                                        errorMaxLines: 3,

                                        // alignLabelWithHint: true,
                                        border: AppStyles().inputBorder,
                                        prefix: Text("+91 "),
                                        contentPadding: AppStyles().contentPaddingForInput,
                                        focusedBorder: AppStyles().focusedInputBorder,
                                      ),
                                      controller: mobileNoController,
                                      key: mobileNokey,
                                      focusNode: mobileNoFocus,
                                      // validator: (value) {
                                      //   if (!value.contains(_emailRegex)) {
                                      //     return "EmailId Invalid";
                                      //   } else if (value.isEmpty) {
                                      //     return "Please Enter EmailId";
                                      //   }
                                      //   return null;
                                      // },
                                      // controller: _emailController,
                                      // onChanged: (value) => _emailText = value,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    TextFormField(
                                      controller: passwordController,
                                      key: passwordFormKey,

                                      cursorColor: mainAppColor,
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            color: mainAppColor,
                                          ),
                                          labelText: passwordLabelName + " *",
                                          labelStyle: AppFonts().getTextStyle('hint_style'),
                                          border: AppStyles().inputBorder,
                                          errorMaxLines: 3,
                                          focusedBorder: AppStyles().focusedInputBorder,
                                          contentPadding: AppStyles().contentPaddingForInput,
                                          suffixIcon: showOrHidePassword
                                              ? IconButton(
                                                  icon: Icon(Icons.visibility_off),
                                                  onPressed: () {
                                                    setState(() {
                                                      showOrHidePassword = !showOrHidePassword;
                                                    });
                                                  },
                                                  color: mainAppColor,
                                                )
                                              : IconButton(
                                                  icon: Icon(Icons.visibility),
                                                  onPressed: () {
                                                    setState(() {
                                                      showOrHidePassword = !showOrHidePassword;
                                                    });
                                                  },
                                                  color: mainAppColor,
                                                )),
                                      obscureText: showOrHidePassword,
                                      validator: (value) => GlobalValidations().signInPasswordValidations(value),
                                      focusNode: passwordFocus,
                                      // autovalidate: true,
                                      // autocorrect: true,

                                      // onSaved: (val) => _passwordError = val,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                    ),
                                    Container(
                                        alignment: Alignment(1, 1),
                                        child: InkWell(
                                          child: Text(
                                            "Forgot Password?",
                                            style: appFonts.getTextStyle('skip_link_style'),
                                          ),
                                          onTap: () {
                                            clearErrorMessages(scafflodkey);
                                            reset();
                                            Navigator.pushNamed(context, '/forgotpassword');
                                          },
                                        )),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    !onLoading
                                        ? Container(
                                            width: 180.0,
                                            child: RaisedButton(
                                              color: mainAppColor,

                                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                                              onPressed: () {
                                                // if (signInFormKey.currentState.validate()) {
                                                //   signInFormKey.currentState.save();
                                                // }

                                                // final data = {
                                                //   'firstName': 'veera',
                                                //   'lastName': 'madala',
                                                //   'email': 'cjckdk@djdjjd.co',
                                                //   'mobileNo': "9505037717",
                                                //   "countryCode": "91",
                                                //   "alternateMobileNo": null,
                                                //   "userPassword": 'a12345',
                                                //   "isNotRegistred": false
                                                // };
                                                // // SqlLiteDataBase()
                                                // //     .dropTable('users');
                                                // // Future.delayed(Duration(seconds: 2), () {
                                                // // SqlLiteDataBase()
                                                // //     .addNewColumnToTable('users',
                                                // //         'isNotRegistred');
                                                // SqlLiteDataBase()
                                                //     .insertDataIntoTable(
                                                //         data, 'users')
                                                //     .then((val) {
                                                //   if (val != 0) {
                                                //     SqlLiteDataBase()
                                                //         .getDataFromTable('users')
                                                //         .then((val) {
                                                //       // print(val);
                                                //       // final data = json.decode(val.toString());
                                                //       val.forEach((res) {
                                                //         print(res);
                                                //       });
                                                //     });
                                                //   }
                                                // });
                                                // Map<String, dynamic> addressData =
                                                //     {
                                                //   "doornumber": "1-2/4848",
                                                //   "street": "main",
                                                //   "city": "hyd",
                                                //   "state": "ap",
                                                //   "pincode": "523301",
                                                //   "isNotRegistred": true
                                                // };
                                                // SqlLiteDataBase()
                                                //     .insertDataIntoTable(
                                                //         addressData, 'address')
                                                //     .then((val) {
                                                //   // if (val != 0) {
                                                //   SqlLiteDataBase()
                                                //       .getDataFromTable('address')
                                                //       .then((val) {
                                                //     print('enter');
                                                //     print(val);
                                                //     // final data = json.decode(val.toString());
                                                //     // val.forEach((res) {
                                                //     //   print(res);
                                                //     // });
                                                //   });
                                                //   // }
                                                // });
                                                // });

                                                setState(() {
                                                  clearErrorMessages(scafflodkey);
                                                  if (signInFormKey.currentState.validate()) {
                                                    onLoading = true;
                                                    // signInFormKey.currentState
                                                    //     .validate();
                                                    Map userDetails = new Map();
                                                    userDetails['username'] = mobileNoController.text.trim();
                                                    userDetails['password'] = passwordController.text.trim();
                                                    SignInService().validateUserCredentials(userDetails).then((val) {
                                                      // print(val);
                                                      http.Response response = val;
                                                      // print(response.body);
                                                      final data = json.decode(response.body);
                                                      print(data);
                                                      // print(data['access_token']);
                                                      // if (data['access_token'] !=
                                                      //         null &&
                                                      //     data['access_token'] !=
                                                      //         '') {
                                                      //   Navigator.of(context)
                                                      //       .pop();
                                                      //   reset();
                                                      // }
                                                      if (data['access_token'] != null && data['access_token'] != '') {
                                                        signInDetails['access_token'] = data['access_token'];
                                                        signInDetails['refresh_token'] = data['refresh_token'];
                                                        signInDetails['expires_in'] = data['expires_in'];
                                                        signInDetails['userName'] = data['userName'];
                                                        print(data['emailId']);
                                                        print(data['mobileNo']);
                                                        signInDetails['userId'] = data['userId'].toString();
                                                        signInDetails['emailId'] = data['emailId'];
                                                        signInDetails['mobileNo'] = data['mobileNo'];
                                                        setState(() {});
                                                        SharedPreferenceService().setAccessToken(data['access_token']);
                                                        SharedPreferenceService().setRefreshToken(data['refresh_token']);
                                                        SharedPreferenceService().setUserName(data['userName']);
                                                        SharedPreferenceService().setUserId(data['userId']);
                                                        SharedPreferenceService().setEmailId(data['emailId']);
                                                        SharedPreferenceService().setMobileNo(data['mobileNo']);
                                                        // final SharedPreferences prefs = SharedPreferences.getInstance();
                                                        // setAccessToken().
                                                        // if(prefs != null){
                                                        //   prefs.
                                                        // }
                                                        // setState(() {});
                                                        if (storeCartDetails.length > 0) {
                                                          addProductDetailsIntoCart();
                                                        } else {
                                                          setState(() {
                                                            onLoading = false;
                                                          });
                                                          Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'));
                                                        }
                                                      } else if (data['error'] != null && data['error'] == 'invalid_grant') {
                                                        showErrorNotifications(ErrorMessages().invalidUserDetailsError, context, scafflodkey);
                                                        setState(() {
                                                          onLoading = false;
                                                        });
                                                      }
                                                    }, onError: (err) {
                                                      print(err);
                                                      setState(() {
                                                        onLoading = false;
                                                      });
                                                      ApiErros().apiErrorNotifications(err, context, '/login', scafflodkey);
                                                    }).catchError((err) {
                                                      // print(err);
                                                      setState(() {
                                                        onLoading = false;
                                                      });
                                                      ApiErros().apiErrorNotifications(err, context, '/login', scafflodkey);
                                                    });
                                                    // print(response);
                                                    // onSubmit();
                                                    // if (_formKey.currentState.validate()) {
                                                    //   // getData(context);
                                                    //   _formKey.currentState.save();
                                                    //   validateUserCredentials(context);
                                                    // } else {
                                                    //   _formKey.currentState.save();
                                                    //   // getData();
                                                    //   performLoginOpenration();
                                                  }
                                                }); // }
                                              },
                                              // color: mainAppColor,y

                                              // shape: ,
                                              // clipBehavior: Clip.antiAlias,
                                              child: Text(Languages.of(context).signIn, style: appFonts.getTextStyle('button_text_color_white')),
                                            ))
                                        : loadingButtonWidget(context),
                                    Container(
                                        width: 180,
                                        child: RaisedButton(
                                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                                          onPressed: () {
                                            // onSubmit();
                                            // if (_formKey.currentState.validate()) {
                                            //   // getData(context);
                                            //   _formKey.currentState.save();
                                            //   validateUserCredentials(context);
                                            // } else {
                                            //   _formKey.currentState.save();
                                            //   // getData();
                                            //   performLoginOpenration();
                                            // }
                                            clearErrorMessages(scafflodkey);
                                            // isNewCustomer = true;
                                            // reset();
                                            // Navigator.pushNamed(
                                            //     context, '/farmdetails');
                                            reset();
                                            editacconutScreen = false;
                                            enablefields = true;
                                            Navigator.pushNamed(context, '/registration');

                                            // Navigator.pushNamed(context, '/videos');

                                            // Navigator.pushNamed(context, '/image');

                                            // Navigator.pushNamed(
                                            //     context, '/farmdetails');
                                            // Navigator.pushNamed(
                                            //     context, '/registration');
                                          },
                                          color: mainYellowColor,
                                          // shape: ,
                                          // clipBehavior: Clip.antiAlias,
                                          child: Text("New Customer?", style: appFonts.getTextStyle('button_text_color_black')),
                                        ))
                                  ]))))
                    ]))),
              ),
            )));
  }
}
