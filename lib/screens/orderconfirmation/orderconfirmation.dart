import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:intl/intl.dart';
// import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/orderconfirmationservice/orderconfirmationservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
// import 'package:cornext_mobile/components/widgets/loadingbutton.dart';

class OrderConfirmationPage extends StatefulWidget {
  @override
  OrderConfirmation createState() => OrderConfirmation();
}

class OrderConfirmation extends State<OrderConfirmationPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map orderDetails = {};
  List orderedProductList = [];
  final currencyFormatter = new NumberFormat('#,##,###.00');
  final OrderConfirmationService orderConfirmationService =
      OrderConfirmationService();
  final ApiErros apiErros = ApiErros();
  bool isOrderDetailsLoading = false;
  final HomeScreenServices homeScreenServices = HomeScreenServices();
  final AppFonts appFonts = AppFonts();

  void initState() {
    getOrderDetails();
    fetchCartDetails();
    super.initState();
  }

  getOrderDetails() {
    final requestObj = {'orderId': orderId, "screenName": "HS"};
    setState(() {
      isOrderDetailsLoading = true;
    });
    orderConfirmationService.getOrderConfirmationDetails(requestObj).then(
        (val) {
      final data = json.decode(val.body);
      print('sssss');
      print(data['paymentDetails']);
      if (data['listOfProducts'] != null && data['listOfProducts'].length > 0) {
        setState(() {
          noOfProductsAddedInCart = 0;
          orderDetails = data;
          // print(orderDetails['orderDetails']);
          orderedProductList = data['listOfProducts'];
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          setState(() {
            isOrderDetailsLoading = false;
          });
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            // getCartDetails();
            getOrderDetails();
          }
        });
      }
      setState(() {
        isOrderDetailsLoading = false;
      });
    }, onError: (err) {
      setState(() {
        isOrderDetailsLoading = false;
      });
      apiErros.apiErrorNotifications(
          err, context, '/orderconfirmation', scaffoldKey);
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

  fetchCartDetails() {
    homeScreenServices.getCartQuantityDetails().then((res) {
      // print(res.body);
      final data = json.decode(res.body);
      if (data != null && data['noOfItemsInCart'] != null) {
        setState(() {
          noOfProductsAddedInCart = int.parse(data['noOfItemsInCart']);
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            fetchCartDetails();
          }
        });
      }
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/home', scaffoldKey);
    });
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
                        // Container(
                        //   child: Text(
                        //     res['productName'],
                        //     softWrap: true,
                        //     style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.bold,
                        //         color: mainAppColor),
                        //   ),
                        // ),
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
                        //     : Container(),
                        // res['productDiscount'] != null
                        //     ? Row(
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: <Widget>[
                        //           // Expanded(
                        //           //   flex: 0,
                        //           //   child: Text(
                        //           //     "Original Price:  ",
                        //           //     style: TextStyle(fontSize: 20.0),
                        //           //   ),
                        //           // ),
                        //           // AppStyles().customPadding(8),
                        //           Container(
                        //             // margin: EdgeInsets.only(top: 5),
                        //             child: res['appliedAgainst'] != null
                        //                 ? Text(
                        //                     res['currencyRepresentation']
                        //                             .toString() +
                        //                         currencyFormatter
                        //                             .format(
                        //                                 priceOfCurrentProduct)
                        //                             .toString() +
                        //                         ' ' +
                        //                         res['appliedAgainst'],
                        //                     // textAlign: TextAlign.center,
                        //                     style: TextStyle(
                        //                         decoration:
                        //                             TextDecoration.lineThrough,
                        //                         // fontWeight: FontWeight.bold,
                        //                         color: Colors.grey[700],
                        //                         fontSize: 15),
                        //                   )
                        //                 : Text(
                        //                     res['currencyRepresentation'] +
                        //                         currencyFormatter
                        //                             .format(
                        //                                 priceOfCurrentProduct)
                        //                             .toString(),
                        //                     // textAlign: TextAlign.center,
                        //                     style: TextStyle(
                        //                         decoration:
                        //                             TextDecoration.lineThrough,
                        //                         // fontWeight: FontWeight.bold,
                        //                         color: Colors.grey[700],
                        //                         fontSize: 15),
                        //                   ),
                        //           ),
                        //           // : Container()

                        //           AppStyles().customPadding(3),
                        //           // res['productDiscount'] != null
                        //           //     ? Container(
                        //           //         margin: EdgeInsets.only(top: 2),
                        //           //         child: Text(
                        //           //           res['productDiscount'] +
                        //           //               ' OFF',
                        //           //           style: TextStyle(
                        //           //               fontStyle: FontStyle.italic,
                        //           //               fontSize: 15,
                        //           //               color: orangeColor),
                        //           //         ))
                        //           //     : Container()

                        //           res['productDiscount'] != null
                        //               ? Text(
                        //                   "Save: " +
                        //                       getSavedAmount(
                        //                           res, priceOfCurrentProduct),
                        //                   style: TextStyle(
                        //                       fontStyle: FontStyle.italic,
                        //                       fontSize: 15,
                        //                       color: orangeColor),
                        //                 )
                        //               : Container(),
                        //         ],
                        //       )
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
                                  res['currencyRepresentation'].toString() +
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
                                  softWrap: true,
                                  text: TextSpan(
                                      // style: DefaultTextStyle.of(context).style,
                                      // text: "kckd",
                                      style: appFonts.getTextStyle(
                                          'text_color_black_style'),
                                      children: [
                                        TextSpan(
                                            text: "Quantity: ",
                                            style: appFonts.getTextStyle(
                                                'quantity_field_heading_text_style')),
                                        TextSpan(
                                          text: res['quantity'].toString(),
                                          style: appFonts.getTextStyle(
                                              'quantity_value_text_style'),
                                        ),
                                        res['units'] != null
                                            ? TextSpan(
                                                text: " " + res['units'],
                                                style: appFonts.getTextStyle(
                                                    'quantity_value_text_style'))
                                            : TextSpan()
                                      ]),
                                ))
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
    return Scaffold(
        key: scaffoldKey,
        appBar: appBarWidgetWithIcons(
            context, false, this.setState, false, '/orderconfirmation'),
        drawer: appBarDrawer(context, this.setState, scaffoldKey),
        // endDrawer: filterDrawer(
        //     this.setState, context, scafflodkey, false, searchFieldController),
        body: !isOrderDetailsLoading
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 4),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          "Thank you for shopping with us",
                          softWrap: true,
                          style: appFonts.getTextStyle(
                              'order_confirmation_screen_message_style'),
                        ),
                      ),
                      orderDetails['durationToDelivery'] != null
                          ? Container(
                              child: Text(
                                "We will send a SMS confirmation with in",
                                style: appFonts.getTextStyle(
                                    'order_confirmation_screen_light_color_message'),
                              ),
                            )
                          : Container(),
                      orderDetails['durationToDelivery'] != null
                          ? Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Duration: " +
                                    orderDetails['durationToDelivery']
                                        .toString() +
                                    ' ' +
                                    orderDetails['durationunits'],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            )
                          : Container(),
                      Divider(
                        thickness: 1,
                      ),
                      orderDetails['orderDetails'] != null
                          ? Container(
                              child: Text(
                                "Order Details",
                                style: appFonts.getTextStyle(
                                    'order_conirmation_screen_headings_style'),
                              ),
                            )
                          : Container(),
                      orderDetails['orderDetails'] != null
                          ? Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    child: Text("Order Id"),
                                  ),
                                  Flexible(
                                    child: Text(
                                      ":" +
                                          "0" *
                                              (10 -
                                                  orderDetails['orderDetails']
                                                          ['orderId']
                                                      .toString()
                                                      .length) +
                                          orderDetails['orderDetails']
                                                  ['orderId']
                                              .toString(),
                                      style: TextStyle(
                                          // fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                      orderDetails['orderDetails'] != null
                          ? Container(
                              child: Row(
                              children: <Widget>[
                                Container(
                                  width: 100,
                                  child: Text("Total amount"),
                                ),
                                Flexible(
                                  child: Text(
                                    ':' +
                                        orderDetails['orderDetails']
                                                ['currencyRepresentation']
                                            .toString() +
                                        currencyFormatter.format(
                                            orderDetails['orderDetails']
                                                ['transactionAmount']),
                                    style: TextStyle(
                                        // fontStyle: FontStyle.italic,
                                        color: orangeColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ))
                          : Container(),
                      Divider(
                        thickness: 1,
                      ),
                      orderDetails['deliveryAddress'] != null
                          ? Container(
                              margin: EdgeInsets.only(top: 2),
                              child: Text(
                                'Your order will be delivered to',
                                style: appFonts.getTextStyle(
                                    'order_conirmation_screen_headings_style'),
                              ),
                            )
                          : Container(),
                      orderDetails['deliveryAddress'] != null
                          ? Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                deliveryAddress,
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            )
                          : Container(),
                      Divider(
                        thickness: 1,
                      ),
                      orderDetails['paymentDetails'] != null
                          ? Container(
                              child: Text(
                                "Payment Information",
                                style: appFonts.getTextStyle(
                                    'order_conirmation_screen_headings_style'),
                              ),
                            )
                          : Container(),
                      orderDetails['paymentDetails'] != null &&
                              orderDetails['paymentDetails']['paymentMode'] !=
                                  null
                          ? Container(
                              // margin: EdgeInsets.only(bottom: 5),
                              child: Row(children: [
                              Container(
                                  width: 100, child: Text("Payment Type")),
                              Flexible(
                                  child: Text(
                                ': ' +
                                    orderDetails['paymentDetails']
                                        ['paymentMode'],
                                style: TextStyle(fontWeight: FontWeight.w700),
                              )),
                            ]))
                          : Container(),
                      orderDetails['paymentDetails'] != null &&
                              orderDetails['paymentDetails']['transactionId'] !=
                                  null
                          ? Container(
                              // margin: EdgeInsets.only(bottom: 5),
                              child: Row(children: [
                              Container(
                                  width: 100, child: Text("Transaction Id")),
                              Flexible(
                                  child: Text(
                                ': ' +
                                    orderDetails['paymentDetails']
                                        ['transactionId'],
                                style: TextStyle(fontWeight: FontWeight.w700),
                              )),
                            ]))
                          : Container(),
                      Divider(
                        thickness: 1,
                      ),
                      orderedProductList.length > 0
                          ? Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                "Purchased Products",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Container(),
                      orderedProductList.length > 0
                          ? Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: getOrderedProducts()),
                            )
                          : Container(),
                      Divider(
                        thickness: 1,
                      ),
                    ],
                  ),
                ))
            : Center(child: customizedCircularLoadingIcon(50)),
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
                    child: Text(
                      "Browse For More Products",
                      style: appFonts
                          .getTextStyle('browse_for_products_link_style'),
                    ),
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
        ));
  }
}
