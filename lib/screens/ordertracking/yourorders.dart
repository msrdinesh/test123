// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appcolors.dart';

// import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cornext_mobile/services/ordertrackingservices/ordertrackingservice.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/services/feedbackservice/feedbackservice.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:android_intent/android_intent.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'dart:async';
import 'package:cornext_mobile/constants/appfonts.dart';
// import 'package:location_permissions/location_permissions.dart';
// import 'package:cornext_mobile/services/addressservice/addressservice.dart';

class OrderListPage extends StatefulWidget {
  @override
  OrderLists createState() => OrderLists();
}

class OrderLists extends State<OrderListPage> {
  List orderDetails = [];
  final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  final OrderTrackingService orderTrackingService = OrderTrackingService();
  bool isLoading = false;
  int pageNo = 1;
  int limit = 15;
  Map orderListInfo = {};
  int totalNumberOfOrders = 0;
  final ScrollController scrollController = ScrollController();
  final listKey = GlobalKey();
  bool isMoreDataLoading = false;
  final ApiErros apiErros = ApiErros();
  String currentAddress = '';
  final HomeScreenServices homeScreenServices = HomeScreenServices();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  Timer timer;
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    super.initState();
    // setState(() {
    fetchOrderList();
    checkAndDisplayFeedbackSubmittedMessage();
    // });
  }

  checkAndDisplayFeedbackSubmittedMessage() {
    Timer(Duration(microseconds: 100), () {
      if (isFeedBackSubmitted) {
        setState(() {
          isFeedBackSubmitted = false;
        });
        showSuccessNotifications(
            "Thank You For Your Feedback", context, scaffoldkey);
      }
    });
  }

  void openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  fetchOrderList() {
    setState(() {
      isLoading = true;
    });
    final requestObj = {
      "limit": limit,
      "pageNumber": pageNo,
      "screenName": "HS"
    };
    print(requestObj);
    orderTrackingService.getOrderListDetails(requestObj).then((val) {
      // print(val.body);
      final data = json.decode(val.body);
      if (data['orderList'] != null) {
        orderListInfo = data;
        orderDetails = data['orderList'];
        totalNumberOfOrders = data['orderCount'];
        print(orderDetails);
        // setState(() {
        isLoading = false;
        scrollController
          ..addListener(() {
            if (totalNumberOfOrders > orderDetails.length &&
                !isMoreDataLoading) {
              // print('data');
              pageNo = pageNo + 1;
              fetchMoreOrdersList();
            }
          });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            fetchOrderList();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
      // });
      setState(() {});
      // print(orderDetails.length);
      // print('satya');
      // print(data);
      // if(data[''])
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      apiErros.apiErrorNotifications(err, context, '/yourorders', scaffoldkey);
    });
  }

  navigateToFeedback(Map orderInfo) {
    // getGeoLocation().then((value) {
    // setState(() {
    // if (value != null) {
    orderIdForFeedback = orderInfo['orderId'];
    orderDateForFeedback = (orderInfo['orderDate']);
    Navigator.popAndPushNamed(context, '/feedback');
    // }
    // }
    // });
  }

  repeatOrder(int orderId, bool isCartDelete) {
    final Map requestObj = {'cartDelete': isCartDelete, 'orderId': orderId};
    // Navigator.pop(context);
    displayLoadingIcon(context);
    orderTrackingService.repeatOrderDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      Navigator.pop(context);
      if (data['addressId'] != null) {
        // selectedDeliveryAddress = {};
        // selectedDeliveryAddress = data['addressDeatils'];
        isRepeatOrder = true;
        repeatOrderAddressId = data['addressId'];
        setState(() {
          noOfProductsAddedInCart = int.parse(data['noOfItemsInCart']);
        });
        Navigator.popAndPushNamed(context, '/deliveryaddress');
        // fetchCartDetails();
      } else if (data['addressId'] == null && data['noOfItemsInCart'] != null) {
        isRepeatOrder = true;
        setState(() {
          noOfProductsAddedInCart = int.parse(data['noOfItemsInCart']);
        });
        Navigator.popAndPushNamed(context, '/deliveryaddress');
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          Navigator.pop(context);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            repeatOrder(orderId, isCartDelete);
          }
        });
      } else if (data['error'] != null) {
        // Navigator.pop(context);
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
    }, onError: (err) {
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
      apiErros.apiErrorNotifications(err, context, '/yourorders', scaffoldkey);
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

  displayRepeatOrderPopup(context, String message, int orderId) {
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
                // contentPadding: EdgeInsets.only(bottom: 5),

                // content: ,
                title:
                    //  Container(
                    //     // height: 40,
                    //     margin: EdgeInsets.only(left: 10),
                    // color: Colors.red[800],
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   // crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: <Widget>[
                    //     // Pad ding(padding: EdgeInsets.only(top: 5)),
                    Text(
                  "Repeat Order",
                  style: appFonts.getTextStyle(
                      'home_screen_repeat_previous_order_popup_heading_style'),
                ),
                // ],

                content: Container(
                    color: Colors.white,
                    child: Row(children: [
                      Container(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: Icon(
                          Icons.info,
                          size: 30,
                          color: mainAppColor,
                        ),
                      ),
                      Flexible(
                        // margin: EdgeInsets.only(
                        //     bottom: 5, right: 10, left: 10, top: 5),
                        child: Text(
                          message,
                          style: appFonts.getTextStyle(
                              'home_screen_repeat_previous_order_popup_content_style'),
                          softWrap: true,
                        ),
                      ),
                    ])),

                // Container(
                //   margin: EdgeInsets.only(top: 20),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: <Widget>[

                //     ],
                //   ),
                // )

                actions: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 7),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      repeatOrder(orderId, false);
                    },
                    child: Text("No"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 7),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      repeatOrder(orderId, true);
                    },
                    child: Text("Yes"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                  ),
                ],
              ));
        });
  }

  Future<Position> getGeoLocation() async {
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    // PermissionStatus permissionStatus =
    //     await LocationPermissions().checkPermissionStatus();
    // print(permissionStatus);
    // ServiceStatus serviceStatus =
    //     await LocationPermissions().checkServiceStatus();
    print(geolocator);
    var isGpsEnabled = await Geolocator().isLocationServiceEnabled();
    // print(isGpsEnabled);
    // GeolocationStatus geolocationStatus =
    //     await geolocator.checkGeolocationPermissionStatus();
    // print(geolocationStatus);
    // if (geolocationStatus == GeolocationStatus.granted) {
    if (isGpsEnabled) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      getAddressFromLatLng(position);
      return position;
    } else {
      // _checkGps();
      openLocationSetting();
      return null;
    }
    // }
  }

  getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> p = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      // List<Placemark> p =
      //     await Geolocator().placemarkFromCoordinates(16.527611, 81.381366);
      Placemark place = p[0];
      String area = "";
      if (place.subThoroughfare != null && place.subThoroughfare != "") {
        area = area + place.subThoroughfare + ", ";
      }
      if (place.thoroughfare != null && place.thoroughfare != "") {
        area = area + place.thoroughfare + ", ";
      }
      if (place.subLocality != null && place.subLocality != "") {
        area = area + place.subLocality;
      }
      // setState(() {
      geoLocationDetails = {
        "area": area,
        "city": place.locality,
        "district": place.subAdministrativeArea,
        "state": place.administrativeArea,
        "pincode": place.postalCode,
        "country": place.country
      };
      print(geoLocationDetails);
      // currentAddress =
      //     "${place.subThoroughfare},${place.thoroughfare},${place.subLocality},${place.locality}, ${place.subAdministrativeArea},${place.administrativeArea},${place.postalCode}, ${place.country}";
      // print(currentAddress);
      // });
    } catch (e) {
      print(e);
    }
  }

  fetchMoreOrdersList() {
    final requestObj = {
      "limit": limit,
      "pageNumber": pageNo,
      "screenName": "HS"
    };
    setState(() {
      isMoreDataLoading = true;
    });
    orderTrackingService.getOrderListDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      print(data);
      setState(() {
        // orderListInfo = data;
        print(data['orderList'].length);
        data['orderList'].forEach((val) {
          orderDetails.add(val);
        });
        setState(() {
          isMoreDataLoading = false;
        });
      });
      // print(orderDetails.length);
      // print('satya');
      // print(data);
    }, onError: (err) {
      setState(() {
        isMoreDataLoading = false;
      });
    });
  }

  Widget getOrderListDetails() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
            // padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            // height: 170,
            width: double.maxFinite,
            child: Card(
              margin: EdgeInsets.only(left: 10, top: 15, right: 10),
              elevation: 3,
              child: GestureDetector(
                onTap: () {
                  orderId = orderDetails[index]['orderId'];
                  Navigator.popAndPushNamed(context, '/yourorderdetails');
                },
                child: Container(
                  // decoration: BoxDecoration(
                  //   border: Border(
                  //     top:
                  //         BorderSide(width: 2.0, color: mainAppColor),
                  //   ),
                  //   color: Colors.white,
                  // ),
                  child: Padding(
                    padding: EdgeInsets.all(1),
                    child: Stack(children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      // getCartProductDetails(),
                                      Container(
                                          child: Row(
                                        children: <Widget>[
                                          Container(
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(5),
                                                    bottomLeft:
                                                        Radius.circular(5)),
                                                child: CachedNetworkImage(
                                                  imageUrl: orderDetails[index]
                                                      ['resourceUrl'],

                                                  // image: AssetImage("assets/images/feednext.png"),
                                                  // height: 100,
                                                  // width: 100,

                                                  // height: MediaQuery.of(
                                                  //             context)
                                                  //         .size
                                                  //         .height /
                                                  //     (MediaQuery.of(context)
                                                  //             .size
                                                  //             .aspectRatio *
                                                  //         26),

                                                  // width: MediaQuery.of(
                                                  //             context)
                                                  //         .size
                                                  //         .width /
                                                  //     (MediaQuery.of(context)
                                                  //             .size
                                                  //             .aspectRatio *
                                                  //         6),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      (MediaQuery.of(context)
                                                              .size
                                                              .aspectRatio *
                                                          11),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      (MediaQuery.of(context)
                                                              .size
                                                              .aspectRatio *
                                                          6.5),

                                                  fit: BoxFit.fill,
                                                  // height: 100,
                                                )),
                                            // child: CachedNetworkImage(
                                            //   imageUrl: imageUrl,
                                            //   height: MediaQuery.of(context).size.height /
                                            //       (MediaQuery.of(context).size.aspectRatio * 13),
                                            //   width: MediaQuery.of(context).size.width /
                                            //       (MediaQuery.of(context).size.aspectRatio * 8),
                                            //   fit: BoxFit.fill,
                                            //   // placeholder: (context, imageUrl) =>
                                            //   //     customizedCircularLoadingIcon(15),
                                            // ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 6, top: 0),
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // AppStyles()
                                                //     .customPadding(
                                                //         2),
                                                Row(children: [
                                                  Container(
                                                    width: 95,
                                                    child: Text(
                                                      'Order Id',
                                                      softWrap: true,
                                                      style: appFonts.getTextStyle(
                                                          'order_list_sub_headings_style'),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(": "),
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width -
                                                        95 -
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .aspectRatio *
                                                                6.5) -
                                                        50,
                                                    child: Text(
                                                      // "0" *
                                                      //         (10 -
                                                      //             orderDetails[
                                                      //                         index]
                                                      //                     [
                                                      //                     'orderId']
                                                      //                 .toString()
                                                      //                 .length) +
                                                      orderDetails[index]
                                                              ['erpOrderId']
                                                          .toString(),
                                                      softWrap: true,
                                                      style: appFonts.getTextStyle(
                                                          'order_list_sub_headings_style'),
                                                    ),
                                                  )
                                                ]),
                                                AppStyles().customPadding(2),
                                                Row(children: [
                                                  Container(
                                                    width: 95,
                                                    child: Text(
                                                      'Order Date',
                                                      softWrap: true,
                                                      style: appFonts.getTextStyle(
                                                          'order_list_sub_headings_style'),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(": "),
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width -
                                                        95 -
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .aspectRatio *
                                                                6.5) -
                                                        50,
                                                    child: Text(
                                                      dateFormat
                                                          .format(DateTime.parse(
                                                              orderDetails[
                                                                      index][
                                                                  'orderDate']))
                                                          .toString(),
                                                      softWrap: true,
                                                      style: appFonts.getTextStyle(
                                                          'order_list_sub_headings_style'),
                                                    ),
                                                  )
                                                ]),
                                                orderDetails[index]
                                                            ['deliverDate'] !=
                                                        null
                                                    ? AppStyles()
                                                        .customPadding(2)
                                                    : Container(),
                                                orderDetails[index]
                                                            ['deliverDate'] !=
                                                        null
                                                    ? Row(children: [
                                                        Container(
                                                          width: 95,
                                                          child: Text(
                                                            'Deliver Date',
                                                            softWrap: true,
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'order_list_sub_headings_style'),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Text(": "),
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              95 -
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .aspectRatio *
                                                                      6.5) -
                                                              50,
                                                          child: Text(
                                                            dateFormat
                                                                .format(DateTime.parse(
                                                                    orderDetails[
                                                                            index]
                                                                        [
                                                                        'deliverDate']))
                                                                .toString(),
                                                            softWrap: true,
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'order_list_sub_headings_style'),
                                                          ),
                                                        )
                                                      ])
                                                    : Container(),
                                                AppStyles().customPadding(2),
                                                Row(children: [
                                                  Container(
                                                    width: 95,
                                                    child: Text(
                                                      'Number of products',
                                                      softWrap: true,
                                                      style: appFonts.getTextStyle(
                                                          'order_list_sub_headings_style'),
                                                    ),
                                                  ),
                                                  Container(child: Text(": ")),
                                                  Container(
                                                    width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width -
                                                        95 -
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .aspectRatio *
                                                                6.5) -
                                                        50,
                                                    child: Text(
                                                      orderDetails[index]
                                                              ['noOfProducts']
                                                          .toString(),
                                                      softWrap: true,
                                                      style: appFonts.getTextStyle(
                                                          'order_list_sub_headings_style'),
                                                    ),
                                                  )
                                                ]),

                                                AppStyles().customPadding(2),
                                              ])
                                        ],
                                      ))
                                    ],
                                  ),
                                  Divider(
                                    thickness: 1,
                                    indent: 5,
                                    endIndent: 10,
                                  ),
                                  Row(
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment
                                      //         .start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        // orderDetails[index]
                                        //         ['feedback']
                                        //     ? RaisedButton(
                                        //         // shape: new RoundedRectangleBorder(
                                        //         //     borderRadius: new BorderRadius.circular(20.0)),
                                        //         onPressed: () {},
                                        //         // color: Colors.grey,
                                        //         // shape: ,
                                        //         // clipBehavior: Clip.antiAlias,
                                        //         child: Text(
                                        //             "FeedBack",
                                        //             style: TextStyle(
                                        //                 color: Colors
                                        //                     .black)),
                                        //       )
                                        //     : RaisedButton(
                                        //         // shape: new RoundedRectangleBorder(
                                        //         //     borderRadius: new BorderRadius.circular(20.0)),
                                        //         onPressed: () {},
                                        //         // color:Colors.grey,
                                        //         // shape: ,
                                        //         // clipBehavior: Clip.antiAlias,
                                        //         child: Text(
                                        //             "Refund",
                                        //             style: TextStyle(
                                        //                 color: Colors
                                        //                     .black)),
                                        //       ),
                                        // AppStyles()
                                        //     .customPadding(6),
                                        orderDetails[index]['status'] != null &&
                                                orderDetails[index]['status'] ==
                                                    "CHANGEADDRESS"
                                            ? RaisedButton(
                                                // shape: new RoundedRectangleBorder(
                                                //     borderRadius: new BorderRadius.circular(20.0)),
                                                onPressed: () {
                                                  isDeliveryAddress = false;
                                                  isAddressEditing = true;
                                                  editAddressDetails = {
                                                    'addressId':
                                                        orderDetails[index]
                                                            ['addressId'],
                                                    'orderId':
                                                        orderDetails[index]
                                                            ['orderId']
                                                  };
                                                  Navigator.popAndPushNamed(
                                                      context,
                                                      '/deliveryaddress');
                                                },
                                                color: mainYellowColor,
                                                // shape: ,
                                                // clipBehavior: Clip.antiAlias,
                                                child: Text("Change Address",
                                                    style: appFonts.getTextStyle(
                                                        'button_text_color_black')),
                                              )
                                            : Container(),
                                        // orderDetails[index]['status'] != null &&
                                        //         orderDetails[index]['status'] ==
                                        //             "REFUND"
                                        //     ? RaisedButton(
                                        //         // shape: new RoundedRectangleBorder(
                                        //         //     borderRadius: new BorderRadius.circular(20.0)),
                                        //         onPressed: () {
                                        //           // orderIdForFeedback =
                                        //           //     orderDetails[index]
                                        //           //         ['orderId'];
                                        //           Navigator.popAndPushNamed(
                                        //               context, '/refund');
                                        //         },
                                        //         // color: Colors.grey,
                                        //         // shape: ,
                                        //         // clipBehavior: Clip.antiAlias,
                                        //         child: Text("Refund",
                                        //             style: TextStyle(
                                        //                 color: Colors.black)),
                                        //       )
                                        //     : Container(),
                                        orderDetails[index]['status'] != null &&
                                                orderDetails[index]['status'] ==
                                                    "DELIVERED"
                                            ? RaisedButton(
                                                // shape: new RoundedRectangleBorder(
                                                //     borderRadius: new BorderRadius.circular(20.0)),
                                                onPressed: () {
                                                  navigateToFeedback(
                                                      orderDetails[index]);

                                                  // orderIdForFeedback =
                                                  //     orderDetails[index]
                                                  //         ['orderId'];
                                                  // orderDateForFeedback =
                                                  //     (orderDetails[index]
                                                  //         ['orderDate']);
                                                  // Navigator.popAndPushNamed(
                                                  //     context, '/feedback');
                                                },
                                                color: mainYellowColor,
                                                // shape: ,
                                                // clipBehavior: Clip.antiAlias,
                                                child: Text("Feedback",
                                                    style: appFonts.getTextStyle(
                                                        'button_text_color_black')),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                        ),
                                        // orderDetails[index]['status'] != null && ?
                                        RaisedButton(
                                          // shape: new RoundedRectangleBorder(
                                          //     borderRadius: new BorderRadius.circular(20.0)),
                                          onPressed: () {
                                            // if (noOfProductsAddedInCart > 0) {
                                            //   displayRepeatOrderPopup(
                                            //       context,
                                            //       "You have some products in the cart. Do you want clear the cart to repeat this order?",
                                            //       orderDetails[index]
                                            //           ['orderId']);
                                            // } else {
                                            //   repeatOrder(
                                            //       orderDetails[index]
                                            //           ['orderId'],
                                            //       true);
                                            // }
                                            checkPreviousOrderLinkedWithSubscription(
                                                orderDetails[index]['orderId']);
                                          },
                                          color: mainAppColor,
                                          // shape: ,
                                          // clipBehavior: Clip.antiAlias,
                                          child: Text("Repeat Order",
                                              style: appFonts.getTextStyle(
                                                  'button_text_color_white')),
                                        ),
                                      ]),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ));
      },
      itemCount: orderDetails.length,
    );
  }

  displaySubscriptionPopup(context, String message, int orderId) {
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
                // contentPadding: EdgeInsets.only(bottom: 5),

                // content: ,
                title:
                    //  Container(
                    //     // height: 40,
                    //     margin: EdgeInsets.only(left: 10),
                    // color: Colors.red[800],
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   // crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: <Widget>[
                    //     // Pad ding(padding: EdgeInsets.only(top: 5)),
                    Text(
                  "Subscription Information",
                  style: appFonts.getTextStyle(
                      'home_screen_repeat_previous_order_popup_heading_style'),
                ),
                // ],

                content: Container(
                    color: Colors.white,
                    child: Row(children: [
                      Container(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: Icon(
                          Icons.info,
                          size: 30,
                          color: mainAppColor,
                        ),
                      ),
                      Flexible(
                        // margin: EdgeInsets.only(
                        //     bottom: 5, right: 10, left: 10, top: 5),
                        child: Text(
                          message,
                          style: appFonts.getTextStyle(
                              'home_screen_repeat_previous_order_popup_content_style'),
                          softWrap: true,
                        ),
                      ),
                    ])),

                // Container(
                //   margin: EdgeInsets.only(top: 20),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: <Widget>[

                //     ],
                //   ),
                // )

                actions: <Widget>[
                  // RaisedButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: Text("Cancel"),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.only(right: 7),
                  // ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // repeatPreviousOrder(null, false);
                    },
                    child: Text("No"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 7),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (noOfProductsAddedInCart > 0) {
                        displayRepeatOrderPopup(
                            context,
                            "You have some products in the cart. Do you want clear the cart to repeat this order?",
                            orderId);
                      } else {
                        repeatOrder(orderId, true);
                      }
                      // repeatPreviousOrder(null, true);
                    },
                    child: Text("Yes"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                  ),
                ],
              ));
        });
  }

  checkPreviousOrderLinkedWithSubscription(int orderId) {
    final Map requestObj = {"orderId": orderId};
    displayLoadingIcon(context);
    orderTrackingService.checkOrderLinkedWithSubscription(requestObj).then(
        (val) {
      final data = json.decode(val.body);
      print(data);
      print(data['orderId']);
      if (data['havingSubscribedOrders'] != null &&
          data['havingSubscribedOrders']) {
        Navigator.of(context).pop();
        displaySubscriptionPopup(
            context,
            "You have subscribed this order. Do you want repeat this order?",
            orderId);
      } else if (data['havingSubscribedOrders'] != null &&
          !data['havingSubscribedOrders'] &&
          data['status'] == null) {
        Navigator.of(context).pop();
        if (noOfProductsAddedInCart > 0) {
          displayRepeatOrderPopup(
              context,
              "You have some products in the cart. Do you want clear the cart to repeat this order?",
              orderId);
        } else {
          repeatOrder(orderId, true);
        }
      } else if (data['status'] != null &&
          data['status'] == "NOPREVIOUSORDERS") {
        Navigator.of(context).pop();
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.of(context).pop();
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            checkPreviousOrderLinkedWithSubscription(orderId);
          }
        });
      } else if (data['error'] != null) {
        Navigator.of(context).pop();
        ApiErros().apiLoggedErrors(data, context, scaffoldkey);
      }
    }, onError: (err) {
      Navigator.of(context).pop();
      ApiErros().apiErrorNotifications(err, context, '/home', scaffoldkey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', ModalRoute.withName('/home'));
          return Future.value(false);
        },
        child: Scaffold(
            key: scaffoldkey,
            appBar: appBarWidgetWithIcons(
                context, false, this.setState, false, '/yourorders'),
            body: !isLoading
                ? orderDetails.length > 0
                    ? Container(
                        child: Column(
                          // mainAxisSize: MainAxisSize.max,
                          mainAxisSize: MainAxisSize.min,

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Your Orders",
                                  style: appFonts.getTextStyle(
                                      'order_list_main_heading_style'),
                                )),
                            Expanded(
                                child: ListView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    controller: scrollController,
                                    children: <Widget>[
                                  getOrderListDetails(),
                                  isMoreDataLoading
                                      ? Center(
                                          child:
                                              customizedCircularLoadingIcon(30),
                                        )
                                      : Container()
                                ])),
                          ],
                        ),
                      )
                    : Container(
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                              Icon(
                                Icons.shopping_basket,
                                size: 100,
                                color: Colors.grey[300],
                              ),
                              Text(
                                "No recent orders",
                                style: appFonts.getTextStyle(
                                    'no_recent_orders_text_style'),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              RaisedButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      '/home', ModalRoute.withName('/home'));
                                },
                                child: Text("Start Shopping"),
                                color: mainYellowColor,
                              )
                            ])),
                      )
                : Center(child: customizedCircularLoadingIcon(50))));
  }

  // Widget cryptoNameSymbol() {
  //   return Align(
  //     alignment: Alignment.centerLeft,
  //     child: RichText(
  //       text: TextSpan(
  //         text: 'Bitcoin',
  //         style: TextStyle(
  //             fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
  //         children: <TextSpan>[
  //           TextSpan(
  //               text: '\nBTC',
  //               style: TextStyle(
  //                   color: Colors.grey,
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget cryptoChange() {
  //   return Align(
  //     alignment: Alignment.topRight,
  //     child: RichText(
  //       text: TextSpan(
  //         text: '+3.67%',
  //         style: TextStyle(
  //             fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20),
  //         children: <TextSpan>[
  //           TextSpan(
  //               text: '\n+202.835',
  //               style: TextStyle(
  //                   color: Colors.green,
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget changeIcon() {
  //   return Align(
  //       alignment: Alignment.topRight,
  //       child: Icon(Icons.account_balance
  //           // Typicons.arrow_sorted_up,
  //           // color: Colors.green,
  //           // size: 30,
  //           ));
  // }
}
