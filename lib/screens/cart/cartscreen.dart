import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/cartservice/cartservice.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
// import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'dart:async';
import 'package:cornext_mobile/services/ordersummaryservice/ordersummaryservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

class CartPage extends StatefulWidget {
  @override
  CartDetails createState() => CartDetails();
}

class CartDetails extends State<CartPage> {
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
  final ProductDetailsService productDetailsService = ProductDetailsService();
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  bool isLoadingIconDisplaying = false;
  bool isBackButtonPressed = false;
  bool isEditFieldFocused = false;
  final AppFonts appFonts = AppFonts();
  Timer timer;

  void initState() {
    if (signInDetails['access_token'] != null) {
      if (orderIdFromDeepLink != "") {
        print(orderIdFromDeepLink);
        // getCartDetails();
        addQuantityToCartFromDeepLink();
      } else {
        getCartDetails();
      }
    } else {
      setState(() {
        noOfProductsAddedInCart = storeCartDetails.length;
      });
      addControllers(storeCartDetails);
      getQuantityInfo();
      setQuantityFocusNodes();
    }
    super.initState();
    showOrHideSearchAndFilter = false;
  }

  addQuantityToCartFromDeepLink() {
    cartService.getOrderDetailsFromDeepLink(orderIdFromDeepLink).then((val) {
      final data = json.decode(val.body);
      if (data['status'] != null && data['status'] == 'SUCCESS') {
        setState(() {
          orderIdFromDeepLink = "";
        });
        getCartDetails();
      } else if (data['status'] != null && data['status'] == "FAILED") {
        showErrorNotifications(
            "Failed to add prdoucts into cart", context, scaffoldkey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, setState)) {
            getCartDetails();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/cart', scaffoldkey);
    });
  }

  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  checkAndDisplayLoginSuccessMessage() {
    timer = Timer(Duration(microseconds: 200), () {
      if (displayRegistrationSuccessMessage) {
        showSuccessNotifications(
            "Account Created Successfully", context, scaffoldkey);
        setState(() {
          displayRegistrationSuccessMessage = false;
        });
      }
    });
  }

  getCartDetails() {
    final requestObj = {
      'limit': cartProductslimit,
      'pageNumber': pageNo,
      'screenName': 'HS'
    };

    cartService.getCartDetails(requestObj).then((res) {
      final data = json.decode(res.body);
      print(data);
      if (data['listOfProductsInCart'] != null &&
          data['noOfItemsInCart'] != null &&
          int.parse(data['noOfItemsInCart']) > 0) {
        if (noOfProductsAddedInCart == 0) {
          setState(() {
            noOfProductsAddedInCart = data['numberOfItems'];
          });
        }
        setState(() {
          cartDetails = data;
          print(data);
          // listOfCartDetails = data['listOfProductsInCart'];
          addControllers(data['listOfProductsInCart']);
          getQuantityInfo();
          setQuantityFocusNodes();
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
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/cart', scaffoldkey);
    });
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
          clearErrorMessages(scaffoldkey);
          showErrorNotifications(
              key.currentState.errorText, context, scaffoldkey);
        } else if (signInDetails['access_token'] != null) {
          // updateTotalPriceOfProducts(
          //     response['priceId'], response['numberOfItems']);
          clearErrorMessages(scaffoldkey);
          // closeNotifications();
          response['numberOfItems'] =
              int.parse(response['controller'].text.trim());
          updateQuantityDetailsOnCart(response, response['numberOfItems']);
        } else {
          clearErrorMessages(scaffoldkey);
          // closeNotifications();
          response['numberOfItems'] =
              int.parse(response['controller'].text.trim());
          updateQuantityDetails(
              response['numberOfItems'], response['productId']);
          updateTotalPriceOfProducts(
              response['productId'], response['numberOfItems']);
          response['key'].currentState?.validate();
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
      print(data);
      if (data.runtimeType == int && data > 0) {
        // print('enter');
        // closeNotifications();
        clearErrorMessages(scaffoldkey);
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
          noOfProductsAddedInCart = data;
        });
        setState(() {});
        updateQuantityDetails(quantity, obj['productId']);
        updateTotalPriceOfProducts(obj['productId'], quantity);
        obj['key'].currentState?.validate();
        if (isEditFieldFocused) {
          setState(() {
            showOrHideSearchAndFilter = false;
            isDeliveryAddress = false;
          });

          Navigator.popAndPushNamed(context, '/deliveryaddress');
        }
        if (isBackButtonPressed) {
          manageBackButtonFunctionality();
        }
      } else if (data == 'FAILED') {
        Navigator.pop(context);
        setState(() {
          isLoadingIconDisplaying = false;
        });
        clearErrorMessages(scaffoldkey);
        showErrorNotifications(
            "Failed to update the cart", context, scaffoldkey);
        updateQuantityDetails(obj['numberOfItems'], obj['productId']);
        obj['key'].currentState?.validate();
        if (isBackButtonPressed) {
          manageBackButtonFunctionality();
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
          manageBackButtonFunctionality();
        }
      } else if (data['error'] != null) {
        Navigator.pop(context);
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
        updateQuantityDetails(obj['numberOfItems'], obj['productId']);
        if (isBackButtonPressed) {
          manageBackButtonFunctionality();
        }
      }
    }, onError: (err) {
      Navigator.pop(context);
      setState(() {
        isLoadingIconDisplaying = false;
      });
      updateQuantityDetails(obj['numberOfItems'], obj['productId']);
      apiErros.apiErrorNotifications(err, context, '/cart', scaffoldkey);
      if (isBackButtonPressed) {
        manageBackButtonFunctionality();
      }
    });
  }

  // UpDate Quantity Details Locally
  updateQuantityDetails(int quantity, int productId) {
    listOfCartDetails.forEach((res) {
      if (res['productId'] == productId) {
        setState(() {
          res['controller'].text = quantity.toString();
          print(quantity);
          res['numberOfItems'] = quantity;
        });
      }
    });
  }

  // UpDate Total Price In Cart
  updateTotalPriceOfProducts(int productId, int quantity) {
    List updatedPriceOfProducts = [];
    bool isQuantityChanged = false;
    priceOfProducts.forEach((val) {
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
        priceOfProducts = updatedPriceOfProducts;
        getTotalAmount(priceOfProducts);
      });
    }
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
    if (signInDetails['access_token'] != null) {
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
        apiErros.apiErrorNotifications(err, context, '/cart', scaffoldkey);
      });
    } else {
      removeItemFromCart(res);
      noOfProductsAddedInCart = noOfProductsAddedInCart - 1;
      setState(() {});
    }
  }

  //Removes Product From Cart
  removeItemFromCart(obj) {
    setState(() {
      listOfCartDetails.removeAt(listOfCartDetails.indexOf(obj));
    });
    if (signInDetails['access_token'] == null) {
      storeCartDetails.removeAt(storeCartDetails
          .indexWhere((val) => val['productId'] == obj['productId']));
    }
  }

  //Navigated to product details page
  getProductDetails(Map object) {
    productDetailsObject['productId'] = object['productId'];
    productDetailsObject['productTypeId'] =
        object['productTypeId'] != null ? object['productTypeId'] : null;
    productDetailsObject['specificationId'] =
        object['specificationId'] != null ? object['specificationId'] : null;
    productDetailsObject['priceId'] =
        object['priceId'] != null ? object['priceId'] : null;
    productDetailsObject['screenName'] = "PRD";
    productDetailsObject['userId'] =
        signInDetails['access_token'] != null ? signInDetails['userId'] : null;
    previousRouteName = '/cart';
    Navigator.of(context).popAndPushNamed('/productdetails');
  }

  // Display Cart Details
  List<Widget> getCartProductDetails() {
    setState(() {
      priceOfProducts = [];
      priceOfTotalProducts = 0;
    });
    return listOfCartDetails.map((res) {
      // print(res);
      double priceOfCurrentProduct = 0.0;

      if (res['taxpercent'] != null) {
        final double taxValue = res['value'] *
            int.parse(res['taxpercent'].toString().replaceAll('%', '')) /
            100;
        print(taxValue);
        // Uncomment this to add tax value;
        // setState(() {
        //   priceOfCurrentProduct = res['value'] + taxValue;
        // });
        // upto here

        //Comment this to add taxvalue
        setState(() {
          priceOfCurrentProduct = res['value'];
        });
        // upto here
      } else {
        setState(() {
          priceOfCurrentProduct = res['value'];
        });
      }

      if (res['units'] == null) {
        if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
          if (res['quantity'] >= res['minimumQuantity']) {
            // priceOfCurrentProduct = priceOfCurrentProduct -
            //     (priceOfCurrentProduct) *
            //         int.parse(
            //             res['productDiscount'].toString().replaceAll('%', '')) /
            //         100;
            priceOfCurrentProduct = res['discountPrice'];
          }
        } else if (res['discountPrice'] != null) {
          priceOfCurrentProduct = res['discountPrice'];
        }
        setState(() {
          priceOfTotalProducts =
              priceOfTotalProducts + (priceOfCurrentProduct * res['quantity']);
        });
      } else {
        if (res['units'] == "Metric Ton") {
          if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
            if (res['quantity'] * 1000 >= res['minimumQuantity']) {
              // priceOfCurrentProduct = priceOfCurrentProduct -
              //     (priceOfCurrentProduct) *
              //         int.parse(res['productDiscount']
              //             .toString()
              //             .replaceAll('%', '')) /
              //         100;
              priceOfCurrentProduct = res['discountPrice'];
            }
          } else if (res['discountPrice'] != null) {
            priceOfCurrentProduct = res['discountPrice'];
          }
          setState(() {
            priceOfTotalProducts = priceOfTotalProducts +
                (priceOfCurrentProduct * res['quantity'] * 1000);
          });
        } else {
          if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
            if (res['quantity'] >= res['minimumQuantity']) {
              // priceOfCurrentProduct = priceOfCurrentProduct -
              //     (priceOfCurrentProduct) *
              //         int.parse(res['productDiscount']
              //             .toString()
              //             .replaceAll('%', '')) /
              //         100;
              priceOfCurrentProduct = res['discountPrice'];
            }
          } else if (res['discountPrice'] != null) {
            priceOfCurrentProduct = res['discountPrice'];
          }
          setState(() {
            priceOfTotalProducts = priceOfTotalProducts +
                (priceOfCurrentProduct * res['quantity']);
          });
        }
      }

      final obj = res;
      priceOfProducts.add(obj);
      final String imageUrl = res['resourceUrl'];
      return Container(
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
              onTap: () {
                getProductDetails(res);
              },
              child: Card(
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
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width /
                                        (MediaQuery.of(context)
                                                .size
                                                .aspectRatio *
                                            6.5) -
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
                                        ),
                                        res['specificationName'] != null
                                            ? TextSpan(
                                                text: " (" +
                                                    res['specificationName'] +
                                                    ")",
                                                style: appFonts.getTextStyle(
                                                    'cart_screen_specification_&_type_names_styles'))
                                            : TextSpan(),
                                        res['productTypeName'] != null
                                            ? TextSpan(
                                                text: ", " +
                                                    res['productTypeName'],
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
                                                currencyFormatter.format(
                                                    priceOfCurrentProduct) +
                                                " " +
                                                res['appliedAgainst'],
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )
                                        : Text(
                                            currencyFormatter.format(
                                                    priceOfCurrentProduct) +
                                                " " +
                                                res['appliedAgainst'],
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )
                                    : res['currencyRepresentation'] != null
                                        ? Text(
                                            res['currencyRepresentation'] +
                                                currencyFormatter.format(
                                                    priceOfCurrentProduct),
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )
                                        : Text(
                                            currencyFormatter
                                                .format(priceOfCurrentProduct),
                                            style: appFonts.getTextStyle(
                                                'cart_screen_product_price_styles'),
                                          )),
                            Container(
                                width: (MediaQuery.of(context).size.width) -
                                    ((MediaQuery.of(context).size.width) /
                                        (MediaQuery.of(context)
                                                .size
                                                .aspectRatio *
                                            6.5)) -
                                    35,
                                child: Row(children: [
                                  res['units'] == null
                                      ? Container(
                                          margin: EdgeInsets.only(top: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: res['key'].currentState !=
                                                                null &&
                                                            res['key']
                                                                .currentState
                                                                .hasError ||
                                                        res['numberOfItems'] >
                                                            9999
                                                    ? Colors.red
                                                    : Colors.grey[300],
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0.3),
                                          width: 115,
                                          height: 37,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              res['numberOfItems'] == 1
                                                  ? SizedBox(
                                                      width: _buttonWidth,
                                                      height: _buttonWidth,
                                                      child: FlatButton(
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          onPressed: () {
                                                            deleteProductFromCart(
                                                                res);
                                                          },
                                                          child: Icon(
                                                            Icons.delete,
                                                            size: 20,
                                                            color: Colors
                                                                .grey[700],
                                                          )),
                                                    )
                                                  : SizedBox(
                                                      width: _buttonWidth,
                                                      height: _buttonWidth,
                                                      child: FlatButton(
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          onPressed: () {
                                                            res['focusNode']
                                                                .unfocus();
                                                            if ((res['productMinimumQuantity'] !=
                                                                        null &&
                                                                    res['numberOfItems'] >
                                                                        res['productMinimumQuantity']
                                                                            .toInt()) ||
                                                                (res['productMinimumQuantity'] ==
                                                                        null &&
                                                                    res['numberOfItems'] >
                                                                        1)) {
                                                              setState(() {
                                                                // displayLoadingIcon(context);
                                                                // res['numberOfItems']--;
                                                                // res['controller'].text =
                                                                //     res['numberOfItems'].toString();
                                                                // updateTotalPriceOfProducts(
                                                                //     res['priceId'],
                                                                //     res['numberOfItems']);
                                                                final quantity =
                                                                    res['numberOfItems'] -
                                                                        1;
                                                                clearErrorMessages(
                                                                    scaffoldkey);
                                                                // closeNotifications();
                                                                if (signInDetails[
                                                                        'access_token'] !=
                                                                    null) {
                                                                  updateQuantityDetailsOnCart(
                                                                      obj,
                                                                      quantity);
                                                                } else {
                                                                  updateQuantityDetails(
                                                                      quantity,
                                                                      obj['productId']);
                                                                  updateTotalPriceOfProducts(
                                                                      obj['productId'],
                                                                      quantity);
                                                                }
                                                              });
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.remove_circle,
                                                            size: 20,
                                                            color: Colors
                                                                .grey[700],
                                                          )),
                                                    ),
                                              Container(
                                                  width: 50,
                                                  child: TextFormField(
                                                    maxLength: 4,
                                                    // textAlign: TextAlign.center,
                                                    controller:
                                                        res['controller'],
                                                    focusNode: res['focusNode'],
                                                    key: res['key'],
                                                    validator: (val) =>
                                                        GlobalValidations()
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
                                                        border:
                                                            InputBorder.none,
                                                        counterText: "",
                                                        errorStyle: appFonts
                                                            .getTextStyle(
                                                                'hide_error_messages_for_formfields')),
                                                    // textAlignVertical: TextAlignVertical.center,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true,
                                                            signed: false),
                                                    textAlign: TextAlign.center,
                                                    onFieldSubmitted: (val) {
                                                      if (val != '' &&
                                                          int.parse(val) !=
                                                              null &&
                                                          int.parse(val) > 0) {
                                                        setState(() {
                                                          res['numberOfItems'] =
                                                              int.parse(val);
                                                        });
                                                      } else if (val != '' &&
                                                          int.parse(val) !=
                                                              null &&
                                                          int.parse(val) == 0) {
                                                        res['numberOfItems'] =
                                                            0;
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
                                                    if (res['numberOfItems'] <
                                                        9999) {
                                                      setState(() {
                                                        // res['numberOfItems']++;
                                                        // res['controller'].text =
                                                        //     res['numberOfItems'].toString();
                                                        // updateTotalPriceOfProducts(
                                                        //     res['priceId'], res['numberOfItems']);
                                                        // Navigator.pop(context);
                                                        final int quantity =
                                                            res['numberOfItems'] +
                                                                1;
                                                        clearErrorMessages(
                                                            scaffoldkey);
                                                        // closeNotifications();
                                                        if (signInDetails[
                                                                'access_token'] !=
                                                            null) {
                                                          updateQuantityDetailsOnCart(
                                                              res, quantity);
                                                        } else {
                                                          updateQuantityDetails(
                                                              quantity,
                                                              obj['productId']);
                                                          updateTotalPriceOfProducts(
                                                              obj['productId'],
                                                              quantity);
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
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0.3),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  (MediaQuery.of(context)
                                                          .size
                                                          .aspectRatio *
                                                      6.5)) -
                                              90,
                                          height: 37,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                  width: 90,
                                                  child: TextFormField(
                                                    maxLength: 4,
                                                    cursorColor: mainAppColor,
                                                    // textAlign: TextAlign.center,
                                                    controller:
                                                        res['controller'],
                                                    focusNode: res['focusNode'],
                                                    key: res['key'],
                                                    validator: (val) => GlobalValidations()
                                                        .unitsQuantityValidations(
                                                            val,
                                                            res['productMinimumQuantity'] !=
                                                                    null
                                                                ? res['productMinimumQuantity']
                                                                    .toInt()
                                                                : null,
                                                            res['units']),
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.all(8),
                                                        // border: InputBorder.none,
                                                        counterText: "",
                                                        border:
                                                            OutlineInputBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color:
                                                                      mainAppColor,
                                                                )),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color:
                                                                      mainAppColor,
                                                                )),
                                                        errorStyle: appFonts
                                                            .getTextStyle(
                                                                'hide_error_messages_for_formfields')),
                                                    // textAlignVertical: TextAlignVertical.center,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true,
                                                            signed: false),
                                                    textAlign: TextAlign.center,
                                                    onFieldSubmitted: (val) {
                                                      if (val != '' &&
                                                          int.parse(val) !=
                                                              null &&
                                                          int.parse(val) > 0) {
                                                        setState(() {
                                                          res['numberOfItems'] =
                                                              int.parse(val);
                                                        });
                                                      }
                                                    },
                                                  )),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5)),
                                              Container(
                                                width: 70,
                                                child: Text(res['units'],
                                                    softWrap: true,
                                                    // overflow:
                                                    //     TextOverflow.ellipsis,
                                                    style: appFonts.getTextStyle(
                                                        'cart_units_text_style')),
                                              )
                                            ],
                                          ),
                                        ),
                                  res['units'] == null
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              left: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .aspectRatio *
                                                              6.5)) -
                                                      90) -
                                                  115),
                                          child: IconButton(
                                            onPressed: () {
                                              deleteProductFromCart(obj);
                                            },
                                            icon: Icon(Icons.delete),
                                            iconSize: 26,
                                            color: Colors.grey[700],
                                          ),
                                        )
                                      : Container(
                                          child: IconButton(
                                            onPressed: () {
                                              deleteProductFromCart(obj);
                                            },
                                            icon: Icon(Icons.delete),
                                            iconSize: 26,
                                            color: Colors.grey[700],
                                          ),
                                        )
                                ])),
                          ])
                    ],
                  ))));
    }).toList();
  }

  reset() {
    searchFieldController.clear();
    searchFieldKey.currentState?.reset();
  }

  getSearchedData() {
    if (searchFieldController.text.trim() != '') {
      productSearchData['productSearchData'] =
          searchFieldController.text.trim();
      List filterProductsData = [];
      filterProducts.forEach((val) {
        if (val['isSelected']) {
          Map obj = {'productCategoryId': val['productCategoryId']};
          filterProductsData.add(obj);
        }
      });
      if (filterProductsData.length > 0) {
        productSearchData['productCategoryInfo'] = filterProductsData;
      }
      reset();
      setState(() {
        showOrHideSearchAndFilter = false;
      });
      Navigator.of(context).pushNamed('/search');
    }
  }

  getTotalAmount(List priceOfProducts) {
    // double totalAmount = 0;
    priceOfProducts.forEach((res) {
      double priceOfCurrentProduct = 0.0;
      if (res['taxpercent'] != null) {
        final double taxValue = res['value'] *
            int.parse(res['taxpercent'].toString().replaceAll('%', '')) /
            100;
        setState(() {
          priceOfCurrentProduct = res['value'] + taxValue;
        });
        // print(priceOfCurrentProduct);
      } else {
        setState(() {
          priceOfCurrentProduct = res['value'];
        });
      }

      if (res['minimumQuantity'] != null && res['discountPrice'] != null) {
        if (res['quantity'] >= res['minimumQuantity']) {
          // priceOfCurrentProduct = priceOfCurrentProduct -
          //     (priceOfCurrentProduct) *
          //         int.parse(
          //             res['productDiscount'].toString().replaceAll('%', '')) /
          //         100;
          priceOfCurrentProduct = res['discountPrice'];
        }
      } else if (res['discountPrice'] != null) {
        priceOfCurrentProduct = res['discountPrice'];
      }
      setState(() {
        priceOfTotalProducts =
            priceOfTotalProducts + (priceOfCurrentProduct * res['quantity']);
      });
    });
  }

  manageBackButtonFunctionality() {
    setState(() {
      isBackButtonPressed = false;
    });
    if (isNavigatedFromSignInPage) {
      previousRouteNameFromCart = '';
      isNavigatedFromSignInPage = false;
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    } else if (previousRouteNameFromCart != '' &&
        previousRouteNameFromCart == "/home") {
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    } else if (previousRouteNameFromCart != '' &&
        previousRouteNameFromCart == "/orderconfirmation") {
      Navigator.pushNamedAndRemoveUntil(context, '/orderconfirmation',
          ModalRoute.withName('/orderconfirmation'));
    } else if (previousRouteNameFromCart != '') {
      Navigator.popAndPushNamed(context, previousRouteNameFromCart);
      previousRouteNameFromCart = '';
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          bool isQuantityFocused = false;
          orderIdFromDeepLink = '';
          listOfCartDetails.forEach((val) {
            if (val['focusNode'] != null && val['focusNode'].hasFocus) {
              setState(() {
                isQuantityFocused = true;
              });
              val['focusNode'].unfocus();
            }
          });
          showOrHideSearchAndFilter = false;
          // displayLoadingIcon(context);
          if (!isQuantityFocused) {
            manageBackButtonFunctionality();
          } else {
            setState(() {
              isBackButtonPressed = true;
            });
          }
          return Future.value(false);
        },
        child: Scaffold(
          key: scaffoldkey,
          appBar: appBarWidgetWithIconsAnSearchboxAndFilterIcon(
              context,
              true,
              this.setState,
              true,
              '/cart',
              searchFieldKey,
              searchFieldController,
              searchFocusNode,
              scaffoldkey),
          endDrawer: showOrHideSearchAndFilter
              ? filterDrawer(this.setState, context, scaffoldkey, false,
                  searchFieldController)
              : null,
          body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // showOrHideSearchAndFilter
                    //     ? Container(
                    //         margin: EdgeInsets.only(top: 2, left: 10),
                    //         height: 40,
                    //         child: Row(children: [
                    //           Expanded(
                    //               flex: 8,
                    //               child: TextFormField(
                    //                   cursorColor: mainAppColor,
                    //                   controller: searchFieldController,
                    //                   onFieldSubmitted: (val) {
                    //                     getSearchedData();
                    //                   },
                    //                   key: searchFieldKey,
                    //                   focusNode: searchFocusNode,
                    //                   decoration: InputDecoration(
                    //                       counterText: "",
                    //                       // alignLabelWithHint: true,
                    //                       hintText: "Search",
                    //                       border: AppStyles().searchBarBorder,
                    //                       // prefix: Text("+91 "),
                    //                       contentPadding:
                    //                           EdgeInsets.fromLTRB(14, 0, 0, 0),
                    //                       focusedBorder:
                    //                           AppStyles().focusedSearchBorder,
                    //                       suffixIcon: IconButton(
                    //                         padding: EdgeInsets.all(0),
                    //                         icon: Icon(Icons.search),
                    //                         onPressed: () {
                    //                           getSearchedData();
                    //                         },
                    //                         color: mainAppColor,
                    //                         tooltip: 'Search',
                    //                         // iconSize: 24,
                    //                       )))),
                    //           Expanded(
                    //               child: IconButton(
                    //             padding: EdgeInsets.all(0),
                    //             icon: Icon(Icons.filter_list),
                    //             onPressed: () {
                    //               scaffoldkey.currentState.openEndDrawer();
                    //             },
                    //             color: mainAppColor,

                    //             tooltip: 'Filter',
                    //             // iconSize: 14,
                    //           )),
                    //           // child: FlatButton.icon(
                    //           //   icon: Icon(Icons.filter_list),
                    //           //   onPressed: () {},
                    //           //   label: Text("Filter"),
                    //           // ),
                    //           // )
                    //         ]))
                    //     : Container(),
                    noOfProductsAddedInCart != 0 && listOfCartDetails.length > 0
                        ? Container(
                            margin: EdgeInsets.only(
                                top: 5, left: 10, right: 10, bottom: 5),
                            child: Text(
                              "Your Cart Details",
                              style: appFonts
                                  .getTextStyle('cart_screen_heading_style'),
                            ),
                          )
                        : Container(),
                    Expanded(
                        child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(children: [
                              noOfProductsAddedInCart != 0
                                  ? listOfCartDetails.length > 0
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                              ListView(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                children:
                                                    getCartProductDetails(),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5),
                                              ),
                                              Divider(
                                                thickness: 1,
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    orderIdFromDeepLink = '';
                                                    Navigator
                                                        .pushNamedAndRemoveUntil(
                                                            context,
                                                            "/home",
                                                            ModalRoute.withName(
                                                                "/home"));
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 2,
                                                        child: Text(
                                                          "Browse For More Products",
                                                          style: appFonts
                                                              .getTextStyle(
                                                                  'browse_for_products_link_style'),
                                                        ),
                                                      ),
                                                      Flexible(
                                                          child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 5),
                                                        child: Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          color: Colors.blue,
                                                          size: 25,
                                                        ),
                                                      ))
                                                    ],
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 70),
                                              ),
                                            ])
                                      : Center(
                                          heightFactor: 13,
                                          child:
                                              customizedCircularLoadingIcon(50))
                                  : Center(
                                      heightFactor: 3,
                                      child: Column(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.center,
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
                                            style: appFonts.getTextStyle(
                                                'cart_empty_styles'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 3),
                                          ),
                                          Text(
                                              "Looks like you have no items in your cart"),
                                          Padding(
                                            padding: EdgeInsets.only(top: 70),
                                          ),
                                          InkWell(
                                              onTap: () {
                                                orderIdFromDeepLink = '';
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        "/home",
                                                        ModalRoute.withName(
                                                            "/home"));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                    padding:
                                                        EdgeInsets.only(top: 5),
                                                    child: Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color: Colors.blue,
                                                      size: 25,
                                                    ),
                                                  ))
                                                ],
                                              ))
                                        ],
                                      )),
                            ]))),
                  ]))),

          bottomNavigationBar: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              height: 70,
              width: MediaQuery.of(context).size.width,
              child: noOfProductsAddedInCart != null &&
                      priceOfProducts.length > 0 &&
                      noOfProductsAddedInCart != null &&
                      noOfProductsAddedInCart > 0
                  ? Card(
                      elevation: 5,
                      margin: EdgeInsets.only(right: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              width: MediaQuery.of(context).size.width / 2 - 30,
                              alignment: Alignment.centerRight,
                              // margin: EdgeInsets.only(left: 50),

                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "₹" +
                                            currencyFormatter
                                                .format(priceOfTotalProducts),
                                        style: appFonts.getTextStyle(
                                            'cart_screen_total_amount_style')),
                                    Container(
                                        margin: EdgeInsets.only(top: 2),
                                        child: Text(noOfProductsAddedInCart > 1
                                            ? "(" +
                                                '$noOfProductsAddedInCart' +
                                                " " +
                                                "items)"
                                            : "(" +
                                                '$noOfProductsAddedInCart' +
                                                " " +
                                                "item)"))
                                  ])),
                          Container(
                              width: MediaQuery.of(context).size.width / 2 - 30,
                              margin: EdgeInsets.only(left: 10),
                              alignment: Alignment.centerRight,
                              child: RaisedButton(
                                onPressed: () {
                                  bool isProductDetailsValid = true;
                                  Map errorObj = {};
                                  // listOfCartDetails.forEach((val) {
                                  //   val['key']
                                  // });
                                  listOfCartDetails.forEach((val) {
                                    if (val['focusNode'].hasFocus) {
                                      isEditFieldFocused = true;
                                      setState(() {});
                                      val['focusNode'].unfocus();
                                    }
                                  });
                                  if (!isEditFieldFocused) {
                                    listOfCartDetails.forEach((val) {
                                      // print(val);
                                      val['key'].currentState?.validate();
                                      if (val['key'].currentState != null &&
                                          !val['key'].currentState.validate()) {
                                        isProductDetailsValid = false;
                                        errorObj = val;
                                      }
                                    });
                                    if (isProductDetailsValid) {
                                      if (signInDetails['access_token'] !=
                                          null) {
                                        setState(() {
                                          showOrHideSearchAndFilter = false;
                                          isDeliveryAddress = false;
                                        });

                                        Navigator.popAndPushNamed(
                                            context, '/deliveryaddress');
                                      } else {
                                        setState(() {
                                          showOrHideSearchAndFilter = false;
                                          isDeliveryAddress = false;
                                        });
                                        isNavigatedFromCartPage = true;
                                        previousRouteName = '';
                                        Navigator.pushNamed(context, '/login');
                                      }
                                    } else {
                                      // closeNotifications();
                                      clearErrorMessages(scaffoldkey);
                                      showErrorNotifications(
                                          errorObj['key']
                                              .currentState
                                              .errorText,
                                          context,
                                          scaffoldkey);
                                    }
                                  }
                                },
                                padding: EdgeInsets.only(
                                    top: 16, bottom: 16, left: 24, right: 24),
                                child: Text(
                                  "Proceed To Buy",
                                  style: appFonts.getTextStyle(
                                      'cart_screen_button_text_styles'),
                                ),
                                elevation: 5,
                                color: mainYellowColor,
                              )),
                        ],
                      ),
                    )
                  : Container()),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        ));
  }
}
