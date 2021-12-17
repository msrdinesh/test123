//import 'dart:math';

import 'package:cornext_mobile/services/editprofileservice/editprofileservice.dart';
// import 'package:cornext_mobile/services/editprofileservie/editprofileservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/imagepaths.dart';
// import 'package:flushbar/flushbar.dart';
import 'package:cornext_mobile/models/customerregistrationmodel.dart';
import 'package:cornext_mobile/services/registrationservices/registrationservice.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'dart:convert';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
// import 'package:cornext_mobile/services/sqflitedbservice/sqllitedbservice.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:flutter/services.dart';

class RegistartionPage extends StatefulWidget {
  @override
  Registration createState() => Registration();
}

class Registration extends State<RegistartionPage> {
  // bool noAnimalsCheck = false;
  // bool cowsCheck = false;
  // bool buffaloCheck = false;
  //bool editacconutScreen = false;
  bool sameAsDeliveryAddressCheck = false;
  bool onLoading = false;
  // int numberOfCows = 0;
  // int numberOfBuffalos = 0;

  // All ControllerNames
  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final mobileNoController = TextEditingController();
  final alternateMobileNoContoller = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final houseNoController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();

  // confirm password enable bool
  bool enableConfirmPassword = false;
  bool enableAlternativeMobileNumber = false;
  Map postUpadteobj;
  //Main Form Key
  final registrationFormkey = GlobalKey<FormState>();

  final animalDetailsTextkey = GlobalKey<EditableTextState>();

  // All Form field keys
  final firstNameKey = GlobalKey<FormFieldState>();
  final surNameKey = GlobalKey<FormFieldState>();
  final mobileNoKey = GlobalKey<FormFieldState>();
  final alternateMobileNoKey = GlobalKey<FormFieldState>();
  final emailkey = GlobalKey<FormFieldState>();
  final passwordKey = GlobalKey<FormFieldState>();
  final confirmPasswordkey = GlobalKey<FormFieldState>();
  final houseNokey = GlobalKey<FormFieldState>();
  final streetKey = GlobalKey<FormFieldState>();
  final cityKey = GlobalKey<FormFieldState>();
  final statekey = GlobalKey<FormFieldState>();
  final pincodeKey = GlobalKey<FormFieldState>();
  final ProfileServies editProfileService = ProfileServies();
  // final star = "*";

  final star = "*";
  // All Focusnodes
  FocusNode firstNameFocus = FocusNode();
  FocusNode surNameFocus = FocusNode();
  FocusNode mobileNoFocus = FocusNode();
  FocusNode alternateMobileNoFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode houseNoFocus = FocusNode();
  FocusNode streetFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode pincodeFocus = FocusNode();
  final AddressServices addressServices = AddressServices();

  // scaffold key
  final scafFoldkey = GlobalKey<ScaffoldState>();
  // Show or hide password bools
  bool showOrHidePassword = true;
  bool showOrdHideConfirmPassword = true;
  bool loadingButtonForEditProfile = false;
  bool isStateError = false;
  List states = [];
  String selectedState;
  final AppFonts appFonts = AppFonts();
  //bool editaccount = true;
  //bool enablefields = false;

  @override
  void initState() {
    setState(() {
      // if (registrationFormkey.currentState != null) {
      //   registrationFormkey.currentState.reset();
      // }
      getStates();

      if (editacconutScreen) {
        getUserDetails();
      }

      checkIsFormFieldsValid();
    });
    super.initState();
  }

  getStates() {
    addressServices.getStates().then((val) {
      final data = json.decode(val.body);
      if (data != null &&
          data['listOfStates'] != null &&
          data['listOfStates'].length > 0) {
        setState(() {
          states = data['listOfStates'];
          // selectedState = states[0]['stateId'].toString();
        });
      } else if (data['error'] != null) {
        ApiErros().apiLoggedErrors(data, context, scafFoldkey);
      }
    }, onError: (err) {
      ApiErros()
          .apiErrorNotifications(err, context, '/registration', scafFoldkey);
    });
  }

  displayLoadingIcon(context) {
    // setState(() {
    //   isLoadingIconDisplaying = true;
    // });
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 100,
                child: customizedCircularLoadingIconWithColorAndSize(
                    50, Colors.white),
              ));
        });
  }

// Fetching user details for edit profilr
  getUserDetails() {
    // displayLoadingIcon(context);
    loadingButtonForEditProfile = true;
    setState(() {});
    editProfileService.getProfileDetails().then((res) {
      print(res.body);
      final data = json.decode(res.body);
      // Navigator.pop(context);
      if (data['user'] != null) {
        setState(() {
          editAddressList = data;
          loadingButtonForEditProfile = false;
          // formdeateailsedit = editAddressList;
          print(editAddressList);
          getEditDetails();
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getUserDetails();
          }
        });
      } else if (data['error'] != null) {
        ApiErros().apiLoggedErrors(data, context, scafFoldkey);
      }
    }, onError: (err) {
      // Navigator.pop(context);
      loadingButtonForEditProfile = false;
      setState(() {});
      ApiErros()
          .apiErrorNotifications(err, context, '/registration', scafFoldkey);
    });
  }

  // updatePrfileDetails() {
  //   editProfileService.updateProfileDetails(postUpadteobj).then((res) {
  //     print(res.body);
  //   });
  //   postUpadteobj = {};
  // }
// checks all TextFormFields is validate or not with global validations
  checkIsFormFieldsValid() {
    GlobalValidations()
        .validateCurrentFieldValidOrNot(firstNameFocus, firstNameKey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(surNameFocus, surNameKey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(mobileNoFocus, mobileNoKey);
    GlobalValidations().validateCurrentFieldValidOrNot(
        alternateMobileNoFocus, alternateMobileNoKey);
    GlobalValidations().validateCurrentFieldValidOrNot(emailFocus, emailkey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(passwordFocus, passwordKey);
    GlobalValidations().validateCurrentFieldValidOrNot(
        confirmPasswordFocus, confirmPasswordkey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(houseNoFocus, houseNokey);
    GlobalValidations().validateCurrentFieldValidOrNot(streetFocus, streetKey);
    GlobalValidations().validateCurrentFieldValidOrNot(cityFocus, cityKey);
    // GlobalValidations().validateCurrentFieldValidOrNot(stateFocus, statekey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(pincodeFocus, pincodeKey);
    checkUserExitsOrNot();
  }

//checks for entered credentials is already exists or not
  checkUserExitsOrNot() {
    mobileNoFocus.addListener(() {
      if (!mobileNoFocus.hasFocus && mobileNoKey.currentState.validate() ||
          editacconutScreen == false) {
        // print(mobileNoController.text);
        Map userDetails = {
          'countryCode': 91,
          'mobileNo': mobileNoController.text.trim().toString()
        };
        if (editacconutScreen &&
            editAddressList['user'] != null &&
            editAddressList['user']["mobileNo"] != null &&
            editAddressList['user']["mobileNo"].toString() !=
                mobileNoController.text.trim()) {
          checkUserAlreadyExists(userDetails, false);
        }
      }
    });
  }

// checks is user is already exists or not. If exists shoes error message or else navigate to farm details
  checkUserAlreadyExists(Map userDetails, bool isNavigation) {
    clearErrorMessages(scafFoldkey);
    RegistrationService().validateUserExitsOrNot(userDetails).then((res) {
      // print(res.body);
      final data = json.decode(res.body);
      if (data != null && data == 'USEREXISTS') {
        showErrorNotifications(
            ErrorMessages().userAlreadyExistsError, context, scafFoldkey);
      } else if (data != null && data == 'USERDOESNOTEXIST') {
        // final Map data = {'mobileNo': mobileNoController.text.trim()};
        if (isNavigation == true) {
          fetchUserDetails();

          if (editacconutScreen) {
            customerRegistrationDetails['personalDetails']['isMobileNoChange'] =
                "true";
          }

          // Map<String, dynamic> registrationData = {
          //   'firstName': firstNameController.text.trim(),
          //   'lastName': surnameController.text.trim(),
          //   'surNames': mobileNoController.text.trim(),
          //   'countryCode': '91',
          //   'alternateMobileNo': alternateMobileNoContoller.text.trim() != ''
          //       ? alternateMobileNoContoller.text.trim()
          //       : null,
          //   'email': emailController.text.trim() != ''
          //       ? emailController.text.trim()
          //       : null,
          //   'userPassword': passwordController.text.trim(),
          //   'isNotRegistred': true
          // };

          // // SqlLiteDataBase()
          // //     .addNewColumnToTable('address', 'isDeliveryAddress', 'BOOLEAN');

          // Map<String, dynamic> addressData = {
          //   'doornumber': sameAsDeliveryAddressCheck
          //       ? houseNoController.text.trim()
          //       : (houseNoController.text.trim() != ''
          //           ? houseNoController.text.trim()
          //           : null),
          //   'street': sameAsDeliveryAddressCheck
          //       ? streetController.text.trim()
          //       : (streetController.text.trim() != ''
          //           ? streetController.text.trim()
          //           : null),
          //   'city': cityController.text.trim(),
          //   'state': stateController.text.trim(),
          //   'pincode': pinCodeController.text.trim(),
          //   'isDeliveryAddress': sameAsDeliveryAddressCheck,
          //   'isNotRegistred': true,
          // };

          // SqlLiteDataBase().updateOneColumnInTable('users', 'isNotRegistred');
          // SqlLiteDataBase().updateOneColumnInTable('address', 'isNotRegistred');
          // SqlLiteDataBase().getDataFromTable('users').then((val) {
          //   print(val);
          // });
          // SqlLiteDataBase()
          //     .insertDataIntoTable(registrationData, 'users')
          //     .then((val) {
          //   // print(customerRegistrationDetails);
          //   // CustomerRegistrationModel()
          //   //         .customerRegistrationDetails =
          //   //     new Map();

          //   // if (customerRegistrationDetails['mobileNo'] != null) {
          //   if (val != 0) {
          //     SqlLiteDataBase()
          //         .insertDataIntoTable(addressData, 'address')
          //         .then((res) {
          //       if (res != 0) {
          //         Navigator.pushNamed(context, "/farmdetails");
          //       }
          //     });
          //   }
          // });

          Navigator.pushNamed(context, "/farmdetails");
          // }
        }
      } else if (data != null && data == "FAILED") {
        showErrorNotifications("Failed to check your mobile. Please try again",
            context, scafFoldkey);
      }

      setState(() {
        onLoading = false;
      });
    }, onError: (err) {
      ApiErros()
          .apiErrorNotifications(err, context, '/registration', scafFoldkey);
      setState(() {
        onLoading = false;
      });
    });
  }

// fetch all the user details for edit profile screen and diplays on respective fields
  getEditDetails() {
    setState(() {
      if (editAddressList != null && editacconutScreen == true) {
        // print(editAddressList);
        firstNameController.text = editAddressList['user']['firstName'];
        surnameController.text = editAddressList['user']["lastName"];
        mobileNoController.text = editAddressList['user']["mobileNo"];
        alternateMobileNoContoller.text =
            editAddressList['user']["alternateMobileNo"];
        emailController.text =
            editAddressList['user']["emailId"] == "info@cornext.in"
                ? ""
                : editAddressList['user']["emailId"];
        passwordController.text = "******";
        //confirmPasswordController.text = editAddressList['user']["password"];
        houseNoController.text = editAddressList['address']["doorNumber"];
        streetController.text = editAddressList['address']["street"];
        cityController.text = editAddressList['address']["city"];
        selectedState = editAddressList['address']["stateId"].toString();
        pinCodeController.text = editAddressList['address']["pincode"];
        sameAsDeliveryAddressCheck =
            editAddressList['address']['deliveryAddress'];
      }
    });
  }

// gets user details from JSON
  fetchUserDetails() {
    customerRegistrationDetails = {
      'personalDetails': {
        'firstName': firstNameController.text.trim(),
        'surName': surnameController.text.trim(),
        'mobileNo': mobileNoController.text.trim(),
        'alternateMobileNo': alternateMobileNoContoller.text.trim() != ''
            ? alternateMobileNoContoller.text.trim()
            : null,
        'emailId': emailController.text.trim() != ''
            ? emailController.text.trim()
            : "info@cornext.in",
        'password': !editacconutScreen ? passwordController.text.trim() : null,
      },
      'communicationDetails': {
        'houseNumber': sameAsDeliveryAddressCheck
            ? houseNoController.text.trim()
            : (houseNoController.text.trim() != ''
                ? houseNoController.text.trim()
                : null),
        'streetOrArea': sameAsDeliveryAddressCheck
            ? streetController.text.trim()
            : (streetController.text.trim() != ''
                ? streetController.text.trim()
                : null),
        'cityOrTownOrVillage': cityController.text.trim(),
        'stateId': int.parse(selectedState),
        'pincode': pinCodeController.text.trim(),
        'sameAsDeliveryAddress': sameAsDeliveryAddressCheck
      }
    };
  }

  // // showAnimalDetailsError(val) {
  //   // final snackBar = SnackBar(
  //   //   content: Text(
  //   //     val,
  //   //     style: TextStyle(
  //   //       color: Colors.red,
  //   //     ),
  //   //     textAlign: TextAlign.center,
  //   //   ),
  //   //   backgroundColor: Colors.white,
  //   // );
  //   // scafFoldkey.currentState.showSnackBar(snackBar);
  //   Flushbar(
  //     flushbarPosition: FlushbarPosition.TOP,
  //     // title: val,
  //     backgroundColor: Colors.white,
  //     duration: Duration(seconds: 8),
  //     maxWidth: 250,
  //     // margin: EdgeInsets.only(top: 55),
  //     borderRadius: 3,
  //     // message: val,
  //     messageText: Text(
  //       val,
  //       style: TextStyle(color: Colors.red),
  //       textAlign: TextAlign.center,
  //     ),
  //   )..show(context);

  //   // scafFoldkey.currentState.sho
  // }

  Widget build(BuildContext context) {
    return Scaffold(
        key: scafFoldkey,
        appBar: plainAppBarWidget,
        body: !loadingButtonForEditProfile
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(cornextBackgroundImagePath),
                            fit: BoxFit.cover)),
                    padding: EdgeInsets.only(top: 0),
                    child: Card(
                        //  shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.only(
                        //           topLeft: Radius.circular(35.0),
                        //           topRight: Radius.circular(35.0))),
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            child: Column(children: [
                              editacconutScreen
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        softWrap: true,
                                        text: TextSpan(
                                            style: appFonts.getTextStyle(
                                                'edit_profile_customer_id_heading_style'),
                                            children: [
                                              TextSpan(
                                                  text: "Your Customer Id is "),
                                              TextSpan(
                                                  text: editAddressList['user']
                                                      ['erpCustomerId'],
                                                  style: appFonts.getTextStyle(
                                                      'edit_profile_customer_id_value_style'))
                                            ]),
                                      ),
                                    )
                                  : Container(),
                              Row(children: <Widget>[
                                editacconutScreen
                                    ? !enablefields
                                        ? Text(editaccoutHeadername,
                                            style: appFonts.getTextStyle(
                                                'internal_headers_style'))
                                        : Container(
                                            margin: EdgeInsets.only(
                                                top: 10, left: 2),
                                            child: Text(editProfile,
                                                style: appFonts.getTextStyle(
                                                    'internal_headers_style')),
                                          )
                                    : Text(
                                        registrationHeaderName,
                                        style: appFonts.getTextStyle(
                                            'registration_heading_style'),
                                      ),
                                editacconutScreen && enablefields == false
                                    ? Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: Icon(Icons.edit),
                                          color: mainAppColor,
                                          alignment: Alignment.centerRight,
                                          onPressed: () {
                                            setState(() {
                                              //editacconutScreen = true;
                                              enableAlternativeMobileNumber =
                                                  true;
                                              enablefields = true;
                                              //();
                                              // getEditDetails();

                                              // editacconutScreen = true;
                                            });
                                          },
                                        ),
                                      )
                                    : Container(),
                              ]),
                              Expanded(
                                  child: SingleChildScrollView(
                                child: Form(
                                    key: registrationFormkey,
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        AppStyles().customPadding(7),
                                        Text(
                                          registrationSideHeaderName,
                                          style: AppFonts().getTextStyle(
                                              'internal_headers_style'),
                                        ),

                                        AppStyles().customPadding(3),

                                        TextFormField(
                                          enabled: enablefields,
                                          decoration: InputDecoration(
                                            border: AppStyles().inputBorder,
                                            errorMaxLines: 3,
                                            focusedBorder:
                                                AppStyles().focusedInputBorder,
                                            labelText:
                                                firstNameLabelName + " *",
                                            labelStyle: AppFonts()
                                                .getTextStyle('hint_style'),
                                            counterText: "",
                                            contentPadding: AppStyles()
                                                .contentPaddingForInput,
                                          ),
                                          autofocus: true,
                                          keyboardType: TextInputType.text,
                                          maxLength: 75,
                                          controller: firstNameController,
                                          validator: (val) =>
                                              GlobalValidations()
                                                  .firstNameValidations(
                                                      val.trim()),
                                          cursorColor: mainAppColor,
                                          key: firstNameKey,
                                          focusNode: firstNameFocus,
                                        ),

                                        AppStyles().customPadding(5),

                                        TextFormField(
                                          enabled: enablefields,
                                          decoration: InputDecoration(
                                              border: AppStyles().inputBorder,
                                              errorMaxLines: 3,
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder,
                                              labelText:
                                                  surNameLabelName + " *",
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              counterText: "",
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput),
                                          keyboardType: TextInputType.text,
                                          maxLength: 75,
                                          cursorColor: mainAppColor,
                                          controller: surnameController,
                                          validator: (val) =>
                                              GlobalValidations()
                                                  .surNameValidations(
                                                      val.trim()),
                                          focusNode: surNameFocus,
                                          key: surNameKey,
                                          // maxLengthEnforced: true,
                                          // onTap: surnameController.,
                                        ),

                                        AppStyles().customPadding(5),

                                        TextFormField(
                                          enabled: enablefields,
                                          cursorColor: mainAppColor,
                                          controller: mobileNoController,
                                          decoration: InputDecoration(
                                              labelText:
                                                  mobileNumberLabelName + " *",
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              errorMaxLines: 3,
                                              counterText: "",
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput,
                                              // alignLabelWithHint: true,
                                              border: AppStyles().inputBorder,
                                              prefix: Text("+91 "),
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder),
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          validator: (value) =>
                                              GlobalValidations()
                                                  .mobileValidationsReg(
                                                      value.trim(),
                                                      alternateMobileNoContoller,
                                                      alternateMobileNoKey),
                                          onChanged: (val) {
                                            setState(() {
                                              if (val.length > 0) {
                                                enableAlternativeMobileNumber =
                                                    true;
                                              } else {
                                                enableAlternativeMobileNumber =
                                                    false;
                                              }
                                            });
                                          },
                                          focusNode: mobileNoFocus,
                                          key: mobileNoKey,
                                          inputFormatters: [
                                            WhitelistingTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),

                                        AppStyles().customPadding(5),

                                        TextFormField(
                                          cursorColor: mainAppColor,
                                          controller:
                                              alternateMobileNoContoller,
                                          enabled:
                                              enableAlternativeMobileNumber &&
                                                  enablefields,
                                          validator: (value) =>
                                              GlobalValidations()
                                                  .alternateMobileNoValidations(
                                                      value.trim(),
                                                      mobileNoController.text
                                                          .trim()),
                                          decoration: InputDecoration(
                                              labelText:
                                                  alternatMobileNoLabelName,
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              errorMaxLines: 3,
                                              counterText: "",
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput,
                                              // alignLabelWithHint: true,
                                              border: AppStyles().inputBorder,
                                              prefix: Text("+91 "),
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder),
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          focusNode: alternateMobileNoFocus,
                                          key: alternateMobileNoKey,
                                          inputFormatters: [
                                            WhitelistingTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),

                                        AppStyles().customPadding(5),

                                        TextFormField(
                                          enabled: enablefields,
                                          controller: emailController,
                                          cursorColor: mainAppColor,
                                          decoration: InputDecoration(
                                              border: AppStyles().inputBorder,
                                              errorMaxLines: 3,
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder,
                                              labelText: emailLabelName,
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput),
                                          validator: (val) =>
                                              GlobalValidations()
                                                  .emailValidations(val.trim()),
                                          focusNode: emailFocus,
                                          key: emailkey,
                                        ),

                                        AppStyles().customPadding(5),
                                        editacconutScreen
                                            ? Container()
                                            : TextFormField(
                                                // enabled:
                                                // editacconutScreen ? false : true,
                                                controller: passwordController,
                                                enableInteractiveSelection:
                                                    false,
                                                // key: passwordFormKey,

                                                cursorColor: mainAppColor,
                                                decoration: InputDecoration(
                                                    labelText:
                                                        passwordLabelName +
                                                            " *",
                                                    labelStyle: AppFonts()
                                                        .getTextStyle(
                                                            'hint_style'),
                                                    errorMaxLines: 3,
                                                    border:
                                                        AppStyles().inputBorder,
                                                    focusedBorder: AppStyles()
                                                        .focusedInputBorder,
                                                    contentPadding: AppStyles()
                                                        .contentPaddingForInput,
                                                    suffixIcon:
                                                        showOrHidePassword
                                                            ? IconButton(
                                                                icon: Icon(Icons
                                                                    .visibility_off),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    showOrHidePassword =
                                                                        !showOrHidePassword;
                                                                  });
                                                                },
                                                                color:
                                                                    mainAppColor,
                                                              )
                                                            : IconButton(
                                                                icon: Icon(Icons
                                                                    .visibility),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    showOrHidePassword =
                                                                        !showOrHidePassword;
                                                                  });
                                                                },
                                                                color:
                                                                    mainAppColor,
                                                              )),
                                                obscureText: showOrHidePassword,
                                                // keyboardType: TextInputType.text,
                                                validator: (value) =>
                                                    GlobalValidations()
                                                        .passwordValidations(
                                                            value.trim(),
                                                            confirmPasswordController,
                                                            confirmPasswordkey),

                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value.length > 0) {
                                                      enableConfirmPassword =
                                                          true;
                                                    } else {
                                                      enableConfirmPassword =
                                                          false;
                                                    }
                                                  });
                                                },
                                                focusNode: passwordFocus,
                                                key: passwordKey,
                                              ),

                                        AppStyles().customPadding(5),

                                        editacconutScreen
                                            ? Container()
                                            : TextFormField(
                                                controller:
                                                    confirmPasswordController,
                                                // key: passwordFormKey,

                                                cursorColor: mainAppColor,
                                                decoration: InputDecoration(
                                                    labelText:
                                                        confirmPasswordLabelName +
                                                            " *",
                                                    labelStyle: AppFonts()
                                                        .getTextStyle(
                                                            'hint_style'),
                                                    errorMaxLines: 3,
                                                    border:
                                                        AppStyles().inputBorder,
                                                    focusedBorder: AppStyles()
                                                        .focusedInputBorder,
                                                    contentPadding: AppStyles()
                                                        .contentPaddingForInput,
                                                    suffixIcon:
                                                        showOrdHideConfirmPassword
                                                            ? IconButton(
                                                                icon: Icon(Icons
                                                                    .visibility_off),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    showOrdHideConfirmPassword =
                                                                        !showOrdHideConfirmPassword;
                                                                  });
                                                                },
                                                                color:
                                                                    mainAppColor,
                                                              )
                                                            : IconButton(
                                                                icon: Icon(Icons
                                                                    .visibility),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    showOrdHideConfirmPassword =
                                                                        !showOrdHideConfirmPassword;
                                                                  });
                                                                },
                                                                color:
                                                                    mainAppColor,
                                                              )),
                                                obscureText:
                                                    showOrdHideConfirmPassword,
                                                enabled: enableConfirmPassword,
                                                enableInteractiveSelection:
                                                    false,

                                                validator: (val) =>
                                                    GlobalValidations()
                                                        .confirmPasswrodValidations(
                                                            val.trim(),
                                                            passwordController
                                                                .text
                                                                .trim()),
                                                focusNode: confirmPasswordFocus,
                                                key: confirmPasswordkey,
                                              ),
                                        // Container(
                                        //     alignment: Alignment(1, 1),
                                        //     child: InkWell(
                                        //       child: Text(
                                        //         showOrdHideConfirmPassword
                                        //             ? "Show"
                                        //             : "Hide",
                                        //         style: TextStyle(color: Colors.blue),
                                        //       ),
                                        //       hoverColor: Colors.grey[700],
                                        //       onTap: () {
                                        //         setState(() {
                                        //           showOrdHideConfirmPassword =
                                        //               !showOrdHideConfirmPassword;
                                        //         });
                                        //       },
                                        //     )),

                                        AppStyles().customPadding(7),

                                        Text(
                                          registrationCommunicationHeaderName,
                                          style: appFonts.getTextStyle(
                                              'internal_headers_style'),
                                        ),

                                        AppStyles().customPadding(3),

                                        TextFormField(
                                          enabled: enablefields,
                                          decoration: InputDecoration(
                                              border: AppStyles().inputBorder,
                                              errorMaxLines: 3,
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder,
                                              labelText:
                                                  sameAsDeliveryAddressCheck
                                                      ? houseNumberLabelName +
                                                          " *"
                                                      : houseNumberLabelName,
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              counterText: "",
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput),
                                          controller: houseNoController,
                                          cursorColor: mainAppColor,
                                          validator: (val) => GlobalValidations()
                                              .houseNumberValidations(
                                                  val.trim(),
                                                  sameAsDeliveryAddressCheck),
                                          maxLength: 75,
                                          focusNode: houseNoFocus,
                                          key: houseNokey,
                                        ),

                                        AppStyles().customPadding(5),

                                        TextFormField(
                                          enabled: enablefields,
                                          decoration: InputDecoration(
                                              border: AppStyles().inputBorder,
                                              errorMaxLines: 3,
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder,
                                              labelText:
                                                  sameAsDeliveryAddressCheck
                                                      ? streetLabelName + " *"
                                                      : streetLabelName,
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              counterText: "",
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput),
                                          controller: streetController,
                                          cursorColor: mainAppColor,
                                          validator: (val) => GlobalValidations()
                                              .streetValidations(val.trim(),
                                                  sameAsDeliveryAddressCheck),
                                          maxLength: 75,
                                          focusNode: streetFocus,
                                          key: streetKey,
                                        ),

                                        AppStyles().customPadding(5),

                                        TextFormField(
                                          enabled: enablefields,
                                          decoration: InputDecoration(
                                              border: AppStyles().inputBorder,
                                              errorMaxLines: 3,
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder,
                                              labelText: cityLabelName + ' *',
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              counterText: "",
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput),
                                          controller: cityController,
                                          cursorColor: mainAppColor,
                                          validator: (val) =>
                                              GlobalValidations()
                                                  .cityValidations(val.trim()),
                                          maxLength: 75,
                                          focusNode: cityFocus,
                                          key: cityKey,
                                        ),

                                        AppStyles().customPadding(5),

                                        // TextFormField(
                                        //   enabled: enablefields,
                                        //   decoration: InputDecoration(
                                        //       border: AppStyles().inputBorder,
                                        //       errorMaxLines: 3,
                                        //       focusedBorder: AppStyles()
                                        //           .focusedInputBorder,
                                        //       labelText: stateLabelName + " *",
                                        //       counterText: "",
                                        //       contentPadding: AppStyles()
                                        //           .contentPaddingForInput),
                                        //   controller: stateController,
                                        //   cursorColor: mainAppColor,
                                        //   // cursorWidth: 10,

                                        //   validator: (val) =>
                                        //       GlobalValidations()
                                        //           .stateValidations(val.trim()),
                                        //   maxLength: 75,
                                        //   focusNode: stateFocus,
                                        //   key: statekey,
                                        // ),
                                        Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: isStateError
                                                        ? Colors.red[700]
                                                        : enablefields
                                                            ? Colors.grey
                                                            : Colors.grey[350],
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                // height: 100,

                                                child: DropdownButton<String>(
                                                  underline: Container(),
                                                  focusNode: stateFocus,
                                                  key: statekey,
                                                  style: AppFonts()
                                                      .getTextStyle(
                                                          'hint_style'),
                                                  disabledHint: !enablefields &&
                                                          states.length > 0
                                                      ? Text(
                                                          states[states.indexWhere((val) =>
                                                                  val['stateId']
                                                                      .toString() ==
                                                                  selectedState)]
                                                              ['name'],
                                                          style: appFonts
                                                              .getTextStyle(
                                                                  'text_color_black_style'),
                                                        )
                                                      : Text(''),
                                                  isExpanded: true,
                                                  hint: Text('State'),
                                                  // selectedItemBuilder:
                                                  //     (BuildContext context) {
                                                  //   return states
                                                  //       .map<Widget>((state) {
                                                  //     return Text(
                                                  //         state['name']);
                                                  //   }).toList();
                                                  // },
                                                  items: states.map((state) {
                                                    // specificationSelection =
                                                    //     productDataSpecifications['specificationId']
                                                    //         .toString();
                                                    return new DropdownMenuItem(
                                                      child: new Text(
                                                        state['name']
                                                            .toString(),
                                                        style: appFonts
                                                            .getTextStyle(
                                                                'state_dropdown_names_style'),
                                                      ),
                                                      value: state['stateId']
                                                          .toString(),
                                                    );
                                                  }).toList(),
                                                  onChanged: enablefields
                                                      ? (newVal) {
                                                          setState(() {
                                                            selectedState =
                                                                newVal;
                                                            isStateError =
                                                                false;
                                                            stateFocus
                                                                .requestFocus();
                                                          });
                                                        }
                                                      : null,
                                                  value: selectedState,
                                                ))),
                                        isStateError
                                            ? Container(
                                                padding: EdgeInsets.only(
                                                    left: 15, top: 5),
                                                child: Text(
                                                  "Please select State.",
                                                  style: appFonts.getTextStyle(
                                                      'state_not_selected_error_styles'),
                                                ),
                                              )
                                            : Container(),

                                        AppStyles().customPadding(5),

                                        TextFormField(
                                          enabled: enablefields,
                                          decoration: InputDecoration(
                                              border: AppStyles().inputBorder,
                                              errorMaxLines: 3,
                                              focusedBorder: AppStyles()
                                                  .focusedInputBorder,
                                              labelText:
                                                  pincodeLabelName + " *",
                                              labelStyle: AppFonts()
                                                  .getTextStyle('hint_style'),
                                              counterText: "",
                                              contentPadding: AppStyles()
                                                  .contentPaddingForInput),
                                          controller: pinCodeController,
                                          cursorColor: mainAppColor,
                                          validator: (val) =>
                                              GlobalValidations()
                                                  .pincodeValidations(
                                                      val.trim()),
                                          maxLength: 6,
                                          keyboardType: TextInputType.phone,
                                          focusNode: pincodeFocus,
                                          key: pincodeKey,
                                        ),

                                        AppStyles().customPadding(5),

                                        Row(children: <Widget>[
                                          Checkbox(
                                            value: sameAsDeliveryAddressCheck,
                                            // checkColor: mainAppColor,
                                            activeColor: mainAppColor,
                                            onChanged: enablefields
                                                ? (bool val) {
                                                    if (enablefields == false) {
                                                      val = false;
                                                    }
                                                    setState(() {
                                                      sameAsDeliveryAddressCheck =
                                                          val;
                                                    });
                                                  }
                                                : (bool val) {},
                                          ),
                                          Text("Same as Delivery Address")
                                        ]),

                                        AppStyles().customPadding(5),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              !onLoading
                                                  ? Container(
                                                      // width: 10,
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              100, 0, 100, 0),
                                                      child: RaisedButton(
                                                        shape: new RoundedRectangleBorder(
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .circular(
                                                                    0.0)),
                                                        onPressed: () {
                                                          // if (enablefields == false) {
                                                          //   setState(() {
                                                          //     return null;
                                                          //   });
                                                          if (enablefields ==
                                                                  true &&
                                                              !editacconutScreen &&
                                                              registrationFormkey
                                                                  .currentState
                                                                  .validate() &&
                                                              selectedState !=
                                                                  null) {
                                                            setState(() {
                                                              Map userDetails =
                                                                  {
                                                                'countryCode':
                                                                    91,
                                                                'mobileNo':
                                                                    mobileNoController
                                                                        .text
                                                                        .trim()
                                                              };
                                                              checkUserAlreadyExists(
                                                                  userDetails,
                                                                  true);
                                                            });
                                                          } else if (selectedState !=
                                                              null) {
                                                            clearErrorMessages(
                                                                scafFoldkey);
                                                            setState(() {
                                                              if (registrationFormkey
                                                                  .currentState
                                                                  .validate()) {
                                                                onLoading =
                                                                    true;
                                                                Map userDetails =
                                                                    {
                                                                  'countryCode':
                                                                      91,
                                                                  'mobileNo':
                                                                      mobileNoController
                                                                          .text
                                                                          .trim()
                                                                };
                                                                if (editacconutScreen &&
                                                                    editAddressList[
                                                                            'user'] !=
                                                                        null &&
                                                                    editAddressList['user']
                                                                            [
                                                                            "mobileNo"] !=
                                                                        null &&
                                                                    editAddressList['user']["mobileNo"]
                                                                            .toString() !=
                                                                        mobileNoController
                                                                            .text
                                                                            .trim()) {
                                                                  checkUserAlreadyExists(
                                                                      userDetails,
                                                                      true);
                                                                } else {
                                                                  setState(() {
                                                                    onLoading =
                                                                        false;
                                                                  });
                                                                  fetchUserDetails();
                                                                  customerRegistrationDetails[
                                                                              'personalDetails']
                                                                          [
                                                                          'isMobileNoChange'] =
                                                                      "false";
                                                                  print(
                                                                      customerRegistrationDetails);
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      '/farmdetails');
                                                                }
                                                              }
                                                            });
                                                          } else {
                                                            setState(() {
                                                              isStateError =
                                                                  true;
                                                            });
                                                          }
                                                        },
                                                        color: mainAppColor,
                                                        child: Text("Continue",
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'button_text_color_white')),
                                                      ))
                                                  : loadingButtonWidget(context)
                                            ])
                                        // Text(data)
                                      ],
                                    )),
                              ))
                            ])))))
            : Center(
                child: customizedCircularLoadingIcon(50),
              ));
  }
}
