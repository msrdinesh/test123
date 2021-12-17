import 'package:http/http.dart' as http;
// import 'package:http/io_client.dart';
// import 'dart:io';
import 'package:cornext_mobile/constants/urls.dart';
import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/utils/utilities/utilities.dart';
// import 'dart:io';

class BaseService {
  final String clientId = "template-client";
  final String clientSecret = "template-client";
  // String code = Uri().queryParameters["code"];
  String granttype = "password";
  final Utilities _utilities = Utilities();
  // IOClient http = new IOClient(new HttpClient()
  //   ..badCertificateCallback =
  //       ((X509Certificate cert, String host, int port) => false));

  Future postDetails(String url, requestObj) {
    return http.post(url, body: json.encode(requestObj), headers: {
      'Content-type': 'application/json',
    });
  }

  Future getDetails(String url) {
    return http.get(url, headers: {
      'Content-type': 'application/json',
    });
  }
  // Future getDetailss(String url,request){
  //   return http.get(url,queryParameters: request);
  // }

  Future validateUserCredentials(Map userDetails) async {
    // final headers = HttpHeaders.
    // var queryParameters = {
    //   'username': userDetails['username'].toString(),
    //   'password': userDetails['password'].toString(),
    //   'grant_type': 'password'
    // };
    // var uri = Uri.http('113.193.236.139:9898/cornext/', '', queryParameters);
    String encodedPassword = _utilities.passwordEncode(userDetails['password']);
    print(encodedPassword);
    return http.post(
        signInUrl +
            'username=' +
            userDetails['username'] +
            '&password=' +
            encodedPassword +
            '&grant_type=password',
        headers: {
          // "client_id": clientId,
          // "client_secret": clientSecret,
          'Content-type': 'application/json',
          'authorization':
              'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret'))
        });
  }

  Future postDetailsByAccessToken(String url, requestObj) {
    // if (getAccessToken() != null) {
    final String token = signInDetails['access_token'];
    return http.post(url, body: json.encode(requestObj), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    // } else {
    //   return null;
    // }
  }

  Future postToRazorPay(String url, requestObj, key, secret) async {
    return http.post(url, body: json.encode(requestObj), headers: {
      'Content-type': 'application/json',
      'authorization': 'Basic ' + base64Encode(utf8.encode('$key:$secret'))
    });
  }

  Future getFromRazorPay(String url, key, secret) async {
    return http.get(url, headers: {
      'Content-type': 'application/json',
      'authorization': 'Basic ' + base64Encode(utf8.encode('$key:$secret'))
    });
  }

  Future getInfoByAccessToken(url) {
    final String token = signInDetails['access_token'];
    return http.get(url, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
  }

  Future getInfoByUserId(url) {
    final String token = signInDetails['access_token'];
    // print(signInDeatils['userId']);
    final String userId = signInDetails['userId'].toString();
    // print(userId);
    return http.get(url + userId.toString(), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
  }

  Future getAccessTokenUsingRefreshToken() {
    final token = signInDetails['refresh_token'];
    return http.post(refreshTokenUrl + "$token", headers: {
      'Content-type': 'application/json',
      'authorization':
          'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret'))
    });
  }
}
