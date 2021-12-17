import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

bool isNewUser = true;
bool editacconutScreen = true;
bool enablefields = false;
Map formdeateailsedit;

class RegistrationService {
  Future validateUserExitsOrNot(requestObj) {
    return BaseService().postDetails(alreadyRegistredurl, requestObj);
  }

  Future registerUser(requestObj) {
    return BaseService().postDetails(registrationUrl, requestObj);
  }

  Future validateOtps(requestObj) {
    return BaseService().postDetails(registrationValidateOtpUrl, requestObj);
  }

  Future getFarmDetails() {
    return BaseService().getDetails(farmDetailsUrl);
  }
}
