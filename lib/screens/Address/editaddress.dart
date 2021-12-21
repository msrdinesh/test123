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
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:flutter/services.dart';

class EditAddressPage extends StatefulWidget {
  @override
  EditAddressDetails createState() => EditAddressDetails();
}

class EditAddressDetails extends State<EditAddressPage> {
  bool onLoading = false;

  var editMobileNoController = TextEditingController();
  var editHouseNoController = TextEditingController();
  var editStreetController = TextEditingController();
  var editCityController = TextEditingController();
  var editStateController = TextEditingController();
  var editPinCodeController = TextEditingController();
  final SuccessMessages successMessages = SuccessMessages();

  //Main Form Key
  final registrationFormkey = GlobalKey<FormState>();

  // All Form field keys

  final editMobileNoKey = GlobalKey<FormFieldState>();
  final editHouseNokey = GlobalKey<FormFieldState>();
  final editStreetKey = GlobalKey<FormFieldState>();
  final editCityKey = GlobalKey<FormFieldState>();
  final editStatekey = GlobalKey<FormFieldState>();
  final editPincodeKey = GlobalKey<FormFieldState>();
  final ApiErros apiErros = ApiErros();
  final AppFonts appFonts = AppFonts();

  final star = "*";

  // All Focusnodes

  FocusNode editMobileNoFocus = FocusNode();
  FocusNode editHouseNoFocus = FocusNode();
  FocusNode editStreetFocus = FocusNode();
  FocusNode editCityFocus = FocusNode();
  FocusNode editStateFocus = FocusNode();
  FocusNode editPincodeFocus = FocusNode();

  // scaffold key
  final scafFoldkey = GlobalKey<ScaffoldState>();
  // Show or hide password bools
  bool showOrHidePassword = true;
  bool showOrdHideConfirmPassword = true;
  final AddressServices addressServices = AddressServices();
  final RefreshTokenService refreshTokenService = RefreshTokenService();
  List states = [];
  String selectedState;
  bool enablePinCode = false;

  @override
  void initState() {
    setState(() {
      // if (registrationFormkey.currentState != null) {
      //   registrationFormkey.currentState.reset();
      // }
      getStates();
      checkIsFormFieldsValid();
      getAddress();
      checkIsPincodeisLinkedWithActiveOrders();
    });
    super.initState();
  }

  checkIsPincodeisLinkedWithActiveOrders() {
    Map requestObj = {
      'addressId': addressDetailsObject['addressId']
    };
    addressServices.checkPincodeLinkedWithActiveOrders(requestObj).then((val) {
      final data = json.decode(val.body);
      if (data['status'] != null && data['status'] == "SUCCESS") {
        setState(() {
          enablePinCode = false;
        });
      } else if (data['status'] != null && data['status'] == "FAILED") {
        setState(() {
          enablePinCode = true;
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        refreshTokenService.getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
            checkIsPincodeisLinkedWithActiveOrders();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldkey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/editaddress', scafFoldkey);
    });
  }

  getStates() {
    addressServices.getStates().then((val) {
      final data = json.decode(val.body);
      if (data != null && data['listOfStates'] != null && data['listOfStates'].length > 0) {
        setState(() {
          states = data['listOfStates'];
          // selectedState = states[0]['stateId'].toString();
        });
      } else if (data['error'] != null) {
        ApiErros().apiLoggedErrors(data, context, scafFoldkey);
      }
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/registration', scafFoldkey);
    });
  }

  // initialization of validations.
  checkIsFormFieldsValid() {
    GlobalValidations().validateCurrentFieldValidOrNot(editMobileNoFocus, editMobileNoKey);

    GlobalValidations().validateCurrentFieldValidOrNot(editHouseNoFocus, editHouseNokey);
    GlobalValidations().validateCurrentFieldValidOrNot(editStreetFocus, editStreetKey);
    GlobalValidations().validateCurrentFieldValidOrNot(editCityFocus, editCityKey);
    // GlobalValidations()
    //     .validateCurrentFieldValidOrNot(editStateFocus, editStatekey);
    GlobalValidations().validateCurrentFieldValidOrNot(editPincodeFocus, editPincodeKey);
    // checkUserExitsOrNot();
  }

  getAddress() {
    // print('requireddata');
    // print(addressDetailsObject['mobileNo']);
    editMobileNoController.text = addressDetailsObject['mobileNo'];
    editHouseNoController.text = addressDetailsObject['doorNumber'];
    editStreetController.text = addressDetailsObject['street'];
    editCityController.text = addressDetailsObject['city'];
    // editStateController.text = addressDetailsObject['state'];
    selectedState = addressDetailsObject['stateId'].toString();
    editPinCodeController.text = addressDetailsObject['pincode'];
  }

  editAdressInfo() {
    Map obj = {
      "addressId": addressDetailsObject['addressId'],
      'mobileNo': editMobileNoController.text.trim(),
      'doorNumber': editHouseNoController.text.trim(),
      'countryCode': 91,
      'street': editStreetController.text.trim(),
      'city': editCityController.text.trim(),
      'stateId': int.parse(selectedState),
      'pincode': editPinCodeController.text.trim(),
      'limit': 2,
      'pageNumber': 1
    };

    // updating address.
    AddressServices().getUpdateAddressDetails(obj).then((res) {
      final data = json.decode(res.body);

      setState(() {
        if (data != null) {
          onLoading = true;
          isAddressEdited = true;
          Navigator.popAndPushNamed(context, '/deliveryaddress');
          // showSuccessNotifications(
          //     successMessages.addressUpdatedSuccessfully, context, scafFoldkey);
        } else if (data['error'] != null) {
          apiErros.apiLoggedErrors(data, context, scafFoldkey);
        }
      });
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
                                  key: registrationFormkey,
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.only(top: 5)),
                                      Container(margin: EdgeInsets.only(left: 5), child: Text("Edit Address", style: appFonts.getTextStyle('edit_&_new_address_heading_style'))),
                                      AppStyles().customPadding(10),
                                      TextFormField(
                                          cursorColor: mainAppColor,
                                          controller: editMobileNoController,
                                          decoration: InputDecoration(
                                              labelText: mobileNumberLabelName + " *",
                                              errorMaxLines: 3,
                                              counterText: "",
                                              contentPadding: AppStyles().contentPaddingForInput,
                                              // alignLabelWithHint: true,
                                              border: AppStyles().inputBorder,
                                              prefix: Text("+91 "),
                                              focusedBorder: AppStyles().focusedInputBorder),
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          validator: (value) => GlobalValidations().mobileValidations(value),
                                          focusNode: editMobileNoFocus,
                                          key: editMobileNoKey),
                                      AppStyles().customPadding(3),
                                      TextFormField(
                                        decoration: InputDecoration(border: AppStyles().inputBorder, errorMaxLines: 3, focusedBorder: AppStyles().focusedInputBorder, labelText: houseNumberLabelName + " *", counterText: "", contentPadding: AppStyles().contentPaddingForInput),
                                        controller: editHouseNoController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations().houseNumberValidations(val.trim(), true),
                                        maxLength: 75,
                                        focusNode: editHouseNoFocus,
                                        key: editHouseNokey,
                                      ),
                                      AppStyles().customPadding(5),
                                      TextFormField(
                                        decoration: InputDecoration(border: AppStyles().inputBorder, errorMaxLines: 3, focusedBorder: AppStyles().focusedInputBorder, labelText: streetLabelName + " *", counterText: "", contentPadding: AppStyles().contentPaddingForInput),
                                        controller: editStreetController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations().streetValidations(val.trim(), true),
                                        maxLength: 75,
                                        focusNode: editStreetFocus,
                                        key: editStreetKey,
                                      ),
                                      AppStyles().customPadding(5),
                                      TextFormField(
                                        decoration: InputDecoration(border: AppStyles().inputBorder, errorMaxLines: 3, focusedBorder: AppStyles().focusedInputBorder, labelText: cityLabelName + ' *', counterText: "", contentPadding: AppStyles().contentPaddingForInput),
                                        controller: editCityController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations().cityValidations(val.trim()),
                                        maxLength: 75,
                                        focusNode: editCityFocus,
                                        key: editCityKey,
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
                                      //   controller: editStateController,
                                      //   cursorColor: mainAppColor,
                                      //   // cursorWidth: 10,
                                      //   validator: (val) => GlobalValidations()
                                      //       .stateValidations(val.trim()),
                                      //   maxLength: 75,
                                      //   focusNode: editStateFocus,
                                      //   key: editStatekey,
                                      // ),
                                      Container(
                                          decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(7)),
                                          child: Container(
                                              padding: EdgeInsets.only(left: 15),
                                              child: DropdownButton<String>(
                                                underline: Container(),
                                                focusNode: editCityFocus,
                                                key: editStatekey,
                                                isExpanded: true,
                                                hint: Text('State'),
                                                items: states.map((state) {
                                                  // specificationSelection =
                                                  //     productDataSpecifications['specificationId']
                                                  //         .toString();
                                                  return new DropdownMenuItem(
                                                    child: new Text(
                                                      state['name'].toString(),
                                                      style: appFonts.getTextStyle('state_dropdown_names_style'),
                                                    ),
                                                    value: state['stateId'].toString(),
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) {
                                                  setState(() {
                                                    selectedState = newVal;
                                                    editStateFocus.requestFocus();
                                                  });
                                                },
                                                value: selectedState,
                                              ))),
                                      AppStyles().customPadding(5),
                                      TextFormField(
                                        decoration: InputDecoration(border: AppStyles().inputBorder, errorMaxLines: 3, focusedBorder: AppStyles().focusedInputBorder, labelText: pincodeLabelName + " *", counterText: "", contentPadding: AppStyles().contentPaddingForInput),
                                        controller: editPinCodeController,
                                        cursorColor: mainAppColor,
                                        validator: (val) => GlobalValidations().pincodeValidations(val.trim()),
                                        maxLength: 6,
                                        enabled: enablePinCode,
                                        keyboardType: TextInputType.phone,
                                        focusNode: editPincodeFocus,
                                        key: editPincodeKey,
                                      ),
                                      AppStyles().customPadding(5),
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                                                  // print('hiiiiiii');
                                                  // print(addressDetailsObject);
                                                  setState(() {
                                                    if (registrationFormkey.currentState.validate() && selectedState != null) {
                                                      editAdressInfo();
                                                    }
                                                  });
                                                },
                                                color: mainAppColor,
                                                child: Text(
                                                  " Save",
                                                  style: appFonts.getTextStyle('button_text_color_white'),
                                                ),
                                              ))
                                            : loadingButtonWidget(context)
                                      ])
                                    ],
                                  )),
                            )))))));
  }
}
