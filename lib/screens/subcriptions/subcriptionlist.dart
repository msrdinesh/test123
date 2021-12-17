// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/subscriptionservice/subscriptionservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'dart:async';
import 'package:cornext_mobile/constants/appfonts.dart';
// import 'package:flutter/services.dart' show rootBundle;

class SubcriptionListPage extends StatefulWidget {
  @override
  SubcriptionListDetails createState() => SubcriptionListDetails();
}

class SubcriptionListDetails extends State<SubcriptionListPage> {
  // List orderDetails = [];
  List subscriberDetails = [];
  final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  final currencyFormatter = NumberFormat('#,##,###.00');
  bool isLoading = false;
  final ApiErros apiErros = ApiErros();
  int limit = 15;
  int pageNo = 1;
  bool isMoreSubscriptionsLoading = false;
  int totalNumberOfPrePaidSubscriptions = 0;
  final ScrollController scrollController = ScrollController();
  Map prepaidSubscriptionDetails = {};
  List prepaidSubscriptionList = [];
  List postPaidSubscriptionList = [];
  bool isPostPaidBtnClicked = false;
  bool isPostPaidDataLoading = false;
  final postPaidSubscriptionKey = GlobalKey();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer timer;
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    setState(() {
      getPrepaidSubscriptionList(false);
    });

    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  getPrepaidSubscriptionList(bool isMoreDataLoading) {
    Map obj = {"limit": limit, "pageNumber": pageNo, 'screenName': 'HS'};
    if (!isMoreDataLoading) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isMoreSubscriptionsLoading = true;
      });
    }
    SubcriptionService().getPrepaidSubscriptionList(obj).then((res) {
      final data = json.decode(res.body);
      // print(data);
      // if (data['subscriptionList'] != null &&
      //     (data['subscriptionList'].length > 0 ||
      //         data['subscriptionList'].length == 0)) {
      // setState(() {
      // if (!isMoreDataLoading) {
      if (data['prepaidSubscriptionList'] != null) {
        prepaidSubscriptionDetails = data;
        // prepaidSubscriptionList = data['prepaidSubscriptionList'];
        addBooleansForPrepaidSubscriptios(data['prepaidSubscriptionList']);
        setState(() {});
        // } else {
        //   data['prepaidSubscriptionList'].forEach((val) {
        //     prepaidSubscriptionList.add(val);
        //   });
        // }
        totalNumberOfPrePaidSubscriptions = data['count'];
        // });
        // scrollController.addListener(() {
        //   if (totalNumberOfSubscriptions > subscriberDetails.length &&
        //       !isMoreSubscriptionsLoading) {
        //     pageNo = pageNo + 1;
        //     getSubscribers(true);
        //   }
        // });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getPrepaidSubscriptionList(false);
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
      }
      setState(() {
        isLoading = false;
        isMoreSubscriptionsLoading = false;
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
        isMoreSubscriptionsLoading = false;
      });
      apiErros.apiErrorNotifications(
          err, context, '/subcriptionlist', scaffoldKey);
    });
  }

  addBooleansForPrepaidSubscriptios(List prepaidSubscriptionInfo) {
    prepaidSubscriptionInfo.forEach((val) {
      Map obj = val;
      obj['isViewSubscriptions'] = false;
      obj['orderDetails'] = [];
      obj['isOrderDetailsLoading'] = false;
      prepaidSubscriptionList.add(obj);
    });
  }

  getIndividualSubscriptionDetails(int subscriptionId, int index) {
    prepaidSubscriptionList[index]['isOrderDetailsLoading'] = true;
    setState(() {});
    SubcriptionService()
        .getIndividualPrepaidSubscriptionDetails(subscriptionId)
        .then((res) {
      final data = json.decode(res.body);
      prepaidSubscriptionList[index]['isOrderDetailsLoading'] = false;
      setState(() {});
      if (data != null && data.length > 0) {
        prepaidSubscriptionList[index]['orderDetails'] = data;
        setState(() {});
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getIndividualSubscriptionDetails(subscriptionId, index);
          }
        });
      } else if (data['error'] != null) {
        prepaidSubscriptionList[index]['isViewSubscriptions'] = false;
        setState(() {});
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
      }
    }, onError: (err) {
      prepaidSubscriptionList[index]['isViewSubscriptions'] = false;
      prepaidSubscriptionList[index]['isOrderDetailsLoading'] = false;
      setState(() {});
      apiErros.apiErrorNotifications(
          err, context, '/subcriptionlist', scaffoldKey);
    });
  }

  getPostpaidSubscriptionDetails() {
    Map obj = {"limit": limit, "pageNumber": pageNo, 'screenName': 'HS'};
    // if (!isMoreDataLoading) {
    //   setState(() {
    //     isLoading = true;
    //   });
    // } else {
    //   setState(() {
    //     isMoreSubscriptionsLoading = true;
    //   });
    // }
    displayLoadingIcon(context);
    SubcriptionService().getPostpaidSubscriptionList(obj).then((res) {
      final data = json.decode(res.body);
      // isPostPaidDataLoading = false;
      // print(data);
      // if (data['subscriptionList'] != null &&
      //     (data['subscriptionList'].length > 0 ||
      //         data['subscriptionList'].length == 0)) {
      // setState(() {
      // if (!isMoreDataLoading) {

      Navigator.pop(context);
      if (data['postpaidSubscriptionList'] != null) {
        // post = data;
        setState(() {
          postPaidSubscriptionList = data['postpaidSubscriptionList'];
        });
        timer = Timer(Duration(milliseconds: 100), () {
          if (prepaidSubscriptionList.length > 0 &&
              postPaidSubscriptionKey != null &&
              postPaidSubscriptionKey.currentContext != null) {
            // Scrollable.ensureVisible(postPaidSubscriptionKey.currentContext);
            // print('object');
            RenderBox box =
                postPaidSubscriptionKey.currentContext.findRenderObject();
            Offset position = box.localToGlobal(Offset.zero);
            scrollController.jumpTo(position.direction + position.dy);

            // }
          }
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getPrepaidSubscriptionList(false);
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
      }
      // setState(() {
      //   isLoading = false;
      //   isMoreSubscriptionsLoading = false;
      // });
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/subcriptionlist', scaffoldKey);
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

  getdata(String id, String subid) {
    setState(() {
      subscriptionDetails['orderId'] = id;
      subscriptionDetails['subscriptionId'] = subid;
    });
  }

  Widget getPrepaidSubscriptions() {
    return ListView.builder(
// scrollDirection: Axis.horizontal,
        itemCount: prepaidSubscriptionList.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final String imageUrl = prepaidSubscriptionList[index]['resourceUrl'];

          return Container(
              // padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              // height: 170,
              width: double.maxFinite,
              child: Card(
                margin: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),

                // elevation: 5,
                child: GestureDetector(
                  // onTap: () {
                  //   Navigator.of(context)
                  //       .pushNamed('/yourorderdetails');
                  // },
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
                                padding: const EdgeInsets.only(
                                  left: 5,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
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
                                                imageUrl: imageUrl,
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
                                                // placeholder: (context, imageUrl) =>
                                                //     customizedCircularLoadingIcon(15),
                                              ),
                                            )),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 6),
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        (MediaQuery.of(context)
                                                                .size
                                                                .aspectRatio *
                                                            6.5) -
                                                    34,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AppStyles()
                                                          .customPadding(2),
                                                      Container(
                                                          child: Row(
                                                        children: [
                                                          Container(
                                                              width: 110,
                                                              child: Text(
                                                                'Subscribed Date',
                                                                softWrap: true,
                                                              )),
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      (MediaQuery.of(context)
                                                                              .size
                                                                              .aspectRatio *
                                                                          6.5) -
                                                                  144,
                                                              child: Text(
                                                                ": " +
                                                                    dateFormat
                                                                        .format(DateTime.parse(prepaidSubscriptionList[index]
                                                                            [
                                                                            'subscribedDate']))
                                                                        .toString(),
                                                                softWrap: true,
                                                              ))
                                                        ],
                                                      )),
                                                      // Container(
                                                      //   child:
                                                      //       // child: Text(
                                                      //       //   'OrderOn: ' +
                                                      //       //       dateFormat
                                                      //       //           .format(DateTime.parse(prepaidSubscriptionList[index]['orderDate']))
                                                      //       //           .toString(),
                                                      //       //   softWrap:
                                                      //       //       true,
                                                      //       //   style:
                                                      //       //       TextStyle(
                                                      //       //     fontSize:
                                                      //       //         16,
                                                      //       //     // fontWeight: FontWeight.bold,
                                                      //       //     // color: mainAppColor
                                                      //       //   ),
                                                      //       // ),
                                                      //       RichText(
                                                      //           text: TextSpan(style: TextStyle(color: Colors.black), children: [
                                                      //     TextSpan(text: "Order Date ", style: TextStyle(fontWeight: FontWeight.w300)),
                                                      //     // TextSpan(
                                                      //     //     text: res['quantity'].toString(),
                                                      //     //     style: TextStyle(fontWeight: FontWeight.w700)),
                                                      //     prepaidSubscriptionList[index]['orderDate'] != null ? TextSpan(text: ': ' + dateFormat.format(DateTime.parse(prepaidSubscriptionList[index]['orderDate'])).toString(), style: TextStyle(fontWeight: FontWeight.w600)) : TextSpan()
                                                      //   ])),
                                                      // ),

                                                      AppStyles()
                                                          .customPadding(2),
                                                      Container(
                                                          child: Row(
                                                        children: [
                                                          Container(
                                                              width: 110,
                                                              child: Text(
                                                                'Number of products',
                                                                softWrap: true,
                                                              )),
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      (MediaQuery.of(context)
                                                                              .size
                                                                              .aspectRatio *
                                                                          6.5) -
                                                                  144,
                                                              child: Text(
                                                                ": " +
                                                                    prepaidSubscriptionList[index]
                                                                            [
                                                                            'numberOfProducts']
                                                                        .toString(),
                                                                softWrap: true,
                                                              ))
                                                        ],
                                                      )),
                                                      AppStyles()
                                                          .customPadding(2),
                                                      Divider(
                                                        thickness: 1,
                                                      ),
                                                      Container(
                                                          child: Text("You have subscribed this order for every " +
                                                              prepaidSubscriptionList[
                                                                          index]
                                                                      [
                                                                      'deliverEvery']
                                                                  .toString() +
                                                              " " +
                                                              prepaidSubscriptionList[
                                                                      index]
                                                                  ['units'] +
                                                              " for next " +
                                                              prepaidSubscriptionList[
                                                                          index]
                                                                      [
                                                                      'occuurences']
                                                                  .toString() +
                                                              " times")),
                                                      // Row(
                                                      //     mainAxisAlignment:
                                                      //         MainAxisAlignment
                                                      //             .end,
                                                      //     children: <Widget>[
                                                      //       RaisedButton(
                                                      //         // color: mainYellowColor,
                                                      //         // shape: new RoundedRectangleBorder(
                                                      //         //     borderRadius: new BorderRadius.circular(20.0)),
                                                      //         onPressed: () {
                                                      //           isSubscriptionAddressEditing =
                                                      //               true;
                                                      //           changeSubscriptionAddress =
                                                      //               {
                                                      //             'subscriptionId':
                                                      //                 prepaidSubscriptionList[
                                                      //                         index]
                                                      //                     [
                                                      //                     'subscriptionId'],
                                                      //             'addressId':
                                                      //                 prepaidSubscriptionList[
                                                      //                         index]
                                                      //                     [
                                                      //                     'addressId']
                                                      //           };
                                                      //           Navigator
                                                      //               .popAndPushNamed(
                                                      //                   context,
                                                      //                   '/deliveryaddress');
                                                      //           // Navigator
                                                      //           //     .popAndPushNamed(
                                                      //           //         context,
                                                      //           //         '/subscription');
                                                      //         },
                                                      //         color:
                                                      //             mainAppColor,
                                                      //         // shape: ,
                                                      //         // clipBehavior: Clip.antiAlias,
                                                      //         child: Text(
                                                      //             "Change Address",
                                                      //             style: appFonts
                                                      //                 .getTextStyle(
                                                      //                     'button_text_color_white')),
                                                      //       ),
                                                      //       Padding(
                                                      //         padding: EdgeInsets
                                                      //             .only(
                                                      //                 left: 10),
                                                      //       ),
                                                      //     ]),
                                                    ]))
                                          ],
                                        ))
                                      ],
                                    ),
                                    Divider(
                                      thickness: 2,
                                    ),
                                    !prepaidSubscriptionList[index]
                                            ['isViewSubscriptions']
                                        ? GestureDetector(
                                            onTap: () {
                                              if (prepaidSubscriptionList[index]
                                                          ['orderDetails']
                                                      .length ==
                                                  0) {
                                                prepaidSubscriptionList[index][
                                                        'isViewSubscriptions'] =
                                                    true;
                                                setState(() {});
                                                getIndividualSubscriptionDetails(
                                                    prepaidSubscriptionList[
                                                            index]
                                                        ['subscriptionId'],
                                                    index);
                                              } else {
                                                prepaidSubscriptionList[index][
                                                        'isViewSubscriptions'] =
                                                    true;
                                                setState(() {});
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Text(
                                                      "View Subscription Details",
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Icon(
                                                      Icons.expand_more,
                                                      size: 26,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ))
                                        : Container(),
                                    prepaidSubscriptionList[index]
                                                    ['orderDetails'] !=
                                                null &&
                                            prepaidSubscriptionList[index]
                                                        ['orderDetails']
                                                    .length >
                                                0 &&
                                            prepaidSubscriptionList[index]
                                                ['isViewSubscriptions']
                                        ? getIndividualOrderList(
                                            prepaidSubscriptionList[index]
                                                ['orderDetails'],
                                            index)
                                        : Container(),
                                    prepaidSubscriptionList[index]
                                            ['isOrderDetailsLoading']
                                        ? Container(
                                            child: Center(
                                                child:
                                                    customizedCircularLoadingIcon(
                                                        25)))
                                        : Container()
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
        });
  }

  Widget getIndividualOrderList(List orderDetails, int index) {
    // print(orderDetails);
    return Column(children: [
      ListView.builder(
// scrollDirection: Axis.horizontal,
          itemCount: orderDetails.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(5),
                    child: Row(children: [
                      Container(
                          child: Icon(
                        Icons.arrow_forward,
                        color: Colors.grey[600],
                        size: 20,
                      )),
                      Container(
                          width: 100,
                          margin: EdgeInsets.only(left: 5),
                          child: Text("OrderDate")),
                      Container(
                          child: Text(": " +
                              dateFormat
                                  .format(DateTime.parse(
                                      orderDetails[index]['orderDate']))
                                  .toString())),
                    ])),
                Container(
                    margin: EdgeInsets.all(5),
                    child: Row(children: [
                      Container(
                          child: Icon(
                        Icons.arrow_forward,
                        color: Colors.grey[600],
                        size: 20,
                      )),
                      Container(
                          width: 100,
                          margin: EdgeInsets.only(left: 5),
                          child: Text("Amount")),
                      Container(
                          child: Text(": " +
                              currencyFormatter.format(
                                  orderDetails[index]['amountPerOrder']))),
                    ])),
                Container(
                    margin: EdgeInsets.all(5),
                    child: Row(children: [
                      Container(
                          child: Icon(
                        Icons.arrow_forward,
                        color: Colors.grey[600],
                        size: 20,
                      )),
                      Container(
                          width: 100,
                          margin: EdgeInsets.only(left: 5),
                          child: Text("Status")),
                      Container(
                        child: orderDetails[index]['status'].toString() ==
                                "STARTED"
                            ? Text(
                                ": Your order is on the way",
                                style: appFonts.getTextStyle(
                                    'text_color_mainappcolor_style'),
                              )
                            : orderDetails[index]['status'].toString() ==
                                    "NOTDELIVERED"
                                ? Text(
                                    ": Order not delivered",
                                    style: appFonts
                                        .getTextStyle('text_color_red_style'),
                                  )
                                : Text(
                                    ": Order Delivered",
                                    style: appFonts.getTextStyle(
                                        'text_color_mainappcolor_style'),
                                  ),
                      ),
                    ])),
                Divider(
                  thickness: 1,
                )
              ],
            );
          }),
      Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.only(right: 5, bottom: 5),
        child: GestureDetector(
            onTap: () {
              prepaidSubscriptionList[index]['isViewSubscriptions'] = false;
              setState(() {});
            },
            child: Icon(
              Icons.expand_less,
              size: 30,
            )),
      )
    ]);
  }

  Widget getPostPaidSubscriptionList() {
    return ListView.builder(
// scrollDirection: Axis.horizontal,
        itemCount: postPaidSubscriptionList.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final String imageUrl =
              postPaidSubscriptionList[index]['resourceUrl'];

          return Container(
              // padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              // height: 170,
              width: double.maxFinite,
              child: Card(
                margin: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),

                // elevation: 5,
                child: GestureDetector(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(1),
                      child: Stack(children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
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
                                                imageUrl: imageUrl,
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
                                                // placeholder: (context, imageUrl) =>
                                                //     customizedCircularLoadingIcon(15),
                                              ),
                                            )),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 6),
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        (MediaQuery.of(context)
                                                                .size
                                                                .aspectRatio *
                                                            6.5) -
                                                    34,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AppStyles()
                                                          .customPadding(2),
                                                      Container(
                                                          child: Row(
                                                        children: [
                                                          Container(
                                                              width: 110,
                                                              child: Text(
                                                                'Subscribed Date',
                                                                softWrap: true,
                                                              )),
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      (MediaQuery.of(context)
                                                                              .size
                                                                              .aspectRatio *
                                                                          6.5) -
                                                                  144,
                                                              child: Text(
                                                                ": " +
                                                                    dateFormat
                                                                        .format(DateTime.parse(postPaidSubscriptionList[index]
                                                                            [
                                                                            'subscribedDate']))
                                                                        .toString(),
                                                                softWrap: true,
                                                              ))
                                                        ],
                                                      )),
                                                      // Container(
                                                      //   child:
                                                      //       // child: Text(
                                                      //       //   'OrderOn: ' +
                                                      //       //       dateFormat
                                                      //       //           .format(DateTime.parse(prepaidSubscriptionList[index]['orderDate']))
                                                      //       //           .toString(),
                                                      //       //   softWrap:
                                                      //       //       true,
                                                      //       //   style:
                                                      //       //       TextStyle(
                                                      //       //     fontSize:
                                                      //       //         16,
                                                      //       //     // fontWeight: FontWeight.bold,
                                                      //       //     // color: mainAppColor
                                                      //       //   ),
                                                      //       // ),
                                                      //       RichText(
                                                      //           text: TextSpan(style: TextStyle(color: Colors.black), children: [
                                                      //     TextSpan(text: "Order Date ", style: TextStyle(fontWeight: FontWeight.w300)),
                                                      //     // TextSpan(
                                                      //     //     text: res['quantity'].toString(),
                                                      //     //     style: TextStyle(fontWeight: FontWeight.w700)),
                                                      //     prepaidSubscriptionList[index]['orderDate'] != null ? TextSpan(text: ': ' + dateFormat.format(DateTime.parse(prepaidSubscriptionList[index]['orderDate'])).toString(), style: TextStyle(fontWeight: FontWeight.w600)) : TextSpan()
                                                      //   ])),
                                                      // ),

                                                      AppStyles()
                                                          .customPadding(2),
                                                      Container(
                                                          child: Row(
                                                        children: [
                                                          Container(
                                                              width: 110,
                                                              child: Text(
                                                                'Number of products',
                                                                softWrap: true,
                                                              )),
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      (MediaQuery.of(context)
                                                                              .size
                                                                              .aspectRatio *
                                                                          6.5) -
                                                                  144,
                                                              child: Text(
                                                                ": " +
                                                                    postPaidSubscriptionList[index]
                                                                            [
                                                                            'numberOfProducts']
                                                                        .toString(),
                                                                softWrap: true,
                                                              ))
                                                        ],
                                                      )),
                                                      AppStyles()
                                                          .customPadding(2),
                                                      Divider(
                                                        thickness: 1,
                                                      ),
                                                      Container(
                                                          child: Text("You have subscribed this order for every " +
                                                              postPaidSubscriptionList[
                                                                          index]
                                                                      [
                                                                      'deliverEvery']
                                                                  .toString() +
                                                              " " +
                                                              postPaidSubscriptionList[
                                                                      index]
                                                                  ['units'])),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            RaisedButton(
                                                              color:
                                                                  mainYellowColor,
                                                              // shape: new RoundedRectangleBorder(
                                                              //     borderRadius: new BorderRadius.circular(20.0)),
                                                              onPressed: () {
                                                                // subscriptionDetails[
                                                                //         'orderId'] =
                                                                //     orderDetails[
                                                                //             'orderDetails']
                                                                //         [
                                                                //         'orderId'];
                                                                editSubcriptions =
                                                                    true;
                                                                subscriptionDetails[
                                                                        'subscriptionId'] =
                                                                    postPaidSubscriptionList[
                                                                            index]
                                                                        [
                                                                        'subscriptionId'];
                                                                Navigator
                                                                    .popAndPushNamed(
                                                                        context,
                                                                        '/subscription');
                                                              },
                                                              // color: Colors.grey,
                                                              // shape: ,
                                                              // clipBehavior: Clip.antiAlias,
                                                              child: Text(
                                                                  "Edit",
                                                                  style: appFonts
                                                                      .getTextStyle(
                                                                          'button_text_color_black')),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5),
                                                            ),
                                                            // RaisedButton(
                                                            //   // color: mainYellowColor,
                                                            //   // shape: new RoundedRectangleBorder(
                                                            //   //     borderRadius: new BorderRadius.circular(20.0)),
                                                            //   onPressed: () {
                                                            //     isSubscriptionAddressEditing =
                                                            //         true;
                                                            //     changeSubscriptionAddress =
                                                            //         {
                                                            //       'subscriptionId':
                                                            //           postPaidSubscriptionList[
                                                            //                   index]
                                                            //               [
                                                            //               'subscriptionId'],
                                                            //       'addressId':
                                                            //           postPaidSubscriptionList[
                                                            //                   index]
                                                            //               [
                                                            //               'addressId']
                                                            //     };
                                                            //     Navigator
                                                            //         .popAndPushNamed(
                                                            //             context,
                                                            //             '/deliveryaddress');
                                                            //     // Navigator
                                                            //     //     .popAndPushNamed(
                                                            //     //         context,
                                                            //     //         '/subscription');
                                                            //   },
                                                            //   color:
                                                            //       mainAppColor,
                                                            //   // shape: ,
                                                            //   // clipBehavior: Clip.antiAlias,
                                                            //   child: Text(
                                                            //       "Change Address",
                                                            //       style: TextStyle(
                                                            //           color: Colors
                                                            //               .white)),
                                                            // ),
                                                            // Padding(
                                                            //   padding: EdgeInsets
                                                            //       .only(
                                                            //           left: 5),
                                                            // ),
                                                          ]),
                                                    ]))
                                          ],
                                        ))
                                      ],
                                    ),
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: appBarWidgetWithIcons(
            context, false, this.setState, false, '/subcriptionlist'),
        body: !isLoading
            ? (prepaidSubscriptionList.length > 0 ||
                    postPaidSubscriptionList.length > 0)
                ? Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              "Subscribed Orders List",
                              style: appFonts.getTextStyle(
                                  'subscription_list_heading_style'),
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 6),
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                controller: scrollController,
                                child: Column(children: [
                                  prepaidSubscriptionList.length > 0
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Pre Payment Subscriptions",
                                                  style: appFonts.getTextStyle(
                                                      'subscription_list_sub_headings_style'),
                                                ),
                                              ]))
                                      : Container(),
                                  getPrepaidSubscriptions(),
                                  prepaidSubscriptionDetails[
                                                  'havePostPaidSubscription'] !=
                                              null &&
                                          prepaidSubscriptionDetails[
                                              'havePostPaidSubscription'] &&
                                          !isPostPaidBtnClicked
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              left: 10,
                                              right: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Divider(
                                                thickness: 2,
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      top: 5, bottom: 5),
                                                  child: InkWell(
                                                    child: Text(
                                                      "View post payment subscription details",
                                                      style: appFonts.getTextStyle(
                                                          'browse_for_products_link_style'),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        isPostPaidBtnClicked =
                                                            true;
                                                        getPostpaidSubscriptionDetails();
                                                      });
                                                    },
                                                  )),
                                              Divider(
                                                thickness: 2,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  postPaidSubscriptionList.length > 0 &&
                                          isPostPaidBtnClicked
                                      ? Divider(
                                          thickness: 2,
                                        )
                                      : Container(),
                                  postPaidSubscriptionList.length > 0 &&
                                          isPostPaidBtnClicked
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              left: 10, right: 10),
                                          key: postPaidSubscriptionKey,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Post Payment Subscriptions",
                                                  style: appFonts.getTextStyle(
                                                      'subscription_list_sub_headings_style'),
                                                ),
                                              ]))
                                      : Container(),
                                  postPaidSubscriptionList.length > 0 &&
                                          isPostPaidBtnClicked
                                      ? Container(
                                          child: getPostPaidSubscriptionList())
                                      : Container(),
                                  isMoreSubscriptionsLoading
                                      ? Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: Center(
                                            child:
                                                customizedCircularLoadingIcon(
                                                    25),
                                          ),
                                        )
                                      : Container()
                                ]))),
                      ],
                    ),
                  )
                : Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.subscriptions,
                            size: 100,
                            color: Colors.grey[300],
                          ),
                          Text(
                            prepaidSubscriptionDetails[
                                            'havePostPaidSubscription'] !=
                                        null &&
                                    prepaidSubscriptionDetails[
                                        'havePostPaidSubscription'] &&
                                    prepaidSubscriptionList.length == 0
                                ? "No prepaid subscriptions found"
                                : "No subscriptions found",
                            style: appFonts.getTextStyle(
                                'subscription_list_no_subscriptions_found'),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      '/home', ModalRoute.withName('/home'));
                                },
                                child: Text(
                                  "Start Shopping",
                                  style: appFonts
                                      .getTextStyle('button_text_color_black'),
                                ),
                                color: mainYellowColor,
                              )),
                          prepaidSubscriptionDetails[
                                          'havePostPaidSubscription'] !=
                                      null &&
                                  prepaidSubscriptionDetails[
                                      'havePostPaidSubscription'] &&
                                  !isPostPaidBtnClicked
                              ? Container(
                                  margin: EdgeInsets.only(
                                      top: 2, bottom: 2, left: 10, right: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      // Divider(
                                      //   thickness: 2,
                                      // ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: InkWell(
                                            child: Text(
                                              "View post payment subscription details",
                                              style: appFonts.getTextStyle(
                                                  'browse_for_products_link_style'),
                                            ),
                                            onTap: () {
                                              isPostPaidBtnClicked = true;
                                              getPostpaidSubscriptionDetails();
                                              setState(() {});
                                            },
                                          )),
                                      // Divider(
                                      //   thickness: 2,
                                      // ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  )
            : Center(
                child: customizedCircularLoadingIcon(50),
              ));
  }
}
