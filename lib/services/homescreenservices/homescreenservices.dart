import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:async';

// Map displayBannerMap = {};
bool displayBanner = true;
bool canDisplayAppUpdatePopup = true;
bool canUpdateUserAppInfo = true;
List filterProducts = [];
List subCategoriesList = [];
bool displayRegistrationSuccessMessage = false;
final DefaultCacheManager _cacheManager = DefaultCacheManager();
// Timer _timer;

removeImagesFromCache() {
  Timer.periodic(Duration(minutes: 15), (Timer timer) {
    // print('called');
    _cacheManager.emptyCache();
  });
}

class HomeScreenServices {
  // bool displayBanner = true;

  Future getProductListDetails(requestObj) {
    print(productListurl);
    print(requestObj);
    return BaseService().postDetails(productListurl, requestObj);
  }

  Future getProductListDetailsAfterLogin(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(productListAfterLoginUrl, requestObj);
  }

  Future getCartQuantityDetails() {
    return BaseService().getInfoByAccessToken(cartQuantityUrl);
  }

  Future getBannerDetails() {
    return BaseService().getDetails(bannerUrl);
  }

  Future getFilterListDetails() {
    return BaseService().getDetails(filterListurl);
  }

  Future getFilterListDetailsAfterLogin() {
    return BaseService().getInfoByAccessToken(filterListurlAfterLogin);
  }

  Future getCarouselDetails() {
    return BaseService().getDetails(carouselImagesUrl);
  }

  Future getCategoriesAndSubCategoriesInfo(requestObj) {
    return BaseService()
        .postDetails(getCategoriesAndSubCategoriesUrl, requestObj);
  }

  Future deleteTokenOnLogout() {
    return BaseService().getInfoByAccessToken(deleteTokenOnLogoutUrl);
  }

  Future getLatestAppVersion() {
    print(getLatestAppVersionUrl);
    return BaseService().getDetails(getLatestAppVersionUrl);
  }

  Future updateUserAppInfo(requestObj) {
    return BaseService().postDetailsByAccessToken(updateAppInfoUrl, requestObj);
  }
}
