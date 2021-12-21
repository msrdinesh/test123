import 'package:cornext_mobile/services/editprofileservice/editprofileservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/models/customerregistrationmodel.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:cornext_mobile/services/registrationservices/registrationservice.dart';
import 'dart:convert';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/successmessages.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
// import 'package:cornext_mobile/services/sqflitedbservice/sqllitedbservice.dart';
import 'package:cornext_mobile/services/cartservice/cartservice.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/services/signinservices/signinservice.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:cornext_mobile/utils/utilities/utilities.dart';
import 'package:flutter/services.dart';
//import 'package:cornext_mobile/services/sqflitedbservice/sqllitedbservice.dart';
// import 'package:cornext_mobile/services/editprofileservie/editprofileservice.dart';

class CustomerOtpValidationPage extends StatefulWidget {
  @override
  CustomerOtpValidation createState() => CustomerOtpValidation();
}

class CustomerOtpValidation extends State<CustomerOtpValidationPage> {
  //controllers
  final mobileNoController = TextEditingController();
  final otpController = TextEditingController();
  bool showResendOtpButton = false;
  bool onLoading = false;
  final ProductDetailsService productDetailsService = ProductDetailsService();
  final RefreshTokenService refreshTokenService = RefreshTokenService();

  //Form keys
  final otpValidationFormKey = GlobalKey<FormState>();

  //All Formfield keys
  final otpKey = GlobalKey<FormFieldState>();

  // All focusNodes
  final FocusNode otpFocus = FocusNode();
  final ProfileServies editProfileService = ProfileServies();
  final GlobalKey<ScaffoldState> scafFoldKey = GlobalKey<ScaffoldState>();
  final AppFonts appFonts = AppFonts();
  final Utilities _utilities = Utilities();

  @override
  void initState() {
    setState(() {
      // print(customerRegistrationDetails['mobileNo']);
      getUserData();
      // mobileNoController.text =
      //     customerRegistrationDetails['personalDetails']['mobileNo'].toString();
      // GlobalValidations().validateCurrentFieldValidOrNot(otpFocus, otpKey);

      Future.delayed(Duration(seconds: 10), () {
        setState(() {
          showResendOtpButton = true;
        });
      });
    });
    super.initState();
  }

  getUserData() {
    // print(val);
    // if (val.length > 0) {
    setState(() {
      mobileNoController.text = customerRegistrationDetails['personalDetails']['mobileNo'].toString();
    });
    // }
  }

  resendOtp() {
    setState(() {
      onLoading = false;
    });

    final Map requestObj = {
      'countryCode': 91,
      'mobileNo': customerRegistrationDetails['personalDetails']['mobileNo'].toString()
    };
    RegistrationService().registerUser(requestObj).then((res) {
      // print(res);
      final data = json.decode(res.body);
      print(data);
      if (data != null && data == 'SUCCESS') {
        // Navigator.pushNamed(context, '/otpvalidation');
        showSuccessNotifications(SuccessMessages().otpSentMessage, context, scafFoldKey);
      }
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/otpvalidation', scafFoldKey);
    }).catchError((err) {
      ApiErros().apiErrorNotifications(err, context, '/otpvalidation', scafFoldKey);
      // print(err);
      // SocketException("Error", osError: err);
      // Error error = err;
      // error.toString();
      // print(err.toString());
      // Error();
      // throw Exception("Failed to connect");
      // final error = json.decode(err);
      // print(error);
    });
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
          displayRegistrationSuccessMessage = true;
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.popAndPushNamed(context, "/cart");
          // clearSuccessNotifications(scafFoldKey);
          // showSuccessNotifications(
          //     "Account Created Successfully", context, scafFoldKey);
        } else {
          storeCartDetails = [];
          onLoading = false;
          setState(() {});
          displayRegistrationSuccessMessage = true;
          Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'));
          // clearSuccessNotifications(scafFoldKey);
          // showSuccessNotifications(
          //     "Account Created Successfully", context, scafFoldKey);
        }
      } else if (data == 'FAILED') {
        onLoading = false;
        setState(() {});
      } else if (data['error'] != null) {
        onLoading = false;
        setState(() {});
        ApiErros().apiLoggedErrors(data, context, scafFoldKey);
      }
    }, onError: (err) {
      print(err);
      onLoading = false;
      setState(() {});
      ApiErros().apiErrorNotifications(err, context, '/login', scafFoldKey);
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

  signInWithCredentials() {
    clearErrorMessages(scafFoldKey);

    // onLoading = true;
    // signInFormKey.currentState
    //     .validate();
    Map userDetails = new Map();
    userDetails['username'] = customerRegistrationDetails['personalDetails']['mobileNo'];
    userDetails['password'] = customerRegistrationDetails['personalDetails']['password'];
    SignInService().validateUserCredentials(userDetails).then((val) {
      // print(val);
      final response = val;
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
        // print(data);
        signInDetails['userId'] = data['userId'].toString();
        signInDetails['userId'] = data['userId'].toString();
        signInDetails['emailId'] = data['emailId'];
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
          displayRegistrationSuccessMessage = true;
          Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'));
          // clearSuccessNotifications(scafFoldKey);
          // showSuccessNotifications(
          //     "Account Created Successfully", context, scafFoldKey);
        }
      } else if (data['error'] != null && data['error'] == 'invalid_grant') {
        showErrorNotifications(ErrorMessages().invalidUserDetailsError, context, scafFoldKey);
        setState(() {
          onLoading = false;
        });
      }
    }, onError: (err) {
      print(err);
      setState(() {
        onLoading = false;
      });
      ApiErros().apiErrorNotifications(err, context, '/login', scafFoldKey);
    }).catchError((err) {
      // print(err);
      setState(() {
        onLoading = false;
      });
      ApiErros().apiErrorNotifications(err, context, '/login', scafFoldKey);
    });
  }

  validateOtp() {
    // if(validateOtp())

    Map requestObj = {
      "otps": {
        "countryCode": 91,
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "mobileOtp": otpController.text.trim()
      },
      "user": {
        "firstName": customerRegistrationDetails['personalDetails']['firstName'],
        "lastName": customerRegistrationDetails['personalDetails']['surName'],
        "countryCode": 91,
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "alternateMobileNo": customerRegistrationDetails['personalDetails']['alternateMobileNo'],
        "emailId": customerRegistrationDetails['personalDetails']['emailId'],
        "userPassword": _utilities.passwordEncode(customerRegistrationDetails['personalDetails']['password'])
      },
      "address": {
        "doorNumber": customerRegistrationDetails['communicationDetails']['houseNumber'],
        "street": customerRegistrationDetails['communicationDetails']['streetOrArea'],
        "city": customerRegistrationDetails['communicationDetails']['cityOrTownOrVillage'],
        "stateId": customerRegistrationDetails['communicationDetails']['stateId'],
        "pincode": customerRegistrationDetails['communicationDetails']['pincode'],
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "countryCode": 91,
        "deliveryAddress": customerRegistrationDetails['communicationDetails']['sameAsDeliveryAddress']
      },
      "farmDetails": customerRegistrationDetails['farmDetails']
    };

    // print(requestObj);
    onLoading = true;
    setState(() {});
    RegistrationService().validateOtps(requestObj).then((res) {
      // print(res.body);
      final data = json.decode(res.body);
      // print('cameeee');
      print(data);
      if (data != null && data == 'SUCCESS') {
        // Navigator.pushReplacementNamed(context, '/login');

        // Navigator.pushNamedAndRemoveUntil(
        //     context, '/login', ModalRoute.withName('/login'));
        signInWithCredentials();

        // Navigator.pushNamed(context, '/login');
        // Navigator.popUntil(context, ModalRoute.withName('/'));
      } else if (data != null && data == 'USEREXISTS') {
        setState(() {
          onLoading = false;
        });
        showErrorNotifications(ErrorMessages().userAlreadyExistsError, context, scafFoldKey);
      } else if (data != null && data == 'MOBILEOTPEXPIRED') {
        setState(() {
          onLoading = false;
        });
        showErrorNotifications(ErrorMessages().mobileNoOtpExpiredError, context, scafFoldKey);
      } else if (data != null && data == 'INVALIDOTP') {
        setState(() {
          onLoading = false;
        });
        showErrorNotifications(ErrorMessages().invalidOtpError, context, scafFoldKey);
      } else if (data != null && data == "FAILED") {
        setState(() {
          onLoading = false;
        });
        showErrorNotifications(ErrorMessages().failedToRegisterErrorMessage, context, scafFoldKey);
      } else if (data != null && data == "UNABLETOREGISTERPLEASECONTACTCORNEXTCUSTOMERSERVICE") {
        setState(() {
          onLoading = false;
        });
        showErrorNotifications(ErrorMessages().userAlreadyExistsError, context, scafFoldKey);
      } else if (data['error'] != null) {
        setState(() {
          onLoading = false;
        });
        ApiErros().apiLoggedErrors(data, context, scafFoldKey);
      }
    }, onError: (err) {
      setState(() {
        onLoading = false;
      });
      ApiErros().apiErrorNotifications(err, context, '/otpvalidation', scafFoldKey);
    });
  }

  validateOtpForUpdateProfile() {
    // print("edit");
    Map requestObj = {
      "otps": {
        "mobileNoChange": true,
        "countryCode": 91,
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "mobileOtp": otpController.text.trim()
      },
      "user": {
        "firstName": customerRegistrationDetails['personalDetails']['firstName'],
        "lastName": customerRegistrationDetails['personalDetails']['surName'],
        "countryCode": 91,
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "alternateMobileNo": customerRegistrationDetails['personalDetails']['alternateMobileNo'],
        "emailId": customerRegistrationDetails['personalDetails']['emailId'],
      },
      "address": {
        "addressId": editAddressList['address']['addressId'],
        "doorNumber": customerRegistrationDetails['communicationDetails']['houseNumber'],
        "street": customerRegistrationDetails['communicationDetails']['streetOrArea'],
        "city": customerRegistrationDetails['communicationDetails']['cityOrTownOrVillage'],
        "stateId": customerRegistrationDetails['communicationDetails']['stateId'],
        "pincode": customerRegistrationDetails['communicationDetails']['pincode'],
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "countryCode": 91,
        "deliveryAddress": customerRegistrationDetails['communicationDetails']['sameAsDeliveryAddress']
      },
      "farmDetails": customerRegistrationDetails['farmDetails'],
      'deleteFarmDetails': customerRegistrationDetails['deleteFarmDetails']
    };
    // print(requestObj);
    setState(() {
      onLoading = true;
    });
    editProfileService.updateProfileDetails(requestObj).then((res) {
      // print('edit profile');
      final data = json.decode(res.body);
      setState(() {
        onLoading = false;
      });
      // print(data);
      if (data != null && data['status'] == 'SUCCESS') {
        // print('success camee');
        // Navigator.pushReplacementNamed(context, '/login');
        SharedPreferenceService().removeUserInfo();
        setState(() {
          signInDetails = {
            "userName": 'Hello, User',
            "userId": "",
          };
          noOfProductsAddedInCart = 0;
        });
        Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
        // signInWithCredentials();
        // Navigator.pushNamed(context, '/login');
        // Navigator.popUntil(context, ModalRoute.withName('/'));
      } else if (data != null && data['status'] == 'USEREXISTS') {
        showErrorNotifications(ErrorMessages().userAlreadyExistsError, context, scafFoldKey);
      } else if (data != null && data['status'] == 'MOBILEOTPEXPIRED') {
        showErrorNotifications(ErrorMessages().mobileNoOtpExpiredError, context, scafFoldKey);
      } else if (data != null && data['status'] == 'INVALIDOTP') {
        showErrorNotifications(ErrorMessages().invalidOtpError, context, scafFoldKey);
      } else if (data != null && data['status'] == "FAILED") {
        showErrorNotifications(ErrorMessages().failedToUpdateProfileErrorMessage, context, scafFoldKey);
      } else if (data != null && data['status'] == "UNABLETOREGISTERPLEASECONTACTCORNEXTCUSTOMERSERVICE") {
        showErrorNotifications(ErrorMessages().userAlreadyExistsError, context, scafFoldKey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
              validateOtpForUpdateProfile();
            }
          },
        );
      } else if (data['error'] != null) {
        setState(() {
          onLoading = false;
        });
        ApiErros().apiLoggedErrors(data, context, scafFoldKey);
      }
    }, onError: (err) {
      setState(() {
        onLoading = false;
      });
      ApiErros().apiErrorNotifications(err, context, '/otpvalidation', scafFoldKey);
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
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage(cornextBackgroundImagePath), fit: BoxFit.cover)),
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
                                    '$otpValidationHeaderName',
                                    style: appFonts.getTextStyle('otp_validation_heading_style'),
                                  ),
                                  AppStyles().customPadding(5),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      border: AppStyles().inputBorder,
                                      errorMaxLines: 3,
                                      focusedBorder: AppStyles().focusedInputBorder,
                                      labelText: '$mobileNumberLabelName',
                                      labelStyle: AppFonts().getTextStyle('hint_style'),
                                      prefixText: "+91 ",
                                      contentPadding: AppStyles().contentPaddingForInput,
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
                                        focusedBorder: AppStyles().focusedInputBorder,
                                        labelText: '$otpLabelName *',
                                        labelStyle: AppFonts().getTextStyle('hint_style'),
                                        contentPadding: AppStyles().contentPaddingForInput,
                                        counterText: "",
                                      ),
                                      maxLength: 6,
                                      keyboardType: TextInputType.phone,
                                      controller: otpController,
                                      validator: (val) => GlobalValidations().otpValidations(val),
                                      focusNode: otpFocus,
                                      key: otpKey),
                                  showResendOtpButton
                                      ? Container(
                                          alignment: Alignment(1, 1),
                                          child: InkWell(
                                            child: Text(
                                              "Resend OTP",
                                              style: appFonts.getTextStyle('skip_link_style'),
                                            ),
                                            onTap: () {
                                              resendOtp();
                                            },
                                          ),
                                        )
                                      : Container(),
                                  AppStyles().customPadding(5),
                                  !onLoading
                                      ? Container(
                                          // margin: EdgeInsets.fromLTRB(
                                          //     100, 0, 100, 0),
                                          padding: EdgeInsets.all(10),
                                          child: RaisedButton(
                                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
                                            onPressed: () {
                                              clearErrorMessages(scafFoldKey);

                                              if (otpValidationFormKey.currentState.validate()) {
                                                onLoading = true;
                                                if (!editacconutScreen) {
                                                  validateOtp();
                                                } else {
                                                  validateOtpForUpdateProfile();
                                                }
                                              }
                                            },
                                            color: mainAppColor,
                                            child: Text(
                                              "Confirm",
                                              style: appFonts.getTextStyle('button_text_color_white'),
                                              textAlign: TextAlign.center,
                                            ),
                                          ))
                                      : loadingButtonWidget(context)
                                ]))))
                  ]))),
            )));
  }
}
