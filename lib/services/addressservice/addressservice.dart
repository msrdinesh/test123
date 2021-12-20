import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

// Map displayBannerMap = {};
// bool displayBanner = true;
// List filterProducts = [];
Map selectedDeliveryAddress = {};
bool isDeliveryAddress = false;
bool isAddressEditing = false;
bool isNavigatingFromDelivarypage = false;
Map editAddressDetails = {};
int repeatOrderAddressId = 0;
bool isRepeatOrder = false;
bool isRepeatPreviousOrder = false;
int repeatPreviousOrderAddressId = 0;
bool isAddressEdited = false;
bool isNewAddressCreated = false;

Map addressDetailsObject = {
  "addressId": 0,
  "doorNumber": null,
  "street": null,
  "city": null,
  "state": null,
  "pincode": null,
  "mobileNo": null,
  "countryCode": 91,
  "limit": 3,
  "pageNumber": 1
};

class AddressServices {
  // bool displayBanner = true;

  Future getAddressDetails(requestObj) {
    print("in getAddressDetials");
    return BaseService().postDetailsByAccessToken(addressDetails, requestObj);
  }

  Future getNewAddressDetails(requestObj) {
    return BaseService().postDetailsByAccessToken(newAddressDetails, requestObj);
  }

  Future getUpdateAddressDetails(requestObj) {
    return BaseService().postDetailsByAccessToken(updateAddressDetails, requestObj);
  }

  Future getDeleteAddress(requestObj) {
    return BaseService().postDetailsByAccessToken(deleteAddressDetails, requestObj);
  }

  Future updateOrderAddressDetails(requestObj) {
    return BaseService().postDetailsByAccessToken(updateOrderAddressUrl, requestObj);
  }

  Future checkAddressLinkedWithSubscriptions(int addressId) {
    return BaseService().getInfoByAccessToken(checkAddressLinkedWithSubscriptionsurl + addressId.toString());
  }

  Future checkPincodeAvailability(String pincode) {
    return BaseService().getInfoByAccessToken(checkPinCodeAvailabilityUrl + pincode.toString());
  }

  Future checkPinCodeAvailabilityForCartProducts(String addressId) {
    return BaseService().getInfoByAccessToken(checkPinCodeAvailableForCartProductsUrl + addressId.toString());
  }

  Future checkPincodeLinkedWithActiveOrders(requestObj) {
    return BaseService().postDetailsByAccessToken(checkPincodeIsLinkedWithActiveOrdersUrl, requestObj);
  }

  Future getStates() {
    return BaseService().getDetails(getStatesurl);
  }
}
