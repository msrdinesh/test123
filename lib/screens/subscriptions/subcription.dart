import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/services/subscriptionservice/subscriptionservice.dart';
// import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
// import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:cornext_mobile/services/subscriptionservice/subscriptionservice.dart';
import 'package:intl/intl.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  SubscriptionDetails createState() => SubscriptionDetails();
}

class SubscriptionDetails extends State<SubscriptionPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String currentUnitType;
  Map orderDetails = {};
  List orderedProductList = [];
  Map subscriptionData = {};
  Map updateSubscription = {};
  bool onLoading = false;
  List subscriptionUnits = [];
  final currencyFormatter = NumberFormat('#,##,###.00');
  var subscriptionController = TextEditingController();
  final subscriptionKey = GlobalKey<FormFieldState>();
  FocusNode subscriptionFocus = FocusNode();
  List<String> subscriptionTimeRelatedData = ['Days', "Weeks", 'Months'];
  String dropdownValue = "Days";
  final ApiErros apiErros = ApiErros();
  double totalAmount = 0.0;
  final AppFonts appFonts = AppFonts();

  void initState() {
    setState(() {
      getSubscriptions();
      validateSubscriptionFieldValidOrNot();
    });
    super.initState();
  }

  validateSubscriptionFieldValidOrNot() {
    GlobalValidations()
        .validateCurrentFieldValidOrNot(subscriptionFocus, subscriptionKey);
  }

  getSubscriptions() {
    // Map obj = {"limit": 2, "pageNumber": 1};
    setState(() {
      onLoading = true;
    });
    SubcriptionService().getSubscriptionUnits().then((res) {
      final data = json.decode(res.body);
      if (data != null && data.length > 0) {
        setState(() {
          subscriptionUnits = data;
          if (editSubcriptions) {
            // getOrderDetails();
            getEditSubscriptions();
          } else if (subscriptionsData['deliveryEvery'] != null) {
            subscriptionController.text =
                subscriptionsData['deliveryEvery'].toString();
            currentUnitType = subscriptionsData['units'].toString();
            setState(() {
              onLoading = false;
            });
          } else {
            currentUnitType = subscriptionUnits[0];
            setState(() {
              onLoading = false;
            });
          }
        });
      } else {
        setState(() {
          onLoading = false;
        });
      }
    }, onError: (err) {
      setState(() {
        onLoading = false;
      });
      apiErros.apiErrorNotifications(
          err, context, '/subscription', scaffoldKey);
    });
  }

  getEditSubscriptions() {
    subscriptionDetails['screenName'] = 'HS';
    SubcriptionService().getEditSubscriptionDetails(subscriptionDetails).then(
        (res) {
      final data = json.decode(res.body);
      if (data != null && data['subscription'] != null) {
        setState(() {
          // editOrderSubscriptionDetailsObject = data;
          orderedProductList = data['productList'];

          subscriptionData = data['subscription'];
          subscriptionController.text =
              subscriptionData['deliverEvery'].toString();
          currentUnitType = subscriptionData['units'].toString();
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getEditSubscriptions();
          }
        });
      }

      setState(() {
        onLoading = false;
      });
    }, onError: (err) {
      setState(() {
        onLoading = false;
      });
      apiErros.apiErrorNotifications(
          err, context, '/subscription', scaffoldKey);
    });
  }

  updateSubscriptionDetails(obj) {
    // print(obj);
    displayLoadingIcon(context);
    SubcriptionService().getUpadateOrderSubscriptionDetails(obj).then((res) {
      final updateSubscriptiondata = json.decode(res.body);
      // print('res update');

      // print(updateSubscriptiondata);
      Navigator.pop(context);
      if (updateSubscriptiondata == "SUCCESS") {
        if (isEditButtonClickedOnOrderDetails) {
          isEditButtonClickedOnOrderDetails = false;
          Navigator.popAndPushNamed(context, '/yourorderdetails');
        } else {
          Navigator.popAndPushNamed(context, '/subcriptionlist');
        }
      } else if (updateSubscriptiondata == "FAILED") {
      } else if (updateSubscriptiondata['error'] != null &&
          updateSubscriptiondata['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            updateSubscriptionDetails(obj);
          }
        });
      } else if (updateSubscriptiondata['error'] != null) {
        apiErros.apiLoggedErrors(updateSubscriptiondata, context, scaffoldKey);
      }
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/subscription', scaffoldKey);
    });
  }

  deleteSubscription(int val) {
    print(val);
    displayLoadingIcon(context);
    SubcriptionService().deleteOrderSubscription(val).then((res) {
      final deleteSubscriptionData = json.decode(res.body);
      Navigator.pop(context);
      if (deleteSubscriptionData == 'SUCCESS') {
        if (isEditButtonClickedOnOrderDetails) {
          isEditButtonClickedOnOrderDetails = false;
          Navigator.popAndPushNamed(context, '/yourorderdetails');
        } else {
          Navigator.popAndPushNamed(context, '/subcriptionlist');
        }
      } else if (deleteSubscriptionData == 'FAILED') {
      } else if (deleteSubscriptionData['error'] != null &&
          deleteSubscriptionData['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            deleteSubscription(val);
          }
        });
      } else if (deleteSubscriptionData['error'] != null) {
        apiErros.apiLoggedErrors(deleteSubscriptionData, context, scaffoldKey);
      }
      // print('delete');
      print(deleteSubscriptionData);
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/subscription', scaffoldKey);
    });
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

  displayCancleSubscriptionMessage(context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: AlertDialog(
                // backgroundColor: Colors.transparent,
                // elevation: 100,
                content: Container(
                  height: 60,
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(
                              top: 10, left: 10, right: 10, bottom: 5),
                          child: Text(
                            "Do you really want to cancle this subscription?",
                            style: appFonts.getTextStyle(
                                'edit_subscription_cancle_popup_heading_style'),
                          )),
                    ],
                  ),
                ),
                actions: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      print(subscriptionData);
                      deleteSubscription(subscriptionData['subscriptionId']);
                    },
                    child: Text("Yes"),
                  ),
                  Padding(padding: EdgeInsets.only(right: 10))
                ],
              ));
        });
  }

  // getOrderDetails() {
  //   rootBundle.loadString('assets/json/orderconfirmation.json').then((val) {
  //     final data = json.decode(val);
  //     setState(() {
  //       orderDetails = data;
  //       orderedProductList = data['products'];
  //     });
  //     // print(data);
  //   });
  // }

  String getDiscountedPrice(productInfo, double productPrice) {
    // if(productInfo[''])
    final currencyFormatter = NumberFormat('#,##,###.00');
    final double discountedValue = productPrice *
        int.parse(
            productInfo['productDiscount'].toString().replaceAll('%', '')) /
        100;
    final double discountedPrice = productPrice - discountedValue;
    String productValue = '';
    if (productInfo['appliedAgainst'] != null) {
      productValue = productInfo['currencyRepresentation'] +
          currencyFormatter.format(discountedPrice).toString() +
          " " +
          productInfo['appliedAgainst'];
    } else {
      productValue = productInfo['currencyRepresentation'] +
          currencyFormatter.format(discountedPrice).toString();
    }
    return productValue;
  }

  getSavedAmount(productInfo, double productPrice) {
    final currencyFormatter = NumberFormat('#,##,###.00');
    final double discountedValue = productPrice *
        int.parse(
            productInfo['productDiscount'].toString().replaceAll('%', '')) /
        100;
    String savedValue = '';
    if (productInfo['appliedAgainst'] != null) {
      savedValue = productInfo['currencyRepresentation'].toString() +
          currencyFormatter.format(discountedValue) +
          " " +
          productInfo['appliedAgainst'];
    } else {
      savedValue = productInfo['currencyRepresentation'].toString() +
          currencyFormatter.format(discountedValue).toString();
    }
    return savedValue;
  }

  List<Widget> getOrderedProducts() {
    setState(() {
      totalAmount = 0.0;
    });
    return orderedProductList.map((res) {
      // print(res);
      double priceOfCurrentProduct = 0.0;
      if (res['taxpercent'] != null) {
        final double taxValue = res['value'] *
            int.parse(res['taxpercent'].toString().replaceAll('%', '')) /
            100;
        setState(() {
          priceOfCurrentProduct = res['value'] + taxValue;
        });
        // print(priceOfCurrentProduct);
      } else {
        setState(() {
          priceOfCurrentProduct = res['value'];
        });
      }

      if (res['units'] == null) {
        if (res['minimumQuantity'] != null && res['productDiscount'] != null) {
          if (res['quantity'] >= res['minimumQuantity']) {
            priceOfCurrentProduct = priceOfCurrentProduct -
                (priceOfCurrentProduct) *
                    int.parse(
                        res['productDiscount'].toString().replaceAll('%', '')) /
                    100;
          }
        }
        setState(() {
          totalAmount = totalAmount + (priceOfCurrentProduct * res['quantity']);
        });
      } else {
        if (res['units'] == "Metric Ton") {
          if (res['minimumQuantity'] != null &&
              res['productDiscount'] != null) {
            if (res['quantity'] * 1000 >= res['minimumQuantity']) {
              priceOfCurrentProduct = priceOfCurrentProduct -
                  (priceOfCurrentProduct) *
                      int.parse(res['productDiscount']
                          .toString()
                          .replaceAll('%', '')) /
                      100;
            }
          }
          setState(() {
            totalAmount =
                totalAmount + (priceOfCurrentProduct * res['quantity'] * 1000);
          });
        } else {
          if (res['minimumQuantity'] != null &&
              res['productDiscount'] != null) {
            if (res['quantity'] >= res['minimumQuantity']) {
              priceOfCurrentProduct = priceOfCurrentProduct -
                  (priceOfCurrentProduct) *
                      int.parse(res['productDiscount']
                          .toString()
                          .replaceAll('%', '')) /
                      100;
            }
          }
          setState(() {
            totalAmount =
                totalAmount + (priceOfCurrentProduct * res['quantity']);
          });
        }
      }
      final String imageUrl = res['resourceUrl'];
      return Container(
          width: MediaQuery.of(context).size.width - 20,
          child: GestureDetector(
              child: Card(
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      Container(
                          child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            bottomLeft: Radius.circular(5)),
                        // child: Image(
                        //   image: NetworkImage(res['resourceUrl']),
                        //   height: 120,
                        //   width: 120,
                        //   fit: BoxFit.fill,
                        // )),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: MediaQuery.of(context).size.height /
                              (MediaQuery.of(context).size.aspectRatio * 12),
                          width: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.aspectRatio * 6.5),
                          fit: BoxFit.fill,
                          placeholder: (context, imageUrl) =>
                              customizedCircularLoadingIcon(15),
                        ),
                      )),
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 5),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width /
                                        (MediaQuery.of(context)
                                                .size
                                                .aspectRatio *
                                            6.5) -
                                    35,
                                child: RichText(
                                  // textAlign: TextAlign.center,
                                  softWrap: true,
                                  text: TextSpan(
                                      style: appFonts.getTextStyle(
                                          'cart_screen_product_name_default_style'),
                                      children: [
                                        res['brandName'] != null
                                            ? TextSpan(
                                                text: res['brandName'] + " ",
                                                style: appFonts.getTextStyle(
                                                    'cart_screen_brandname_style'))
                                            : TextSpan(),
                                        TextSpan(
                                            text: res['productName'],
                                            style: TextStyle(
                                              color: mainAppColor,
                                            )),
                                        res['specificationName'] != null
                                            ? TextSpan(
                                                text: " (" +
                                                    res['specificationName'] +
                                                    ")",
                                                style: appFonts.getTextStyle(
                                                    'cart_screen_specification_&_type_names_styles'))
                                            : TextSpan(),
                                        res['productTypeName'] != null
                                            ? TextSpan(
                                                text: ", " +
                                                    res['productTypeName'],
                                                style: appFonts.getTextStyle(
                                                    'cart_screen_specification_&_type_names_styles'))
                                            : TextSpan()
                                      ]),
                                )

                                // Text(
                                //   res['productName'],
                                //   softWrap: true,
                                //   style: TextStyle(
                                //       fontSize: 16,
                                //       fontWeight: FontWeight.bold,
                                //       color: mainAppColor),
                                // ),
                                ),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                child: res['appliedAgainst'] != null
                                    ? res['currencyRepresentation'] != null
                                        ? Text(
                                            res['currencyRepresentation'] +
                                                currencyFormatter.format(
                                                    priceOfCurrentProduct) +
                                                " " +
                                                res['appliedAgainst'],
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )
                                        : Text(
                                            currencyFormatter.format(
                                                    priceOfCurrentProduct) +
                                                " " +
                                                res['appliedAgainst'],
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )
                                    : res['currencyRepresentation'] != null
                                        ? Text(
                                            res['currencyRepresentation'] +
                                                currencyFormatter.format(
                                                    priceOfCurrentProduct),
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )
                                        : Text(
                                            currencyFormatter
                                                .format(priceOfCurrentProduct),
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )),
                            res['quantity'] != null
                                ? Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: RichText(
                                      text: TextSpan(
                                          style: appFonts.getTextStyle(
                                              'text_color_black_with_font_family'),
                                          children: [
                                            TextSpan(
                                                text: "Quantity : ",
                                                style: appFonts.getTextStyle(
                                                    'quantity_field_heading_text_style')),
                                            TextSpan(
                                                text:
                                                    res['quantity'].toString(),
                                                style: appFonts.getTextStyle(
                                                    'quantity_value_text_style')),
                                            res['quantityRepresentation'] !=
                                                    null
                                                ? TextSpan(
                                                    text: " " +
                                                        res[
                                                            'quantityRepresentation'],
                                                    style: appFonts.getTextStyle(
                                                        'quantity_value_text_style'))
                                                : TextSpan()
                                          ]),
                                    ),
                                  )
                                : Container()
                          ])
                    ],
                  ))));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String deliveryAddress = "";
    if (orderDetails['deliveryaddress'] != null) {
      deliveryAddress = orderDetails['deliveryaddress']['city'] +
          ", " +
          orderDetails['deliveryaddress']['state'] +
          ", " +
          orderDetails['deliveryaddress']['pincode'];
      if (orderDetails['deliveryaddress']['street'] != null) {
        deliveryAddress =
            orderDetails['deliveryaddress']['street'] + ", " + deliveryAddress;
      }
      if (orderDetails['deliveryaddress']['doorNumber'] != null) {
        deliveryAddress = orderDetails['deliveryaddress']['doorNumber'] +
            ", " +
            deliveryAddress;
      }
    }
    return WillPopScope(
        onWillPop: () {
          if (editSubcriptions && isEditButtonClickedOnOrderDetails) {
            editSubcriptions = false;
            isEditButtonClickedOnOrderDetails = false;
            Navigator.popAndPushNamed(context, '/yourorderdetails');
            return Future.value(false);
          } else if (editSubcriptions) {
            editSubcriptions = false;
            Navigator.popAndPushNamed(context, '/subcriptionlist');
            return Future.value(false);
          } else {
            Navigator.popAndPushNamed(context, '/ordersummary');
            return Future.value(false);
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          appBar: appBarWidgetWithIcons(
              context, false, this.setState, false, '/subscription'),
          // drawer: appBarDrawer(context, this.setState),
          // endDrawer: filterDrawer(
          //     this.setState, context, scafflodkey, false, searchFieldController),
          body: !onLoading
              ? Container(
                  margin: EdgeInsets.only(left: 10, right: 10, top: 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        !editSubcriptions
                            ? Container(
                                // padding: EdgeInsets.only(top: 25, bottom: 25),
                                child: Text(
                                  subcription,
                                  style: appFonts.getTextStyle(
                                      'edit_subscription_heading_style'),
                                ),
                              )
                            : Text(
                                editSubcription,
                                style: appFonts.getTextStyle(
                                    'edit_subscription_heading_style'),
                              ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              orderedProductList.length > 0 && editSubcriptions
                                  ? Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: ListView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          children: getOrderedProducts()),
                                    )
                                  : Container(),
                              // Divider(
                              //   thickness: 2,
                              // ),
                              totalAmount > 0
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 2, bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              width: 160,
                                              child: Text(
                                                "Total amount",
                                                style: appFonts.getTextStyle(
                                                    'edit_subscription_total_amount_heading_style'),
                                              )),
                                          Container(
                                            child: Text(": "),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                130 -
                                                80,
                                            child: Text(
                                              currencyFormatter
                                                  .format(totalAmount),
                                              style: appFonts.getTextStyle(
                                                  'edit_subscription_total_amount_value_style'),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey[300]),
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: EdgeInsets.all(25),
                                  width: MediaQuery.of(context).size.width - 20,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                              Container(
                                                child: Text(
                                                  "Deliver Every:  ",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                              ),
                                              Container(
                                                width: 95,
                                                child: TextFormField(
                                                  controller:
                                                      subscriptionController,
                                                  decoration: InputDecoration(
                                                      border: AppStyles()
                                                          .inputBorder,
                                                      // errorMaxLines: 3,
                                                      errorStyle:
                                                          appFonts.getTextStyle(
                                                              'hide_error_messages_for_formfields'),
                                                      // errorText: "",
                                                      isDense: true,
                                                      focusedBorder: AppStyles()
                                                          .focusedInputBorder,
                                                      // labelText: pincodeLabelName + " *",
                                                      counterText: "",
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 11)),
                                                  // cursorColor: mainAppColor,
                                                  validator: (value) =>
                                                      GlobalValidations()
                                                          .subscriptionValidations(
                                                              value.trim()),
                                                  maxLength: 4,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  focusNode: subscriptionFocus,
                                                  // autofocus: true,
                                                  key: subscriptionKey,
                                                ),
                                              ),

                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 8),
                                                // margin: EdgeInsets.only(
                                                //     left: 0,
                                                //     right: MediaQuery.of(context).size.width / 4),
                                                width: 80,
                                                // height: 40,
                                                // child: DropdownButton<String>(
                                                //   isExpanded: true,
                                                //   hint: new Text('           '),
                                                //   items: subscriptionUnits
                                                //       .map((unitType) {
                                                //     // productSelection =
                                                //     //     productDataTypes['productTypeId']
                                                //     //         .toString();

                                                //     return new DropdownMenuItem<
                                                //         String>(
                                                //       child: new Text(
                                                //         unitType,
                                                //         style: TextStyle(
                                                //             fontSize: 15.0),
                                                //       ),
                                                //       value: unitType.toString(),
                                                //       // // value: unitType['priceId'].toString(),
                                                //       // child: Text(value),
                                                //       // value: dropdownValue.toString(),
                                                //     );
                                                //   }).toList(),
                                                //   onChanged: (newVal) {
                                                //     setState(() {
                                                //       currentUnitType = newVal;
                                                //     });
                                                //   },
                                                //   value: currentUnitType,
                                                // )
                                                child: Text(currentUnitType),
                                              )
                                              //     : Container()
                                              // : Container()
                                            ])),
                                        subscriptionKey.currentState != null &&
                                                subscriptionKey
                                                    .currentState.hasError
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  subscriptionKey
                                                      .currentState.errorText,
                                                  maxLines: 3,
                                                  style: appFonts.getTextStyle(
                                                      'text_color_red_style'),
                                                ),
                                              )
                                            : Container(),
                                        AppStyles().customPadding(15),
                                        !editSubcriptions
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                    RaisedButton(
                                                      // shape:
                                                      //     new RoundedRectangleBorder(
                                                      //         borderRadius:
                                                      //             new BorderRadius
                                                      //                     .circular(
                                                      //                 20.0)),
                                                      onPressed: () {
                                                        Navigator
                                                            .popAndPushNamed(
                                                                context,
                                                                '/ordersummary');
                                                      },
                                                      color: mainYellowColor,
                                                      // shape: ,
                                                      // clipBehavior: Clip.antiAlias,
                                                      child: Text(
                                                        "Skip",
                                                      ),
                                                    ),
                                                    AppStyles()
                                                        .customPadding(15),
                                                    RaisedButton(
                                                      // shape:
                                                      //     new RoundedRectangleBorder(
                                                      //         borderRadius:
                                                      //             new BorderRadius
                                                      //                     .circular(
                                                      //                 20.0)),
                                                      onPressed: () {
                                                        subscriptionFocus
                                                            .unfocus();
                                                        subscriptionKey
                                                            .currentState
                                                            ?.validate();
                                                        if (subscriptionKey
                                                                .currentState
                                                                .validate() &&
                                                            subscriptionController
                                                                    .text
                                                                    .trim() !=
                                                                '' &&
                                                            subscriptionKey
                                                                    .currentState !=
                                                                null) {
                                                          setState(() {
                                                            subscriptionsData =
                                                                {
                                                              "deliveryEvery":
                                                                  subscriptionController
                                                                      .text
                                                                      .trim(),
                                                              "units":
                                                                  currentUnitType,
                                                            };
                                                          });
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/ordersummary');
                                                        } else {
                                                          Text(
                                                            subscriptionKey
                                                                .currentState
                                                                .errorText,
                                                            maxLines: 4,
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'text_color_red_style'),
                                                          );
                                                        }
                                                      },
                                                      color: mainAppColor,
                                                      // shape: ,
                                                      // clipBehavior: Clip.antiAlias,
                                                      child: Text("Subscribe",
                                                          style: appFonts
                                                              .getTextStyle(
                                                                  'button_text_color_white')),
                                                    )
                                                  ])
                                            : Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    20,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                          width: 158,
                                                          child: RaisedButton(
                                                            // shape: new RoundedRectangleBorder(
                                                            //     borderRadius:
                                                            //         new BorderRadius.circular(
                                                            //             20.0)),
                                                            onPressed: () {
                                                              displayCancleSubscriptionMessage(
                                                                  context);
                                                            },
                                                            // color: Colors.redAccent,
                                                            // shape: ,
                                                            // clipBehavior: Clip.antiAlias,
                                                            child: Text(
                                                                "Cancel Subscription",
                                                                style: appFonts
                                                                    .getTextStyle(
                                                                        'button_text_color_black')),
                                                          )),
                                                      AppStyles()
                                                          .customPadding(8),
                                                      Container(
                                                          width: 70,
                                                          child: RaisedButton(
                                                            // shape: new RoundedRectangleBorder(
                                                            //     borderRadius:
                                                            //         new BorderRadius.circular(
                                                            //             20.0)),
                                                            onPressed: () {
                                                              subscriptionKey
                                                                  .currentState
                                                                  .validate();
                                                              setState(() {});
                                                              if (!subscriptionKey
                                                                      .currentState
                                                                      .hasError &&
                                                                  subscriptionController
                                                                          .text
                                                                          .trim() !=
                                                                      '') {
                                                                setState(() {
                                                                  subscriptionsData =
                                                                      {
                                                                    "deliveryEvery":
                                                                        subscriptionController
                                                                            .text
                                                                            .trim(),
                                                                    "units":
                                                                        currentUnitType,
                                                                  };
                                                                  updateSubscription =
                                                                      {
                                                                    "deliverEvery":
                                                                        subscriptionController
                                                                            .text
                                                                            .trim(),
                                                                    "units":
                                                                        currentUnitType,
                                                                    "subscriptionId":
                                                                        subscriptionData[
                                                                            'subscriptionId'],
                                                                    // "occuurences": 3,
                                                                    "prePayment":
                                                                        false
                                                                  };
                                                                  updateSubscriptionDetails(
                                                                      updateSubscription);
                                                                });
                                                              }
                                                            },
                                                            color: mainAppColor,
                                                            // shape: ,
                                                            // clipBehavior: Clip.antiAlias,
                                                            child: Text("Save",
                                                                style: appFonts
                                                                    .getTextStyle(
                                                                        'button_text_color_white')),
                                                          ))
                                                    ]))
                                      ])),
                              // InkWell(
                              //     onTap: () {
                              //       Navigator.pushNamedAndRemoveUntil(
                              //           context, "/home", ModalRoute.withName("/home"));
                              //     },
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: <Widget>[
                              //         Flexible(
                              //           flex: 2,
                              //           child: Text(
                              //             "Browse for more products",
                              //             style: TextStyle(color: Colors.blue, fontSize: 18),
                              //           ),
                              //         ),
                              //         Flexible(
                              //           child: Icon(
                              //             Icons.keyboard_arrow_right,
                              //             color: Colors.blue,
                              //             size: 25,
                              //           ),
                              //         )
                              //       ],
                              //     )),
                            ],
                          ),
                        ))
                      ]))
              : Center(
                  child: customizedCircularLoadingIcon(50),
                ),
        ));
  }
}
