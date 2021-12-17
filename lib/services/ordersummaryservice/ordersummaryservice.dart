import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
// import 'package:cornext_mobile/utils/apierrors/apierror.dart';

String orderIdFromDeepLink = "";
Map currentOrderInfo = {};
List listOfProductsToBeOrder = [];
String routeNameBeforePayment = '';
Timer _timer;

makeApiCallsOnFailedOrders(context) {
  Timer.periodic(Duration(seconds: 30), (Timer timer) {
    checkAndPostFailedOrderDetails(context, timer);
  });
}

void checkAndPostFailedOrderDetails(context, Timer timer) {
  // print('enter');
  if (signInDetails['access_token'] != null) {
    SharedPreferenceService()
        .checkAccessTokenAndUpdateuserDetails()
        .then((val) {
      List<String> orderList = [];
      orderList = val.getStringList('orderDetails' + signInDetails['userId']);
      // print('enter');
      if (orderList != null && orderList.length > 0) {
        postFailedOrderDetails(orderList, context);
      } else {
        if (timer != null) {
          // print(_timer.isActive);
          timer.cancel();
        }
      }
    });
  } else {
    if (timer != null) {
      timer.cancel();
    }
  }
}

postFailedOrderDetails(List<String> listOfOrderDetails, context) {
  listOfOrderDetails.forEach((val) => {
        OrderSummaryService().postOrderDetails(jsonDecode(val)).then(
            (orderData) {
          // print(orderInfo);
          final orderInfo = json.decode(orderData.body);
          print(orderInfo);
          if (orderInfo != null && orderInfo['orderId'] != null) {
            SharedPreferenceService()
                .removeCurrentOrderFromFailedOrderDetails(val);
          } else if (orderInfo != null &&
              orderInfo['error'] != null &&
              orderInfo['error'] == "invalid_token") {
            Navigator.of(context).pushNamed('/login');
          } else if (orderInfo['error'] != null) {
            // Navigator.pop(context);
            // ApiErros().apiLoggedErrors(data, context, scaffoldKey);
          }
        }, onError: (err) {
          // print(err);
          // Navigator.pop(context);
          // apiErros.apiErrorNotifications(
          //     err, context, '/orderconfirmation', scaffoldKey);
        })
      });
}

addQuantityToInventoryAfterCertainTime(String pincode) {
  _timer = Timer(Duration(minutes: 15), () {
    addQuantityToInventoryApi(pincode);
  });
}

addQuantityToInventoryApi(String pincode) {
  print(pincode);
  SharedPreferenceService().checkAccessTokenAndUpdateuserDetails().then((val) {
    if (val.get('transactionKey') != null &&
        val.get('transactionKey').toString().length > 0) {
      OrderSummaryService()
          .addQuantityToInventoryOnPaymentFail(pincode)
          .then((val) {
        final data = json.decode(val.body);
        print(data);
        if (data['status'] != null && data['status'] == "SUCCESS") {
          SharedPreferenceService().removeTransactionKey();
        } else {
          _timer.cancel();
        }
      });
    } else {
      _timer.cancel();
    }
  });
}

class OrderSummaryService {
  Future getUserRegistrationDiscountDetails() {
    return BaseService().getInfoByAccessToken(registrationDiscountDetails);
  }

  Future getCouponCodeDetails(requestObj) {
    return BaseService().postDetailsByAccessToken(couponCodeUrl, requestObj);
  }

  Future postOrderDetails(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(sendOrderDetailsurl, requestObj);
  }

  Future getOrderDetailsFromDeepLink(String orderId) {
    return BaseService()
        .getInfoByAccessToken(orderDetailsFromDeepLinkUrl + orderId.toString());
  }

  Future removeProductQuantityFromErpDataTabel(String pincode) {
    return BaseService()
        .getInfoByAccessToken(removeProductsFromErpDataTableUrl + pincode);
  }

  Future addQuantityToInventoryOnPaymentFail(String pincode) {
    return BaseService()
        .getInfoByAccessToken(addQuantityToInventoryUrl + pincode);
  }

  Future getRazorPayKey() {
    return BaseService().getInfoByAccessToken(getRazorPayKeyUrl);
  }

  getRazorPayKeyAndSecret(context, setState, scafflodkey) {
    getRazorPayKey().then((val) {
      final data = jsonDecode(val.body);
      if (data != null && data['key'] != null) {
        signInDetails['razorPayKey'] = data['key'];
        signInDetails['razorPaySecret'] = data['secret'];
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getRazorPayKeyAndSecret(context, setState, scafflodkey);
          }
        });
      } else if (data['error'] != null) {
        ApiErros().apiLoggedErrors(data, context, scafflodkey);
      }
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
    });
  }
}
