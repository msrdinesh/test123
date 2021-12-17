import 'dart:convert';

import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

int orderId = 0;

class OrderConfirmationService {
  final BaseService baseService = BaseService();
  Future getOrderConfirmationDetails(requestObj) {
    return baseService.postDetailsByAccessToken(
        orderConfirmationurl, requestObj);
  }

  Future<String> createRazorPayOrder(requestObj) async {
    String key =
        signInDetails['razorPayKey'].toString(); //signInDetails['rp-key'];
    String secret = signInDetails['razorPaySecret']
        .toString(); //signInDetails['rp-secret'];
    var res = await baseService.postToRazorPay(
        razorPayCreateOrderUrl, requestObj, key, secret);
    var resp = json.decode(res.body);
    return resp['id'];
  }

  Future<String> fetchRazorPayPayment(paymentId) async {
    String key =
        signInDetails['razorPayKey'].toString(); //signInDetails['rp-key'];
    String secret = signInDetails['razorPaySecret']
        .toString(); //signInDetails['rp-secret'];
    var res = await baseService.getFromRazorPay(
        '$razorPayGetPaymentDetailsUrl$paymentId', key, secret);
    var resp = json.decode(res.body);
    return resp['method'];
  }
}
