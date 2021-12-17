import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

// Map displayBannerMap = {};
//bool displayBanner = true;
//List filterProducts = [];
Map editAddressList = {};

class ProfileServies {
  // bool displayBanner = true;

  Future getProfileDetails() {
    return BaseService().getInfoByAccessToken(pofileDetailsUrl);
  }

  Future updateProfileDetails(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(updateUserDetails, requestObj);
  }
}
