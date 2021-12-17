import 'package:cornext_mobile/models/signinmodel.dart';
// import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/baseService/baseservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
// import 'dart:convert';
// import 'package:cornext_mobile/utils/apierrors/apierror.dart';

class RefreshTokenService {
  Future getAccessTokenUsingRefreshToken() async {
    return BaseService().getAccessTokenUsingRefreshToken();
  }

  logout(state) {
    SharedPreferenceService().removeUserInfo();
    state(() {
      signInDetails = {
        "userName": 'Hello, User',
        "userId": "",
      };
      noOfProductsAddedInCart = 0;
    });
    int index = -1;
    filterProducts.forEach((val) {
      if (val['categoryName'] == 'Favorites') {
        index = filterProducts.indexOf(val);
      }
    });
    if (index != -1) {
      state(() {
        filterProducts.removeAt(index);
      });
    }
  }

  bool getAccessTokenFromData(data, context, state) {
    // print('error');
    // print(data);
    if (data['access_token'] != null) {
      signInDetails['access_token'] = data['access_token'];
      SharedPreferenceService().setAccessToken(data['access_token']);
      return true;
    } else if (data['error'] != null && data['error'] == 'invalid_token') {
      logout(state);
      return false;
    } else if (data['error'] != null && data['error'] == "invalid_grant") {
      logout(state);
      return false;
    }
    return false;
  }
  // Future val;
  // bool val = false;
  // final response = await BaseService().getAccessTokenUsingRefreshToken();
  // if (response) {
  //   if (response.body != null) {
  //     final data = json.decode(response.body);
  //     if (data['access_token'] != null) {
  //       // return true;
  //       signInDeatils['access_token'] = data['access_token'];
  //       // signInDeatils['refresh_token'] = data['refresh_token'];
  //       val = true;
  //     } else if (data['error'] != null && data['error'] != 'invalid_token') {
  //       Navigator.pushReplacementNamed(context, "/login");
  //       val = false;
  //     }
  //   }
  //   return Future.value(val);
  //   // return true;
  // } else {
  //   return Future.value(val);
  // }
  // BaseService().getAccessTokenUsingRefreshToken().then((res) {
  //   final data = json.decode(res.body);
  //   if (data['access_token'] != null) {
  //     // return Future.value(true);
  //     val = true;
  //   } else if (data['error'] != null && data['error'] == "invalid_token") {
  //     Navigator.pushReplacementNamed(context, "/login");
  //     // return Future.value(false);
  //     val = false;
  //   }
  // }, onError: (err) {
  //   ApiErros().apiErrorNotifications(err, context);
  //   // return Future.value(false);
  //   val = false;
  // }).whenComplete(() {
  //   return val;
  // });
  // return Future.value(val);
  // return val;
  // return null;
}
