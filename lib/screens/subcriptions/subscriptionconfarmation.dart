import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/services/ordersummaryservice/ordersummaryservice.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cornext_mobile/services/orderconfirmationservice/orderconfirmationservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:flutter/services.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/constants/urls.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscrptionConformationPage extends StatefulWidget {
  @override
  _SubscrptionConformationPageState createState() => _SubscrptionConformationPageState();
}

class _SubscrptionConformationPageState extends State<SubscrptionConformationPage> {
  final scafFoldkey = GlobalKey<ScaffoldState>();
  final OrderSummaryService orderSummaryService = OrderSummaryService();
  final ApiErros apiErros = ApiErros();
  final RefreshTokenService refreshTokenService = RefreshTokenService();
  final SharedPreferenceService _sharedPreferenceService = SharedPreferenceService();
  final AppFonts appFonts = AppFonts();

  Razorpay _razorpay;

  static const platform = const MethodChannel('feednext/paymentgateway');

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Show Loading Icon On Updating/Deleting Cart Details
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
                // listOfCartDetails.forEach((val) {
                //   if (val['focusNode'] != null) {
                //     val['focusNode'].unfocus();
                //   }
                // });
                // if (isLoadingIconDisplaying) {
                //   Navigator.of(context).pop();
                // }
                return Future.value(true);
              },
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 100,
                child: customizedCircularLoadingIconWithColorAndSize(50, Colors.white),
              ));
        });
  }

  displayStockNotAvailableMessage(List listOfProductsNotAvailable) {
    if (listOfProductsNotAvailable.length == listOfProductsToBeOrder.length) {
      showErrorNotifications('Stock not available for selected products', context, scafFoldkey);
    } else {
      List notAvailableProducts = [];
      listOfProductsToBeOrder.forEach((val) {
        if (listOfProductsNotAvailable.indexWhere((res) => res['productId'] == val['productId']) != -1) {
          String productName = val['productName'];
          if (val['specificationName'] != null && val['specificationName'] != "") {
            productName = productName + " (" + val['specificationName'] + ")";
          }
          notAvailableProducts.add(productName);
        }
      });
      showErrorNotifications('Stock not available for ' + notAvailableProducts.join(', '), context, scafFoldkey);
    }
  }

  checkAndRemoveCartDetailsFrommErpDataTable(bool openPaymentGateWay, generatedOrderId) {
    orderSummaryService.removeProductQuantityFromErpDataTabel(selectedDeliveryAddress['pincode'].toString()).then((val) {
      final data = json.decode(val.body);
      if (data != null && data['listOfProductsNotAvailable'] != null && data['listOfProductsNotAvailable'].length == 0) {
        // sendOrderDetails();
        if (openPaymentGateWay) {
          //_callPayUNative();
          payUsingRazorPay();
        } else if (generatedOrderId != null) {
          orderId = generatedOrderId;
          // orderIdFromDeepLink = 0;
          currentOrderInfo = {};
          selectedDeliveryAddress = {};
          _sharedPreferenceService.removeTransactionKey();
          // subscriptionDetails = {};
          Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation', ModalRoute.withName('/orderconfirmation'));
        }
      } else if (data != null && data['listOfProductsNotAvailable'] != null && data['listOfProductsNotAvailable'].length > 0) {
        if (generatedOrderId != null) {
          orderId = generatedOrderId;
          // orderIdFromDeepLink = 0;
          currentOrderInfo = {};
          selectedDeliveryAddress = {};
          _sharedPreferenceService.removeTransactionKey();
          // subscriptionDetails = {};
          Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation', ModalRoute.withName('/orderconfirmation'));
        } else {
          displayStockNotAvailableMessage(data['listOfProductsNotAvailable']);
        }
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.pop(context);
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
              checkAndRemoveCartDetailsFrommErpDataTable(openPaymentGateWay, generatedOrderId);
            }
          },
        );
      } else if (data['error'] != null) {
        Navigator.pop(context);
        if (generatedOrderId != null) {
          orderId = generatedOrderId;
          // orderIdFromDeepLink = 0;
          currentOrderInfo = {};
          selectedDeliveryAddress = {};
          _sharedPreferenceService.removeTransactionKey();
          // subscriptionDetails = {};
          Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation', ModalRoute.withName('/orderconfirmation'));
        } else {
          apiErros.apiLoggedErrors(data, context, scafFoldkey);
        }
      }
    }, onError: (err) {
      if (generatedOrderId != null) {
        orderId = generatedOrderId;
        // orderIdFromDeepLink = 0;
        currentOrderInfo = {};
        selectedDeliveryAddress = {};
        _sharedPreferenceService.removeTransactionKey();
        // subscriptionDetails = {};
        Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation', ModalRoute.withName('/orderconfirmation'));
      } else {
        apiErros.apiErrorNotifications(err, context, '/subscriptionconformation', scafFoldkey);
      }
    });
  }

  sendOrderDetails(String payMode, String txnId) {
    // Map requestObj = {
    //   "userId": signInDeatils['userId'],
    //   "orderId": orderIdFromDeepLink > 0 ? orderIdFromDeepLink : null,
    //   "paymentSuccess": true,
    //   "havingRegistrationDiscount": registrationDiscount > 0 ? true : false,
    //   "addressId": selectedDeliveryAddress['addressId'],
    //   "deepLink": !makeAdvancePayment &&
    //           advancePaymentkey.currentState != null &&
    //           advancePaymentkey.currentState.validate() &&
    //           advancePaymentController.text.trim() != ""
    //       ? ""
    //       : null,
    //   "amountPerOrder": actualPriceOfCurrentOrder,
    //   "totalProductDiscountAmountPerOrder": productDiscountAmount,
    //   "totalTaxAmountPerOrder": totalTaxAmount,
    //   "transactionAmount": couponDiscount > 0
    //       ? subscribedprice > 0
    //           ? subscribedprice - couponDiscount
    //           : priceOfTotalProducts - couponDiscount
    //       : subscribedprice > 0 ? subscribedprice : priceOfTotalProducts,
    //   "couponDetails": couponDiscount > 0
    //       ? {
    //           'couponId': couponCodeDiscount['couponId'],
    //           'couponDiscount': couponDiscount
    //         }
    //       : null,
    //   "subscription": subscriptionsData['deliveryEvery'] != null &&
    //           advancePaymentkey.currentState.validate() &&
    //           advancePaymentController.text.trim() != ""
    //       ? {
    //           "deliverEvery": subscriptionsData['deliveryEvery'],
    //           "units": subscriptionsData['units'],
    //           "occuurences": int.parse(advancePaymentController.text.trim()),
    //           "prePayment": makeAdvancePayment
    //         }
    //       : null,
    //   "productDetails": getProductDetailsInfo()
    // };
    print('data');
    currentOrderInfo['paymentMode'] = payMode;
    currentOrderInfo['transactionId'] = txnId;
    displayLoadingIcon(context);
    orderSummaryService.postOrderDetails(currentOrderInfo).then((val) {
      final data = json.decode(val.body);
      // Navigator.pop(context);

      // data['orderId']
      if (data != null && data['orderId'] != null) {
        _sharedPreferenceService.checkAccessTokenAndUpdateuserDetails().then((txnKey) {
          if (txnKey.getString('transactionKey') != null && txnKey.getString('transactionKey').length > 0) {
            orderId = data['orderId'];
            orderIdFromDeepLink = "";
            currentOrderInfo = {};
            selectedDeliveryAddress = {};
            _sharedPreferenceService.removeTransactionKey();
            // subscriptionDetails = {};
            Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation', ModalRoute.withName('/orderconfirmation'));
          } else {
            checkAndRemoveCartDetailsFrommErpDataTable(false, data['orderId']);
          }
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.pop(context);
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
              sendOrderDetails(payMode, txnId);
            } else {
              Navigator.pop(context);
              _sharedPreferenceService.removeTransactionKey();
              _sharedPreferenceService.addFailedOrderDetails(currentOrderInfo);
              makeApiCallsOnFailedOrders(context);
              noOfProductsAddedInCart = 0;
              Navigator.pushReplacementNamed(context, '/ordercreationfailedscreen');
            }
          },
        );
      } else if (data['error'] != null) {
        Navigator.pop(context);
        _sharedPreferenceService.removeTransactionKey();
        _sharedPreferenceService.addFailedOrderDetails(currentOrderInfo);
        makeApiCallsOnFailedOrders(context);
        noOfProductsAddedInCart = 0;
        Navigator.pushReplacementNamed(context, '/ordercreationfailedscreen');
      }
    }, onError: (err) {
      Navigator.pop(context);
      _sharedPreferenceService.removeTransactionKey();
      _sharedPreferenceService.addFailedOrderDetails(currentOrderInfo);
      makeApiCallsOnFailedOrders(context);
      noOfProductsAddedInCart = 0;
      Navigator.pushReplacementNamed(context, '/ordercreationfailedscreen');
      // apiErros.apiErrorNotifications(
      //     err, context, '/orderconfirmation', scafFoldkey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.popAndPushNamed(context, "/ordersummary");
          return Future.value(false);
        },
        child: Scaffold(
            key: scafFoldkey,
            appBar: plainAppBarWidget,
            body: Container(
                height: MediaQuery.of(context).size.height / 2,
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 5, left: 5)),
                      Container(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Subscription Confirmation",
                              style: appFonts.getTextStyle('subscription_confirmation_heading_style'),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 85),
                      ),
                      (SingleChildScrollView(
                          child: Center(
                        child: Card(
                          margin: EdgeInsets.only(bottom: 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // Padding(
                              //   padding: EdgeInsets.only(top: 5),
                              // ),
                              Padding(
                                padding: EdgeInsets.only(top: 20, left: 2),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Would you like to subscribe? ",
                                    style: appFonts.getTextStyle('subscription_confirmation_sub_heading_style'),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                              ),
                              Container(
                                  // width:
                                  //     MediaQuery.of(context).size.width - 100,
                                  child: RaisedButton(
                                color: mainAppColor,
                                onPressed: () {
                                  Navigator.popAndPushNamed(context, '/subscriptionsummary');
                                },
                                child: Text(
                                  "Yes, Subscribe my orders.",
                                  style: appFonts.getTextStyle('button_text_color_white'),
                                  textAlign: TextAlign.center,
                                ),
                              )),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    onPressed: () {
                                      checkAndRemoveCartDetailsFrommErpDataTable(true, null);
                                    },
                                    child: Text(
                                      "Skip subscription, take me to payment",
                                      style: appFonts.getTextStyle('subscription_confirmation_skip_link_style'),
                                    ),
                                  )),
                              // Padding(padding: EdgeInsets.only(bottom: 10)),
                            ],
                          ),
                        ),
                      )))
                    ]))));
  }

  addQuantityToInventoryOnPaymentFail() {
    displayLoadingIcon(context);
    orderSummaryService.addQuantityToInventoryOnPaymentFail(selectedDeliveryAddress['pincode'].toString()).then((val) {
      final data = json.decode(val.body);
      Navigator.of(context).pop();
      if (data['status'] != null && data['status'] == "SUCCESS") {
        // Navigator.of(context).pop();
        _sharedPreferenceService.removeTransactionKey();
        routeNameBeforePayment = '/ordersummary';
        Navigator.pushReplacementNamed(context, '/paymentfailederrorscreen');
      } else if (data['status'] != null && data['status'] == "FAILED") {
        showErrorNotifications("Failed to add products into inventory", context, scafFoldkey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
              addQuantityToInventoryOnPaymentFail();
            }
          },
        );
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scafFoldkey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/subscriptionconformation', scafFoldkey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void payUsingRazorPay() async {
    var now = new DateTime.now().millisecondsSinceEpoch;
    var userId = signInDetails['userId'];
    String transactionId = "$userId$now";
    var orderDetails = {
      'amount': currentOrderInfo['transactionAmount'] * 100,
      'currency': 'INR',
      'receipt': transactionId,
      'payment_capture': 1,
    };

    String orderId = await OrderConfirmationService().createRazorPayOrder(orderDetails);
    var options = {
      'key': signInDetails['razorPayKey'].toString(),
      'amount': currentOrderInfo['transactionAmount'] * 100,
      'name': 'FeedNext',
      'description': 'Order processing',
      'order_id': orderId,
      'prefill': {
        'contact': signInDetails['mobileNo'],
        'email': signInDetails['emailId'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      //Snackbar to show failure
      addQuantityToInventoryOnPaymentFail();
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    displayLoadingIcon(context);
    OrderConfirmationService().fetchRazorPayPayment(response.paymentId).then((value) {
      Navigator.pop(context);
      print('payment Mode');
      print(value);
      sendOrderDetails(value, response.paymentId);
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    //Snackbar to show failure
    addQuantityToInventoryOnPaymentFail();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL_WALLET: " + response.walletName);
  }

  Future<void> _callPayUNative() async {
    var response;
    try {
      var now = new DateTime.now().millisecondsSinceEpoch;
      var userId = signInDetails['userId'];
      String transactionId = "$userId$now";
      var params = {
        "amount": currentOrderInfo['transactionAmount'].toString(),
        "firstName": signInDetails['userName'],
        "email": signInDetails['emailId'],
        "phone": signInDetails['mobileNo'],
        "hashURL": getHashUrl,
        "transactionId": transactionId, //Send a transactionID/orderID to update it with status later
        "access_token": signInDetails['access_token'] //Access Token for Hash genaration
      };
      _sharedPreferenceService.addTransactionKey(transactionId);
      addQuantityToInventoryAfterCertainTime(selectedDeliveryAddress['pincode'].toString());
      response = await platform.invokeMethod('callPayU', params);
      var jsonVal = jsonDecode(response);
      if (jsonVal["status"] == "success") {
        // checkAndRemoveCartDetailsFrommErpDataTable();
        String mode = 'Others';
        if (jsonVal['mode'] == 'CC') {
          mode = 'Credit Card';
        }
        sendOrderDetails(mode, jsonVal['txnid']);
      } else {
        //Snackbar to show failure
        addQuantityToInventoryOnPaymentFail();
      }
    } on PlatformException catch (e) {
      //Snackbar to show failure
      addQuantityToInventoryOnPaymentFail();
    }
  }
}
