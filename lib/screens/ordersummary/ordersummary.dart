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
import 'package:cornext_mobile/constants/appfonts.dart';
import 'dart:async';
// import 'package:http/http.dart' as http;

class OrderSummaryPage extends StatefulWidget {
  @override
  OrderSummary createState() => OrderSummary();
}

class OrderSummary extends State<OrderSummaryPage> {
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
  bool makeAdvancePayment = false;
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
  Map couponCodeDiscount = {};
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final AppFonts appFonts = AppFonts();
  bool isBackButtonClicked = false;
  bool isQuantityFieldFocused = false;
  void initState() {
    if (orderIdFromDeepLink != "") {
      getOrderDetailsFromDeepLink();
    } else {
      getCartDetails();
      checkAdvancePaymentValidations();
      super.initState();
    }
    orderSummaryService.getRazorPayKeyAndSecret(context, setState, scaffoldKey);
  }

  void dispose() {
    super.dispose();
  }

  checkAdvancePaymentValidations() {
    GlobalValidations().validateCurrentFieldValidOrNot(
        advancePaymentFocusNode, advancePaymentkey);
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
          final data = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(data, context, setState)) {
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
      if (makeAdvancePayment &&
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
                print(subscribedprice);
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
                listOfCartDetails.forEach((val) {
                  if (val['focusNode'] != null) {
                    val['focusNode'].unfocus();
                  }
                });
                if (isLoadingIconDisplaying) {
                  Navigator.of(context).pop();
                }
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

  getSubscribedAmount() {
    if (advancePaymentkey.currentState.validate() &&
        advancePaymentController.text.trim() != "") {
      // getCartProductDetails();
      if (previousNoofSubscriptions == 0 ||
          (previousNoofSubscriptions !=
              int.parse(advancePaymentController.text.trim()))) {
        if (userRegistrationDiscountInfo != null &&
            userRegistrationDiscountInfo['active'] != null &&
            userRegistrationDiscountInfo['active']) {
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
            actualSubscribedPrice = actualPriceOfCurrentOrder *
                int.parse(advancePaymentController.text);
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
        updateQuantityDetails(quantity, obj['productId']);
        updateTotalPriceOfProducts(obj['productId'], quantity);
        obj['key'].currentState?.validate();
        if (isBackButtonClicked) {
          manageBackButtonClick();
        }
        // addUserRegistrationDiscount(true);
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
        if (isBackButtonClicked) {
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
              if (isBackButtonClicked) {
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
        if (isBackButtonClicked) {
          manageBackButtonClick();
        }
      } else if (data['error'] != null) {
        Navigator.pop(context);
        apiErros.apiLoggedErrors(data, context, scaffoldKey);
        updateQuantityDetails(obj['numberOfItems'], obj['productId']);
        if (isBackButtonClicked) {
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
      if (isBackButtonClicked) {
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
        });
      }
    });
  }

  // UpDate Total Price In Cart
  updateTotalPriceOfProducts(int productId, int quantity) {
    List updatedPriceOfProducts = [];
    bool isQuantityChanged = false;
    listOfCartDetails.forEach((val) {
      Map obj = val;
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
        addUserRegistrationDiscount(true);
      });
    }
    Timer(Duration(milliseconds: 10), () {
      if (isQuantityFieldFocused) {
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
        addUserRegistrationDiscount(true);
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
  }

  // Display Cart Details
  List<Widget> getCartProductDetails() {
    setState(() {
      totalTaxAmount = 0.0;
      productDiscountAmount = 0.0;
      priceOfProducts = [];
    });
    return listOfCartDetails.map((res) {
      print(res['quantity']);
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
              // priceOfCurrentProduct = priceOfCurrentProduct -
              //     (priceOfCurrentProduct) *
              //         int.parse(res['productDiscount']
              //             .toString()
              //             .replaceAll('%', '')) /
              //         100;
              priceOfCurrentProduct = res['discountPrice'];
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
                              // Padding(
                              //   padding: EdgeInsets.only(left: 5),
                              // ),
                              Container(
                                // margin: EdgeInsets.only(left: 2),
                                width: 70,
                                child: Text(
                                  res['units'],
                                  softWrap: true,
                                  style: appFonts
                                      .getTextStyle('cart_units_text_style'),
                                ),
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

  getCouponCodeDiscount() {
    final requestObj = {"couponCode": couponCodeController.text.trim()};
    displayLoadingIcon(context);
    orderSummaryService.getCouponCodeDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      Navigator.pop(context);
      if (data != null) {
        if (data['couponDiscount'] != null) {
          setState(() {
            couponCodeDiscount = data;
            couponCodeErrors = "";
            couponCodeSuccessMessages = "Coupon code successfully applied";
          });
          addCouponCodeDiscount();
        } else if (data['status'] != null && data['status'] == "EXPIRED") {
          setState(() {
            couponCodeErrors = "Coupon Code Expired";
            couponDiscount = 0.0;
          });
        } else if (data['status'] != null && data['status'] == "INVALID") {
          setState(() {
            couponCodeErrors = "Coupon Code not valid";
            couponDiscount = 0.0;
          });
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
      Navigator.pop(context);
      apiErros.apiErrorNotifications(
          err, context, '/ordersummary', scaffoldKey);
    });
  }

  // Add Coupon Discount;
  addCouponCodeDiscount() {
    double couponDiscountAmount = 0.0;
    if (couponCodeDiscount['couponDiscount'] != null &&
        couponCodeDiscount['amountAppliedIn'] == "Rs") {
      couponDiscountAmount = couponCodeDiscount['couponDiscount'];
    } else if (couponCodeDiscount['couponDiscount'] != null &&
        couponCodeDiscount['amountAppliedIn'] == "%") {
      couponDiscountAmount =
          priceOfTotalProducts * (couponCodeDiscount['couponDiscount'] / 100);
    }
    if (couponDiscountAmount > 0) {
      if (subscribedprice > 0) {
        if (subscribedprice > couponCodeDiscount['minimumOrderAmount']) {
          setState(() {
            couponDiscount = couponDiscountAmount;
          });
        }
      } else {
        if (priceOfTotalProducts > couponCodeDiscount['minimumOrderAmount']) {
          setState(() {
            couponDiscount = couponDiscountAmount;
          });
        }
      }
    }
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
          // unComment this to add taxvalue;
          // priceOfCurrentProduct = res['value'] + taxValue;

          //comment this to add taxvalue;
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

  manageOrderDispatch() {
    bool isProductDetailsValid = true;
    Map errorObj = {};
    setState(() {
      isQuantityFieldFocused = false;
    });
    listOfCartDetails.forEach((val) {
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
      sendOrderDetails();
      // Navigator.pushNamed(context, "/subscriptionconformation");
    } else {
      // closeNotifications();
      clearErrorMessages(scaffoldKey);
      showErrorNotifications(
          errorObj['key'].currentState.errorText, context, scaffoldKey);
    }
  }

  sendOrderDetails() {
    Map requestObj = {
      "userId": signInDetails['userId'],
      "orderId": orderIdFromDeepLink != "" ? orderIdFromDeepLink : null,
      "paymentSuccess": true,
      "havingRegistrationDiscount": registrationDiscount > 0 ? true : false,
      "addressId": selectedDeliveryAddress['addressId'],
      "deepLink": null,
      "amountPerOrder": actualPriceOfCurrentOrder,
      "totalProductDiscountAmountPerOrder": productDiscountAmount,
      "totalTaxAmountPerOrder": totalTaxAmount,
      "transactionAmount": couponDiscount > 0
          ? priceOfTotalProducts - couponDiscount
          : priceOfTotalProducts,
      "couponDetails": couponDiscount > 0
          ? {
              'couponId': couponCodeDiscount['couponId'],
              'couponDiscount': couponDiscount
            }
          : null,
      "subscription": null,
      "productDetails": getProductDetailsInfo()
    };
    print(requestObj);
    currentOrderInfo = requestObj;
    listOfProductsToBeOrder = listOfCartDetails;
    // Map obj = {
    //   "key": "1UngQS1p",
    //   // "txnid": "000100"
    //   "amount": "1000",
    //   "productinfo": "Jeans",
    //   "firstname": "Veera",
    //   "email": "veera@gmail.com",
    //   "phone": "9505037717",
    //   "surl":"",
    //   "furl":"",
    //   "service_provider":"payu_paisa"
    // };
    // http.post("https://sandboxsecure.payu.in/_payment",body: obj).then((res){
    //   print(res.body);

    // });
    print('jsjs');
    print(requestObj);
    Navigator.popAndPushNamed(context, '/subscriptionconformation');

    // Uncomment to don't show subscription screen
    // displayLoadingIcon(context);
    // orderSummaryService.postOrderDetails(requestObj).then((val) {
    //   final data = json.decode(val.body);
    //   Navigator.pop(context);
    //   print(data);
    //   print("aaaa");

    //   // data['orderId']
    //   if (data != null && data['orderId'] != null) {
    //     orderId = data['orderId'];
    //     orderIdFromDeepLink = 0;
    //     subscriptionDetails = {};
    //     Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation',
    //         ModalRoute.withName('/orderconfirmation'));
    //   } else {
    //     print(data);
    //   }
    // }, onError: (err) {
    //   print(err);
    //   Navigator.pop(context);
    //   apiErros.apiErrorNotifications(err, context, '/ordersummary',scaffoldKey);
    // });
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
    print(productDetailsObj);
    return productDetailsObj;
  }

  manageBackButtonClick() {
    setState(() {
      isBackButtonClicked = false;
    });
    Navigator.popAndPushNamed(context, '/deliveryaddress');
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
          selectedDeliveryAddress = {};
          //   isRepeatOrder = false;
          //   Navigator.popAndPushNamed(context, '/yourorders');
          //   return Future.value(false);
          // } else {
          // });
          // isRepeatOrder = false;
          bool isQuantityFieldOnFocus = false;
          listOfCartDetails.forEach((val) {
            if (val['focusNode'] != null && val['focusNode'].hasFocus) {
              setState(() {
                isQuantityFieldOnFocus = true;
              });
              val['focusNode'].unfocus();
            }
          });
          if (!isQuantityFieldOnFocus) {
            manageBackButtonClick();
          } else {
            setState(() {
              isBackButtonClicked = true;
            });
          }
          // if (isLoadingIconDisplaying) {
          //   Navigator.of(context).pop();
          // }

          return Future.value(false);
          // }
        },
        child: Scaffold(
            // appBar: appBarWidgetWithIcons(context, false, this.setState, false,'/ordersummary'),
            key: scaffoldKey,
            appBar: plainAppBarWidget,
            body: !isLoading
                ? listOfCartDetails.length > 0
                    ? GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
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
                                        Container(
                                          // width: 115,
                                          margin: EdgeInsets.only(right: 10),
                                          // alignment: Alignment.topRight,
                                          // child: RaisedButton(
                                          //   onPressed: () {},
                                          //   child: Row(
                                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //     children: <Widget>[Text("Change"), Icon(Icons.edit)],
                                          //   ),
                                          // ),
                                          child: GestureDetector(
                                            onTap: () {
                                              isNavigatingFromDelivarypage =
                                                  true;
                                              Navigator.popAndPushNamed(
                                                  context, "/deliveryaddress");
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        )
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
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Apply Coupon",
                                    style: appFonts.getTextStyle(
                                        'order_summary_selected_products_heading_style'),
                                  ),
                                ),
                                Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text("Coupon code:"),
                                        ),
                                        Flexible(
                                            child: TextFormField(
                                          controller: couponCodeController,
                                          key: couponCodeKey,
                                          cursorColor: mainAppColor,
                                          onChanged: (val) {
                                            setState(() {
                                              couponCodeErrors = '';
                                              couponCodeSuccessMessages = '';
                                            });
                                          },
                                          onFieldSubmitted: (val) {
                                            // onPressed: () {
                                            setState(() {
                                              couponCodeSuccessMessages = '';
                                              couponCodeErrors = '';
                                            });
                                            if (couponCodeKey.currentState
                                                .validate()) {
                                              getCouponCodeDiscount();
                                            } else {
                                              couponDiscount = 0.0;
                                              setState(() {});
                                            }
                                            // },
                                          },
                                          validator: (val) =>
                                              GlobalValidations()
                                                  .couponCodeValidations(val),
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  borderSide: BorderSide(
                                                    color:
                                                        couponCodeErrors != ""
                                                            ? Colors.red
                                                            : mainAppColor,
                                                  )),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  borderSide: BorderSide(
                                                      color: couponCodeErrors !=
                                                              ""
                                                          ? Colors.red
                                                          : couponCodeSuccessMessages !=
                                                                  ""
                                                              ? mainAppColor
                                                              : Colors.grey)),
                                              focusedBorder:
                                                  appStyles.focusedInputBorder,
                                              isDense: true,
                                              errorStyle: appFonts.getTextStyle(
                                                  'hide_error_messages_for_formfields'),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 11,
                                                      vertical: 8)),
                                        )),
                                        Container(
                                          child: RaisedButton(
                                            color: orangeColor,
                                            onPressed: () {
                                              setState(() {
                                                couponCodeSuccessMessages = '';
                                                couponCodeErrors = '';
                                              });
                                              if (couponCodeKey.currentState
                                                  .validate()) {
                                                getCouponCodeDiscount();
                                              } else {
                                                couponDiscount = 0.0;
                                                setState(() {});
                                              }
                                            },
                                            child: Text(
                                              "Apply Coupon",
                                              style: appFonts.getTextStyle(
                                                  'button_text_color_white'),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),

                                couponCodeErrors != ""
                                    ? Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(right: 30),
                                        child: Text(
                                          couponCodeErrors,
                                          style: appFonts.getTextStyle(
                                              'text_color_red_style'),
                                        ),
                                      )
                                    : Container(),
                                couponCodeKey.currentState != null &&
                                        couponCodeKey.currentState.hasError
                                    ? Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(right: 30),
                                        child: Text(
                                          couponCodeKey.currentState.errorText,
                                          style: appFonts.getTextStyle(
                                              'text_color_red_style'),
                                        ),
                                      )
                                    : Container(),
                                couponCodeSuccessMessages != ''
                                    ? Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(right: 30),
                                        child: Text(
                                          couponCodeSuccessMessages,
                                          style: appFonts.getTextStyle(
                                              'text_color_mainappcolor_style'),
                                        ),
                                      )
                                    : Container(),
                                // Divider(
                                //   thickness: 2,
                                // ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   // crossAxisAlignment: CrossAxisAlignment.center,
                                //   children: <Widget>[
                                //     Container(
                                //         height: 40,
                                //         width: 160,
                                //         child: RaisedButton(
                                //           onPressed: () {
                                //             setState(() {
                                //               editSubcriptions = false;
                                //             });
                                //             Navigator.popAndPushNamed(
                                //                 context, '/subscription');
                                //           },
                                //           child: Text(
                                //             "Subscribe",
                                //             style: TextStyle(
                                //                 color: Colors.white,
                                //                 fontSize: 17),
                                //           ),
                                //           color: mainAppColor,
                                //         ))
                                //   ],
                                // ),
                                // subscriptionsData != null &&
                                //         subscriptionsData['deliveryEvery'] != null
                                //     ? Container(
                                //         margin:
                                //             EdgeInsets.only(top: 5, bottom: 5),
                                //         alignment: Alignment.center,
                                //         child: Text(
                                //           "Deliver Every " +
                                //               subscriptionsData['deliveryEvery'] +
                                //               " " +
                                //               subscriptionsData['units'],
                                //           style: TextStyle(
                                //             // fontWeight: FontWeight.bold,
                                //             fontSize: 16,
                                //           ),
                                //         ),
                                //       )
                                //     : Container(),
                                // subscriptionsData != null &&
                                //         subscriptionsData['deliveryEvery'] != null
                                //     ? Container(
                                //         alignment: Alignment.center,
                                //         margin:
                                //             EdgeInsets.only(left: 15, right: 10),
                                //         // width: MediaQuery.of(context).size.width - 100,
                                //         child: Center(
                                //             child: Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.center,
                                //           children: <Widget>[
                                //             Flexible(
                                //                 child: Container(
                                //                     margin: EdgeInsets.only(
                                //                         right: 10),
                                //                     child: Text("For next :"))),
                                //             Flexible(
                                //                 child: Container(
                                //                     margin: EdgeInsets.only(
                                //                         right: 10),
                                //                     child: TextFormField(
                                //                       controller:
                                //                           advancePaymentController,
                                //                       key: advancePaymentkey,
                                //                       focusNode:
                                //                           advancePaymentFocusNode,
                                //                       cursorColor: mainAppColor,
                                //                       maxLength: 4,
                                //                       validator: (val) =>
                                //                           GlobalValidations()
                                //                               .advancePaymentValidations(
                                //                                   val),
                                //                       keyboardType: TextInputType
                                //                           .numberWithOptions(
                                //                               decimal: false,
                                //                               signed: false),
                                //                       decoration: InputDecoration(
                                //                           border: appStyles
                                //                               .inputBorder,
                                //                           focusedBorder: appStyles
                                //                               .focusedInputBorder,
                                //                           isDense: true,
                                //                           counterText: "",
                                //                           suffix: Text("Times"),
                                //                           errorStyle: TextStyle(
                                //                               fontSize: 0),
                                //                           contentPadding:
                                //                               EdgeInsets
                                //                                   .symmetric(
                                //                                       horizontal:
                                //                                           11,
                                //                                       vertical:
                                //                                           8)),
                                //                       onFieldSubmitted: (val) {
                                //                         if (makeAdvancePayment &&
                                //                             advancePaymentController
                                //                                     .text
                                //                                     .trim() !=
                                //                                 "" &&
                                //                             advancePaymentkey
                                //                                 .currentState
                                //                                 .validate()) {
                                //                           getSubscribedAmount();
                                //                         } else {
                                //                           setState(() {
                                //                             subscribedprice = 0;
                                //                             actualSubscribedPrice =
                                //                                 0;
                                //                             previousNoofSubscriptions =
                                //                                 0;
                                //                             taxAmountWithSubscription =
                                //                                 0;
                                //                             // advancePaymentController.clear();
                                //                             // advancePaymentkey.currentState?.reset();
                                //                           });
                                //                           addUserRegistrationDiscount(false);
                                //                         }
                                //                       },
                                //                     ))),
                                //             // Container(
                                //             //     child: RaisedButton(
                                //             //   onPressed: () {
                                //             //     getSubscribedAmount();
                                //             //   },
                                //             //   child: Text("Apply"),
                                //             // ))
                                //           ],
                                //         )))
                                //     : Container(),
                                // subscriptionsData != null &&
                                //         subscriptionsData['deliveryEvery'] != null
                                //     ? Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //             Container(
                                //                 height: 28,
                                //                 width: 32,
                                //                 child: Checkbox(
                                //                   value: makeAdvancePayment,
                                //                   onChanged: (val) {
                                //                     setState(() {
                                //                       makeAdvancePayment = val;
                                //                       if (!makeAdvancePayment) {
                                //                         setState(() {
                                //                           subscribedprice = 0;
                                //                           actualSubscribedPrice =
                                //                               0;
                                //                           previousNoofSubscriptions =
                                //                               0;
                                //                           taxAmountWithSubscription =
                                //                               0;
                                //                           advancePaymentController
                                //                               .clear();
                                //                           advancePaymentkey
                                //                               .currentState
                                //                               ?.reset();
                                //                         });
                                //                         addUserRegistrationDiscount(false);
                                //                       } else {
                                //                         if (advancePaymentController
                                //                                     .text
                                //                                     .trim() !=
                                //                                 "" &&
                                //                             advancePaymentkey
                                //                                 .currentState
                                //                                 .validate()) {
                                //                           getSubscribedAmount();
                                //                         }
                                //                       }
                                //                     });
                                //                   },
                                //                   activeColor: mainAppColor,
                                //                 )),
                                //             Flexible(
                                //                 child: Text(
                                //               "Make advance payment for subscription",
                                //               style: TextStyle(
                                //                   fontSize: 16,
                                //                   fontWeight: FontWeight.w600),
                                //             )),
                                //           ])
                                //     : Container(),

                                // advancePaymentkey.currentState != null &&
                                //         advancePaymentkey.currentState.hasError
                                //     ? Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: <Widget>[
                                //           Flexible(
                                //             child: Text(
                                //               advancePaymentkey
                                //                   .currentState.errorText,
                                //               style: TextStyle(color: Colors.red),
                                //             ),
                                //           )
                                //         ],
                                //       )
                                //     : Container(),
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
                                                  child: Text(couponCodeDiscount[
                                                              'currencyRepresentation']
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
                        listOfCartDetails.forEach((val) {
                          if (val['focusNode'] != null &&
                              val['focusNode'].hasFocus) {
                            setState(() {
                              isQuantityFieldFocused = true;
                            });
                            val['focusNode'].unfocus();
                          }
                        });
                        if (!isQuantityFieldFocused) {
                          manageOrderDispatch();
                        }
                      },
                      child: Text(
                        "Proceed To Payment",
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
}
