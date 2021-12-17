import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:intl/intl.dart';
// import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/ordertrackingservices/ordertrackingservice.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/services/subscriptionservice/subscriptionservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

class YourOrderDetailsPage extends StatefulWidget {
  @override
  YourOrderDetails createState() => YourOrderDetails();
}

class YourOrderDetails extends State<YourOrderDetailsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map orderDetails = {};
  List orderedProductList = [];
  final currencyFormatter = NumberFormat('#,##,###.00');
  final OrderTrackingService orderTrackingService = OrderTrackingService();
  final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  final ApiErros apiErros = ApiErros();
  bool isLoading = false;
  final AppFonts appFonts = AppFonts();

  void initState() {
    getOrderDetails();
    super.initState();
  }

  getOrderDetails() {
    setState(() {
      isLoading = true;
    });
    final Map requestObj = {'orderId': orderId, "screenName": "HS"};
    orderTrackingService.getIndividualOrderDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      print(data);
      if (data['listOfProducts'] != null) {
        orderDetails = data;
        print(orderDetails['orderDetails']);
        orderedProductList = data['listOfProducts'];
        setState(() {});
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getOrderDetails();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
      }
      setState(() {
        isLoading = false;
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      apiErros.apiErrorNotifications(
          err, context, '/yourorderdetails', scaffoldKey);
    });
  }

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
    return orderedProductList.map((res) {
      // print(res);
      // double priceOfCurrentProduct = 0.0;
      // if (res['taxpercent'] != null) {
      //   final double taxValue = res['value'] *
      //       int.parse(res['taxpercent'].toString().replaceAll('%', '')) /
      //       100;
      //   setState(() {
      //     priceOfCurrentProduct = res['value'] + taxValue;
      //   });
      //   // print(priceOfCurrentProduct);
      // } else {
      //   setState(() {
      //     priceOfCurrentProduct = res['value'];
      //   });
      // }
      final String imageUrl = res['resourceUrl'];
      return Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
              margin: EdgeInsets.only(
                top: 5,
              ),
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
                                    (MediaQuery.of(context).size.aspectRatio *
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
                                            text: ", " + res['productTypeName'],
                                            style: appFonts.getTextStyle(
                                                'cart_screen_specification_&_type_names_styles'))
                                        : TextSpan()
                                  ]),
                            )),
                        // res['productDiscount'] != null
                        //     ? Container(
                        //         alignment: Alignment.center,
                        //         // margin: EdgeInsets.only(left: 14),
                        //         child: Text(
                        //           getDiscountedPrice(
                        //               res, priceOfCurrentProduct),
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 16.0),
                        //           // textAlign: TextAlign.justify,
                        //         ))
                        //     : Container(
                        //         alignment: Alignment.center,
                        //         child: res['appliedAgainst'] != null
                        //             ? Center(
                        //                 child: Text(
                        //                 res['currencyRepresentation'] +
                        //                     currencyFormatter
                        //                         .format(priceOfCurrentProduct)
                        //                         .toString() +
                        //                     ' ' +
                        //                     res['appliedAgainst'],
                        //                 textAlign: TextAlign.center,
                        //                 style: TextStyle(
                        //                     fontSize: 16,
                        //                     fontWeight: FontWeight.bold),
                        //               ))
                        //             : Text(
                        //                 res['currencyRepresentation'] +
                        //                     currencyFormatter
                        //                         .format(priceOfCurrentProduct)
                        //                         .toString(),
                        //                 style: TextStyle(
                        //                     fontWeight: FontWeight.bold,
                        //                     // color: Colors.grey[700],
                        //                     fontSize: 16),
                        //               ),
                        //       ),
                        res['totalAmount'] != null
                            ? Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  res['currencyRepresentation'] +
                                      currencyFormatter
                                          .format(res['totalAmount']),
                                  style: appFonts.getTextStyle(
                                      'feedback_screen_total_amount_text_style'),
                                ),
                              )
                            : Container(),

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
                                            text: res['quantity'].toString(),
                                            style: appFonts.getTextStyle(
                                                'quantity_value_text_style')),
                                        res['quantityRepresentation'] != null
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
              )));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String deliveryAddress = "";
    if (orderDetails['deliveryAddress'] != null) {
      deliveryAddress = orderDetails['deliveryAddress']['city'] +
          ", " +
          orderDetails['deliveryAddress']['state'] +
          ", " +
          orderDetails['deliveryAddress']['pincode'];
      if (orderDetails['deliveryAddress']['street'] != null) {
        deliveryAddress =
            orderDetails['deliveryAddress']['street'] + ", " + deliveryAddress;
      }
      if (orderDetails['deliveryAddress']['doorNumber'] != null) {
        deliveryAddress = orderDetails['deliveryAddress']['doorNumber'] +
            ", " +
            deliveryAddress;
      }
    }
    return WillPopScope(
        onWillPop: () {
          Navigator.popAndPushNamed(context, '/yourorders');
          return Future.value(false);
        },
        child: Scaffold(
            key: scaffoldKey,
            appBar: appBarWidgetWithIcons(
                context, false, this.setState, false, '/yourorderdetails'),
            // drawer: appBarDrawer(context, this.setState),
            // endDrawer: filterDrawer(
            //     this.setState, context, scafflodkey, false, searchFieldController),
            body: !isLoading
                ? Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 4),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 10, top: 5),
                            child: Text(
                              "Your Order Details",
                              style: appFonts.getTextStyle(
                                  'order_details_screen_heading_style'),
                            ),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                orderDetails['orderDetails'] != null
                                    ? Container(
                                        child: Text(
                                          "Order Details",
                                          style: appFonts.getTextStyle(
                                              'order_details_sub_headings_style'),
                                        ),
                                      )
                                    : Container(),
                                orderDetails['orderDetails'] != null &&
                                        orderDetails['orderDetails']
                                                ['orderDate'] !=
                                            null
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(children: [
                                          Container(
                                            width: 100,
                                            child: Text("Order Date"),
                                          ),
                                          Flexible(
                                            child: Text(": "),
                                          ),
                                          Container(
                                            child: Text(
                                              dateFormat.format(DateTime.parse(
                                                  orderDetails['orderDetails']
                                                      ['orderDate'])),
                                              style: appFonts.getTextStyle(
                                                  'order_details_payment_detail_values_style'),
                                            ),
                                          )
                                        ]))
                                    : Container(),
                                orderDetails['orderDetails'] != null
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 100,
                                              child: Text("Order Id "),
                                            ),
                                            Flexible(
                                              child: Text(": "),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // "0" *
                                                //         (10 -
                                                //             orderDetails[
                                                //                         'orderDetails']
                                                //                     ['orderId']
                                                //                 .toString()
                                                //                 .length) +
                                                orderDetails['orderDetails']
                                                        ['erpOrderId']
                                                    .toString(),
                                                style: TextStyle(
                                                    // fontStyle: FontStyle.italic,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(),
                                orderDetails['orderDetails'] != null
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 100,
                                              child: Text("Total amount"),
                                            ),
                                            Flexible(
                                              child: Text(": "),
                                            ),
                                            Flexible(
                                              child: Text(
                                                orderDetails['orderDetails'][
                                                            'currencyRepresentation']
                                                        .toString() +
                                                    currencyFormatter.format(
                                                        orderDetails[
                                                                'orderDetails']
                                                            ['amountPerOrder']),
                                                style: TextStyle(
                                                    // fontStyle: FontStyle.italic,
                                                    color: orangeColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ))
                                    : Container(),
                                Divider(
                                  thickness: 1,
                                ),
                                orderedProductList.length > 0
                                    ? Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          "Purchased Products",
                                          style: appFonts.getTextStyle(
                                              'order_details_sub_headings_style'),
                                        ),
                                      )
                                    : Container(),
                                orderedProductList.length > 0
                                    ? Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: ListView(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            children: getOrderedProducts()),
                                      )
                                    : Container(),
                                Divider(
                                  thickness: 1,
                                ),
                                orderDetails['deliveryAddress'] != null
                                    ? Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Payment Information",
                                          style: appFonts.getTextStyle(
                                              'order_details_main_headings_style'),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey[300]),
                                        borderRadius: BorderRadius.circular(5)),
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, top: 5),
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          orderDetails['orderDetails'] !=
                                                      null &&
                                                  orderDetails['orderDetails']
                                                          ['paymentMode'] !=
                                                      null
                                              ? Container(
                                                  child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 100,
                                                      child:
                                                          Text('Payment Type'),
                                                    ),
                                                    Flexible(
                                                      // width: 100,
                                                      child: Text(
                                                        ': ' +
                                                            orderDetails[
                                                                        'orderDetails']
                                                                    [
                                                                    'paymentMode']
                                                                .toString(),
                                                        style: appFonts
                                                            .getTextStyle(
                                                                'order_details_payment_detail_values_style'),
                                                      ),
                                                    )
                                                  ],
                                                ))
                                              : Container(),
                                          orderDetails['orderDetails'] !=
                                                      null &&
                                                  orderDetails['orderDetails']
                                                          ['transactionId'] !=
                                                      null
                                              ? Container(
                                                  child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 100,
                                                      child: Text(
                                                          'Transaction Id'),
                                                    ),
                                                    Flexible(
                                                      // width: 100,
                                                      child: Text(
                                                        ': ' +
                                                            orderDetails[
                                                                        'orderDetails']
                                                                    [
                                                                    'transactionId']
                                                                .toString(),
                                                        style: appFonts
                                                            .getTextStyle(
                                                                'order_details_payment_detail_values_style'),
                                                      ),
                                                    )
                                                  ],
                                                ))
                                              : Container(),
                                          Divider(
                                            thickness: 1,
                                          ),
                                          orderDetails['deliveryAddress'] !=
                                                  null
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(top: 2),
                                                  child: Text(
                                                    'Billing Address',
                                                    style: appFonts.getTextStyle(
                                                        'order_details_sub_headings_style'),
                                                  ),
                                                )
                                              : Container(),
                                          orderDetails['deliveryAddress'] !=
                                                  null
                                              ? Container(
                                                  margin: EdgeInsets.only(
                                                      top: 5, bottom: 5),
                                                  child: Text(
                                                    deliveryAddress,
                                                  ),
                                                )
                                              : Container(),
                                        ])),
                                orderDetails['orderDetails'] != null &&
                                        orderDetails['orderDetails']
                                                ['transactionAmount'] !=
                                            null
                                    ? Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          "Order Summary",
                                          style: appFonts.getTextStyle(
                                              'order_details_main_headings_style'),
                                        ))
                                    : Container(),
                                orderDetails['orderDetails'] != null &&
                                        orderDetails['orderDetails']
                                                ['transactionAmount'] !=
                                            null
                                    ? Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey[300]),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        margin: EdgeInsets.only(top: 5),
                                        child: Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 3),
                                                ),
                                                orderDetails['orderDetails'][
                                                            'totalProductDiscountAmountPerOrder'] !=
                                                        null
                                                    ? Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              width: 130,
                                                              child: Text(
                                                                  "Discounts"),
                                                            ),
                                                            Flexible(
                                                              child: Text(": "),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  130 -
                                                                  40,
                                                              child: orderDetails[
                                                                              'orderDetails']
                                                                          [
                                                                          'totalProductDiscountAmountPerOrder'] >
                                                                      0
                                                                  ? Text(
                                                                      orderDetails['orderDetails']
                                                                              [
                                                                              'currencyRepresentation'] +
                                                                          currencyFormatter.format(orderDetails['orderDetails']
                                                                              [
                                                                              'totalProductDiscountAmountPerOrder']),
                                                                      style: appFonts
                                                                          .getTextStyle(
                                                                              'order_details_amount_values_style'),
                                                                    )
                                                                  : Text(
                                                                      orderDetails['orderDetails']
                                                                              [
                                                                              'currencyRepresentation'] +
                                                                          "0.00",
                                                                      style: appFonts
                                                                          .getTextStyle(
                                                                              'order_details_amount_values_style'),
                                                                    ),
                                                            )
                                                          ],
                                                        ))
                                                    : Container(),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 3),
                                                ),
                                                orderDetails['orderDetails'][
                                                            'totalTaxAmountPerOrder'] !=
                                                        null
                                                    ? Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              width: 130,
                                                              child: Text(
                                                                  "Taxes and charges"),
                                                            ),
                                                            Flexible(
                                                              child: Text(": "),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  130 -
                                                                  40,
                                                              child: orderDetails[
                                                                              'orderDetails']
                                                                          [
                                                                          'totalTaxAmountPerOrder'] >
                                                                      0
                                                                  ? Text(
                                                                      orderDetails['orderDetails']
                                                                              [
                                                                              'currencyRepresentation'] +
                                                                          currencyFormatter.format(orderDetails['orderDetails']
                                                                              [
                                                                              'totalTaxAmountPerOrder']),
                                                                      style: appFonts
                                                                          .getTextStyle(
                                                                              'order_details_amount_values_style'),
                                                                    )
                                                                  : Text(
                                                                      orderDetails['orderDetails']
                                                                              [
                                                                              'currencyRepresentation'] +
                                                                          "0.00",
                                                                      style: appFonts
                                                                          .getTextStyle(
                                                                              'order_details_amount_values_style'),
                                                                    ),
                                                            )
                                                          ],
                                                        ))
                                                    : Container(),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 3),
                                                ),
                                                orderDetails['orderDetails'][
                                                            'amountPerOrder'] !=
                                                        null
                                                    ? Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              width: 130,
                                                              child: Text(
                                                                "Total amount",
                                                                style: appFonts
                                                                    .getTextStyle(
                                                                        'order_details_total_amount_heading_style'),
                                                              ),
                                                            ),
                                                            Flexible(
                                                              child: Text(": "),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  130 -
                                                                  40,
                                                              child: Text(
                                                                orderDetails[
                                                                            'orderDetails']
                                                                        [
                                                                        'currencyRepresentation'] +
                                                                    currencyFormatter.format(
                                                                        orderDetails['orderDetails']
                                                                            [
                                                                            'amountPerOrder']),
                                                                style: appFonts
                                                                    .getTextStyle(
                                                                        'order_details_sub_headings_style'),
                                                              ),
                                                            )
                                                          ],
                                                        ))
                                                    : Container(),
                                              ],
                                            )))
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.only(top: 5),
                                ),
                                orderDetails['havingSubscribedOrders'] !=
                                            null &&
                                        orderDetails['havingSubscribedOrders']
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: InkWell(
                                            onTap: () {
                                              subscriptionDetails = {};
                                              isEditButtonClickedOnOrderDetails =
                                                  true;
                                              editSubcriptions = true;
                                              // subscriptionDetails['orderId'] =
                                              //     orderDetails['orderDetails']
                                              //         ['orderId'];
                                              subscriptionDetails[
                                                      'subscriptionId'] =
                                                  orderDetails['orderDetails']
                                                      ['subscriptionId'];
                                              Navigator.popAndPushNamed(
                                                  context, '/subscription');
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Flexible(
                                                  flex: 6,
                                                  child: Text(
                                                    "View your subscription details",
                                                    style: appFonts.getTextStyle(
                                                        'browse_for_products_link_style'),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Icon(
                                                    Icons.keyboard_arrow_right,
                                                    color: Colors.blue,
                                                    size: 25,
                                                  ),
                                                )
                                              ],
                                            )))
                                    : Container(),
                                Divider(
                                  thickness: 1,
                                ),
                              ],
                            ),
                          ))
                        ]))
                : Center(
                    child: customizedCircularLoadingIcon(50),
                  ),
            bottomNavigationBar: Container(
              height: 70,
              child: InkWell(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/home", ModalRoute.withName("/home"));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Text("Browse For More Products",
                            style: appFonts.getTextStyle(
                                'browse_for_products_link_style')),
                      ),
                      Flexible(
                          child: Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.blue,
                          size: 25,
                        ),
                      ))
                    ],
                  )),
            )));
  }
}
