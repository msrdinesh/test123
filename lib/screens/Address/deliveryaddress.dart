import 'dart:convert';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/services/subscriptionservice/subscriptionservice.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/constants/successmessages.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'dart:async';

class AddressPage extends StatefulWidget {
  @override
  AddressDetails createState() => AddressDetails();
}

class AddressDetails extends State<AddressPage> {
  List addressList = [];
  bool isAddressLoading = false;

  int selectedRadio;
  int select;
  final AddressServices addressServices = AddressServices();
  final ApiErros apiErros = ApiErros();
  final infoIcon = GlobalKey();
  int limit = 15;
  int pageNo = 1;
  final ScrollController scrollController = ScrollController();
  final SubcriptionService subcriptionService = SubcriptionService();
  final ErrorMessages errorMessages = ErrorMessages();
  final SuccessMessages successMessages = SuccessMessages();
  bool isMoreAddressListLoading = false;
  int totalNumberOfAddresses = 0;
  final GlobalKey<ScaffoldState> scafFoldKey = GlobalKey<ScaffoldState>();
  final AppFonts appFonts = AppFonts();
  Timer timer;
  @override
  void initState() {
    selectedRadio = 0;
    getAddress(false);
    checkAndDisplayAddressMessages();
    super.initState();
    select = 0;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  setSelectedUser(int user) {
    setState(() {
      selectedRadio = user;
    });
  }

  checkAndDisplayAddressMessages() {
    timer = Timer(Duration(milliseconds: 200), () {
      if (isAddressEdited) {
        showSuccessNotifications(
            successMessages.addressUpdatedSuccessfully, context, scafFoldKey);
        setState(() {
          isAddressEdited = false;
        });
      } else if (isNewAddressCreated) {
        showSuccessNotifications(
            successMessages.addressAddedMessages, context, scafFoldKey);
        setState(() {
          isNewAddressCreated = false;
        });
      }
    });
  }

  //navigation to ordersummery page.
  navigateToOrderSummary() {
    selectedDeliveryAddress = addressList[selectedRadio];
    if (isNavigatingFromDelivarypage) {
      Navigator.pop(context);
    }
    isNavigatingFromDelivarypage = false;
    // isRepeatOrder = false;

    Navigator.pushNamed(context, "/ordersummary");
  }

  displayLoadingIcon(context) {
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

  displayInformation(context, String message) {
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
                  child: Container(
                      height: 150,
                      //  MediaQuery.of(context).size.height / 3.8,
                      child: Card(
                        // margin: EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: 40,
                                // color: Colors.red[800],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    // Pad ding(padding: EdgeInsets.only(top: 5)),
                                    Text(
                                      " Information",
                                      style: appFonts.getTextStyle(
                                          'delivery_address_delete_info_popup_heading_style'),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.close,
                                            size: 35,
                                          ),
                                        ))
                                  ],
                                )),
                            Padding(padding: EdgeInsets.only(top: 5)),
                            Center(
                              child: Container(
                                  color: Colors.white,
                                  child: Row(children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 40,
                                        color: mainAppColor,
                                      ),
                                    ),
                                    Flexible(
                                      // margin: EdgeInsets.only(
                                      //     bottom: 5, right: 10, left: 10, top: 5),
                                      child: Text(
                                        message,
                                        style: appFonts.getTextStyle(
                                            'delivery_address_delete_info_popup_content_style'),
                                        softWrap: true,
                                      ),
                                    )
                                  ])),
                            )
                          ],
                        ),
                      ))));
        });
  }

  // updating Order address details
  updateOrderAddressDetails() {
    Map requestObj = {
      'orderId': editAddressDetails['orderId'],
      'addressId': addressList[selectedRadio]['addressId']
    };
    displayLoadingIcon(context);
    addressServices.updateOrderAddressDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      print(data);
      Navigator.pop(context);
      if (data['status'] != null && data['status'] == "AVAILABLE") {
        isAddressEditing = false;
        Navigator.popAndPushNamed(context, '/yourorders');
      } else if (data['status'] != null &&
          data['status'] == "PINCODENOTAVAILABLE") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications(data['message'], context, scafFoldKey);
      } else if (data['status'] != null &&
          data['status'] == "STOCKNOTAVAILABLE") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications(data['message'], context, scafFoldKey);
      } else if (data['status'] != null && data['status'] == "FAILED") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications("Failed to update the Address. Please try again",
            context, scafFoldKey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            updateOrderAddressDetails();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldKey);
      }
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/deliveryaddress', scafFoldKey);
    });
  }

  // updating subscription address
  updateSubscriptionAddressdetails() {
    Map requestObj = {
      'subscriptionId': changeSubscriptionAddress['subscriptionId'],
      'addressId': addressList[selectedRadio]['addressId']
    };
    displayLoadingIcon(context);
    subcriptionService.updateSubscriptionAddress(requestObj).then((val) {
      final data = json.decode(val.body);
      Navigator.pop(context);
      if (data['status'] != null && data['status'] == "AVAILABLE") {
        isSubscriptionAddressEditing = false;
        changeSubscriptionAddress = {};
        Navigator.popAndPushNamed(context, '/subcriptionlist');
      } else if (data['status'] != null &&
          data['status'] == "PINCODENOTAVAILABLE") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications(data['message'], context, scafFoldKey);
      } else if (data['status'] != null &&
          data['status'] == "STOCKNOTAVAILABLE") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications(data['message'], context, scafFoldKey);
      } else if (data['status'] != null && data['status'] == "FAILED") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications("Failed to update the Address. Please try again",
            context, scafFoldKey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            updateSubscriptionAddressdetails();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldKey);
      }
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/deliveryaddress', scafFoldKey);
    });
  }

  checkStackPointAvailability() {
    displayLoadingIcon(context);
    addressServices
        .checkPinCodeAvailabilityForCartProducts(
            addressList[selectedRadio]['addressId'].toString())
        .then((val) {
      final data = json.decode(val.body);
      Navigator.pop(context);
      print(data);
      if (data['status'] != null && data['status'] == "AVAILABLE") {
        // if (isAddressEditing) {
        //   updateOrderAddressDetails();
        // } else if (isSubscriptionAddressEditing) {
        //   updateSubscriptionAddressdetails();
        // } else {
        navigateToOrderSummary();
        // }
      } else if (data['status'] != null &&
          data['status'] == "STOCKNOTAVAILABLE") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications(data['message'], context, scafFoldKey);
      } else if (data['status'] != null &&
          data['status'] == "PINCODENOTAVAILABLE") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications(data['message'], context, scafFoldKey);
      } else if (data['status'] != null && data['status'] == "CARTEMPTY") {
        clearErrorMessages(scafFoldKey);
        showErrorNotifications(
            "Please add some products in cart", context, scafFoldKey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            updateOrderAddressDetails();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldKey);
      }
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/deliveryaddress', scafFoldKey);
    });
  }

  getAddress(bool isMoreDataLoading) {
    Map obj = {"limit": limit, "pageNumber": pageNo};
    if (!isMoreDataLoading) {
      setState(() {
        isAddressLoading = true;
      });
    } else {
      setState(() {
        isMoreAddressListLoading = true;
      });
    }
    AddressServices().getAddressDetails(obj).then((res) {
      final addressData = json.decode(res.body);

      print('address');
      print(addressData);

      if (addressData['addressList'] != null &&
          addressData['addressList'].length > 0) {
        setState(() {
          if (!isMoreDataLoading) {
            addressList = addressData['addressList'];
          } else {
            addressData['addressList'].forEach((val) {
              addressList.add(val);
            });
          }
          setState(() {});
          // print(changeSubscriptionAddress['addressId']);
          // print(selectedDeliveryAddress["addressId"]);
          if (isAddressEditing ||
              isSubscriptionAddressEditing ||
              isRepeatOrder ||
              isRepeatPreviousOrder ||
              selectedDeliveryAddress["addressId"] != null) {
            if (isAddressEditing) {
              selectedRadio = addressList.indexWhere(
                  (val) => val['addressId'] == editAddressDetails['addressId']);
            } else if (isRepeatOrder && repeatOrderAddressId > 0) {
              selectedRadio = addressList.indexWhere(
                  (val) => val['addressId'] == repeatOrderAddressId);
            } else if (selectedDeliveryAddress["addressId"] != null) {
              selectedRadio = addressList.indexWhere((val) =>
                  val['addressId'] == selectedDeliveryAddress["addressId"]);
            } else if (isRepeatPreviousOrder &&
                repeatPreviousOrderAddressId > 0) {
              selectedRadio = addressList.indexWhere(
                  (val) => val['addressId'] == repeatPreviousOrderAddressId);
            } else {
              print(addressList.indexWhere((val) =>
                  val['addressId'] == changeSubscriptionAddress['addressId']));
              selectedRadio = addressList.indexWhere((val) =>
                  val['addressId'] == changeSubscriptionAddress['addressId']);
            }
          }
          totalNumberOfAddresses = addressData['count'];
          print(addressData['count']);
          print(addressList.length);
          scrollController
            ..addListener(() {
              if (totalNumberOfAddresses > addressList.length &&
                  !isMoreAddressListLoading &&
                  scrollController.position.pixels ==
                      scrollController.position.maxScrollExtent) {
                // print('data');
                pageNo = pageNo + 1;
                getAddress(true);
              }
            });
          // print(addressList[0]['communicationAddress']);
        });
      } else if (addressData['error'] != null &&
          addressData['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final data = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(data, context, setState)) {
            getAddress(false);
          }
        });
      } else if (addressData['error'] != null) {
        apiErros.apiLoggedErrors(addressData, context, scafFoldKey);
      }
      setState(() {
        isAddressLoading = false;
        isMoreAddressListLoading = false;
      });
      // print(addressList);
      // print(addressList[0]['city']);
      // print(addressList.length);
    }, onError: (err) {
      setState(() {
        isAddressLoading = false;
      });
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/deliveryaddress', scafFoldKey);
    });
  }

  deleteUserAddress(index) {
    // print('index value');
    // print(index);
    Map obj = {"addressId": index};
    displayLoadingIcon(context);
    AddressServices().getDeleteAddress(obj).then((res) {
      final deletedata = json.decode(res.body);
      // print('deleteresponse');
      // print(deletedata);
      // setState(() {
      // Navigator.popAndPushNamed(context, '/deliveryaddress');
      // });
      Navigator.pop(context);
      if (deletedata == "SUCCESS") {
        setState(() {
          pageNo = 1;
          addressList = [];
        });
        getAddress(false);
        showSuccessNotifications(
            successMessages.addressDeleteSuccessmessage, context, scafFoldKey);
      } else if (deletedata == "SUBSCRIBED") {
        displayInformation(
            context, errorMessages.addressLinkedWithSubscriptionsError);
      } else if (deletedata == "FAILED") {
      } else if (deletedata['error'] != null &&
          deletedata['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final data = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(data, context, setState)) {
            updateOrderAddressDetails();
          }
        });
      } else if (deletedata['error'] != null) {
        apiErros.apiLoggedErrors(deletedata, context, scafFoldKey);
      }
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/deliveryaddress', scafFoldKey);
    });
  }

  Widget createRadioListUsers() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: addressList.length,
      // physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      // itemCount: parseDetails(userDetails).length,
      itemBuilder: (context, index) {
        String addressData = addressList[index]['city'].toString() +
            ', ' +
            addressList[index]['state'].toString() +
            ", \n" +
            addressList[index]['pincode'].toString() +
            " \n" +
            'Mobile Number: ' +
            addressList[index]['mobileNo'].toString();
        if (addressList[index]['street'] != null) {
          addressData = addressList[index]['street'] + ", \n" + addressData;
        }
        if (addressList[index]['doorNumber'] != null) {
          addressData = addressList[index]['doorNumber'] + ", " + addressData;
        }
        return Column(children: [
          Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              Padding(
                padding: EdgeInsets.all(3.0),
              ),
              Expanded(
                  flex: 1,
                  child: Radio(
                    activeColor: mainAppColor,
                    value: index,
                    groupValue: selectedRadio,
                    onChanged: (val) {
                      setSelectedUser(val);
                    },
                  )),
              Expanded(
                  flex: 7,
                  child: ListTile(
                      // title: Text(parseDetails(userDetails)[index].id.toString()),
                      subtitle: Row(children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                          ),
                          Text(
                            addressData,
                            style: appFonts.getTextStyle(
                                'delivery_address_address_info_content_style'),
                          ),

                          // Padding(
                          //   padding: EdgeInsets.only(left: 1.0),
                          // ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 3.0),
                    // ),

                    Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            // print('present address');
                            setState(() {
                              addressDetailsObject = addressList[index];
                              Navigator.popAndPushNamed(
                                  context, '/editaddress');
                            });
                            // print(addressDetailsObject);

                            // editAddressDetails();
                          },
                        )),
                    !addressList[index]['communicationAddress']
                        ? Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.grey[700],
                                ),
                                onPressed: () {
                                  setState(() {
                                    deleteUserAddress(
                                        addressList[index]['addressId']);
                                  });
                                }))
                        : Expanded(
                            flex: 1,
                            child: IconButton(
                                // tooltip: "This is A message",
                                // key: infoIcon,
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.grey[700],
                                  size: 25,
                                ),
                                onPressed: () {
                                  displayInformation(context,
                                      "This cannot be deleted as this is primary address.");
                                  // setState(() {
                                  //   deleteUserAddress(
                                  //       addressList[index]['addressId']);
                                  // });
                                }),
                          ),

                    //   ],
                  ]))),
            ],
          ),
          Divider(thickness: 1)
        ]);

        // Padding(
        //   padding: EdgeInsets.only(left: 3.0),
        // ),
      },
      // )
    );

    // }
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (!isDeliveryAddress &&
              !isAddressEditing &&
              !isNavigatingFromDelivarypage &&
              !isSubscriptionAddressEditing &&
              !isRepeatOrder &&
              !isRepeatPreviousOrder) {
            Navigator.popAndPushNamed(context, '/cart');
            return Future.value(false);
          } else if (isAddressEditing) {
            isAddressEditing = false;
            editAddressDetails = {};
            Navigator.popAndPushNamed(context, '/yourorders');
            return Future.value(false);
          } else if (isSubscriptionAddressEditing) {
            isSubscriptionAddressEditing = false;
            changeSubscriptionAddress = {};
            Navigator.popAndPushNamed(context, '/subcriptionlist');
            return Future.value(false);
          } else if (isNavigatingFromDelivarypage) {
            isNavigatingFromDelivarypage = false;
            Navigator.popAndPushNamed(context, '/ordersummary');

            return Future.value(false);
          } else if (isRepeatOrder) {
            isRepeatOrder = false;
            repeatOrderAddressId = 0;
            Navigator.popAndPushNamed(context, '/yourorders');
            return Future.value(false);
          } else if (isRepeatPreviousOrder) {
            isRepeatPreviousOrder = false;
            repeatPreviousOrderAddressId = 0;
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', ModalRoute.withName('/home'));
            return Future.value(false);
          }
          isDeliveryAddress = false;
          return Future.value(true);
        },
        child: Scaffold(
            key: scafFoldKey,
            appBar: plainAppBarWidget,
            body: !isAddressLoading
                ? Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        !isDeliveryAddress
                            ? Container(
                                // height: 45,
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Select a Delivery Address",
                                  style: appFonts.getTextStyle(
                                      'delivery_address_heading_style'),
                                ),
                              )
                            : Container(
                                // height: 45,
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Delivery Address",
                                  style: appFonts.getTextStyle(
                                      'delivery_address_heading_style'),
                                ),
                              ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.all(2.0),
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                                controller: scrollController,
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(children: [
                                  createRadioListUsers(),
                                  isMoreAddressListLoading
                                      ? Container(
                                          alignment: Alignment.center,
                                          child: Center(
                                            child:
                                                customizedCircularLoadingIcon(
                                                    25),
                                          ),
                                        )
                                      : Container(),
                                  !isDeliveryAddress && addressList.length > 0
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          //crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                              Align(
                                                // alignment: Alignment.bottomCenter,
                                                child: RaisedButton(
                                                  // shape: new oundedRectangleBorder(
                                                  //     borderRadius: new BorderRadius.circular(20.0)),
                                                  padding: EdgeInsets.only(
                                                      left: 35, right: 35),
                                                  color: mainYellowColor,
                                                  child: Text(
                                                    "Add New Address",
                                                    style: appFonts.getTextStyle(
                                                        'button_text_color_black'),
                                                  ),
                                                  onPressed: () {
                                                    Navigator
                                                        .pushReplacementNamed(
                                                            context,
                                                            "/newaddress");

                                                    // Navigator.pushNamed(context, '/newaddress');
                                                  },
                                                ),
                                              )
                                            ])
                                      : Container(),
                                ]))),
                        // Padding(
                        //   padding: EdgeInsets.only(top: 40.0),
                        // ),
                      ],
                    )))
                : Center(
                    child: circularLoadingIcon(),
                  ),
            bottomNavigationBar: !isAddressLoading &&
                    !isDeliveryAddress &&
                    addressList.length > 0
                ? Container(
                    height: 50,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Padding(
                          //         padding: EdgeInsets.only(right: 0),
                          //       )
                          //     : Container(),
                          RaisedButton(
                            // shape: new RoundedRectangleBorder(
                            //     borderRadius:
                            //         new BorderRadius.circular(20.0)),
                            color: mainAppColor,
                            child: Text(
                              " Deliver To This Address ",
                              style: appFonts
                                  .getTextStyle('button_text_color_white'),
                            ),
                            onPressed: () {
                              if (isAddressEditing) {
                                updateOrderAddressDetails();
                              } else if (isSubscriptionAddressEditing) {
                                updateSubscriptionAddressdetails();
                              } else {
                                checkStackPointAvailability();
                              }
                              // getAddress();
                            },
                          )
                        ]))
                : !isAddressLoading && addressList.length > 0
                    ? Container(
                        height: 50,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Align(
                                // alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  // shape: new oundedRectangleBorder(
                                  //     borderRadius: new BorderRadius.circular(20.0)),
                                  // padding: EdgeInsets.only(left: 30, right: 30),
                                  color: mainAppColor,
                                  child: Text(
                                    "Add New Address",
                                    style: appFonts.getTextStyle(
                                        'button_text_color_white'),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, "/newaddress");

                                    // Navigator.pushNamed(context, '/newaddress');
                                  },
                                ),
                              )
                            ]))
                    : Container(
                        height: 50,
                      )));
  }
}
