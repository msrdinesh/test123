import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'package:cornext_mobile/constants/urls.dart';

// Map productDetails = {};
List productGalleryList = [];
Map productDetailsObject = {
  "productId": null,
  "productTypeId": null,
  "specificationId": null,
  "priceId": null
};

List<Map> previousProductDetails = [];

class ProductDetailsService {
  Future getProductDetails(requestObj) {
    return BaseService().postDetails(productDetailsUrl, requestObj);
  }

  Future getProdctDetailsTypes(requestObj) {
    return BaseService().postDetails(productDetailTypesUrl, requestObj);
  }

  Future getProductDetailsInstructions(requestObj) {
    return BaseService().postDetails(productDetailInstructions, requestObj);
  }

  Future getProductUnits(requestObj) {
    return BaseService().postDetails(productDetailUnits, requestObj);
  }

  Future getPincodeAvailability(String val) {
    return BaseService().getDetails(productPincodecheck + val);
  }

  Future addProductIntoCart(requestObj) {
    return BaseService().postDetailsByAccessToken(addToCartUrl, requestObj);
  }

  Future addProductIntoFavorites(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(addIntoFavoritesUrl, requestObj);
  }

  Future deleteProductFromFavorites(requestObj) {
    return BaseService()
        .postDetailsByAccessToken(deleteFromFavoritesUrl, requestObj);
  }

  Future getPreviousOrderedPinCode() {
    return BaseService().getInfoByAccessToken(previousOrderdedPincodeUrl);
  }

  Future getSizesOfCurrentProduct(Map requestObj) {
    return BaseService().postDetails(getSizesOfCurrentProductUrl, requestObj);
  }

  Future checkPinCodeAvalibility(requestObj) {
    return BaseService()
        .postDetails(checkPinCodeAvailableForProduct, requestObj);
  }
}
