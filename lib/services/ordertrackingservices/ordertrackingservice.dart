import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

int orderId = 0;
bool isFeedBackSubmitted = false;

class OrderTrackingService {
  final BaseService baseService = BaseService();
  Future getOrderListDetails(requestObj) {
    return baseService.postDetailsByAccessToken(
        getOrderListDetailsUrl, requestObj);
  }

  Future getIndividualOrderDetails(Map requestObj) {
    return baseService.postDetailsByAccessToken(
        getIndividualOrderDetailsUrl, requestObj);
  }

  Future repeatOrderDetails(requestObj) {
    return baseService.postDetailsByAccessToken(repeatOrderurl, requestObj);
  }

  Future checkOrderLinkedWithSubscription(requestObj) {
    return baseService.postDetailsByAccessToken(
        isOrderLinkedWithSubscriptionUrl, requestObj);
  }
}
