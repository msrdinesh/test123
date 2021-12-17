import 'package:cornext_mobile/services/baseService/baseservice.dart';

class SignInService {
  Future validateUserCredentials(userDetails) async {
    return BaseService().validateUserCredentials(userDetails);
  }
}
