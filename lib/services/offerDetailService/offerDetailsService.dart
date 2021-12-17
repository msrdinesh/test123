import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

int offerId = 0;

class OffeerDetailsServices {
  Future getOfferDescription(Map requestObj) {
    return BaseService().postDetails(offerDetailsUrl, requestObj);
  }
}
