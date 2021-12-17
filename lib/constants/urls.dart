import 'package:cornext_mobile/constants/appconstants.dart';

//Url Prefix for production server
final String urlPrefix =
    "http://113.193.236.139:8888/cornext/v" + appVersion.toString() + "/";
//"https://mobileapis.feednext.in/cornext/v" + appVersion.toString() + "/";
//   "https://FeedNext-MobileAPIS-ELB-2044358733.ap-south-1.elb.amazonaws.com/cornext/v" +
//     appVersion.toString() +
//   "/";

final String urlPrefixWithOutAppVersion =
    "http://113.193.236.139:8888/cornext/";
//"https://mobileapis.feednext.in/cornext/";
// "https://FeedNext-MobileAPIS-ELB-2044358733.ap-south-1.elb.amazonaws.com/cornext/";

//Url Prefix for production server
// final String urlPrefix =
//     "http://113.193.236.139:9898/cornext/v" + appVersion.toString() + "/";
// final String urlPrefixWithOutAppVersion =
//     "http://113.193.236.139:9898/cornext/";

//Other production url
// final String urlPrefix =
//     "http://14.99.47.46:9898/cornext/v" + appVersion.toString() + "/";
// final String urlPrefixWithOutAppVersion =
//     "http://14.99.47.46:9898/cornext/";

//Url Prefix for development server
// final String urlPrefix =
//     "http://113.193.236.139:8888/cornext/v" + appVersion.toString() + "/";
// final String urlPrefixWithOutAppVersion =
//     "http://113.193.236.139:8888/cornext/";

final String signInUrl = urlPrefixWithOutAppVersion + "oauth/token?";
final String refreshTokenUrl = urlPrefixWithOutAppVersion +
    'oauth/token?grant_type=refresh_token&refresh_token=';
final String alreadyRegistredurl = urlPrefix + "registration/alreadyregistered";
final String registrationUrl = urlPrefix + 'registration/generateotps';
final String forgotPasswordGenerateOtpUrl =
    urlPrefix + 'forgotpasswordgenerateotp';
final String forgotPasswordValidateOtpUrl =
    urlPrefix + 'validateforgotpasswordotp';
final String newPasswordUrl = urlPrefix + 'updateuserpassword';
final String registrationValidateOtpUrl =
    '$urlPrefix' + 'registration/validateotps';
final String farmDetailsUrl = urlPrefix + 'registration/getanimaldetails';
final String productListurl = urlPrefix + 'getproductlist';
final String cartQuantityUrl = urlPrefix + 'getquantity';
final String bannerUrl = urlPrefix + 'getbannerimage/BANNER';
final String productDetailsUrl = urlPrefix + 'getproductdetails';
final String filterListurl = urlPrefix + 'getallcategories';
final String productDetailTypesUrl = urlPrefix + 'getproductdatatypes';
final String carouselImagesUrl = urlPrefix + 'getcarouselviewimages/HSCAROUSEL';
final String productDetailInstructions = urlPrefix + 'getproductinstructions';
final String productDetailUnits = urlPrefix + 'getproductunits';
final String filterListurlAfterLogin = urlPrefix + 'getallcategoriesafterlogin';
final String productPincodecheck = urlPrefix + 'getdeliverypincodes/';
final String addToCartUrl = '$urlPrefix' + 'insertintocart';
final String cartDetailsUrl = '$urlPrefix' + 'getproductsincart';
final String addressDetails = urlPrefix + 'getuseraddresses';
final String newAddressDetails = urlPrefix + 'addnewaddress';
final String updateAddressDetails = urlPrefix + 'updateaddress';
final String deleteAddressDetails = urlPrefix + 'deleteaddress';
final String addIntoFavoritesUrl = '$urlPrefix' + 'insertintofavourties';
final String deleteFromFavoritesUrl = '$urlPrefix' + 'deletefavourites';
final String productListAfterLoginUrl =
    '$urlPrefix' + 'getproductlistafterlogin';
final String deleteFromCartUrl = "$urlPrefix" + 'deletefromcart';
final String feedBackUrl = "$urlPrefix" + 'insertfeedback';
final String offerDetailsUrl = "$urlPrefix" + 'getofferdescription';

final String pofileDetailsUrl = '$urlPrefix' + 'getuserprofile';
final String updateUserDetails = '$urlPrefix' + 'updateuserprofile';

final String registrationDiscountDetails =
    "$urlPrefix" + "getRegistartiondiscountdetails";
final String couponCodeUrl = "$urlPrefix" + "getprivatecoupondetails";
final String sendOrderDetailsurl = "$urlPrefix" + "insertorderdetails";
final String orderConfirmationurl =
    "$urlPrefix" + "getorderconfirmationdetails";
final String subcribersUrl = "$urlPrefix" + "getsubscribedorders";
final String getSubcriptionUnits = "$urlPrefix" + "getsubscriptionunits";
final String getEditSubcribers = "$urlPrefix" + "getordersubscriptiondetails";
final String reasonsForRefund = '$urlPrefix' + 'getrefundreasons';
final String updateReason = '$urlPrefix' + 'insertrefund';
final String getOrderListDetailsUrl = '$urlPrefix' + 'getordertrakingdetails';
final String updateOrderSubscription = "$urlPrefix" + 'updateordersubscription';
final String deleteOrderSubscriptionInfo =
    "$urlPrefix" + 'deactivatesubscription/';
final String getIndividualOrderDetailsUrl = "$urlPrefix" + 'getorderdetails';
final String updateOrderAddressUrl = "$urlPrefix" + 'updateorderadress';
final String changeSubscriptionAddressUrl =
    "$urlPrefix" + 'updatesubscribedorderaddress';
final String checkAddressLinkedWithSubscriptionsurl =
    '$urlPrefix' + 'issubscribedaddress/';
final String checkPinCodeAvailabilityUrl = '$urlPrefix' + 'ispincodeavailable/';
final String previousOrderdedPincodeUrl = '$urlPrefix' + 'getprevorderpincode';
final String repeatOrderurl = "$urlPrefix" + 'reapeatorder';
final String orderDetailsFromDeepLinkUrl = '$urlPrefix' + 'getorderdata/';
final String isOrderLinkedWithSubscriptionUrl =
    '$urlPrefix' + 'subscribedorderornot';
final String getCategoriesAndSubCategoriesUrl =
    "$urlPrefix" + "getallcategories";
final String prepaidSubscriptionListUrl =
    '$urlPrefix' + 'getprepaidsubscribedorders';
final String postpaidSubscriptionListurl =
    '$urlPrefix' + 'getpostpaidsubscribedorders';
final String getIndividualPrepaidSubscriptionData =
    '$urlPrefix' + "getsubscriptiondrilldowndata/";
final String getSizesOfCurrentProductUrl = '$urlPrefix' + 'getproductsizes';
final String checkPinCodeAvailableForProduct =
    '$urlPrefix' + 'checkAvailability';
final String removeProductsFromErpDataTableUrl =
    '$urlPrefix' + 'deletequantity/';
final String checkPinCodeAvailableForCartProductsUrl =
    '$urlPrefix' + 'getAvailability/';
final String deleteTokenOnLogoutUrl = '$urlPrefix' + 'deleteToken';
final String getStatesurl = '$urlPrefix' + 'registration/getstates';
final String getHashUrl = '$urlPrefix' + 'gethash';
final String addQuantityToInventoryUrl = '$urlPrefix' + 'addquantity/';
final String checkPincodeIsLinkedWithActiveOrdersUrl =
    '$urlPrefix' + 'getcurrentordershippingadresscount';
final String getLatestAppVersionUrl =
    urlPrefixWithOutAppVersion + 'getappversion';
final String updateAppInfoUrl = urlPrefix + 'updateuserappversion';
final String razorPayCreateOrderUrl = 'https://api.razorpay.com/v1/orders';
final String razorPayGetPaymentDetailsUrl =
    'https://api.razorpay.com/v1/payments/';
final String getRazorPayKeyUrl =
    '$urlPrefixWithOutAppVersion' + 'getrazorpaycredentials';
