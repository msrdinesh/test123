import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

class RefundInitiationService {
  Future getRefundeReasons() {
    return BaseService().getInfoByAccessToken(reasonsForRefund);
  }

  Future updateReasons(requestObj) {
    return BaseService().postDetailsByAccessToken(updateReason, requestObj);
  }
}
