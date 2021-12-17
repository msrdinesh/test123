// import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

class ForgotPasswordService {
  Future getOtp(requestObj) {
    return BaseService().postDetails(forgotPasswordGenerateOtpUrl, requestObj);
  }

  Future validateOtp(requestObj) {
    return BaseService().postDetails(forgotPasswordValidateOtpUrl, requestObj);
  }

  Future newpassword(requestObj) {
    return BaseService().postDetails(newPasswordUrl, requestObj);
  }
}
