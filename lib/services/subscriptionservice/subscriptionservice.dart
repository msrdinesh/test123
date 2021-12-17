import 'package:cornext_mobile/constants/urls.dart';
import 'package:cornext_mobile/services/baseService/baseservice.dart';

Map subscriptionsData = {};
bool editSubcriptions = false;
bool isEditButtonClickedOnOrderDetails = false;
Map changeSubscriptionAddress = {};
bool isSubscriptionAddressEditing = false;

Map editOrderSubscriptionDetailsObject = {
  "productId": 0,
  "productName": null,
  "productTypeId": 0,
  "productTypeName": null,
  "brandId": 0,
  "priceId": 0,
  "resourceUrl": null,
  "specificationId": 0,
  "specificationName": null,
  "currency": null,
  "value": 0,
  "appliedAgainst": null,
  "taxRepresentation": null,
  "currencyRepresentation": null,
  "productDiscount": null,
  "minimumQuantity": 0,
  "quantity": 0,
  "quantityRepresentation": null,
  "unitsId": 0,
  "units": null
};

Map subscriptionDetails = {
  "orderId": 0,
  "subscriptionId": 0,
  // "limit": 2,
  // "pageNumber": 1
};

class SubcriptionService {
  Future getSubscriberDetails(requestObj) {
    return BaseService().postDetailsByAccessToken(subcribersUrl, requestObj);
  }

  Future getSubscriptionUnits() {
    return BaseService().getDetails(getSubcriptionUnits);
  }

  Future getEditSubscriptionDetails(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(getEditSubcribers, requestObj);
  }

  Future getUpadateOrderSubscriptionDetails(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(updateOrderSubscription, requestObj);
  }

  Future deleteOrderSubscription(int val) {
    return BaseService()
        .getInfoByAccessToken(deleteOrderSubscriptionInfo + val.toString());
  }

  Future updateSubscriptionAddress(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(changeSubscriptionAddressUrl, requestObj);
  }

  Future getPrepaidSubscriptionList(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(prepaidSubscriptionListUrl, requestObj);
  }

  Future getPostpaidSubscriptionList(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(postpaidSubscriptionListurl, requestObj);
  }

  Future getIndividualPrepaidSubscriptionDetails(int subscriptionId) {
    return BaseService().getInfoByAccessToken(
        getIndividualPrepaidSubscriptionData + subscriptionId.toString());
  }

  // Future getPincodeAvailability(String val) {
  //   return BaseService().getDetails(productPincodecheck + val);
  // }
}
