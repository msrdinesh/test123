import 'package:shared_preferences/shared_preferences.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cornext_mobile/models/signinmodel.dart';

class SharedPreferenceService {
  void setAccessToken(String accessToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("access_token");
    prefs.setString("access_token", accessToken);
    // return prefs;
  }

  Future<String> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  void setRefreshToken(String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("refresh_token");
    prefs.setString("refresh_token", refreshToken);
  }

  void setUserName(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userName");
    prefs.setString("userName", username);
  }

  void setUserId(int userid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userId");
    prefs.setString("userId", userid.toString());
  }

  void setEmailId(String emailId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("emailId");
    prefs.setString("emailId", emailId.toString());
  }

  void setMobileNo(String mobileNo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("mobileNo");
    prefs.setString("mobileNo", mobileNo.toString());
  }

  Future<SharedPreferences> checkAccessTokenAndUpdateuserDetails() async {
    return SharedPreferences.getInstance();
  }

  Future getUserName() {
    return SharedPreferences.getInstance();
    // return '';
  }

  void addFailedOrderDetails(Map orderDetails) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> failedOrderDetails = [];
    failedOrderDetails = prefs.getStringList('orderDetails' + orderDetails['userId'].toString());
    if (failedOrderDetails != null && failedOrderDetails.length > 0) {
      failedOrderDetails.add(json.encode(orderDetails));
      prefs.remove('orderDetails' + orderDetails['userId'].toString());
      prefs.setStringList('orderDetails' + orderDetails['userId'].toString(), failedOrderDetails);
    } else {
      failedOrderDetails = [];
      failedOrderDetails.add(json.encode(orderDetails));
      prefs.remove('orderDetails' + orderDetails['userId'].toString());
      prefs.setStringList('orderDetails' + orderDetails['userId'].toString(), failedOrderDetails);
    }
  }

  void removeCurrentOrderFromFailedOrderDetails(String orderDetails) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> failedOrderDetails = prefs.getStringList('orderDetails' + signInDetails['userId'].toString());
    if (failedOrderDetails.length > 0) {
      // failedOrderDetails.add(orderDetails.toString());
      failedOrderDetails.remove(orderDetails);
      prefs.remove('orderDetails' + signInDetails['userId'].toString());
      prefs.setStringList('orderDetails' + signInDetails['userId'].toString(), failedOrderDetails);
    } else {
      // failedOrderDetails.add(orderDetails.toString());
      prefs.remove('orderDetails' + signInDetails['userId'].toString());
    }
  }

  removeUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('refresh_token');
    prefs.remove('mobileNo');
    prefs.remove('emailId');
    prefs.remove('userId');
    prefs.remove('userName');
  }

  addTransactionKey(String txnId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('transactionKey', txnId);
  }

  removeTransactionKey() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('transactionKey');
  }
}
