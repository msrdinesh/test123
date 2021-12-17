import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

int orderIdForFeedback = 0;
String orderDateForFeedback = '';
Map geoLocationDetails = {};

class FeedBackServices {
  final BaseService baseService = BaseService();
  Future postFeedBack(requestObj) {
    return baseService.postDetailsByAccessToken(feedBackUrl, requestObj);
  }
}
