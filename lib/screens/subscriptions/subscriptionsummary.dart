import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:cornext_mobile/services/cartservice/cartservice.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:intl/intl.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'dart:convert';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/ordersummaryservice/ordersummaryservice.dart';
import 'package:cornext_mobile/services/subscriptionservice/subscriptionservice.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
// import 'package:http/http.dart' as http;
import 'package:cornext_mobile/services/orderconfirmationservice/orderconfirmationservice.dart';
import 'package:flutter/services.dart';
import 'package:cornext_mobile/constants/urls.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionSummaryPage extends StatefulWidget {
  @override
  SubscriptionSummary createState() => SubscriptionSummary();
}

class SubscriptionSummary extends State<SubscriptionSummaryPage> {
  int cartProductslimit = 15;
  int pageNo = 1;
  double _buttonWidth = 30;
  final CartService cartService = CartService();
  final RefreshTokenService refreshTokenService = RefreshTokenService();
  final ApiErros apiErros = ApiErros();
  Map cartDetails = {};
  List listOfCartDetails = [];
  List priceOfProducts = [];
  final currencyFormatter = NumberFormat('#,##,###.00');
  double priceOfTotalProducts = 0;
  final AppStyles appStyles = AppStyles();
  final ProductDetailsService productDetailsService = ProductDetailsService();
  // bool makeAdvancePayment = false;
  double discounntedAmount = 0;
  double actualPriceOfCurrentOrder = 0;
  String currencyRepresentation = '';
  final couponCodeController = TextEditingController();
  final couponCodeKey = GlobalKey<FormFieldState>();
  final advancePaymentController = TextEditingController();
  final advancePaymentkey = GlobalKey<FormFieldState>();
  final advancePaymentFocusNode = FocusNode();
  double actualSubscribedPrice = 0.0;
  double subscribedprice = 0.0;
  int previousNoofSubscriptions = 0;
  Map userRegistrationDiscountInfo = {};
  double couponDiscount = 0.0;
  String couponCodeErrors = "";
  final OrderSummaryService orderSummaryService = OrderSummaryService();
  double registrationDiscount = 0.0;
  double totalTaxAmount = 0;
  double taxAmountWithSubscription = 0;
  double productDiscountAmount = 0;
  String couponCodeSuccessMessages = '';
  bool isLoading = false;
  final totalAmountKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  bool isLoadingIconDisplaying = false;
  List subscriptionUnits = [];
  var subscriptionController = TextEditingController();
  final subscriptionKey = GlobalKey<FormFieldState>();
  FocusNode subscriptionFocus = FocusNode();
  List<String> subscriptionTimeRelatedData = ['Days', "Weeks", 'Months'];
  String dropdownValue = "Days";
  String currentUnitType;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('feednext/paymentgateway');
  final SharedPreferenceService _sharedPreferenceService =
      SharedPreferenceService();
  final AppFonts appFonts = AppFonts();
  bool isBackButtonPressed = false;
  bool isQuantityFieldOnFocus = false;

  Razorpay _razorpay;

  void initState() {
    if (orderIdFromDeepLink != "") {
      getOrderDetailsFromDeepLink();
    } else {
      getCartDetails();
      checkAdvancePaymentValidations();
      getSubscriptions();
      if (currentOrderInfo['couponDetails'] != null &&
          currentOrderInfo['couponDetails']['couponDiscount'] > 0) {
        couponDiscount = currentOrderInfo['couponDetails']['couponDiscount'];
        setState(() {});
      }
      super.initState();
    }

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  checkAdvancePaymentValidations() {
    GlobalValidations().validateCurrentFieldValidOrNot(
        advancePaymentFocusNode, advancePaymentkey);
    // print(subscriptionController);
    if (subscriptionController != null &&
        subscriptionController.text.trim() != '') {
      GlobalValidations()
          .validateCurrentFieldValidOrNot(subscriptionFocus, subscriptionKey);
    }
  }

  getOrderDetailsFromDeepLink() {
    orderSummaryService.getOrderDetailsFromDeepLink(orderIdFromDeepLink).then(
        (val) {
      final data = json.decode(val.body);
      if (data['listOfProducts'] != null) {
        setState(() {
          cartDetails = data;
          selectedDeliveryAddress = data['deliveryAddress'];
          // listOfCartDetails = data['listOfProductsInCart'];
          addControllers(data['listOfProducts']);
          getQuantityInfo();
          setQuantityFocusNodes();
          getTotalAmount(listOfCartDetails);
          getRegistrationDiscountInfo();
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getOrderDetailsFromDeepLink();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(
          err, context, '/ordersummary', scaffoldKey);
    });
  }

  // Fetch the cart details from back end
  getCartDetails() {
    final requestObj = {
      'limit': cartProductslimit,
      'pageNumber': pageNo,
      'screenName': 'HS'
    };
    setState(() {
      isLoading = true;
    });
    cartService.getCartDetails(requestObj).then((res) {
      final data = json.decode(res.body);
      if (data['listOfProductsInCart'] != null &&
          data['noOfItemsInCart'] != null &&
          int.parse(data['noOfItemsInCart']) > 0) {
        setState(() {
          cartDetails = data;
          // listOfCartDetails = data['listOfProductsInCart'];
          addControllers(data['listOfProductsInCart']);
          getQuantityInfo();
          setQuantityFocusNodes();
          getTotalAmount(listOfCartDetails);
          getRegistrationDiscountInfo();
        });
      } else if (data['noOfItemsInCart'] != null &&
          int.parse(data['noOfItemsInCart']) == 0) {
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getCartDetails();
          }
        });
      }
      setState(() {
        isLoading = false;
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      apiErros.apiErrorNotifications(err, context, '/cart', scaffoldKey);
    });
  }

  getRegistrationDiscountInfo() {
    orderSummaryService.getUserRegistrationDiscountDetails().then((val) {
      // print(val.body);
      if (val.body != "") {
        final data = json.decode(val.body);
        if (data != null && data['registrationDiscountId'] != null) {
          userRegistrationDiscountInfo = data;
          addUserRegistrationDiscount(true);
        } else if (data['error'] != null && data['error'] == "invalid_token") {
          RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (RefreshTokenService()
                .getAccessTokenFromData(refreshTokenData, context, setState)) {
              getCartDetails();
            }
          });
        }
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(
          err, context, '/ordersummary', scaffoldKey);
    });
  }

  addUserRegistrationDiscount(bool updateTotalAmount) {
    registrationDiscount = 0.0;
    setState(() {});
    if (userRegistrationDiscountInfo != null &&
        userRegistrationDiscountInfo['active'] != null &&
        userRegistrationDiscountInfo['active'] &&
        updateTotalAmount) {
      if (subscriptionController.text.trim() != "" &&
          subscriptionKey.currentState.validate() &&
          advancePaymentkey.currentState.validate() &&
          advancePaymentController.text.trim() != "") {
        if (userRegistrationDiscountInfo['minimumOrderAmount'] != null) {
          if (subscribedprice >
              userRegistrationDiscountInfo['minimumOrderAmount']) {
            if (int.parse(advancePaymentController.text.trim()) >
                userRegistrationDiscountInfo['noOfOrders']) {
              setState(() {
                // print(userRegistrationDiscountInfo['noOfOrders']);
                // print(actualSubscribedPrice);
                // print(subscribedprice);
                // print(userRegistrationDiscountInfo['discountAmountPerOrder']);
                subscribedprice = subscribedprice -
                    (userRegistrationDiscountInfo['discountAmountPerOrder'] *
                        userRegistrationDiscountInfo['noOfOrders']);

                // print(subscribedprice);
                registrationDiscount =
                    ((userRegistrationDiscountInfo['discountAmountPerOrder'] +
                            0.0) *
                        userRegistrationDiscountInfo['noOfOrders']);
                // });
              });
            } else {
              setState(() {
                subscribedprice = subscribedprice -
                    (userRegistrationDiscountInfo['discountAmountPerOrder'] *
                        int.parse(advancePaymentController.text.trim()));
                registrationDiscount =
                    ((userRegistrationDiscountInfo['discountAmountPerOrder'] +
                            0.0) *
                        int.parse(advancePaymentController.text.trim()));
              });
            }
          }
        } else {
          if (int.parse(advancePaymentController.text.trim()) >
              userRegistrationDiscountInfo['noOfOrders']) {
            setState(() {
              subscribedprice = subscribedprice -
                  (userRegistrationDiscountInfo['discountAmountPerOrder'] *
                      userRegistrationDiscountInfo['noOfOrders']);
              registrationDiscount =
                  ((userRegistrationDiscountInfo['discountAmountPerOrder'] +
                          0.0) *
                      userRegistrationDiscountInfo['noOfOrders']);
            });
          } else {
            setState(() {
              subscribedprice = subscribedprice -
                  (userRegistrationDiscountInfo['discountAmountPerOrder'] *
                      int.parse(advancePaymentController.text.trim()));
              registrationDiscount =
                  ((userRegistrationDiscountInfo['discountAmountPerOrder'] +
                          0.0) *
                      int.parse(advancePaymentController.text.trim()));
            });
          }
        }
      } else {
        if (userRegistrationDiscountInfo['minimumOrderAmount'] != null) {
          if (priceOfTotalProducts >
              userRegistrationDiscountInfo['minimumOrderAmount']) {
            setState(() {
              priceOfTotalProducts = priceOfTotalProducts -
                  userRegistrationDiscountInfo['discountAmountPerOrder'];
              registrationDiscount =
                  userRegistrationDiscountInfo['discountAmountPerOrder'] + 0.0;
            });
          }
        } else {
          setState(() {
            priceOfTotalProducts = priceOfTotalProducts -
                userRegistrationDiscountInfo['discountAmountPerOrder'];
            registrationDiscount =
                userRegistrationDiscountInfo['discountAmountPerOrder'];
          });
        }
      }
    } else if (userRegistrationDiscountInfo != null &&
        userRegistrationDiscountInfo['active'] != null &&
        userRegistrationDiscountInfo['active']) {
      if (userRegistrationDiscountInfo['minimumOrderAmount'] != null) {
        if (priceOfTotalProducts >
            userRegistrationDiscountInfo['minimumOrderAmount']) {
          registrationDiscount =
              userRegistrationDiscountInfo['discountAmountPerOrder'] + 0.0;
          setState(() {});
        }
      } else {
        registrationDiscount =
            userRegistrationDiscountInfo['discountAmountPerOrder'] + 0.0;
        setState(() {});
      }
    }
  }

  addControllers(List cartInfo) {
    if (cartInfo.length > 0) {
      cartInfo.forEach((res) {
        final obj = res;
        obj['controller'] = TextEditingController();
        obj['key'] = GlobalKey<FormFieldState>();
        obj['focusNode'] = FocusNode();
        obj['numberOfItems'] = res['quantity'].round();
        // setState(() {
        //   obj['controller'].text = res['quantity'];
        // });
        listOfCartDetails.add(obj);
      });
    }
  }

  setQuantityFocusNodes() {
    listOfCartDetails.forEach((res) {
      validateCurrentQuantityField(res['focusNode'], res['key'], context, res);
    });
  }

  validateCurrentQuantityField(FocusNode focusNode,
      GlobalKey<FormFieldState> key, context, Map response) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (!key.currentState.validate()) {
          // closeNotifications();
          clearErrorMessages(scaffoldKey);
          showErrorNotifications(
              key.currentState.errorText, context, scaffoldKey);
        } else {
          // updateTotalPriceOfProducts(
          //     response['priceId'], response['numberOfItems']);
          if (orderIdFromDeepLink != "") {
            response['numberOfItems'] =
                int.parse(response['controller'].text.trim());
            updateQuantityDetails(
                response['numberOfItems'], response['productId']);
            updateTotalPriceOfProducts(
                response['productId'], response['numberOfItems']);
            response['key'].currentState?.validate();
            if (totalAmountKey != null) {
              RenderBox box = totalAmountKey.currentContext.findRenderObject();
              Offset position = box.localToGlobal(Offset.zero);
              scrollController.jumpTo(position.dy);
            }
          } else {
            response['numberOfItems'] =
                int.parse(response['controller'].text.trim());
            updateQuantityDetailsOnCart(response, response['numberOfItems']);
          }
        }
      }
    });
  }

  getQuantityInfo() {
    listOfCartDetails.forEach((res) {
      if (res['controller'] != null && res['quantity'] != null) {
        setState(() {
          res['controller'].text = res['quantity'].round().toString();
        });
      }
    });
  }

  // Show Loading Icon On Updating/Deleting Cart Details
  displayLoadingIcon(context) {
    setState(() {
      isLoadingIconDisplaying = true;
    });
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {
                // listOfCartDetails.forEach((val) {
                //   if (val['focusNode'] != null) {
                //     val['focusNode'].unfocus();
                //   }
                // });
                // if (isLoadingIconDisplaying) {
                //   Navigator.of(context).pop();
                // }
                return Future.value(true);
              },
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 100,
                child: customizedCircularLoadingIconWithColorAndSize(
                    50, Colors.white),
              ));
        });
  }

  getSubscribedAmount(bool isQuantityUpdated) {
    if (advancePaymentkey.currentState.validate() &&
        advancePaymentController.text.trim() != "") {
      // getCartProductDetails();
      if (previousNoofSubscriptions == 0 ||
          (previousNoofSubscriptions !=
              int.parse(advancePaymentController.text.trim())) ||
          isQuantityUpdated) {
        if (userRegistrationDiscountInfo != null &&
            userRegistrationDiscountInfo['active'] != null &&
            userRegistrationDiscountInfo['active'] &&
            registrationDiscount > 0) {
          setState(() {
            actualSubscribedPrice = (actualPriceOfCurrentOrder) *
                int.parse(advancePaymentController.text);
            subscribedprice = (priceOfTotalProducts +
                    userRegistrationDiscountInfo['discountAmountPerOrder']) *
                int.parse(advancePaymentController.text.trim());
            previousNoofSubscriptions =
                int.parse(advancePaymentController.text.trim());
            taxAmountWithSubscription = totalTaxAmount *
                int.parse(advancePaymentController.text.trim());
            addUserRegistrationDiscount(true);
          });
        } else {
          setState(() {
            // print(advancePaymentController.text);
            actualSubscribedPrice = actualPriceOfCurrentOrder *
                int.parse(advancePaymentController.text);
            // print(actualSubscribedPrice);
            subscribedprice = priceOfTotalProducts *
                int.parse(advancePaymentController.text.trim());
            previousNoofSubscriptions =
                int.parse(advancePaymentController.text.trim());
            taxAmountWithSubscription = totalTaxAmount *
                int.parse(advancePaymentController.text.trim());
            addUserRegistrationDiscount(true);
          });
        }
      }
    }
  }

  // Update QuantityDetails On DataBase Cart
  updateQuantityDetailsOnCart(obj, int quantity) {
    Map returnObj = {"cart": []};
    Map requestObj = {
      'productId': obj['productId'],
      'productTypeId': obj['productTypeId'],
      'specificationId': obj['specificationId'],
      'priceId': obj['priceId'],
      'quantity': quantity,
      'brandId': obj['brandId'] != null ? obj['brandId'] : null,
      'isAppend': false
    };
    returnObj['cart'].add(requestObj);
    displayLoadingIcon(context);
    productDetailsService.addProductIntoCart(returnObj).then((res) {
      dynamic data;
      if (res.body != null && res.body == "FAILED") {
        data = res.body;
      } else {
        data = json.decode(res.body);
      }
      if (data.runtimeType == int && data > 0) {
        // closeNotifications();
        clearErrorMessages(scaffoldKey);
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
          noOfProductsAddedInCart = data;
        });

        print(quantity);
        updateQuantityDetails(quantity, obj['productId']);
        updateTotalPriceOfProducts(obj['productId'], quantity);
        obj['key'].currentState?.validate();
        if (isBackButtonPressed) {
          manageBackButtonClick();
        }
        // else if (isQuantityFieldOnFocus) {
        //   manageOrderDispatch();
        // }
        // if (totalAmountKey != null) {
        //   RenderBox box = totalAmountKey.currentContext.findRenderObject();
        //   Offset position = box.localToGlobal(Offset.zero);
        //   scrollController.jumpTo(position.dy);
        // }
      } else if (data == 'FAILED') {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
        });
        clearErrorMessages(scaffoldKey);
        showErrorNotifications(
            "Failed to update the cart", context, scaffoldKey);
        updateQuantityDetails(obj['numberOfItems'], obj['productId']);
        obj['key'].currentState?.validate();
        if (isBackButtonPressed) {
          manageBackButtonClick();
        }
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
        });
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (refreshTokenService.getAccessTokenFromData(
                refreshTokenData, context, setState)) {
              updateQuantityDetailsOnCart(obj, quantity);
            } else {
              if (isBackButtonPressed) {
                manageBackButtonClick();
              }
            }
          },
        );
      } else if (data['error'] != null &&
          data['error'] == "Internal Server Error") {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
        });
        updateQuantityDetails(obj['numberOfItems'], obj['productId']);
        if (isBackButtonPressed) {
          manageBackButtonClick();
        }
      } else if (data['error'] != null) {
        Navigator.pop(context);
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
        updateQuantityDetails(obj['numberOfItems'], obj['productId']);
        if (isBackButtonPressed) {
          manageBackButtonClick();
        }
      }
    }, onError: (err) {
      Navigator.pop(context);
      setState(() {
        isLoadingIconDisplaying = false;
      });
      updateQuantityDetails(obj['numberOfItems'], obj['productId']);
      apiErros.apiErrorNotifications(err, context, '/cart', scaffoldKey);
      if (isBackButtonPressed) {
        manageBackButtonClick();
      }
    });
  }

  // UpDate Quantity Details Locally
  updateQuantityDetails(int quantity, int productId) {
    listOfCartDetails.forEach((res) {
      if (res['productId'] == productId) {
        setState(() {
          res['controller'].text = quantity.toString();
          res['numberOfItems'] = quantity;
          // res['quantity'] = quantity;
        });
      }
    });
    // getTotalAmount(priceOfProducts);
  }

  // UpDate Total Price In Cart
  updateTotalPriceOfProducts(int productId, int quantity) {
    List updatedPriceOfProducts = [];
    bool isQuantityChanged = false;
    listOfCartDetails.forEach((val) {
      Map obj = val;
      print(val['quantity']);
      if (val['productId'] == productId && val['quantity'] != quantity) {
        obj['quantity'] = quantity;
        isQuantityChanged = true;
        updatedPriceOfProducts.add(obj);
      } else {
        updatedPriceOfProducts.add(obj);
      }
    });
    if (isQuantityChanged) {
      setState(() {
        listOfCartDetails = updatedPriceOfProducts;
        getTotalAmount(listOfCartDetails);
        // addUserRegistrationDiscount(true);
        if (userRegistrationDiscountInfo != null &&
            userRegistrationDiscountInfo['active'] != null &&
            userRegistrationDiscountInfo['active']) {
          if (userRegistrationDiscountInfo['minimumOrderAmount'] != null) {
            if (priceOfTotalProducts >
                userRegistrationDiscountInfo['minimumOrderAmount']) {
              setState(() {
                priceOfTotalProducts = priceOfTotalProducts -
                    userRegistrationDiscountInfo['discountAmountPerOrder'];
                registrationDiscount =
                    userRegistrationDiscountInfo['discountAmountPerOrder'] +
                        0.0;
              });
            }
          } else {
            setState(() {
              priceOfTotalProducts = priceOfTotalProducts -
                  userRegistrationDiscountInfo['discountAmountPerOrder'];
              registrationDiscount =
                  userRegistrationDiscountInfo['discountAmountPerOrder'];
            });
          }
        }
        // print(actualPriceOfCurrentOrder);
        // print(priceOfTotalProducts);
        if ((subscriptionController.text.trim() != "" &&
                subscriptionKey.currentState.validate()) &&
            (advancePaymentController.text.trim() != "" &&
                advancePaymentkey.currentState.validate())) {
          // print('enters');
          getSubscribedAmount(true);
          // addUserRegistrationDiscount()
        } else {
          setState(() {
            subscribedprice = 0;
            actualSubscribedPrice = 0;
            previousNoofSubscriptions = 0;
            taxAmountWithSubscription = 0;
            // advancePaymentController.clear();
            // advancePaymentkey.currentState?.reset();
          });
          // addUserRegistrationDiscount(true);
        }
      });
    }

    Timer(Duration(milliseconds: 10), () {
      if (isQuantityFieldOnFocus) {
        manageOrderDispatch();
      }
    });
  }

  deleteProductFromCart(res) {
    print(res);
    Map requestObj = {
      'productId': res['productId'],
      'productTypeId': res['productTypeId'],
      'specificationId': res['specificationId'],
      'priceId': res['priceId'],
      'brandId': res['brandId'] != null ? res['brandId'] : null
    };
    displayLoadingIcon(context);
    cartService.deleteProductFromCart(requestObj).then((val) {
      dynamic data;
      if (val.body != null && val.body == "FAILED") {
        data = val.body;
      } else {
        data = json.decode(val.body);
      }
      if (data.runtimeType == int) {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
          noOfProductsAddedInCart = data;
        });
        removeItemFromCart(res);
        // addUserRegistrationDiscount(true);
      } else if (val.body != null && val.body == "FAILED") {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
        });
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            if (refreshTokenService.getAccessTokenFromData(
                refreshTokenData, context, setState)) {
              deleteProductFromCart(res);
            }
          },
        );
      } else if (data['error'] != null &&
          data['error'] == "Internal Server Error") {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
        });
      }
    }, onError: (err) {
      Navigator.pop(context);
      setState(() {
        isLoadingIconDisplaying = false;
      });
      // updateQuantityDetails(obj['numberOfItems'], obj['priceId']);
      apiErros.apiErrorNotifications(err, context, '/cart', scaffoldKey);
    });
  }

  //Removes Product From Cart
  removeItemFromCart(obj) {
    listOfCartDetails.removeAt(listOfCartDetails.indexOf(obj));
    // print(listOfCartDetails);
    setState(() {});
    getTotalAmount(listOfCartDetails);
    print(actualPriceOfCurrentOrder);
    print(priceOfTotalProducts);
    if (userRegistrationDiscountInfo != null &&
        userRegistrationDiscountInfo['active'] != null &&
        userRegistrationDiscountInfo['active']) {
      if (userRegistrationDiscountInfo['minimumOrderAmount'] != null) {
        if (priceOfTotalProducts >
            userRegistrationDiscountInfo['minimumOrderAmount']) {
          setState(() {
            priceOfTotalProducts = priceOfTotalProducts -
                userRegistrationDiscountInfo['discountAmountPerOrder'];
            registrationDiscount =
                userRegistrationDiscountInfo['discountAmountPerOrder'] + 0.0;
          });
        }
      } else {
        setState(() {
          priceOfTotalProducts = priceOfTotalProducts -
              userRegistrationDiscountInfo['discountAmountPerOrder'];
          registrationDiscount =
              userRegistrationDiscountInfo['discountAmountPerOrder'];
        });
      }
    }
    if ((subscriptionController.text.trim() != "" &&
            subscriptionKey.currentState.validate()) &&
        (advancePaymentController.text.trim() != "" &&
            advancePaymentkey.currentState.validate())) {
      // print('enters');
      getSubscribedAmount(true);
      // addUserRegistrationDiscount()
    } else {
      setState(() {
        subscribedprice = 0;
        actualSubscribedPrice = 0;
        previousNoofSubscriptions = 0;
        taxAmountWithSubscription = 0;
        // advancePaymentController.clear();
        // advancePaymentkey.currentState?.reset();
      });
      // addUserRegistrationDiscount(true);
    }
  }

  // Display Cart Details
  List<Widget> getCartProductDetails() {
    setState(() {
      totalTaxAmount = 0.0;
      productDiscountAmount = 0.0;
      priceOfProducts = [];
    });
    return listOfCartDetails.map((res) {
      // print(res);
      double priceOfCurrentProduct = 0.0;
      if (res['currencyRepresentation'] != null) {
        setState(() {
          currencyRepresentation = res['currencyRepresentation'].toString();
        });
      }
      if (res['taxpercent'] != null) {
        final double taxValue = res['value'] *
            int.parse(res['taxpercent'].toString().replaceAll('%', '')) /
            100;
        setState(() {
          //Uncomment this to add taxvalue;
          // priceOfCurrentProduct = res['value'] + taxValue;
          // upto here;

          // Comment this to add Tax value;
          priceOfCurrentProduct = res['value'];
          // upto here
          totalTaxAmount = (totalTaxAmount + (taxValue * res['quantity']));
        });
        // print(priceOfCurrentProduct);
      } else {
        setState(() {
          priceOfCurrentProduct = res['value'];
        });
      }
      if (res['units'] != null) {
        if (res['units'] == "Metric Ton") {
          if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
            if (res['quantity'] * 1000 >= res['minimumQuantity']) {
              productDiscountAmount = productDiscountAmount +
                  (((priceOfCurrentProduct * 1000) -
                          (res['discountPrice'] * 1000)) *
                      res['numberOfItems']);
              // (((priceOfCurrentProduct * 1000) *
              //         int.parse(res['productDiscount']
              //             .toString()
              //             .replaceAll('%', '')) /
              //         100) *
              //     res['numberOfItems']);
              priceOfCurrentProduct = res['discountPrice'];
              // priceOfCurrentProduct -
              //     (priceOfCurrentProduct) *
              //         int.parse(res['productDiscount']
              //             .toString()
              //             .replaceAll('%', '')) /
              //         100;
            }
          } else if (res['discountPrice'] != null) {
            productDiscountAmount = productDiscountAmount +
                (((priceOfCurrentProduct * 1000) -
                        (res['discountPrice'] * 1000)) *
                    res['numberOfItems']);
            priceOfCurrentProduct = res['discountPrice'];
          }
        }
      } else {
        if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
          if (res['quantity'] >= res['minimumQuantity']) {
            productDiscountAmount = productDiscountAmount +
                ((priceOfCurrentProduct - res['discountPrice']) *
                    res['numberOfItems']);
            // (((priceOfCurrentProduct) *
            //         int.parse(res['productDiscount']
            //             .toString()
            //             .replaceAll('%', '')) /
            //         100) *
            //     res['numberOfItems']);
            priceOfCurrentProduct = res['discountPrice'];
          }
        } else if (res['discountPrice'] != null) {
          productDiscountAmount = productDiscountAmount +
              ((priceOfCurrentProduct - res['discountPrice']) *
                  res['numberOfItems']);
          priceOfCurrentProduct = res['discountPrice'];
        }
      }

      final obj = res;
      if (res['units'] != null && res['units'] == "Metric Ton") {
        obj['totalAmount'] = priceOfCurrentProduct * res['quantity'] * 1000;
      } else {
        obj['totalAmount'] = priceOfCurrentProduct * res['quantity'];
      }
      obj['amountPerQuantity'] = priceOfCurrentProduct;
      setState(() {
        priceOfProducts.add(obj);
      });
      final String imageUrl = res['resourceUrl'];
      return Card(
          margin: EdgeInsets.only(left: 10, top: 5, right: 10),
          child: Row(
            children: <Widget>[
              Container(
                  child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5)),
                // child: Image(
                //   image: NetworkImage(res['resourceUrl']),
                //   height: 120,
                //   width: 120,
                //   fit: BoxFit.fill,
                // )),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.aspectRatio * 6.5),
                  width: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.aspectRatio * 6.5),
                  fit: BoxFit.fill,
                  placeholder: (context, imageUrl) =>
                      customizedCircularLoadingIcon(15),
                ),
              )),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 5),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: MediaQuery.of(context).size.width -
                        MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.aspectRatio * 6.5) -
                        35,
                    child: RichText(
                      // textAlign: TextAlign.center,
                      softWrap: true,
                      text: TextSpan(
                          style: appFonts.getTextStyle(
                              'cart_screen_product_name_default_style'),
                          children: [
                            res['brandName'] != null
                                ? TextSpan(
                                    text: res['brandName'] + " ",
                                    style: appFonts.getTextStyle(
                                        'cart_screen_brandname_style'))
                                : TextSpan(),
                            TextSpan(
                                text: res['productName'],
                                style: TextStyle(
                                  color: mainAppColor,
                                )),
                            res['specificationName'] != null
                                ? TextSpan(
                                    text: " (" + res['specificationName'] + ")",
                                    style: appFonts.getTextStyle(
                                        'cart_screen_specification_&_type_names_styles'))
                                : TextSpan(),
                            res['productTypeName'] != null
                                ? TextSpan(
                                    text: ", " + res['productTypeName'],
                                    style: appFonts.getTextStyle(
                                        'cart_screen_specification_&_type_names_styles'))
                                : TextSpan()
                          ]),
                    )

                    // Text(
                    //   res['productName'],
                    //   softWrap: true,
                    //   style: TextStyle(
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.bold,
                    //       color: mainAppColor),
                    // ),
                    ),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: res['appliedAgainst'] != null
                        ? res['currencyRepresentation'] != null
                            ? Text(
                                res['currencyRepresentation'] +
                                    currencyFormatter
                                        .format(priceOfCurrentProduct) +
                                    " " +
                                    res['appliedAgainst'],
                                style: appFonts.getTextStyle(
                                    'cart_screen_product_price_styles'),
                              )
                            : Text(
                                currencyFormatter
                                        .format(priceOfCurrentProduct) +
                                    " " +
                                    res['appliedAgainst'],
                                style: appFonts.getTextStyle(
                                    'cart_screen_product_price_styles'),
                              )
                        : res['currencyRepresentation'] != null
                            ? Text(
                                res['currencyRepresentation'] +
                                    currencyFormatter
                                        .format(priceOfCurrentProduct),
                                style: appFonts.getTextStyle(
                                    'cart_screen_product_price_styles'),
                              )
                            : Text(
                                currencyFormatter.format(priceOfCurrentProduct),
                                style: appFonts.getTextStyle(
                                    'cart_screen_product_price_styles'),
                              )),
                Row(children: [
                  res['units'] == null
                      ? Container(
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: res['key'].currentState != null &&
                                            res['key'].currentState.hasError ||
                                        res['numberOfItems'] > 9999
                                    ? Colors.red
                                    : Colors.grey[300],
                                width: res['key'].currentState != null &&
                                        res['key'].currentState.hasError
                                    ? 1
                                    : 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 0.3),
                          width: 120,
                          height: 37,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              res['numberOfItems'] == 1
                                  ? SizedBox(
                                      width: _buttonWidth,
                                      height: _buttonWidth,
                                      child: FlatButton(
                                          padding: EdgeInsets.all(0),
                                          onPressed: () {
                                            deleteProductFromCart(res);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.grey[700],
                                          )),
                                    )
                                  : SizedBox(
                                      width: _buttonWidth,
                                      height: _buttonWidth,
                                      child: FlatButton(
                                          padding: EdgeInsets.all(0),
                                          onPressed: () {
                                            res['focusNode'].unfocus();
                                            if ((res['productMinimumQuantity'] !=
                                                        null &&
                                                    res['numberOfItems'] >
                                                        res['productMinimumQuantity']
                                                            .toInt()) ||
                                                (res['productMinimumQuantity'] ==
                                                        null &&
                                                    res['numberOfItems'] > 1)) {
                                              setState(() {
                                                // displayLoadingIcon(context);
                                                // res['numberOfItems']--;
                                                // res['controller'].text =
                                                //     res['numberOfItems'].toString();
                                                // updateTotalPriceOfProducts(
                                                //     res['priceId'],
                                                //     res['numberOfItems']);
                                                final quantity =
                                                    res['numberOfItems'] - 1;
                                                if (orderIdFromDeepLink != "") {
                                                  updateQuantityDetails(
                                                      quantity,
                                                      res['productId']);
                                                  updateTotalPriceOfProducts(
                                                      res['productId'],
                                                      quantity);
                                                  res['key']
                                                      .currentState
                                                      ?.validate();
                                                  if (totalAmountKey != null) {
                                                    RenderBox box =
                                                        totalAmountKey
                                                            .currentContext
                                                            .findRenderObject();
                                                    Offset position =
                                                        box.localToGlobal(
                                                            Offset.zero);
                                                    scrollController
                                                        .jumpTo(position.dy);
                                                  }
                                                } else {
                                                  updateQuantityDetailsOnCart(
                                                      res, quantity);
                                                }
                                              });
                                            }
                                          },
                                          child: Icon(
                                            Icons.remove_circle,
                                            size: 20,
                                            color: Colors.grey[700],
                                          )),
                                    ),
                              Container(
                                  width: 50,
                                  child: TextFormField(
                                    maxLength: 4,
                                    // textAlign: TextAlign.center,
                                    controller: res['controller'],
                                    focusNode: res['focusNode'],
                                    key: res['key'],
                                    validator: (val) => GlobalValidations()
                                        .quantityValidations(
                                            val,
                                            res['productMinimumQuantity'] !=
                                                    null
                                                ? res['productMinimumQuantity']
                                                    .toInt()
                                                : null,
                                            res['units']),
                                    decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        counterText: "",
                                        errorStyle: appFonts.getTextStyle(
                                            'hide_error_messages_for_formfields')),
                                    // textAlignVertical: TextAlignVertical.center,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    textAlign: TextAlign.center,
                                    onFieldSubmitted: (val) {
                                      if (val != '' &&
                                          int.parse(val) != null &&
                                          int.parse(val) > 0) {
                                        setState(() {
                                          res['numberOfItems'] = int.parse(val);
                                        });
                                      } else if (val != '' &&
                                          int.parse(val) != null &&
                                          int.parse(val) == 0) {
                                        res['numberOfItems'] = 0;
                                      }
                                    },
                                  )),
                              SizedBox(
                                width: _buttonWidth,
                                height: _buttonWidth,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    res['focusNode'].unfocus();
                                    if (res['numberOfItems'] < 9999) {
                                      setState(() {
                                        // res['numberOfItems']++;
                                        // res['controller'].text =
                                        //     res['numberOfItems'].toString();
                                        // updateTotalPriceOfProducts(
                                        //     res['priceId'], res['numberOfItems']);
                                        // Navigator.pop(context);
                                        final int quantity =
                                            res['numberOfItems'] + 1;
                                        if (orderIdFromDeepLink != "") {
                                          updateQuantityDetails(
                                              quantity, res['productId']);
                                          updateTotalPriceOfProducts(
                                              res['productId'], quantity);
                                          res['key'].currentState?.validate();
                                          if (totalAmountKey != null) {
                                            RenderBox box = totalAmountKey
                                                .currentContext
                                                .findRenderObject();
                                            Offset position =
                                                box.localToGlobal(Offset.zero);
                                            scrollController
                                                .jumpTo(position.dy);
                                          }
                                        } else {
                                          updateQuantityDetailsOnCart(
                                              res, quantity);
                                        }
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 5),
                          // decoration: BoxDecoration(
                          //   border: Border.all(color: Colors.grey[300], width: 2),
                          //   borderRadius: BorderRadius.circular(10),
                          // ),
                          padding: EdgeInsets.symmetric(vertical: 0.3),
                          width: MediaQuery.of(context).size.width -
                              (MediaQuery.of(context).size.width /
                                  (MediaQuery.of(context).size.aspectRatio *
                                      6.5)) -
                              90,
                          height: 37,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                  width: 90,
                                  child: TextFormField(
                                    maxLength: 4,
                                    cursorColor: mainAppColor,
                                    // textAlign: TextAlign.center,
                                    controller: res['controller'],
                                    focusNode: res['focusNode'],
                                    key: res['key'],
                                    validator: (val) => GlobalValidations()
                                        .quantityValidations(
                                            val,
                                            res['productMinimumQuantity'] !=
                                                    null
                                                ? res['productMinimumQuantity']
                                                    .toInt()
                                                : null,
                                            res['units']),
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8),
                                        // border: InputBorder.none,
                                        counterText: "",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide(
                                              color: mainAppColor,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide(
                                              color: mainAppColor,
                                            )),
                                        errorStyle: appFonts.getTextStyle(
                                            'hide_error_messages_for_formfields')),
                                    // textAlignVertical: TextAlignVertical.center,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    textAlign: TextAlign.center,
                                    onFieldSubmitted: (val) {
                                      if (val != '' &&
                                          int.parse(val) != null &&
                                          int.parse(val) > 0) {
                                        setState(() {
                                          res['numberOfItems'] = int.parse(val);
                                        });
                                      }
                                    },
                                  )),
                              Padding(
                                padding: EdgeInsets.only(left: 5),
                              ),
                              Container(
                                // margin: EdgeInsets.only(left: 2),
                                width: 70,
                                child: Text(res['units'],
                                    softWrap: true,
                                    style: appFonts
                                        .getTextStyle('cart_units_text_style')),
                              )
                            ],
                          ),
                        ),
                  res['units'] == null
                      ? Container(
                          margin: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width -
                                      (MediaQuery.of(context).size.width /
                                          (MediaQuery.of(context)
                                                  .size
                                                  .aspectRatio *
                                              6.5)) -
                                      90) -
                                  120),
                          child: IconButton(
                            onPressed: () {
                              deleteProductFromCart(obj);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.grey[700],
                            ),
                            iconSize: 26,
                          ),
                        )
                      : Container(
                          child: IconButton(
                            onPressed: () {
                              deleteProductFromCart(obj);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.grey[700],
                            ),
                            iconSize: 26,
                          ),
                        )
                ]),
              ])
            ],
          ));
    }).toList();
  }

  // Get Total Amount
  getTotalAmount(List priceOfProducts) {
    // double totalAmount = 0;
    print(priceOfProducts);
    setState(() {
      priceOfTotalProducts = 0;
      actualPriceOfCurrentOrder = 0;
    });
    priceOfProducts.forEach((res) {
      double priceOfCurrentProduct = 0.0;
      if (res['taxpercent'] != null) {
        // final double taxValue = res['value'] *
        //     int.parse(res['taxpercent'].toString().replaceAll('%', '')) /
        //     100;
        setState(() {
          // Uncomment this to add tax value;
          // priceOfCurrentProduct = res['value'] + taxValue;

          //comment this to add tax value;
          priceOfCurrentProduct = res['value'];
        });
        // print(priceOfCurrentProduct);
      } else {
        setState(() {
          priceOfCurrentProduct = res['value'];
        });
      }
      if (res['units'] == null) {
        setState(() {
          actualPriceOfCurrentOrder = actualPriceOfCurrentOrder +
              (priceOfCurrentProduct * res['quantity']);
        });
      } else {
        if (res['units'] == "Metric Ton") {
          actualPriceOfCurrentOrder = actualPriceOfCurrentOrder +
              (priceOfCurrentProduct * res['quantity'] * 1000);
        } else {
          actualPriceOfCurrentOrder = actualPriceOfCurrentOrder +
              (priceOfCurrentProduct * res['quantity']);
        }
      }
      if (res['units'] == null) {
        if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
          if (res['quantity'] >= res['minimumQuantity']) {
            priceOfCurrentProduct = res['discountPrice'];
            // priceOfCurrentProduct -
            //     (priceOfCurrentProduct) *
            //         int.parse(
            //             res['productDiscount'].toString().replaceAll('%', '')) /
            //         100;
          }
        } else if (res['discountPrice'] != null) {
          priceOfCurrentProduct = res['discountPrice'];
        }
      } else {
        if (res['units'] == "Metric Ton") {
          if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
            if (res['quantity'] * 1000 >= res['minimumQuantity']) {
              priceOfCurrentProduct = res['discountPrice'];
            }
          } else if (res['discountPrice'] != null) {
            priceOfCurrentProduct = res['discountPrice'];
          }
        } else {
          if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
            if (res['quantity'] >= res['minimumQuantity']) {
              priceOfCurrentProduct = res['discountPrice'];
            }
          } else if (res['discountPrice'] != null) {
            priceOfCurrentProduct = res['discountPrice'];
          }
        }
      }
      setState(() {
        if (res['units'] == null) {
          priceOfTotalProducts =
              priceOfTotalProducts + (priceOfCurrentProduct * res['quantity']);
        } else {
          if (res['units'] == "Metric Ton") {
            priceOfTotalProducts = priceOfTotalProducts +
                (priceOfCurrentProduct * res['quantity'] * 1000);
          } else {
            priceOfTotalProducts = priceOfTotalProducts +
                (priceOfCurrentProduct * res['quantity']);
          }
        }
      });
    });
  }

  getSubscriptions() {
    // Map obj = {"limit": 2, "pageNumber": 1};

    SubcriptionService().getSubscriptionUnits().then((res) {
      final data = json.decode(res.body);
      if (data != null && data.length > 0) {
        setState(() {
          subscriptionUnits = data;
          currentUnitType = subscriptionUnits[0];
        });
      } else {}
    }, onError: (err) {
      apiErros.apiErrorNotifications(
          err, context, '/subscription', scaffoldKey);
    });
  }

  displayStockNotAvailableMessage(List listOfProductsNotAvailable) {
    if (listOfProductsNotAvailable.length == listOfCartDetails.length) {
      showErrorNotifications(
          'Stock not available for selected products', context, scaffoldKey);
    } else {
      List notAvailableProducts = [];
      listOfCartDetails.forEach((val) {
        if (listOfProductsNotAvailable
                .indexWhere((res) => res['productId'] == val['productId']) !=
            -1) {
          String productName = val['productName'];
          if (val['specificationName'] != null &&
              val['specificationName'] != "") {
            productName = productName + " (" + val['specificationName'] + ")";
          }
          notAvailableProducts.add(productName);
        }
      });
      showErrorNotifications(
          'Stock not available for ' + notAvailableProducts.join(', '),
          context,
          scaffoldKey);
    }
  }

  checkAndRemoveCartDetailsFrommErpDataTable(
      bool openPaymentGateWay, generatedOrderId) {
    orderSummaryService
        .removeProductQuantityFromErpDataTabel(
            selectedDeliveryAddress['pincode'].toString())
        .then((val) {
      final data = json.decode(val.body);
      if (data != null &&
          data['listOfProductsNotAvailable'] != null &&
          data['listOfProductsNotAvailable'].length == 0) {
        // sendOrderDetails();
        if (openPaymentGateWay) {
          //_callPayUNative();
          payUsingRazorPay();
        } else if (generatedOrderId != null) {
          orderId = generatedOrderId;
          orderIdFromDeepLink = "";
          currentOrderInfo = {};
          selectedDeliveryAddress = {};
          _sharedPreferenceService.removeTransactionKey();
          // subscriptionDetails = {};
          Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation',
              ModalRoute.withName('/orderconfirmation'));
        }
      } else if (data != null &&
          data['listOfProductsNotAvailable'] != null &&
          data['listOfProductsNotAvailable'].length > 0) {
        if (generatedOrderId != null) {
          orderId = generatedOrderId;
          // orderIdFromDeepLink = 0;
          currentOrderInfo = {};
          selectedDeliveryAddress = {};
          _sharedPreferenceService.removeTransactionKey();
          // subscriptionDetails = {};
          Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation',
              ModalRoute.withName('/orderconfirmation'));
        } else {
          displayStockNotAvailableMessage(data['listOfProductsNotAvailable']);
        }
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.pop(context);
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (refreshTokenService.getAccessTokenFromData(
                refreshTokenData, context, setState)) {
              checkAndRemoveCartDetailsFrommErpDataTable(
                  openPaymentGateWay, generatedOrderId);
            }
          },
        );
      } else if (data['error'] != null) {
        Navigator.pop(context);
        if (generatedOrderId != null) {
          orderId = generatedOrderId;
          // orderIdFromDeepLink = 0;
          currentOrderInfo = {};
          selectedDeliveryAddress = {};
          _sharedPreferenceService.removeTransactionKey();
          // subscriptionDetails = {};
          Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation',
              ModalRoute.withName('/orderconfirmation'));
        } else {
          apiErros.apiLoggedErrors(data, context, scaffoldKey);
        }
      }
    }, onError: (err) {
      if (generatedOrderId != null) {
        orderId = generatedOrderId;
        // orderIdFromDeepLink = 0;
        currentOrderInfo = {};
        selectedDeliveryAddress = {};
        _sharedPreferenceService.removeTransactionKey();
        // subscriptionDetails = {};
        Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation',
            ModalRoute.withName('/orderconfirmation'));
      } else {
        apiErros.apiErrorNotifications(
            err, context, '/subscriptionsummary', scaffoldKey);
      }
    });
  }

  Map getOrderInfo(String payMode, String txnId) {
    Map requestObj = {
      "userId": signInDetails['userId'],
      "orderId": orderIdFromDeepLink != "" ? orderIdFromDeepLink : null,
      "paymentSuccess": true,
      "paymentMode": payMode,
      'transactionId': txnId,
      "havingRegistrationDiscount": registrationDiscount > 0 ? true : false,
      "addressId": selectedDeliveryAddress['addressId'],
      "deepLink": subscriptionKey.currentState.validate() &&
              subscriptionController.text.trim() != "" &&
              advancePaymentkey.currentState != null &&
              !advancePaymentkey.currentState.hasError &&
              advancePaymentController.text.trim() == ""
          ? "https://cornext.feednext.app"
          : null,
      "amountPerOrder": actualPriceOfCurrentOrder,
      "totalProductDiscountAmountPerOrder": productDiscountAmount,
      "totalTaxAmountPerOrder": totalTaxAmount,
      "transactionAmount": couponDiscount > 0
          ? subscribedprice > 0
              ? subscribedprice - couponDiscount
              : priceOfTotalProducts - couponDiscount
          : subscribedprice > 0 ? subscribedprice : priceOfTotalProducts,
      "couponDetails":
          couponDiscount > 0 ? currentOrderInfo['couponDetails'] : null,
      "subscription": subscriptionController.text.trim() != "" &&
              subscriptionKey.currentState.validate()
          ? {
              "deliverEvery": int.parse(subscriptionController.text.trim()),
              "units": currentUnitType,
              "occuurences": advancePaymentController.text.trim() != ""
                  ? int.parse(advancePaymentController.text.trim())
                  : null,
              "prePayment": subscriptionController.text.trim() != "" &&
                      subscriptionKey.currentState.validate() &&
                      !advancePaymentkey.currentState.hasError &&
                      advancePaymentController.text.trim() == ""
                  ? false
                  : true
            }
          : null,
      "productDetails": getProductDetailsInfo(),
      "havingSubscribedOrders": true
    };
    return requestObj;
  }

  manageOrderDispatch() {
    bool isProductDetailsValid = true;
    Map errorObj = {};
    setState(() {
      isQuantityFieldOnFocus = false;
    });
    listOfCartDetails.forEach((val) {
      val['key'].currentState.validate();
      if (val['key'].currentState != null &&
          !val['key'].currentState.validate()) {
        isProductDetailsValid = false;
        errorObj = val;
      }
    });
    if (isLoadingIconDisplaying) {
      Navigator.of(context).pop();
    }
    if (isProductDetailsValid) {
      subscriptionKey.currentState.validate();
      setState(() {});
      if (!subscriptionKey.currentState.hasError &&
          subscriptionController.text.trim() != "") {
        if (advancePaymentController.text.trim() != "" &&
            !advancePaymentkey.currentState.hasError) {
          advancePaymentkey.currentState.validate();
          setState(() {});
          if (!advancePaymentkey.currentState.hasError) {
            // sendOrderDetails();
            checkAndRemoveCartDetailsFrommErpDataTable(true, null);
            // _callPayUNative();
          }
        } else {
          // sendOrderDetails();
          checkAndRemoveCartDetailsFrommErpDataTable(true, null);
          // _callPayUNative();
        }
        // setState(() {});
      } else {
        // closeNotifications();

        clearErrorMessages(scaffoldKey);
        showErrorNotifications(
            errorObj['key'].currentState.errorText, context, scaffoldKey);
      }
    }
  }

  sendOrderDetails(String payMode, String txnId) {
    Map requestObj = getOrderInfo(payMode, txnId);
    print('aaa');
    print(requestObj);
    // currentOrderInfo = requestObj;
    // Map obj = {
    //   "key": "1UngQS1p",
    //   // "txnid": "000100"
    //   "amount": "1000",
    //   "productinfo": "Jeans",
    //   "firstname": "Veera",
    //   "email": "veera@gmail.com",
    //   "phone": "9505037717",
    //   "surl": "",
    //   "furl": "",
    //   "service_provider": "payu_paisa"
    // };
    // http.post("https://sandboxsecure.payu.in/_payment", body: obj).then((res) {
    //   print(res.body);
    // });
    // Navigator.pushNamed(context,'/subscriptionconformation');
    // print('jsjs');
    // print(requestObj);

    // Uncomment to don't show subscription screen
    displayLoadingIcon(context);
    orderSummaryService.postOrderDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      Navigator.pop(context);
      // print(data);
      // print("aaaa");

      // data['orderId']
      if (data != null && data['orderId'] != null) {
        _sharedPreferenceService
            .checkAccessTokenAndUpdateuserDetails()
            .then((txnKey) {
          if (txnKey.getString('transactionKey') != null &&
              txnKey.getString('transactionKey').length > 0) {
            orderId = data['orderId'];
            orderIdFromDeepLink = "";
            currentOrderInfo = {};
            selectedDeliveryAddress = {};
            _sharedPreferenceService.removeTransactionKey();
            // subscriptionDetails = {};
            Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation',
                ModalRoute.withName('/orderconfirmation'));
          } else {
            checkAndRemoveCartDetailsFrommErpDataTable(false, data['orderId']);
          }
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.pop(context);
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (refreshTokenService.getAccessTokenFromData(
                refreshTokenData, context, setState)) {
              sendOrderDetails(payMode, txnId);
            }
          },
        );
      } else if (data['error'] != null) {
        Navigator.pop(context);
        _sharedPreferenceService.addFailedOrderDetails(requestObj);
        makeApiCallsOnFailedOrders(context);
        // apiErros.apiLoggedErrors(data, context, scaffoldKey);
        Navigator.pushReplacementNamed(context, '/ordercreationfailedscreen');
      }
    }, onError: (err) {
      print(err);
      Navigator.pop(context);
      _sharedPreferenceService.addFailedOrderDetails(requestObj);
      makeApiCallsOnFailedOrders(context);
      // apiErros.apiErrorNotifications(
      //     err, context, '/orderconfirmation', scaffoldKey);
      Navigator.pushReplacementNamed(context, '/ordercreationfailedscreen');
    });
    // print(requestObj);
  }

  getProductDetailsInfo() {
    List productDetailsObj = [];
    listOfCartDetails.forEach((res) {
      Map obj = {
        "productId": res['productId'],
        "brandId": res['brandId'] != null ? res['brandId'] : null,
        "productTypeId":
            res['productTypeId'] != null ? res['productTypeId'] : null,
        "specificationId":
            res['specificationId'] != null ? res['specificationId'] : null,
        "priceId": res['priceId'] != null ? res['priceId'] : null,
        "quantity": res['numberOfItems'],
        "quantityRepresentation": res['units'] != null ? res['units'] : null,
        "totalAmount": priceOfProducts[priceOfProducts.indexWhere(
            (val) => val['productId'] == res['productId'])]['totalAmount'],
        "amountPerQuantity": priceOfProducts[priceOfProducts.indexWhere(
            (val) => val['productId'] == res['productId'])]['amountPerQuantity']
      };
      productDetailsObj.add(obj);
    });
    return productDetailsObj;
  }

  manageBackButtonClick() {
    setState(() {
      isBackButtonPressed = false;
    });
    Navigator.popAndPushNamed(context, '/ordersummary');
  }

  @override
  Widget build(BuildContext context) {
    String addressData = '';
    if (selectedDeliveryAddress['pincode'] != null) {
      addressData = selectedDeliveryAddress['city'].toString() +
          ', ' +
          selectedDeliveryAddress['state'].toString() +
          ", " +
          selectedDeliveryAddress['pincode'].toString();
      if (selectedDeliveryAddress['street'] != null) {
        addressData = selectedDeliveryAddress['street'] + ", " + addressData;
      }
      if (selectedDeliveryAddress['doorNumber'] != null) {
        addressData =
            selectedDeliveryAddress['doorNumber'] + ", " + addressData;
      }
    }
    return WillPopScope(
        onWillPop: () {
          // setState(() {
          // if (isRepeatOrder) {
          subscriptionsData = {};
          // selectedDeliveryAddress = {};
          //   isRepeatOrder = false;
          //   Navigator.popAndPushNamed(context, '/yourorders');
          //   return Future.value(false);
          // } else {
          // });
          // isRepeatOrder = false;
          bool isQuantityFieldFocused = false;
          listOfCartDetails.forEach((val) {
            if (val['focusNode'] != null && val['focusNode'].hasFocus) {
              setState(() {
                isQuantityFieldFocused = true;
              });
              val['focusNode'].unfocus();
            }
          });
          if (!isQuantityFieldFocused) {
            manageBackButtonClick();
          } else {
            setState(() {
              isBackButtonPressed = true;
            });
          }

          return Future.value(false);
          // }
        },
        child: Scaffold(
            // appBar: appBarWidgetWithIcons(context, false, this.setState, false,'/ordersummary'),
            appBar: plainAppBarWidget,
            key: scaffoldKey,
            body: !isLoading
                ? listOfCartDetails.length > 0
                    ? GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if ((subscriptionController.text.trim() != "" &&
                                  subscriptionKey.currentState.validate()) &&
                              (advancePaymentController.text.trim() != "" &&
                                  advancePaymentkey.currentState.validate())) {
                            getSubscribedAmount(false);
                          } else {
                            setState(() {
                              subscribedprice = 0;
                              actualSubscribedPrice = 0;
                              previousNoofSubscriptions = 0;
                              taxAmountWithSubscription = 0;
                              // advancePaymentController.clear();
                              // advancePaymentkey.currentState?.reset();
                            });
                            addUserRegistrationDiscount(false);
                          }
                        },
                        child: Container(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Deliver To",
                                            style: appFonts.getTextStyle(
                                                'order_summary_headings_style'),
                                          ),
                                        ),
                                        // Container(
                                        //   // width: 115,
                                        //   margin: EdgeInsets.only(right: 10),
                                        //   // alignment: Alignment.topRight,
                                        //   // child: RaisedButton(
                                        //   //   onPressed: () {},
                                        //   //   child: Row(
                                        //   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //   //     children: <Widget>[Text("Change"), Icon(Icons.edit)],
                                        //   //   ),
                                        //   // ),
                                        //   child: GestureDetector(
                                        //     onTap: () {
                                        //       isNavigatingFromDelivarypage =
                                        //           true;
                                        //       Navigator.popAndPushNamed(
                                        //           context, "/deliveryaddress");
                                        //     },
                                        //     child: Icon(
                                        //       Icons.edit,
                                        //       color: Colors.grey[700],
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    )),
                                addressData != ""
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            top: 5, left: 10, right: 10),
                                        child: Text(
                                          // selectedDeliveryAddress['doorNumber'].toString() +
                                          //     ',' +
                                          //     selectedDeliveryAddress['street'].toString() +
                                          addressData,
                                          style: appFonts.getTextStyle(
                                              'order_summary_screen_delivery_address_contnet_style'),
                                          softWrap: true,
                                        ))
                                    : Container(),
                                Divider(
                                  thickness: 2,
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text(
                                      "Selected Products",
                                      style: appFonts.getTextStyle(
                                          'order_summary_headings_style'),
                                    )),
                                ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: getCartProductDetails(),
                                ),
                                Divider(
                                  thickness: 2,
                                ),

                                Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey[400])),
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Column(children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    "Deliver Every: ",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 95,
                                                  child: TextFormField(
                                                    controller:
                                                        subscriptionController,
                                                    decoration: InputDecoration(
                                                        border: AppStyles()
                                                            .inputBorder,
                                                        // errorMaxLines: 3,
                                                        errorStyle: appFonts
                                                            .getTextStyle(
                                                                'hide_error_messages_for_formfields'),
                                                        // errorText: "",
                                                        isDense: true,
                                                        focusedBorder: AppStyles()
                                                            .focusedInputBorder,
                                                        // labelText: pincodeLabelName + " *",
                                                        counterText: "",
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        11)),
                                                    // cursorColor: mainAppColor,
                                                    validator: (value) =>
                                                        GlobalValidations()
                                                            .subscriptionValidations(
                                                                value.trim()),
                                                    maxLength: 4,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    focusNode:
                                                        subscriptionFocus,
                                                    // autofocus: true,
                                                    key: subscriptionKey,
                                                    onFieldSubmitted: (val) {
                                                      if (subscriptionKey
                                                              .currentState
                                                              .validate() &&
                                                          subscriptionController
                                                                  .text
                                                                  .trim() !=
                                                              "" &&
                                                          !advancePaymentkey
                                                              .currentState
                                                              .hasError &&
                                                          advancePaymentController
                                                                  .text
                                                                  .trim() !=
                                                              "") {
                                                        getSubscribedAmount(
                                                            false);
                                                      } else {
                                                        setState(() {
                                                          subscribedprice = 0;
                                                          actualSubscribedPrice =
                                                              0;
                                                          previousNoofSubscriptions =
                                                              0;
                                                          taxAmountWithSubscription =
                                                              0;
                                                          // advancePaymentController.clear();
                                                          // advancePaymentkey.currentState?.reset();
                                                        });
                                                        addUserRegistrationDiscount(
                                                            false);
                                                      }
                                                    },
                                                  ),
                                                ),

                                                currentUnitType != null
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 5),
                                                        // margin: EdgeInsets.only(
                                                        //     left: 0,
                                                        //     right: MediaQuery.of(context).size.width / 4),
                                                        width: 80,
                                                        // height: 40,
                                                        child:
                                                            //     DropdownButton<String>(
                                                            //   isExpanded: true,
                                                            //   hint: new Text(
                                                            //       '           '),
                                                            //   items: subscriptionUnits
                                                            //       .map((unitType) {
                                                            //     // productSelection =
                                                            //     //     productDataTypes['productTypeId']
                                                            //     //         .toString();

                                                            //     return new DropdownMenuItem<
                                                            //         String>(
                                                            //       child: new Text(
                                                            //         unitType,
                                                            //         style: TextStyle(
                                                            //             fontSize: 15.0),
                                                            //       ),
                                                            //       value: unitType
                                                            //           .toString(),
                                                            //       // // value: unitType['priceId'].toString(),
                                                            //       // child: Text(value),
                                                            //       // value: dropdownValue.toString(),
                                                            //     );
                                                            //   }).toList(),
                                                            //   onChanged: (newVal) {
                                                            //     setState(() {
                                                            //       currentUnitType =
                                                            //           newVal;
                                                            //     });
                                                            //   },
                                                            //   value: currentUnitType,
                                                            // )
                                                            Text(
                                                                currentUnitType))
                                                    : Container()
                                                //     : Container()
                                                // : Container()
                                              ]),
                                          subscriptionKey.currentState !=
                                                      null &&
                                                  subscriptionKey
                                                      .currentState.hasError
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(top: 3),
                                                  child: Text(
                                                    subscriptionKey
                                                        .currentState.errorText,
                                                    style: appFonts.getTextStyle(
                                                        'text_color_red_style'),
                                                  ),
                                                )
                                              : Container()
                                        ]))),
                                Divider(
                                  thickness: 2,
                                ),

                                Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey[400])),
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Column(children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  // alignment:
                                                  //     Alignment.centerRight,
                                                  child: Text(
                                                    "Pay For: ",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 95,
                                                  child: TextFormField(
                                                    controller:
                                                        advancePaymentController,
                                                    decoration: InputDecoration(
                                                        border: AppStyles()
                                                            .inputBorder,
                                                        // errorMaxLines: 3,
                                                        errorStyle: appFonts
                                                            .getTextStyle(
                                                                'hide_error_messages_for_formfields'),
                                                        // errorText: "",
                                                        isDense: true,
                                                        focusedBorder: AppStyles()
                                                            .focusedInputBorder,
                                                        // labelText: pincodeLabelName + " *",
                                                        counterText: "",
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        11)),
                                                    // cursorColor: mainAppColor,
                                                    validator: (value) =>
                                                        GlobalValidations()
                                                            .subscriptionValidations(
                                                                value.trim()),
                                                    maxLength: 4,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    focusNode:
                                                        advancePaymentFocusNode,
                                                    // autofocus: true,
                                                    key: advancePaymentkey,
                                                    onFieldSubmitted: (val) {
                                                      if (!subscriptionKey
                                                              .currentState
                                                              .hasError &&
                                                          subscriptionController.text
                                                                  .trim() !=
                                                              "" &&
                                                          advancePaymentkey
                                                              .currentState
                                                              .validate() &&
                                                          advancePaymentController
                                                                  .text
                                                                  .trim() !=
                                                              "") {
                                                        getSubscribedAmount(
                                                            false);
                                                      } else {
                                                        setState(() {
                                                          subscribedprice = 0;
                                                          actualSubscribedPrice =
                                                              0;
                                                          previousNoofSubscriptions =
                                                              0;
                                                          taxAmountWithSubscription =
                                                              0;
                                                          // advancePaymentController.clear();
                                                          // advancePaymentkey.currentState?.reset();
                                                        });
                                                        addUserRegistrationDiscount(
                                                            false);
                                                      }
                                                    },
                                                  ),
                                                ),

                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 5, right: 5),
                                                  // width: 80,
                                                  child: Text("Times"),
                                                )
                                                //     : Container()
                                                // : Container()
                                              ]),
                                          advancePaymentkey.currentState !=
                                                      null &&
                                                  advancePaymentkey
                                                      .currentState.hasError
                                              ? Container(
                                                  child: Text(
                                                    advancePaymentkey
                                                        .currentState.errorText,
                                                    style: appFonts.getTextStyle(
                                                        'text_color_red_style'),
                                                  ),
                                                )
                                              : Container()
                                        ]))),
                                Divider(
                                  thickness: 2,
                                ),
                                registrationDiscount > 0
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10, top: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                // alignment:
                                                //     Alignment.centerRight,
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    50,
                                                child: Text(
                                                  "Registration Discount",
                                                  style: appFonts.getTextStyle(
                                                      'ordersummary_total_amount_labels_heading_style'),
                                                )),
                                            // ),
                                            Flexible(
                                              child: Text(": "),
                                            ),
                                            Flexible(
                                              child: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      "$currencyRepresentation" +
                                                          "$registrationDiscount")),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(),
                                couponDiscount > 0
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10, top: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                // alignment:
                                                //     Alignment.centerRight,
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    50,
                                                child: Text(
                                                  "Coupon Discount",
                                                  style: appFonts.getTextStyle(
                                                      'ordersummary_total_amount_labels_heading_style'),
                                                )),
                                            // ),
                                            Flexible(
                                              child: Text(": "),
                                            ),
                                            Flexible(
                                              child: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      currencyRepresentation
                                                              .toString() +
                                                          "$couponDiscount")),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(),
                                taxAmountWithSubscription > 0
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10, top: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                // alignment: Alignment.centerRight,
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    50,
                                                child: Text(
                                                  "Taxes and charges",
                                                  style: appFonts.getTextStyle(
                                                      'ordersummary_total_amount_labels_heading_style'),
                                                )),
                                            // ),
                                            Container(
                                                child: Text(': ' +
                                                    currencyRepresentation
                                                        .toString() +
                                                    currencyFormatter.format(
                                                        taxAmountWithSubscription))),
                                            // )
                                          ],
                                        ),
                                      )
                                    : totalTaxAmount > 0
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                left: 10, right: 10, top: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                    // alignment:
                                                    //     Alignment.centerRight,
                                                    margin: EdgeInsets.only(
                                                        left: 10),
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            50,
                                                    child: Text(
                                                      "Taxes and charges",
                                                      style: appFonts.getTextStyle(
                                                          'ordersummary_total_amount_labels_heading_style'),
                                                    )),
                                                // ),
                                                Flexible(
                                                  child: Text(": "),
                                                ),
                                                Container(
                                                    child: Text(
                                                        currencyRepresentation
                                                                .toString() +
                                                            currencyFormatter
                                                                .format(
                                                                    totalTaxAmount))),
                                                // )
                                              ],
                                            ),
                                          )
                                        : Container(),
                                Container(
                                  key: totalAmountKey,
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          // alignment: Alignment.centerRight,
                                          margin: EdgeInsets.only(left: 10),
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2 -
                                              50,
                                          child: Text(
                                            "Total amount",
                                            style: appFonts.getTextStyle(
                                                'ordersummary_total_amount_heading_style'),
                                          )),
                                      // ),
                                      // Padding(
                                      //     padding:
                                      //         EdgeInsets.only(left: 9, right: 4)),
                                      Flexible(
                                        child: Text(": "),
                                      ),
                                      Container(
                                          // alignment: Alignment.centerLeft,
                                          child: subscribedprice == 0
                                              ? couponDiscount > 0
                                                  ? Text(
                                                      "$currencyRepresentation" +
                                                          currencyFormatter.format(
                                                              priceOfTotalProducts -
                                                                  couponDiscount),
                                                      style: appFonts.getTextStyle(
                                                          'ordersummary_total_amount_content_style'),
                                                      softWrap: true,
                                                    )
                                                  : Text(
                                                      "$currencyRepresentation" +
                                                          currencyFormatter.format(
                                                              priceOfTotalProducts),
                                                      style: appFonts.getTextStyle(
                                                          'ordersummary_total_amount_content_style'),
                                                      softWrap: true,
                                                    )
                                              : couponDiscount > 0
                                                  ? Text(
                                                      "$currencyRepresentation" +
                                                          currencyFormatter.format(
                                                              subscribedprice -
                                                                  couponDiscount),
                                                      style: appFonts.getTextStyle(
                                                          'ordersummary_total_amount_content_style'),
                                                      softWrap: true,
                                                    )
                                                  : Text(
                                                      "$currencyRepresentation" +
                                                          currencyFormatter.format(
                                                              subscribedprice),
                                                      style: appFonts.getTextStyle(
                                                          'ordersummary_total_amount_content_style'),
                                                      softWrap: true,
                                                    ))
                                    ],
                                  ),
                                ),

                                (actualPriceOfCurrentOrder -
                                                priceOfTotalProducts >
                                            0 ||
                                        couponDiscount > 0)
                                    ? Container(
                                        margin:
                                            EdgeInsets.only(top: 5, right: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  "You will Save : ",
                                                  style: appFonts.getTextStyle(
                                                      'ordersummary_total_amount_labels_heading_style'),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: subscribedprice == 0
                                                    ? couponDiscount > 0
                                                        ? Text(
                                                            "$currencyRepresentation" +
                                                                currencyFormatter.format(
                                                                    (actualPriceOfCurrentOrder -
                                                                            priceOfTotalProducts) +
                                                                        couponDiscount),
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'ordersummary_total_discount_content_style'),
                                                          )
                                                        : Text(
                                                            "$currencyRepresentation" +
                                                                currencyFormatter.format(
                                                                    actualPriceOfCurrentOrder -
                                                                        priceOfTotalProducts),
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'ordersummary_total_discount_content_style'),
                                                          )
                                                    : couponDiscount > 0
                                                        ? Text(
                                                            "$currencyRepresentation" +
                                                                currencyFormatter.format(
                                                                    (actualSubscribedPrice -
                                                                            subscribedprice) +
                                                                        couponDiscount),
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'ordersummary_total_discount_content_style'),
                                                          )
                                                        : Text(
                                                            "$currencyRepresentation" +
                                                                currencyFormatter.format(
                                                                    actualSubscribedPrice -
                                                                        subscribedprice),
                                                            style: appFonts
                                                                .getTextStyle(
                                                                    'ordersummary_total_discount_content_style'),
                                                          ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  " on this order",
                                                  style: appFonts.getTextStyle(
                                                      'ordersummary_total_amount_labels_heading_style'),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                )

                                // Padding(
                                //   padding: EdgeInsets.only(left: 1.0),
                                // ),
                              ],
                            ),
                          ),
                        ))
                    : Center(
                        heightFactor: 3,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.remove_shopping_cart,
                              size: 60,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                            ),
                            Text(
                              "Cart is empty",
                              style: appFonts.getTextStyle('cart_empty_styles'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                            ),
                            Text("Looks like you have no items in your cart"),
                            Padding(
                              padding: EdgeInsets.only(top: 70),
                            ),
                            InkWell(
                                onTap: () {
                                  selectedDeliveryAddress = {};
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      "/home", ModalRoute.withName("/home"));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        "Browse For Products",
                                        style: appFonts.getTextStyle(
                                            'browse_for_products_link_style'),
                                      ),
                                    ),
                                    Flexible(
                                        child: Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.blue,
                                        size: 25,
                                      ),
                                    ))
                                  ],
                                ))
                          ],
                        ))
                : Center(child: customizedCircularLoadingIcon(50)),
            // floatingActionButton: Container(
            //   alignment: Alignment.bottomCenter,
            //   child: RaisedButton(
            //     onPressed: () {},
            //     child: Text("Proceed To Payment"),
            //   ),
            // ),
            // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            bottomNavigationBar: !isLoading && listOfCartDetails.length > 0
                ? Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: RaisedButton(
                      onPressed: () {
                        if (subscriptionFocus.hasFocus) {
                          subscriptionFocus.unfocus();
                        }
                        if (advancePaymentFocusNode.hasFocus) {
                          advancePaymentFocusNode.unfocus();
                          if (!subscriptionKey.currentState.hasError &&
                              subscriptionController.text.trim() != "" &&
                              advancePaymentkey.currentState.validate() &&
                              advancePaymentController.text.trim() != "") {
                            getSubscribedAmount(false);
                          } else {
                            setState(() {
                              subscribedprice = 0;
                              actualSubscribedPrice = 0;
                              previousNoofSubscriptions = 0;
                              taxAmountWithSubscription = 0;
                              // advancePaymentController.clear();
                              // advancePaymentkey.currentState?.reset();
                            });
                            addUserRegistrationDiscount(false);
                          }
                        }
                        listOfCartDetails.forEach((val) {
                          val['key'].currentState.validate();
                          if (val['focusNode'] != null &&
                              val['focusNode'].hasFocus) {
                            val['focusNode'].unfocus();
                            setState(() {
                              isQuantityFieldOnFocus = true;
                            });
                          }
                        });
                        if (!isQuantityFieldOnFocus) {
                          manageOrderDispatch();
                        }
                      },
                      child: Text(
                        "Proceed Subscription",
                        style: appFonts
                            .getTextStyle('add_font_family_rale_way_bold'),
                      ),
                      color: mainYellowColor,
                    ),
                  )
                : Container(
                    height: 1,
                  )));
  }

  addQuantityToInventoryOnPaymentFail() {
    displayLoadingIcon(context);
    orderSummaryService
        .addQuantityToInventoryOnPaymentFail(
            selectedDeliveryAddress['pincode'].toString())
        .then((val) {
      final data = json.decode(val.body);
      Navigator.of(context).pop();
      setState(() {
        isLoadingIconDisplaying = false;
      });
      if (data['status'] != null && data['status'] == "SUCCESS") {
        // Navigator.of(context).pop();
        _sharedPreferenceService.removeTransactionKey();
        routeNameBeforePayment = '/subscriptionsummary';
        Navigator.pushReplacementNamed(context, '/paymentfailederrorscreen');
      } else if (data['status'] != null && data['status'] == "FAILED") {
        showErrorNotifications(
            "Failed to add products into inventory", context, scaffoldKey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        refreshTokenService.getAccessTokenUsingRefreshToken().then(
          (res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (refreshTokenService.getAccessTokenFromData(
                refreshTokenData, context, setState)) {
              addQuantityToInventoryOnPaymentFail();
            }
          },
        );
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(
          err, context, '/subscriptionsummary', scaffoldKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void payUsingRazorPay() async {
    var now = new DateTime.now().millisecondsSinceEpoch;
    var userId = signInDetails['userId'];
    String transactionId = "$userId$now";

    var amount = couponDiscount > 0
        ? subscribedprice > 0
            ? (subscribedprice - couponDiscount)
            : (priceOfTotalProducts - couponDiscount)
        : subscribedprice > 0 ? subscribedprice : priceOfTotalProducts;

    var orderDetails = {
      'amount': amount * 100,
      'currency': 'INR',
      'receipt': transactionId,
      'payment_capture': 1,
    };

    String orderId =
        await OrderConfirmationService().createRazorPayOrder(orderDetails);
    var options = {
      'key': signInDetails['razorPayKey'].toString(),
      'amount': amount * 100,
      'name': 'FeedNext',
      'description': 'Order processing',
      'order_id': orderId,
      'prefill': {
        'contact': signInDetails['mobileNo'],
        'email': signInDetails['emailId'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      //Snackbar to show failure
      addQuantityToInventoryOnPaymentFail();
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    displayLoadingIcon(context);
    OrderConfirmationService()
        .fetchRazorPayPayment(response.paymentId)
        .then((value) {
      Navigator.pop(context);
      sendOrderDetails(value, response.paymentId);
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    //Snackbar to show failure
    addQuantityToInventoryOnPaymentFail();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL_WALLET: " + response.walletName);
    print(response);
  }

  Future<void> _callPayUNative() async {
    var response;
    try {
      var now = new DateTime.now().millisecondsSinceEpoch;
      var userId = signInDetails['userId'];
      String transactionId = "$userId$now";
      var params = {
        "amount": couponDiscount > 0
            ? subscribedprice > 0
                ? (subscribedprice - couponDiscount).toString()
                : (priceOfTotalProducts - couponDiscount).toString()
            : subscribedprice > 0
                ? subscribedprice.toString()
                : priceOfTotalProducts.toString(),
        "firstName": signInDetails['userName'],
        "email": signInDetails['emailId'],
        "phone": signInDetails['mobileNo'],
        "hashURL": getHashUrl,
        "transactionId":
            transactionId, //Send a transactionID/orderID to update it with status later
        "access_token":
            signInDetails['access_token'] //Access Token for Hash genaration
      };
      _sharedPreferenceService.addTransactionKey(transactionId);
      addQuantityToInventoryAfterCertainTime(
          selectedDeliveryAddress['pincode'].toString());
      response = await platform.invokeMethod('callPayU', params);
      var jsonVal = jsonDecode(response);
      // print(jsonVal);
      if (jsonVal["status"] == "success") {
        // checkAndRemoveCartDetailsFrommErpDataTable();
        String mode = 'Others';
        if (jsonVal['mode'] == 'CC') {
          mode = 'Credit Card';
        }
        sendOrderDetails(mode, jsonVal['txnid']);
      } else {
        //Snackbar to show failure
        print("Payment Failed");

        // routeNameBeforePayment = '/subscriptionsummary';
        // Navigator.pushReplacementNamed(context, '/paymentfailederrorscreen');
        addQuantityToInventoryOnPaymentFail();
      }
    } on PlatformException catch (e) {
      //Snackbar to show failure
      print(e);
      print("Payment Failed");
      // Navigator.pop(context);
      // routeNameBeforePayment = '/subscriptionsummary';
      // Navigator.pushReplacementNamed(context, '/paymentfailederrorscreen');
      addQuantityToInventoryOnPaymentFail();
    }
  }
}
