import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/services/editprofileservice/editprofileservice.dart';
// import 'package:cornext_mobile/services/editprofileservie/editprofileservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
// import 'package:flushbar/flushbar.dart';
// import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/models/customerregistrationmodel.dart';
import 'package:cornext_mobile/services/registrationservices/registrationservice.dart';
import 'dart:convert';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
// import 'package:cornext_mobile/constants/regularexpression.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
// import 'package:flutter/services.dart' show rootBundle;

class FarmDetailsPage extends StatefulWidget {
  @override
  FarmDetails createState() => FarmDetails();
}

class FarmDetails extends State<FarmDetailsPage> {
  final animalDetailsTextkey = GlobalKey<EditableTextState>();
  bool noAnimalsCheck = false;
  bool cowsCheck = false;
  bool buffaloCheck = false;
  bool sameAsDeliveryAddressCheck = false;
  int numberOfCows = 0;
  int numberOfBuffalos = 0;
  bool onLoading = false;
  bool onFarmDetailsLoading = false;
  bool loadingButtonForSkipClick = false;
  double _buttonWidth = 30;

  final numberOfCowsController = TextEditingController();
  final numberOfBuffaloController = TextEditingController();
  final ProfileServies editProfileService = ProfileServies();
  final ApiErros apiErros = ApiErros();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    fetchFarmDetails();
    // onLoading = true;
    // if (editacconutScreen) {
    //   // setState(() {});
    // }

    super.initState();
  }

//checks skip button is true or false, if true then farm details will make as empty
  registerNewUser(isSkipped) {
    clearErrorMessages(scaffoldKey);
    customerRegistrationDetails['farmDetails'] = getAnimalSubId();

    if (noAnimalsCheck || (isSkipped && !editacconutScreen)) {
      customerRegistrationDetails['farmDetails'] = [];
    }

    if (editacconutScreen) {
      final deletedFarmDetails =
          getRemovedFarmDetails(editAddressList['farmDetails']);
      print(deletedFarmDetails);
      customerRegistrationDetails['deleteFarmDetails'] = deletedFarmDetails;
      if (customerRegistrationDetails['personalDetails']['isMobileNoChange'] ==
          "true") {
        sendOtpToUser();
      } else {
        updateUserDetails();
      }
    } else {
      print('sjjs');
      sendOtpToUser();
    }
  }

// update user deatils in json
  updateUserDetails() {
    // print('details');

    // print(customerRegistrationDetails);
    Map requestObj = {
      "otps": {"mobileNoChange": false},
      "user": {
        "firstName": customerRegistrationDetails['personalDetails']
            ['firstName'],
        "lastName": customerRegistrationDetails['personalDetails']['surName'],
        "countryCode": 91,
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "alternateMobileNo": customerRegistrationDetails['personalDetails']
            ['alternateMobileNo'],
        "emailId": customerRegistrationDetails['personalDetails']['emailId'],
      },
      "address": {
        "addressId": editAddressList['address']['addressId'],
        "doorNumber": customerRegistrationDetails['communicationDetails']
            ['houseNumber'],
        "street": customerRegistrationDetails['communicationDetails']
            ['streetOrArea'],
        "city": customerRegistrationDetails['communicationDetails']
            ['cityOrTownOrVillage'],
        "stateId": customerRegistrationDetails['communicationDetails']
            ['stateId'],
        "pincode": customerRegistrationDetails['communicationDetails']
            ['pincode'],
        "mobileNo": customerRegistrationDetails['personalDetails']['mobileNo'],
        "countryCode": 91,
        "deliveryAddress": customerRegistrationDetails['communicationDetails']
            ['sameAsDeliveryAddress']
      },
      "farmDetails": customerRegistrationDetails['farmDetails'],
      'deleteFarmDetails': customerRegistrationDetails['deleteFarmDetails']
    };
    print('user hhdhd');
    print(requestObj['address']);

    editProfileService.updateProfileDetails(requestObj).then((res) {
      final data = json.decode(res.body);
      // print('ssdsds');
      print(data);
      setState(() {
        onLoading = false;
      });
      // if (data != null && data == 'SUCCESS') {
      if (data != null && data['profile'] != null) {
        // Navigator.pushReplacementNamed(context, '/login');
        SharedPreferenceService().setUserName(data['profile']['user']
                ['firstName'] +
            " " +
            data['profile']['user']['lastName']);
        signInDetails['userName'] = data['profile']['user']['firstName'] +
            " " +
            data['profile']['user']['lastName'];
        SharedPreferenceService()
            .setEmailId(data['profile']['user']['emailId']);
        signInDetails['emailId'] = data['profile']['user']['emailId'];
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
        // Navigator.pushNamed(context, '/login');
        // Navigator.popUntil(context, ModalRoute.withName('/'));
      } else if (data['status'] != null && data['status'] == 'USEREXISTS') {
        showErrorNotifications(
            ErrorMessages().userAlreadyExistsError, context, scaffoldKey);
      } else if (data['status'] != null &&
          data['status'] == 'MOBILEOTPEXPIRED') {
        showErrorNotifications(
            ErrorMessages().mobileNoOtpExpiredError, context, scaffoldKey);
      } else if (data['status'] != null && data['status'] == "FAILED") {
        showErrorNotifications(
            ErrorMessages().failedToUpdateProfileErrorMessage,
            context,
            scaffoldKey);
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
      }
    }, onError: (err) {
      setState(() {
        onLoading = false;
      });
    });
  }

  List getRemovedFarmDetails(List previousSelectedFarmDetails) {
    final List removedFarmDetails = [];
    if (previousSelectedFarmDetails.length > 0) {
      previousSelectedFarmDetails.forEach((res) {
        subCategories.forEach((val) {
          if (val['isFinal'] != null && val['isFinal']) {
            Map obj = getObjectFromJson(val['path']);
            if (obj['animalSubId'] != null &&
                obj['animalSubId'] == res['animalSubId'] &&
                val[val['path'] + "isChecked"] != null &&
                !val[val['path'] + "isChecked"] &&
                val['updatedFromFormDetails'] != null &&
                val['updatedFromFormDetails']) {
              final sendObj = {'animalSubId': res['animalSubId']};
              removedFarmDetails.add(sendObj);
            }
          }
        });
      });
    }
    return removedFarmDetails;
  }

// send otp to the user registred number
  sendOtpToUser() {
    final Map requestObj = {
      'countryCode': 91,
      'mobileNo':
          customerRegistrationDetails['personalDetails']['mobileNo'].toString()
    };
    RegistrationService().registerUser(requestObj).then((res) {
      final data = json.decode(res.body);
      if (data != null && data == 'SUCCESS') {
        Navigator.pushNamed(context, '/otpvalidation');
      }

      setState(() {
        onLoading = false;
        loadingButtonForSkipClick = false;
      });
    }, onError: (err) {
      setState(() {
        onLoading = false;
        loadingButtonForSkipClick = false;
      });
      ApiErros()
          .apiErrorNotifications(err, context, '/farmdetails', scaffoldKey);
    }).catchError((err) {
      setState(() {
        onLoading = false;
        loadingButtonForSkipClick = false;
      });
      ApiErros()
          .apiErrorNotifications(err, context, '/farmdetails', scaffoldKey);
    });
  }

  Map farmDetailsObj;
  List categories = [];
  List subCategories = [];

  // Future fetchFarmDetails() async {
  //   rootBundle.loadString('assets/json/farminfo.json').then((val) {
  //     final data = json.decode(val);
  //     farmDetailsObj = data['animalType'];
  //     // parseFarmDetails();
  //     if (farmDetailsObj.keys.length > 0) {
  //       intializeFarmDetails();
  //       print(subCategories);
  //       setState(() {
  //         intializeCheckBoxes();
  //       });
  //     }
  //   });

// final obj = null;

// fetches farm details for edit profile screen

  fetchFarmDetails() {
    // print('saaaaaaa');
    onFarmDetailsLoading = true;

    RegistrationService().getFarmDetails().then((res) {
      final data = json.decode(res.body);
      setState(() {
        onFarmDetailsLoading = false;
      });

      farmDetailsObj = data['animalType'];
      // parseFarmDetails();
      if (farmDetailsObj.keys.length > 0) {
        intializeFarmDetails();
        intializeFocusNodes();
        // removeSubCategoryIdsFromJson();
        // print(subCategories);
        // Future.delayed(Duration(milliseconds: 10), () {
        setState(() {
          intializeCheckBoxes();
        });

        if (editacconutScreen) {
          updateFarmDetails(editAddressList['farmDetails']);
        }
        // });
      }
    }, onError: (err) {
      ApiErros()
          .apiErrorNotifications(err, context, '/farmdetails', scaffoldKey);
      setState(() {
        onFarmDetailsLoading = false;
      });

      // print(err);
    });
  }

// fetches farm details from JSON api
  intializeFarmDetails() {
    farmDetailsObj.keys.forEach((val) {
      // print(val);
      // print(farmDetailsObj[val]);
      final jsonVal = {"value": val, "path": val, val + "isChecked": false};
      // if(farmDetailsObj[val].keys.length > 0 && farmDetailsObj[val].keys.toList().indexOf('animalSubId') == -1){
      if (!findCurrentElement(val)) {
        categories.add(jsonVal);
      }
      parseFarmDetails(farmDetailsObj[val], val);
      // } else {
      //   jsonVal['isFinal'] = true;
      //   jsonVal[val + 'controller'] = TextEditingController();
      //   jsonVal[val + 'totalNo'] = 0;
      //   jsonVal[val + 'formKey'] = GlobalKey<FormFieldState>();
      //   jsonVal[val + 'focusNode'] = FocusNode();
      //   print(jsonVal);
      //   if (!findCurrentElement(val)) {
      //     categories.add(jsonVal);
      //   }
      // }
    });
  }
// update farm details with newly entered values

  updateFarmDetails(List farmDetails) {
    if (farmDetails.length > 0) {
      farmDetails.forEach((res) {
        subCategories.forEach((val) {
          if (val['isFinal'] != null && val['isFinal']) {
            Map obj = getObjectFromJson(val['path']);
            if (obj['animalSubId'] != null &&
                obj['animalSubId'] == res['animalSubId']) {
              setState(() {
                val[val['path'] + "isChecked"] = true;
                val[val['path'] + "controller"].text =
                    res['quantity'].toString();
                val[val['path'] + "totalNo"] = res['quantity'];
                val['updatedFromFormDetails'] = true;
                updateFarmDetailsBooleans(val['path']);
              });
            }
          }
        });
      });
    } else {
      setState(() {
        noAnimalsCheck = true;
      });
    }
  }

// update farm detail check boxs
  updateFarmDetailsBooleans(String path) {
    List pathValues = path.split('|');
    String initiatePath = '';
    pathValues.forEach((res) {
      if (initiatePath == '') {
        initiatePath = res;
        categories.forEach((val) {
          if (val['path'] == res) {
            setState(() {
              val[val['path'] + 'isChecked'] = true;
            });
          }
        });
      } else {
        initiatePath = initiatePath + '|' + res;
        subCategories.forEach((val) {
          if (val['path'] == initiatePath) {
            // print(val[val['path'] + 'isChecked']);
            setState(() {
              val[val['path'] + 'isChecked'] = true;
            });
          }
        });
      }
    });
  }

// update farm details
  parseFarmDetails(Map data, String path) {
    if (data.keys.length > 0) {
      data.keys.forEach((val) {
        final updatedPath = path + '|' + val;
        final jsonVal = {
          "value": val,
          "path": updatedPath,
          updatedPath + "isChecked": false
        };
        // if (getParsedJson.indexOf(jsonVal) == -1) {
        if (!findCurrentElement(updatedPath)) {
          // print(data[val]);
          if (data[val].keys.length > 0 &&
              data[val].keys.toList().indexOf('animalSubId') == -1) {
            // print(data[val].keys);
            subCategories.add(jsonVal);
            parseFarmDetails(data[val], updatedPath);
          } else {
            // if () {
            // print(jsonVal['value']);
            jsonVal['isFinal'] = true;
            jsonVal[updatedPath + 'controller'] = TextEditingController();
            jsonVal[updatedPath + 'totalNo'] = 0;
            jsonVal[updatedPath + 'formKey'] = GlobalKey<FormFieldState>();
            jsonVal[updatedPath + 'focusNode'] = FocusNode();
            setState(() {
              jsonVal[updatedPath + 'controller'].text = '0';
            });
            // }
            subCategories.add(jsonVal);
            // }
            intializeFarmDetails();
          }
        }
      });
    } else {
      intializeFarmDetails();
    }
  }

// intialize focus nodes
  intializeFocusNodes() {
    subCategories.forEach((res) {
      if (res[res['path'] + 'focusNode'] != null) {
        GlobalValidations().validateCurrentFarmFieldValidOrNot(
            res[res['path'] + 'focusNode'],
            res[res['path'] + 'formKey'],
            context,
            scaffoldKey);
      }
    });
  }

// update sub categories from json
  removeSubCategoryIdsFromJson() {
    for (int i = 0; i < subCategories.length; i++) {
      if (subCategories[i]['value'] == 'animalSubId' ||
          subCategories[i]['value'] == 'animaiId') {
        subCategories.removeAt(i);
      }
    }
  }

  List<Widget> intialCheckBoxes = [];
  List firstLevelSubCategoriesData = [];
  intializeCheckBoxes() {
    return Expanded(
        // height: MediaQuery.of(context).size.height / 1.8,
        child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int i) {
              return new Card(
                  child: Column(children: <Widget>[
                CheckboxListTile(
                  value: categories[i][categories[i]['path'] + 'isChecked'],
                  title: Text(categories[i]['value'],
                      style: appFonts
                          .getTextStyle('farm_details_check_box_text_style')),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: mainAppColor,
                  onChanged: (noAnimalsCheck ||
                          onLoading ||
                          loadingButtonForSkipClick)
                      ? null
                      : (bool val) {
                          setState(() {
                            if (val) {
                              setState(() {
                                firstLevelSubCategoriesData =
                                    getSubCategoriesInfo(
                                        categories[i]['value']);
                              });
                            }
                            categories[i][categories[i]['path'] + 'isChecked'] =
                                val;
                            if (!categories[i]
                                [categories[i]['path'] + 'isChecked']) {
                              setSubCategoriesBooleans(categories[i]['path']);
                            }
                          });
                        },
                ),
                // categories[i][categories[i]['path'] + 'controller'] == null ?
                getSubCategoriesWidgets(
                    categories[i][categories[i]['path'] + 'isChecked'],
                    getSubCategoriesInfo(categories[i]['path']),
                    true)
                // : Container(
                //               margin: EdgeInsets.only(right: 25),
                //               decoration: BoxDecoration(
                //                 border: Border.all(
                //                     color: categories[i][categories[i]['path'] + 'formKey']
                //                                         .currentState !=
                //                                     null &&
                //                                 categories[i][categories[i]['path'] + 'formKey']
                //                                     .currentState
                //                                     .hasError ||
                //                             categories[i][categories[i]['path'] + 'totalNo'] >
                //                                 9999 ||
                //                             categories[i][categories[i]['path'] + 'controller'].text.trim() == ""
                //                         ? Colors.red
                //                         : Colors.grey[300],
                //                     width: 2),
                //                 borderRadius: BorderRadius.circular(10),
                //               ),
                //               padding: EdgeInsets.symmetric(vertical: 0.3),
                //               width: 115,
                //               child: Row(
                //                 mainAxisAlignment:
                //                     MainAxisAlignment.spaceEvenly,
                //                 children: <Widget>[
                //                   SizedBox(
                //                     width: _buttonWidth,
                //                     height: _buttonWidth,
                //                     child: FlatButton(
                //                       padding: EdgeInsets.all(0),
                //                       onPressed: (noAnimalsCheck ||
                //                               onLoading ||
                //                               loadingButtonForSkipClick)
                //                           ? null
                //                           : () {
                //                               setState(() {
                //                                 if (categories[i][categories[i]['path'] + 'totalNo'] >
                //                                     0) {
                //                                   setState(() {
                //                                     categories[i][categories[i]['path'] + 'totalNo']--;
                //                                     categories[i][categories[i]['path'] + 'controller']
                //                                         .text = categories[i][categories[i]['path'] + 'totalNo']
                //                                         .toString();
                //                                     categories[i][categories[i]['path'] + 'focusNode']
                //                                         .unfocus();
                //                                   });
                //                                 }
                //                                 if (categories[i][categories[i]['path'] + 'totalNo'] ==
                //                                     0) {
                //                                   setState(() {
                //                                     // cowsCheck = false;
                //                                     categories[i][categories[i]['path'] + 'controller']
                //                                         .text = "0";
                //                                   });
                //                                 }
                //                                 categories[i][categories[i]['path'] + 'formKey']
                //                                     .currentState
                //                                     ?.validate();
                //                               });
                //                             },
                //                       child: Icon(
                //                         Icons.remove_circle,
                //                         size: 20,
                //                         color: Colors.grey[700],
                //                       ),
                //                     ),
                //                   ),

                //                   // Text(numberOfCows.toString()),
                //                   Container(
                //                       // padding: EdgeInsets.only(top: -10),
                //                       width: 38,
                //                       // constraints:
                //                       //     BoxConstraints(minWidth: 22),
                //                       child: TextFormField(
                //                         controller: categories[i][categories[i]['path'] + 'controller'],
                //                         //              validator: (value) => GlobalValidations()
                //                         // .mobileValidations(value.trim()),
                //                         enabled: (noAnimalsCheck ||
                //                                 onLoading ||
                //                                 loadingButtonForSkipClick)
                //                             ? false
                //                             : true,
                //                         decoration: InputDecoration(
                //                             border: InputBorder.none,
                //                             errorMaxLines: 1,
                //                             labelText: "",
                //                             counterText: "",
                //                             contentPadding:
                //                                 EdgeInsets.only(top: -15),
                //                             errorStyle: TextStyle(
                //                                 fontSize: 0, height: 0)),
                //                         // cursorRadius: Radius.circular(5),
                //                         // initialValue: "0",
                //                         validator: (val) =>
                //                             GlobalValidations()
                //                                 .animalFieldValidations(
                //                                     val,
                //                                     categories[i]['value']),
                //                         // autovalidate: true,
                //                         cursorColor: mainAppColor,
                //                         key: categories[i][categories[i]['path'] + 'formKey'],
                //                         // expands: true,
                //                         focusNode: categories[i][categories[i]['path'] + 'focusNode'],
                //                         textAlign: TextAlign.center,
                //                         // focusNode: noAnimalsCheck?null:,
                //                         keyboardType:
                //                             TextInputType.numberWithOptions(
                //                                 decimal: true,
                //                                 signed: false),
                //                         // autovalidate: true,
                //                         maxLength: 4,
                //                         onChanged: (noAnimalsCheck ||
                //                                 onLoading ||
                //                                 loadingButtonForSkipClick)
                //                             ? null
                //                             : (val) {
                //                                 setState(() {
                //                                   // if (!subCategories[index][
                //                                   //         subCategories[
                //                                   //                     index]
                //                                   //                 ['path'] +
                //                                   //             'formKey']
                //                                   //     .currentState
                //                                   //     .validate()) {
                //                                   //   showErrorMessages(
                //                                   //       subCategories[
                //                                   //               index][subCategories[
                //                                   //                       index]
                //                                   //                   [
                //                                   //                   'path'] +
                //                                   //               'formKey']
                //                                   //           .currentState
                //                                   //           .errorText,
                //                                   //       context);
                //                                   // }
                //                                   // subCategories[index][
                //                                   //         subCategories[
                //                                   //                     index]
                //                                   //                 ['path'] +
                //                                   //             'controller']
                //                                   //     .text = val.trim();
                //                                   if (val != '' &&
                //                                       categories[i][categories[i]['path'] + 'formKey']
                //                                           .currentState
                //                                           .validate() &&
                //                                       int.parse(val) != 0) {
                //                                     categories[i][categories[i]['path'] + 'isChecked'] = true;
                //                                     categories[i][categories[i]['path'] + 'totalNo'] = int
                //                                         .parse(val);
                //                                   } else {
                //                                     categories[i][categories[i]['path'] + 'isChecked'] = false;
                //                                     categories[i][categories[i]['path'] + 'totalNo'] = 0;
                //                                   }
                //                                 });
                //                               },
                //                         // cursorColor: Colors.green[800],
                //                       )),

                //                   SizedBox(
                //                     width: _buttonWidth,
                //                     height: _buttonWidth,
                //                     child: FlatButton(
                //                       padding: EdgeInsets.all(0),
                //                       onPressed: (noAnimalsCheck ||
                //                               onLoading ||
                //                               loadingButtonForSkipClick)
                //                           ? null
                //                           : () {
                //                               setState(() {
                //                                 if (categories[i][categories[i]['path'] + 'totalNo'] <=
                //                                     9999) {
                //                                   setState(() {
                //                                     categories[i][categories[i]['path'] + 'totalNo']++;
                //                                   });
                //                                 }

                //                                 if (categories[i][categories[i]['path'] + 'totalNo'] >
                //                                         0 &&
                //                                     categories[i][categories[i]['path'] + 'totalNo'] <
                //                                         9999) {
                //                                   setState(() {
                //                                     categories[i][categories[i]['path'] + 'isChecked'] = true;
                //                                     categories[i][categories[i]['path'] + 'controller']
                //                                         .text = categories[i][categories[i]['path'] + 'totalNo']
                //                                         .toString();
                //                                     categories[i][categories[i]['path'] + 'focusNode']
                //                                         .unfocus();
                //                                   });
                //                                 }
                //                                 categories[i][categories[i]['path'] + 'formKey']
                //                                     .currentState
                //                                     ?.validate();
                //                               });
                //                             },
                //                       child: Icon(
                //                         Icons.add_circle,
                //                         size: 20,
                //                         color: Colors.grey[700],
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ))
              ]));
            }));
  }

// fetches sub categories from JSON
  List getSubCategoriesInfo(String val) {
    Map obj;
    if (val.indexOf('|') != -1) {
      obj = getObjectFromJson(val);
    } else {
      obj = farmDetailsObj[val];
    }
    List returnList = [];
    if (obj != null) {
      obj.keys.forEach((res) {
        subCategories.forEach((response) {
          if (res == response['value'] && response['path'].indexOf(val) != -1) {
            returnList.add(response);
          }
        });
      });
    }
    return returnList.toList();
  }

// updates subcategories with new values
  setSubCategoriesBooleans(String path) {
    subCategories.forEach((val) {
      if (val['path'].indexOf(path) != -1) {
        setState(() {
          val[val['path'] + 'isChecked'] = false;
          if (val[val['path'] + 'totalNo'] != null) {
            val[val['path'] + 'totalNo'] = 0;
            val[val['path'] + 'controller'].text = "0";
          }
        });
      }
    });
  }

//fetches animal details
  getAnimalSubId() {
    List animalInfo = [];
    subCategories.forEach((val) {
      if (val[val['path'] + 'isChecked'] &&
          val[val['path'] + 'totalNo'] != null) {
        // print('kkdkd');
        Map animalSubId = getObjectFromJson(val['path']);
        animalSubId['quantity'] = val[val['path'] + 'totalNo'];
        // print(getObjectFromJson(val['path']));
        animalInfo.add(animalSubId);
      }
    });
    return animalInfo;
  }

  // displays animal details
  Widget getSubCategoriesWidgets(
      bool isChecked, List subCategories, isScrollable) {
    Widget value = (isChecked && subCategories.length > 0)
        ? Container(

            // height: subCategories.length * 65.0,
            constraints: BoxConstraints(minHeight: subCategories.length * 65.0),
            padding: new EdgeInsets.only(left: 10.0, right: 5.0),

            // margin: EdgeInsets.fromLTRB(
            //     15, 0, MediaQuery.of(context).size.width / 30, 0),
            // width: MediaQuery.of(context).size.width / 1.2,
            // constraints: BoxConstraints(maxHeight: subCategories.length * 65.0),
            // fit: BoxFit.fitHeight,
            // flex: 10,
            // fit: FlexFit.tight,
            child: ListView.builder(
                itemCount: subCategories.length,
                // physics: !isScrollable
                //     ? NeverScrollableScrollPhysics()
                //     : AlwaysScrollableScrollPhysics(),
                physics: NeverScrollableScrollPhysics(),
                // itemExtent: ,
                shrinkWrap: true,
                // padding: EdgeInsets.fromLTRB(
                //     15, 0, MediaQuery.of(context).size.width / 75, 0),
                // scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      // scrollDirection: Axis,
                      // physics: NeverScrollableScrollPhysics(),
                      child: Column(children: <Widget>[
                    // Expanded(
                    // Container()

                    Row(children: <Widget>[
                      Expanded(
                          child: CheckboxListTile(
                        value: subCategories[index]
                            [subCategories[index]['path'] + 'isChecked'],
                        title: Text(subCategories[index]['value'],
                            style: appFonts.getTextStyle(
                                'farm_details_subcategories_check_box_text_style')),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: mainAppColor,
                        onChanged: (noAnimalsCheck ||
                                onLoading ||
                                loadingButtonForSkipClick)
                            ? null
                            : (bool val) {
                                setState(() {
                                  subCategories[index][subCategories[index]
                                          ['path'] +
                                      'isChecked'] = val;
                                  if (subCategories[index][subCategories[index]
                                          ['path'] +
                                      'isChecked']) {
                                    if (subCategories[index][
                                            subCategories[index]['path'] +
                                                'controller'] !=
                                        null) {
                                      setState(() {
                                        subCategories[index][
                                                subCategories[index]['path'] +
                                                    'controller']
                                            .text = '1';
                                        subCategories[index][
                                            subCategories[index]['path'] +
                                                'totalNo'] = 1;
                                        subCategories[index][
                                                subCategories[index]['path'] +
                                                    'formKey']
                                            .currentState
                                            ?.validate();
                                      });
                                    }
                                  } else {
                                    if (subCategories[index][
                                            subCategories[index]['path'] +
                                                'controller'] !=
                                        null) {
                                      setState(() {
                                        subCategories[index][
                                                subCategories[index]['path'] +
                                                    'controller']
                                            .text = '0';
                                        subCategories[index][
                                            subCategories[index]['path'] +
                                                'totalNo'] = 0;
                                        subCategories[index][
                                                subCategories[index]['path'] +
                                                    'focusNode']
                                            .unfocus();
                                      });
                                    }
                                  }
                                  if (!subCategories[index][subCategories[index]
                                          ['path'] +
                                      'isChecked']) {
                                    setSubCategoriesBooleans(
                                        subCategories[index]['path']);
                                  }
                                });
                              },
                      )),
                      (subCategories[index]['isFinal'] != null &&
                              subCategories[index]['isFinal'])
                          ? Container(
                              child: Container(
                                  margin: EdgeInsets.only(right: 25),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: subCategories[index][subCategories[index]
                                                                    ['path'] +
                                                                'formKey']
                                                            .currentState !=
                                                        null &&
                                                    subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'formKey']
                                                        .currentState
                                                        .hasError ||
                                                subCategories[index]
                                                        [subCategories[index]['path'] + 'totalNo'] >
                                                    9999 ||
                                                subCategories[index][subCategories[index]['path'] + 'controller'].text.trim() == ""
                                            ? Colors.red
                                            : Colors.grey[300],
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 0.3),
                                  width: 115,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      SizedBox(
                                        width: _buttonWidth,
                                        height: _buttonWidth,
                                        child: FlatButton(
                                          padding: EdgeInsets.all(0),
                                          onPressed: (noAnimalsCheck ||
                                                  onLoading ||
                                                  loadingButtonForSkipClick)
                                              ? null
                                              : () {
                                                  setState(() {
                                                    if (subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'totalNo'] >
                                                        0) {
                                                      setState(() {
                                                        subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'totalNo']--;
                                                        subCategories[index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'controller']
                                                            .text = subCategories[
                                                                    index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'totalNo']
                                                            .toString();
                                                        subCategories[index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'focusNode']
                                                            .unfocus();
                                                      });
                                                    }
                                                    if (subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'totalNo'] ==
                                                        0) {
                                                      setState(() {
                                                        // cowsCheck = false;
                                                        subCategories[
                                                            index][subCategories[
                                                                index]['path'] +
                                                            'isChecked'] = false;
                                                        subCategories[index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'controller']
                                                            .text = "0";
                                                      });
                                                    }
                                                    subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'formKey']
                                                        .currentState
                                                        ?.validate();
                                                  });
                                                },
                                          child: Icon(
                                            Icons.remove_circle,
                                            size: 20,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),

                                      // Text(numberOfCows.toString()),
                                      Container(
                                          // padding: EdgeInsets.only(top: -10),
                                          width: 38,
                                          // constraints:
                                          //     BoxConstraints(minWidth: 22),
                                          child: TextFormField(
                                            controller: subCategories[index][
                                                subCategories[index]['path'] +
                                                    'controller'],
                                            //              validator: (value) => GlobalValidations()
                                            // .mobileValidations(value.trim()),
                                            enabled: (noAnimalsCheck ||
                                                    onLoading ||
                                                    loadingButtonForSkipClick)
                                                ? false
                                                : true,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                errorMaxLines: 1,
                                                labelText: "",
                                                counterText: "",
                                                contentPadding:
                                                    EdgeInsets.only(top: -15),
                                                errorStyle: appFonts.getTextStyle(
                                                    'hide_error_messages_for_formfields')),
                                            // cursorRadius: Radius.circular(5),
                                            // initialValue: "0",
                                            validator: (val) =>
                                                GlobalValidations()
                                                    .animalFieldValidations(
                                                        val,
                                                        subCategories[index]
                                                            ['value']),
                                            // autovalidate: true,
                                            cursorColor: mainAppColor,
                                            key: subCategories[index][
                                                subCategories[index]['path'] +
                                                    'formKey'],
                                            // expands: true,
                                            focusNode: subCategories[index][
                                                subCategories[index]['path'] +
                                                    'focusNode'],
                                            textAlign: TextAlign.center,
                                            // focusNode: noAnimalsCheck?null:,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true,
                                                    signed: false),
                                            // autovalidate: true,
                                            maxLength: 4,
                                            onChanged: (noAnimalsCheck ||
                                                    onLoading ||
                                                    loadingButtonForSkipClick)
                                                ? null
                                                : (val) {
                                                    setState(() {
                                                      // if (!subCategories[index][
                                                      //         subCategories[
                                                      //                     index]
                                                      //                 ['path'] +
                                                      //             'formKey']
                                                      //     .currentState
                                                      //     .validate()) {
                                                      //   showErrorMessages(
                                                      //       subCategories[
                                                      //               index][subCategories[
                                                      //                       index]
                                                      //                   [
                                                      //                   'path'] +
                                                      //               'formKey']
                                                      //           .currentState
                                                      //           .errorText,
                                                      //       context);
                                                      // }
                                                      // subCategories[index][
                                                      //         subCategories[
                                                      //                     index]
                                                      //                 ['path'] +
                                                      //             'controller']
                                                      //     .text = val.trim();
                                                      if (val != '' &&
                                                          subCategories[
                                                                  index][subCategories[
                                                                          index]
                                                                      ['path'] +
                                                                  'formKey']
                                                              .currentState
                                                              .validate() &&
                                                          int.parse(val) != 0) {
                                                        subCategories[
                                                            index][subCategories[
                                                                index]['path'] +
                                                            'isChecked'] = true;
                                                        subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'totalNo'] = int
                                                            .parse(val);
                                                      } else {
                                                        subCategories[
                                                            index][subCategories[
                                                                index]['path'] +
                                                            'isChecked'] = false;
                                                        subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'totalNo'] = 0;
                                                      }
                                                    });
                                                  },
                                            // cursorColor: Colors.green[800],
                                          )),

                                      SizedBox(
                                        width: _buttonWidth,
                                        height: _buttonWidth,
                                        child: FlatButton(
                                          padding: EdgeInsets.all(0),
                                          onPressed: (noAnimalsCheck ||
                                                  onLoading ||
                                                  loadingButtonForSkipClick)
                                              ? null
                                              : () {
                                                  setState(() {
                                                    if (subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'totalNo'] <=
                                                        9999) {
                                                      setState(() {
                                                        subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'totalNo']++;
                                                      });
                                                    }

                                                    if (subCategories[index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'totalNo'] >
                                                            0 &&
                                                        subCategories[index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'totalNo'] <
                                                            9999) {
                                                      setState(() {
                                                        subCategories[
                                                            index][subCategories[
                                                                index]['path'] +
                                                            'isChecked'] = true;
                                                        subCategories[index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'controller']
                                                            .text = subCategories[
                                                                    index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'totalNo']
                                                            .toString();
                                                        subCategories[index][
                                                                subCategories[
                                                                            index]
                                                                        [
                                                                        'path'] +
                                                                    'focusNode']
                                                            .unfocus();
                                                      });
                                                    }
                                                    subCategories[index][
                                                            subCategories[index]
                                                                    ['path'] +
                                                                'formKey']
                                                        .currentState
                                                        ?.validate();
                                                  });
                                                },
                                          child: Icon(
                                            Icons.add_circle,
                                            size: 20,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )))
                          : Expanded(child: Container()),
                    ]),

                    (subCategories[index]
                                [subCategories[index]['path'] + 'isChecked'] &&
                            getSubCategoriesInfo(subCategories[index]['path'])
                                    .length >
                                0)
                        ? getSubCategoriesWidgets(
                            subCategories[index]
                                [subCategories[index]['path'] + 'isChecked'],
                            getSubCategoriesInfo(subCategories[index]['path']),
                            false)
                        : Container()
                  ]));
                }))
        : Container();
    if (value is Widget) {
      return value;
    } else {
      return null;
    }
  }

  Map getObjectFromJson(String val) {
    List splittedData = val.split('|');
    Map returnObj = farmDetailsObj;
    splittedData.forEach((value) {
      returnObj = returnObj[value];
    });
    return returnObj;
  }

  bool findCurrentElement(value) {
    bool isElement = false;
    subCategories.forEach((val) {
      if (val['path'] == value) {
        isElement = true;
      }
    });
    categories.forEach((val) {
      if (val['path'] == value) {
        isElement = true;
      }
    });
    return isElement;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // resizeToAvoidBottomPadding: false,
      appBar: plainAppBarWidget,
      // resizeToAvoidBottomPadding: false,
      // resizeToAvoidBottomPadding: false,
      // resizeToAvoidBottomInset: false,
      body: !onFarmDetailsLoading
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
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Container(
                        child: Form(
                            // padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
                            // constraints: BoxConstraints(minHeight: 100),
                            child: Column(children: <Widget>[
                      !loadingButtonForSkipClick
                          ? Container(
                              alignment: Alignment(1, 1),
                              padding: EdgeInsets.only(top: 3, right: 6),

                              // margin: EdgeInsets.fromLTRB(100, 0, 100, 0),
                              child: InkWell(
                                child: Text(
                                  'Skip',
                                  style:
                                      appFonts.getTextStyle('skip_link_style'),
                                ),
                                onTap: () {
                                  //
                                  setState(() {
                                    loadingButtonForSkipClick = true;
                                  });
                                  registerNewUser(true);
                                },
                              )
                              // child: RaisedButton(
                              //   onPressed: () {
                              //     Navigator.pushNamed(
                              //         context, '/otpvalidation');
                              //   },
                              //   child: Text(
                              //     "Skip",
                              //     // style: TextStyle(color: Colors.white),
                              //   ),
                              //   // color: mainAppColor,
                              // ),
                              )
                          : Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width - 65),
                              // height: 15,
                              // width: 15,
                              // child: Align(
                              //     alignment: Alignment(1, 1),
                              // child: InkWell(

                              child: loadingButtonForLinks()),
                      // ),
                      // ),
                      Row(children: <Widget>[
                        Padding(padding: EdgeInsets.only(right: 5)),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            registrationAnimalHeaderName,
                            style: appFonts
                                .getTextStyle('farm_details_heading_style'),
                            key: animalDetailsTextkey,
                          ),
                        ),
                      ]),
                      AppStyles().customPadding(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(left: 15)),
                          Checkbox(
                            value: noAnimalsCheck,
                            // checkColor: mainAppColor,
                            activeColor: mainAppColor,
                            onChanged: (onLoading || loadingButtonForSkipClick)
                                ? null
                                : (bool val) {
                                    setState(() {
                                      noAnimalsCheck = val;

                                      if (noAnimalsCheck) {
                                        // cowsCheck = false;
                                        // buffaloCheck = false;
                                        // numberOfCowsController.text = "0";
                                        // numberOfBuffaloController.text =
                                        //     "0";
                                        // numberOfCows = 0;
                                        // numberOfBuffalos = 0;
                                        // setSubCategoriesBooleans('path');
                                        if (categories.length > 0) {
                                          categories.forEach((val) {
                                            if (val[
                                                val['path'] + 'isChecked']) {
                                              setSubCategoriesBooleans(
                                                  val['path']);
                                              setState(() {
                                                val[val['path'] + 'isChecked'] =
                                                    false;
                                              });
                                            }
                                          });
                                        }
                                        // cowsCheck = null;
                                        // numberOfCowsController.dispose();
                                      }
                                      //       if (!subCategories[index][subCategories[index]
                                      //         ['path'] +
                                      //     'isChecked']) {
                                      //   setSubCategoriesBooleans(
                                      //       subCategories[index]['path']);
                                      // }
                                    });
                                    // re;
                                  },
                          ),
                          AppStyles().customPadding(6),
                          Text(noAnimalsLabelName,
                              style: appFonts.getTextStyle(
                                  'farm_details_noanimals_check_style'))
                        ],
                      ),
                      // Padding(padding: EdgeInsets.only(left: 10)),
                      // Column(
                      //   children: intialCheckBoxes,
                      // ),
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                      ),
                      intializeCheckBoxes(),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            !onLoading
                                ? Container(
                                    // margin: EdgeInsets.only(left: 20),
                                    child: RaisedButton(
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(0.0)),
                                      onPressed: () {
                                        // closeNotifications();
                                        clearErrorMessages(scaffoldKey);
                                        setState(() {
                                          // closeNotifications();

                                          dynamic isValue = GlobalValidations()
                                              .animalDetailsValidations(
                                                  subCategories);
                                          if (!noAnimalsCheck &&
                                              isValue != null) {
                                            showErrorNotifications(
                                                isValue, context, scaffoldKey);
                                          } else {
                                            onLoading = true;
                                            registerNewUser(false);
                                            // Navigator.pushNamed(
                                            //     context, '/otpvalidation');
                                          }
                                        });
                                      },
                                      child: Text(
                                        "Continue",
                                        style: appFonts.getTextStyle(
                                            'button_text_color_white'),
                                      ),
                                      color: mainAppColor,
                                    ),
                                  )
                                : loadingButtonWidget(context)
                          ]),
                    ]))),
                  )))
          : Center(child: circularLoadingIcon()),
    );
  }
}
