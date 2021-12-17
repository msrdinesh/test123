import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

List storeCartDetails = [];
bool isNavigatedFromCartPage = false;
bool isNavigatedFromSignInPage = false;

class CartService {
  final BaseService baseService = BaseService();
  Future getCartDetails(requestObj) {
    return baseService.postDetailsByAccessToken(cartDetailsUrl, requestObj);
  }

  Future deleteProductFromCart(requestObj) {
    return baseService.postDetailsByAccessToken(deleteFromCartUrl, requestObj);
  }

  Future getOrderDetailsFromDeepLink(String orderId) {
    return BaseService()
        .getInfoByAccessToken(orderDetailsFromDeepLinkUrl + orderId.toString());
  }
}
