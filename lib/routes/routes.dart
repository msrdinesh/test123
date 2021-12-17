import 'package:cornext_mobile/screens/Address/deliveryaddress.dart';
import 'package:cornext_mobile/screens/Address/editaddress.dart';
import 'package:cornext_mobile/screens/Address/newaddress.dart';
import 'package:cornext_mobile/screens/cart/cartscreen.dart';
import 'package:cornext_mobile/screens/forgotpassword/createnewpassword.dart';
import 'package:cornext_mobile/screens/forgotpassword/forgotpassword.dart';
import 'package:cornext_mobile/screens/forgotpassword/forgotpasswordotpvalidation.dart';
import 'package:cornext_mobile/screens/imageandvideos/images.dart';
import 'package:cornext_mobile/screens/imageandvideos/videos.dart';
import 'package:cornext_mobile/screens/offerDetails/offerDetailsPage.dart';
import 'package:cornext_mobile/screens/ordertracking/yourorderdetails.dart';
import 'package:cornext_mobile/screens/ordertracking/yourorders.dart';
//import 'package:cornext_mobile/screens/refundinitiationform/refundinitiationform.dart';
import 'package:cornext_mobile/screens/signin/signin.dart';
import 'package:cornext_mobile/screens/registration/registration.dart';
import 'package:cornext_mobile/screens/home/homescreen.dart';
import 'package:cornext_mobile/screens/otpvalidation/otpvalidation.dart';
import 'package:cornext_mobile/screens/subcriptions/subcription.dart';
import 'package:cornext_mobile/screens/subcriptions/subcriptionlist.dart';
import 'package:cornext_mobile/screens/subcriptions/subscriptionconfarmation.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/screens/farmdetails/farmdetails.dart';
import 'package:cornext_mobile/screens/productsearchandfilter/productsearchandfilter.dart';
import 'package:cornext_mobile/screens/productdetails/productdetails.dart';
import 'package:cornext_mobile/screens/errorscreen/errorscreen.dart';
import 'package:cornext_mobile/screens/productdetails/productdetailsimagesandvideos.dart';
import 'package:cornext_mobile/screens/ordersummary/ordersummary.dart';
import 'package:cornext_mobile/screens/feedbackform/feedbackform.dart';
import 'package:cornext_mobile/screens/orderconfirmation/orderconfirmation.dart';
import 'package:cornext_mobile/screens/subcriptions/subscriptionsummary.dart';
import 'package:cornext_mobile/screens/errorscreen/paymentfailederrorscreen.dart';
import 'package:cornext_mobile/screens/errorscreen/ordercreationfailedscreen.dart';
import 'package:cornext_mobile/screens/faqs/faqsscreen.dart';
import 'package:cornext_mobile/screens/notificationscreens/appudatescreen.dart';

RouteFactory configureRoutes() {
  return (settings) {
    // final val = settings.name;
    Widget screen;
    switch (settings.name) {
      case '/login':
        screen = SignInPage();
        break;
      case '/registration':
        screen = RegistartionPage();
        break;
      case '/home':
        screen = HomePage();
        break;
      case '/otpvalidation':
        screen = CustomerOtpValidationPage();
        break;
      case '/farmdetails':
        screen = FarmDetailsPage();
        break;
      case '/forgotpassword':
        screen = ForgotPasswordPage();
        break;
      case '/subscriptionconformation':
        screen = SubscrptionConformationPage();
        break;

      case '/image':
        screen = ImageCarousel();
        break;
      case '/subcriptionlist':
        screen = SubcriptionListPage();
        break;

      case '/otpvalidationforforgotpassword':
        screen = ForgotPasswordOtpValidationPage();
        break;
      case '/videos':
        screen = VideoDetailsPage();
        break;

      case '/CreateNewPassswordInForgotPasswordPage':
        screen = CreateNewPassswordInForgotPasswordPage();
        break;

      case '/search':
        screen = ProductSearchAndFilterPage();
        break;
      case '/productdetails':
        screen = ProductDetailsPage();
        break;
      case '/errorscreen':
        screen = ErrorScreenPage();
        break;
      case '/productvideosandimages':
        screen = ProductDetailsImagesAndVideosPage();
        break;
      case '/deliveryaddress':
        screen = AddressPage();
        break;
      case '/subscription':
        screen = SubscriptionPage();
        break;
      case '/newaddress':
        screen = NewAddressPage();
        break;
      case '/editaddress':
        screen = EditAddressPage();
        break;

      case '/yourorderdetails':
        screen = YourOrderDetailsPage();
        break;
      case '/cart':
        screen = CartPage();
        break;

      case '/ordersummary':
        screen = OrderSummaryPage();
        break;
      case '/feedback':
        screen = FeedbackPage();
        break;
      case '/OfferDetails':
        screen = OfferDeatils();
        break;
      case '/yourorders':
        screen = OrderListPage();
        break;

      case '/orderconfirmation':
        screen = OrderConfirmationPage();
        break;
      case '/subscriptionsummary':
        screen = SubscriptionSummaryPage();
        break;
      case '/paymentfailederrorscreen':
        screen = PaymentFailedErrorPage();
        break;
      case '/ordercreationfailedscreen':
        screen = OrderCreationFailedPage();
        break;
      case '/faqs':
        screen = FaqsPage();
        break;
      case '/appupdate':
        screen = AppUpdatePage();
        break;
      default:
        return null;
    }
    return MaterialPageRoute(builder: (BuildContext context) => screen);
  };
}
