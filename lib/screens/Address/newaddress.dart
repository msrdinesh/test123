import 'dart:convert';

import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
// import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/constants/successmessages.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:flutter/services.dart';

class NewAddressPage extends StatefulWidget {
  @override
  NewAddressDetails createState() => NewAddressDetails();
}

class NewAddressDetails extends State<NewAddressPage> {
  bool onLoading = false;

  final newMobileNoController = TextEditingController();
  final newHouseNoController = TextEditingController();
  final newStreetController = TextEditingController();
  final newCityController = TextEditingController();
  final newStateController = TextEditingController();
  final newPinCodeController = TextEditingController();
  final SuccessMessages successMessages = SuccessMessages();

  // confirm password enable bool

  //Main Form Key
  final addressFormkey = GlobalKey<FormState>();

  // All Form field keys

  final newMobileNoKey = GlobalKey<FormFieldState>();
  final newHouseNokey = GlobalKey<FormFieldState>();
  final newStreetKey = GlobalKey<FormFieldState>();
  final newCityKey = GlobalKey<FormFieldState>();
  final newStatekey = GlobalKey<FormFieldState>();
  final newPincodeKey = GlobalKey<FormFieldState>();
  final ApiErros apiErros = ApiErros();

  // final star = "*";

  final star = "*";

  // All Focusnodes

  FocusNode newMobileNoFocus = FocusNode();
  FocusNode newHouseNoFocus = FocusNode();
  FocusNode newStreetFocus = FocusNode();
  FocusNode newCityFocus = FocusNode();
  FocusNode newStateFocus = FocusNode();
  FocusNode newPincodeFocus = FocusNode();

  // scaffold key
  final scafFoldkey = GlobalKey<ScaffoldState>();
  // Show or hide password bools
  bool showOrHidePassword = true;
  bool showOrdHideConfirmPassword = true;
  final AddressServices addressServices = AddressServices();
  bool isStateError = false;
  List states = [];
  String selectedState;
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    setState(() {
      // if (registrationFormkey.currentState != null) {
      //   registrationFormkey.currentState.reset();
      // }
      getStates();
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

  checkIsFormFieldsValid() {
    GlobalValidations()
        .validateCurrentFieldValidOrNot(newMobileNoFocus, newMobileNoKey);

    GlobalValidations()
        .validateCurrentFieldValidOrNot(newHouseNoFocus, newHouseNokey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(newStreetFocus, newStreetKey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(newCityFocus, newCityKey);
    // GlobalValidations()
    //     .validateCurrentFieldValidOrNot(newStateFocus, newStatekey);
    GlobalValidations()
        .validateCurrentFieldValidOrNot(newPincodeFocus, newPincodeKey);
    // checkUserExitsOrNot();
  }

  newAddressinformation() {
    Map obj = {
      'mobileNo': newMobileNoController.text.trim(),
      'doorNumber': newHouseNoController.text.trim(),
      'countryCode': 91,
      'street': newStreetController.text.trim(),
      'city': newCityController.text.trim(),
      'stateId': int.parse(selectedState),
      'pincode': newPinCodeController.text.trim(),
      'limit': 2,
      'pageNumber': 1
    };

    // add new address
    AddressServices().getNewAddressDetails(obj).then((res) {
      final data = json.decode(res.body);
      setState(() {
        if (data != null) {
          onLoading = true;
          isNewAddressCreated = true;
          Navigator.pushReplacementNamed(context, "/deliveryaddress");
          // showSuccessNotifications(
          //     successMessages.addressAddedMessages, context, scafFoldkey);
        } else if (data['error'] != null) {
          apiErros.apiLoggedErrors(data, context, scafFoldkey);
        }
      });
      // print('late');
      // print(data);
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.popAndPushNamed(context, '/deliveryaddress');
          return Future.value(false);
        },
        child: Scaffold(
            key: scafFoldkey,
            appBar: plainAppBarWidget,
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Container(
                    // decoration: BoxDecoration(
                    //     image: DecorationImage(
                    //         image: AssetImage(cornextBackgroundImagePath),
                    //         fit: BoxFit.fill)),
                    padding: EdgeInsets.only(top: 5),
                    child: Container(
                        //  shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.only(
                        //           topLeft: Radius.circular(35.0),
                        //           topRight: Radius.circular(35.0))),
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            child: SingleChildScrollView(
                              child: Form(
                                  key: addressFormkey,
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          child: Text("Add New Address",
                                              style: appFonts.getTextStyle(
                                                  'edit_&_new_address_heading_style'))),
                                      AppStyles().customPadding(15),
                                      TextFormField(
                                        cursorColor: mainAppColor,
                                        controller: newMobileNoController,
                                        decoration: InputDecoration(
                                            labelText:
                                                mobileNumberLabelName + " *",
                                            errorMaxLines: 3,
                                            counterText: "",
                                            contentPadding: AppStyles()
                                                .contentPaddingForInput,
                                            // alignLabelWithHint: true,
                                            border: AppStyles().inputBorder,
                                            prefix: Text("+91 "),
                                            focusedBorder:
                                                AppStyles().focusedInputBorder),
                                        keyboardType: TextInputType.number,
                                        maxLength: 10,
                                        validator: (value) =>
                                            GlobalValidations()
                                                .mobileValidations(value),
                                        focusNode: newMobileNoFocus,
                                        key: newMobileNoKey,
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter
                                              .digitsOnly
                                        ],
                                      ),
                                      AppStyles().customPadding(3),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            border: AppStyles().inputBorder,
                                            errorMaxLines: 3,
                                            focusedBorder:
                                                AppStyles().focusedInputBorder,
                                            labelText:
                                                houseNumberLabelName + " *",
                                            counterText: "",
                                            contentPadding: AppStyles()
                                                .contentPaddingForInput),
                                        controller: newHouseNoController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations()
                                            .houseNumberValidations(
                                                val.trim(), true),
                                        maxLength: 75,
                                        focusNode: newHouseNoFocus,
                                        key: newHouseNokey,
                                      ),
                                      AppStyles().customPadding(5),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            border: AppStyles().inputBorder,
                                            errorMaxLines: 3,
                                            focusedBorder:
                                                AppStyles().focusedInputBorder,
                                            labelText: streetLabelName + " *",
                                            counterText: "",
                                            contentPadding: AppStyles()
                                                .contentPaddingForInput),
                                        controller: newStreetController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations()
                                            .streetValidations(
                                                val.trim(), true),
                                        maxLength: 75,
                                        focusNode: newStreetFocus,
                                        key: newStreetKey,
                                      ),
                                      AppStyles().customPadding(5),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            border: AppStyles().inputBorder,
                                            errorMaxLines: 3,
                                            focusedBorder:
                                                AppStyles().focusedInputBorder,
                                            labelText: cityLabelName + ' *',
                                            counterText: "",
                                            contentPadding: AppStyles()
                                                .contentPaddingForInput),
                                        controller: newCityController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations()
                                            .cityValidations(val.trim()),
                                        maxLength: 75,
                                        focusNode: newCityFocus,
                                        key: newCityKey,
                                      ),
                                      AppStyles().customPadding(5),
                                      // TextFormField(
                                      //   decoration: InputDecoration(
                                      //       border: AppStyles().inputBorder,
                                      //       errorMaxLines: 3,
                                      //       focusedBorder:
                                      //           AppStyles().focusedInputBorder,
                                      //       labelText: stateLabelName + " *",
                                      //       counterText: "",
                                      //       contentPadding: AppStyles()
                                      //           .contentPaddingForInput),
                                      //   controller: newStateController,
                                      //   cursorColor: mainAppColor,
                                      //   // cursorWidth: 10,
                                      //   validator: (val) => GlobalValidations()
                                      //       .stateValidations(val.trim()),
                                      //   maxLength: 75,
                                      //   focusNode: newStateFocus,
                                      //   key: newStatekey,
                                      // ),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: isStateError
                                                      ? Colors.red[700]
                                                      : Colors.grey,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              child: DropdownButton<String>(
                                                underline: Container(),
                                                focusNode: newStateFocus,
                                                key: newStatekey,
                                                isExpanded: true,
                                                hint: Text('State'),
                                                items: states.map((state) {
                                                  // specificationSelection =
                                                  //     productDataSpecifications['specificationId']
                                                  //         .toString();
                                                  return new DropdownMenuItem(
                                                    child: new Text(
                                                      state['name'].toString(),
                                                      style: appFonts.getTextStyle(
                                                          'state_dropdown_names_style'),
                                                    ),
                                                    value: state['stateId']
                                                        .toString(),
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) {
                                                  setState(() {
                                                    selectedState = newVal;
                                                    newStateFocus
                                                        .requestFocus();
                                                    isStateError = false;
                                                  });
                                                },
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
                                        decoration: InputDecoration(
                                            border: AppStyles().inputBorder,
                                            errorMaxLines: 3,
                                            focusedBorder:
                                                AppStyles().focusedInputBorder,
                                            labelText: pincodeLabelName + " *",
                                            counterText: "",
                                            contentPadding: AppStyles()
                                                .contentPaddingForInput),
                                        controller: newPinCodeController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations()
                                            .pincodeValidations(val.trim()),
                                        maxLength: 6,
                                        keyboardType: TextInputType.phone,
                                        focusNode: newPincodeFocus,
                                        key: newPincodeKey,
                                      ),
                                      AppStyles().customPadding(5),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            !onLoading
                                                ? Container(
                                                    // width: 10,
                                                    // margin: EdgeInsets.fromLTRB(
                                                    //     100, 0, 100, 0),
                                                    child: RaisedButton(
                                                    // shape:
                                                    //     new RoundedRectangleBorder(
                                                    //         borderRadius:
                                                    //             new BorderRadius
                                                    //                     .circular(
                                                    //                 20.0)),
                                                    onPressed: () {
                                                      if (addressFormkey
                                                              .currentState
                                                              .validate() &&
                                                          selectedState !=
                                                              null) {
                                                        newAddressinformation();
                                                      } else if (selectedState ==
                                                          null) {
                                                        setState(() {
                                                          isStateError = true;
                                                        });
                                                      }
                                                    },
                                                    color: mainAppColor,
                                                    child: Text(
                                                      "Add",
                                                      style: appFonts.getTextStyle(
                                                          'button_text_color_white'),
                                                    ),
                                                  ))
                                                : loadingButtonWidget(context)
                                          ])
                                    ],
                                  )),
                            )))))));
  }
}
