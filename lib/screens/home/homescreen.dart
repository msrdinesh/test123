import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as p;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as g;
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cornext_mobile/services/connectivityservice/connectivityservice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/services/offerDetailService/offerDetailsService.dart';
import 'package:uni_links/uni_links.dart';
import 'package:cornext_mobile/services/ordersummaryservice/ordersummaryservice.dart';
import 'package:cornext_mobile/services/ordertrackingservices/ordertrackingservice.dart';
import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';

import 'dart:async';
import 'package:cornext_mobile/constants/appfonts.dart';
import 'package:cornext_mobile/services/deviceinfoservice/deviceinfoservice.dart';
import 'package:cornext_mobile/constants/appconstants.dart';

class HomePage extends StatefulWidget {
  @override
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends State<HomePage> {
  bool isChecked = false;
  bool isLoading = false;
  bool BOOL = false;
  String pincode = "";
  String place = "";
  String textInLocation = "Deliver to ";
  final passwordController = TextEditingController();
  final passwordFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<ScaffoldState> scafFoldKey = GlobalKey<ScaffoldState>();
  int totalNumberOfAddresses = 0;
  final ApiErros apiErros = ApiErros();
  int selectedRadio;
  var changeSubscriptionAddress = {};
  final AddressServices addressServices = AddressServices();
  bool isAddressLoading = false;
  List addressList = [];
  List productDetails = [];
  final Connectivity _connectivity = Connectivity();
  List productShowMoreOrLess = [];
  List carouselDetails = [];
  bool productDetailsLoading = false;
  bool bannerScreenLoading = false;
  bool isBannerImageLoading = false;
  Map bannerInfo = {};
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  final scafflodkey = GlobalKey<ScaffoldState>();
  final HomeScreenServices homeScreenServices = HomeScreenServices();
  final ConnectivityService connectivityService = ConnectivityService();
  int _currentIndex = 0;
  final ScrollController scrollController = ScrollController();
  final productListKey = GlobalKey();
  // final ScrollController scrollControllerForProducts = ScrollController();
  int limit = 15;
  int pageNo = 1;
  int totalNumberOfProducts = 0;
  bool isMoreProductsLoading = false;
  List categoriesInfo = [];
  final OrderTrackingService orderTrackingService = OrderTrackingService();
  Timer timer;
  dynamic fetchCartDetailsApi;
  final AppFonts appFonts = AppFonts();
  final DeviceInfo deviceInfo = DeviceInfo();
  bool isMoreAddressListLoading = false;
  bool isSubscriptionAddressEditing = false;
  int pressed = 0;

  @override
  void initState() {
    super.initState();
    // getUniLinksData();
    setState(() {
      filterProducts = [];
      subCategoriesList = [];
      checkAccessTokenAndUpdateUserDetails();
      removeImagesFromCache();
    });
    checkAndDisplayLoginSuccessMessage();
    getAddress(false);
  }

  // @override
  // void dispose() {
  //   if (timer != null) {
  //     timer.cancel();
  //   }
  //   if (fetchCartDetailsApi != null) {
  //     fetchCartDetailsApi?.cancle();
  //   }
  //   super.dispose();
  // }

  checkAndDisplayLoginSuccessMessage() {
    timer = Timer(Duration(microseconds: 200), () {
      if (displayRegistrationSuccessMessage) {
        showSuccessNotifications("Account Created Successfully", context, scafflodkey);
        if (timer != null) {
          timer.cancel();
        }
        setState(() {
          displayRegistrationSuccessMessage = false;
        });
      }
    });
  }

  checkAppUpdates() {
    homeScreenServices.getLatestAppVersion().then((val) {
      final data = json.decode(val.body);
      if (data['appVersion'] <= appVersion) {
        setState(() {
          canDisplayAppUpdatePopup = false;
        });
        fetchBannerDetails();
        fetchCarouselDetails();
        fetchProductListDetails(false);
        fetchCategoriesDetails();
      } else if (data['appVersion'] > appVersion && data['mandatoryUpdate']) {
        setState(() {
          canDisplayAppUpdatePopup = false;
        });
        Navigator.of(context).pushNamedAndRemoveUntil('/appupdate', ModalRoute.withName('appupdate'));
      } else if (data['appVersion'] > appVersion && !data['mandatoryUpdate']) {
        setState(() {
          canDisplayAppUpdatePopup = false;
        });
        displayAppUpdatePopup();
        fetchCarouselDetails();
        fetchProductListDetails(false);
        fetchCategoriesDetails();
      } else if (data['error'] != null) {
        setState(() {
          canDisplayAppUpdatePopup = false;
        });
        ApiErros().apiLoggedErrors(data, context, scafflodkey);
      } else {}
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
    });
  }

  checkInternetConnection() async {
    previousScreenRouteName = '/home';
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (err) {
      print(err);
    }
    if (!connectivityService.getConnectionStatus(result)) {
      Navigator.of(context).pushReplacementNamed('/errorscreen');
    } else {
      if (canDisplayAppUpdatePopup) {
        checkAppUpdates();
      } else {
        fetchBannerDetails();
        fetchCarouselDetails();
        fetchProductListDetails(false);
        fetchCategoriesDetails();
      }
    }
  }

  reset() {
    searchFieldController.clear();
    searchFieldKey.currentState?.reset();
  }

  fetchBannerDetails() {
    setState(() {
      bannerScreenLoading = true;
    });
    homeScreenServices.getBannerDetails().then((res) {
      final data = json.decode(res.body);
      // print(data['imageResourceUrl']);
      setState(() {
        bannerInfo = data;
      });
      if (data['imageResourceUrl'] != null) {
        Future.delayed(Duration(milliseconds: 1), () {
          if (displayBanner) {
            setState(() {
              displayBannerDialog(context, data['imageResourceUrl']);
            });
          }
        });
      }
      setState(() {
        bannerScreenLoading = false;
      });
    }, onError: (err) {
      setState(() {
        bannerScreenLoading = false;
      });
      ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
    });
  }

  fetchCarouselDetails() {
    homeScreenServices.getCarouselDetails().then((val) {
      // print(val.body);
      final data = json.decode(val.body);
      if (data.length > 0) {
        setState(() {
          carouselDetails = data;
          getCarouselData();
        });
      }
    });
  }

  fetchFilterDetails() {
    if (signInDetails['access_token'] == null) {
      homeScreenServices.getFilterListDetails().then((val) {
        final data = json.decode(val.body);
        print(data);
        // setState(() {
        //   filterProducts = setSelectedBooleanInFilter(data);
        // });
      }, onError: (err) {});
    } else {
      homeScreenServices.getFilterListDetailsAfterLogin().then((val) {
        final data = json.decode(val.body);
        if (data.length > 0) {
          // setState(() {
          //   filterProducts = setSelectedBooleanInFilter(data);
          // });
        } else if (data['error'] != null && data['error'] == "invalid_token") {
          RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (RefreshTokenService().getAccessTokenFromData(refreshTokenData, context, setState)) {
              fetchFilterDetails();
            }
          });
        }
      }, onError: (err) {});
    }
  }

  List setSelectedBooleanInFilter(List filterData) {
    List filterList = [];
    if (filterData.length > 0) {
      filterData.forEach((val) {
        if (val['subCategories'] != null) {
          getSubCategories(val['subCategories'], val['categoryName']);
        }
        if (val['isSelected'] == null) {
          Map obj = val;
          obj['isSelected'] = false;
          filterList.add(obj);
        }
      });
    }
    return filterList;
  }

  getSubCategories(List subCategories, String categoryName) {
    subCategories.forEach((val) {
      Map obj = val;
      obj['path'] = categoryName + "|" + val['subCategoryName'];
      obj['isChecked'] = false;
      obj['manualSelection'] = false;
      subCategoriesList.add(obj);
    });
  }

  fetchCartDetails() {
    homeScreenServices.getCartQuantityDetails().then((res) {
      // print(res.body);
      final data = json.decode(res.body);
      if (data != null && data['noOfItemsInCart'] != null) {
        setState(() {
          noOfProductsAddedInCart = int.parse(data['noOfItemsInCart']);
        });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          print(refreshTokenData);
          if (RefreshTokenService().getAccessTokenFromData(refreshTokenData, context, setState)) {
            fetchCartDetails();
          }
        });
      }
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
    });
  }

  checkAccessTokenAndUpdateUserDetails() {
    SharedPreferenceService().checkAccessTokenAndUpdateuserDetails().then((val) {
      if (val.get("access_token") == null) {
        // Navigator.pushNamed(context, "/login");
        // Navigator.pushNamedAndRemoveUntil(
        //     context, '/login', ModalRoute.withName('/login'));
        signInDetails = {
          "userName": "Hello, User",
          "userId": ""
        };
        checkInternetConnection();
      } else {
        setState(() {
          signInDetails['access_token'] = val.get("access_token");
          signInDetails['refresh_token'] = val.get("refresh_token");
          signInDetails['userName'] = val.get('userName');
          signInDetails['userId'] = val.get('userId');
          signInDetails['emailId'] = val.get('emailId');
          signInDetails['mobileNo'] = val.get('mobileNo');
        });
        // getLinksInfo();
        // val.remove('orderDetails' + signInDeatils['userId']);
        makeApiCallsOnFailedOrders(context);
        checkInternetConnection();
        if (canUpdateUserAppInfo) {
          checkUpdateUserAppInfo();
        }
        fetchCartDetails();
      }
    });
  }

  checkUpdateUserAppInfo() {
    deviceInfo.getDeviceInfo().then((info) {
      if (info['manufacturer'] != null && info['model'] != null && info['versionSdkInt'] != null) {
        final Map requestObj = {
          'userMobileCompany': info['manufacturer'],
          'userMobileModel': info['model'],
          'osVersion': 'andriod-sdk-' + info['versionSdkInt'].toString(),
          'appVersion': appVersion
        };
        homeScreenServices.updateUserAppInfo(requestObj).then((val) {
          final data = json.decode(val.body);
          if (data['status'] != null && data['status'] == "SUCCESS") {
            setState(() {
              canUpdateUserAppInfo = false;
            });
          } else if (data['error'] != null && data['error'] == "invalid_token") {
            RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
              final refreshTokenData = json.decode(res.body);
              if (RefreshTokenService().getAccessTokenFromData(refreshTokenData, context, setState)) {
                checkUpdateUserAppInfo();
              }
            });
          } else if (data['error'] != null) {
            ApiErros().apiLoggedErrors(data, context, scafflodkey);
          }
        }, onError: (err) {
          ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
        });
      }
    });
  }

  getLinksInfo() async {
    fetchCartDetails();
    final data = await getInitialLink();
    if (data != null) {
      var uri = Uri.parse(data);
      var list = uri.queryParametersAll;
      if (list.keys.length > 0) {
        orderIdFromDeepLink = list.keys.first;
        Navigator.pushNamed(context, '/ordersummary');
      }
    } else {
      checkInternetConnection();
    }
  }

  fetchProductListDetails(bool isMoreData) async {
    if (!isMoreData) {
      setState(() {
        productDetailsLoading = true;
      });
    } else {
      setState(() {
        isMoreProductsLoading = true;
      });
    }
    final requestObj = {
      "productCategoryName": null,
      "productSearchData": null,
      "pageNumber": pageNo,
      "limit": limit,
      "screenName": "HS"
    };
    fetchCartDetailsApi = homeScreenServices.getProductListDetails(requestObj).then((val) {
      print(val.body);
      final data = json.decode(val.body);
      if (data['listOfProducts'] != null) {
        // if(data['listOfProducts'])
        // showProductDetailsInfo();
        setState(() {
          totalNumberOfProducts = data['productCount'];
          if (!isMoreData) {
            productDetails = data['listOfProducts'];
          } else {
            data['listOfProducts'].forEach((val) {
              productDetails.add(val);
            });
          }
          // setState(() {}); //$$$$
          setState(() {
            initializeShowMoreOrLessBooleans();
            showProductDetails(
              productDetails,
              this.setState,
              productShowMoreOrLess,
              NeverScrollableScrollPhysics(),
              true,
              context,
              '/home',
            );
          });
          scrollController.addListener(() {
            if (totalNumberOfProducts > productDetails.length && !isMoreProductsLoading && scrollController.position.pixels == scrollController.position.maxScrollExtent) {
              setState(() {
                pageNo = pageNo + 1;
              });
              fetchProductListDetails(true);
            }
          });
        });
      }
      setState(() {
        productDetailsLoading = false;
        isMoreProductsLoading = false;
      });
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
      setState(() {
        productDetailsLoading = false;
        isMoreProductsLoading = false;
      });
    });
  }

  initializeShowMoreOrLessBooleans() {
    productDetails.forEach((val) {
      setState(() {
        productShowMoreOrLess.add(false);
      });
    });
  }

  String resValue = '';

  getProductInfo(productInfo) {
    setState(() {
      displayBanner = false;
      Navigator.of(context).pop();
    });
    if (productInfo['productId'] != null) {
      productDetailsObject['productId'] = productInfo['productId'];
    }
    if (productInfo['productTypeId'] != null) {
      productDetailsObject['productTypeId'] = productInfo['productTypeId'];
    }
    if (productInfo['specificationId'] != null) {
      productDetailsObject['specificationId'] = productInfo['specificationId'];
    }
    if (productInfo["priceId"] != null) {
      productDetailsObject['priceId'] = productInfo['priceId'];
    }
    if (signInDetails['access_token'] != null) {
      productDetailsObject['userId'] = signInDetails['userId'];
    } else {
      productDetailsObject['userId'] = null;
    }
    previousRouteName = '/home';
    Navigator.of(context).pushNamed('/productdetails');
  }

  displayBannerDialog(context, url) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 200,
                  child: SingleChildScrollView(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                              // elevation: 50,
                              // contentPadding: EdgeInsets.all(0),
                              // alignment: Alignment.center,
                              // fit: StackFit.loose,
                              mainAxisSize: MainAxisSize.min,
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              // overflow: Overflow.clip,
                              children: [
                                // Container(
                                //   alignment: Alignment(1, 1),
                                //   padding: EdgeInsets.all(10),
                                //   // margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                //   child: IconButton(
                                //     icon: Icon(Icons.close),
                                //     onPressed: () {},
                                //   ),
                                // ),
                                !isBannerImageLoading
                                    ? Container(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setState(() {
                                              // displayBannerMap['displayBanner'] = 'close';
                                              displayBanner = false;
                                              // });
                                              // homeScreenServices
                                              //     .displayBannerMap['displayBanner'] = 'close';
                                              Navigator.pop(context);
                                            },
                                            child: Align(
                                              alignment: Alignment(1, 1),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            )),
                                      )
                                    : Container(),
                                GestureDetector(
                                    onTap: () {
                                      // getProductInfo(bannerInfo);\
                                      setState(() {
                                        displayBanner = false;
                                        Navigator.of(context).pop();
                                      });
                                      offerId = 0;
                                      offerId = bannerInfo['offerId'];
                                      Navigator.pushNamed(context, '/OfferDetails');
                                    },
                                    // child: Image(
                                    //   loadingBuilder: (BuildContext context, Widget child,
                                    //       ImageChunkEvent event) {
                                    //     // return circularLoadingIcon();
                                    //     if (event == null) {
                                    //       return child;
                                    //     }
                                    //     return circularLoadingIconWithColor(Colors.white);
                                    //   },
                                    //   image: NetworkImage(url),
                                    // )
                                    child: Container(
                                      height: MediaQuery.of(context).size.width,
                                      width: MediaQuery.of(context).size.width,
                                      child: CachedNetworkImage(
                                        imageUrl: url,
                                        // height: 300,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) => circularLoadingIconWithColor(Colors.white),
                                      ),
                                    )),
                                // Positioned(
                                //   right: 0.0,
                                //   top: 0.0,
                                //   child: GestureDetector(
                                //       onTap: () {
                                //         // setState(() {
                                //         // displayBannerMap['displayBanner'] = 'close';
                                //         displayBanner = false;
                                //         // });
                                //         // homeScreenServices
                                //         //     .displayBannerMap['displayBanner'] = 'close';
                                //         Navigator.pop(context);
                                //       },
                                //       child: Align(
                                //         alignment: Alignment.topRight,
                                //         child: CircleAvatar(
                                //           child: Icon(
                                //             Icons.close,
                                //             // color: Colors.white,
                                //           ),
                                //           backgroundColor: Colors.transparent,
                                //           maxRadius: 5.0,
                                //         ),
                                //       )),
                                // ),
                              ])))));
        });
  }

  Widget getCarouselData() {
    return Stack(children: [
      new CarouselSlider(
        // realPage: 100,
        viewportFraction: 1.0,

        items: carouselDetails.map((imageInfo) {
          // return Image(
          //   fit: BoxFit.fill,
          //   loadingBuilder:
          //       (BuildContext context, Widget child, ImageChunkEvent event) {
          //     // return circularLoadingIcon();
          //     if (event == null) {
          //       return child;
          //     }
          //     return customizedCircularLoadingIcon(25);
          //   },
          //   image: NetworkImage(imageInfo['imageResourceUrl']),
          //   width: MediaQuery.of(context).size.width,
          // );
          final String url = imageInfo['imageResourceUrl'];
          // print(imageInfo);
          return GestureDetector(
              onTap: () {
                if (imageInfo['offerId'] != null && imageInfo['offerImage']) {
                  offerId = 0;
                  offerId = imageInfo['offerId'];
                  Navigator.pushNamed(context, '/OfferDetails');
                } else {
                  productDetailsObject['productId'] = imageInfo['productId'];
                  productDetailsObject['productTypeId'] = imageInfo['productTypeId'] != null ? imageInfo['productTypeId'] : null;
                  productDetailsObject['specificationId'] = imageInfo['specificationId'] != null ? imageInfo['specificationId'] : null;
                  productDetailsObject['priceId'] = imageInfo['priceId'] != null ? imageInfo['priceId'] : null;
                  productDetailsObject['userId'] = signInDetails['access_token'] != null ? signInDetails['userId'] : null;
                  productDetailsObject['screenName'] = 'PRD';
                  Navigator.of(context).pushNamed('/productdetails');
                }
              },
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.fill,
                // imageBuilder: ,
                placeholder: (context, url) => customizedCircularLoadingIcon(25),
                width: MediaQuery.of(context).size.width,
              ));
        }).toList(),
        aspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width / 2.08) : 9.0,

        autoPlay: true,

        // dotSpacing: 2,
        // animationCurve: Curves.fastOutSlowIn,
        // animationDuration: Duration(seconds: 1),
      ),
      Positioned(
          // top: 10,

          bottom: -0.0,
          right: 0.0,
          left: 0.0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: carouselDetails.map((val) {
                return Container(
                    width: 8.0,
                    height: 8.0,
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: carouselDetails.indexOf(val) == _currentIndex
                          ? Colors.white
                          // fromRGBO(0, 0, 0, 0.9)
                          : Colors.white60,
                      // fromRGBO(0, 0, 0, 0.4)),
                    ));
              }).toList()))
    ]);
  }

  getSearchedData(int categoryId) {
    // if (searchFieldController.text.trim() != '') {
    productSearchData['productSearchData'] = searchFieldController.text.trim();
    List filterProductsData = [];
    // filterProducts.forEach((val) {
    //   if (val['isSelected']) {
    //     if (val['productCategoryId'] != null) {
    //       Map obj = {'productCategoryId': val['productCategoryId']};
    //       filterProductsData.add(obj);
    //     }
    //   }
    // });
    // getSelectedCategoriesInfo();
    if (categoryId != null) {
      Map obj = {
        'categoryId': categoryId
      };
      // Uncomment this for default highlightion of subcategoris
      // final categoryName = filterProducts[filterProducts.indexWhere(
      //     (val) => val['categoryId'] == categoryId)]['categoryName'];
      // subCategoriesList.forEach((val) {
      //   if (val['path'].toString().startsWith(categoryName)) {
      //     val['isChecked'] = true;
      //   }
      //   val['manualSelection'] = false;
      // });
      // upto here
      filterProductsData.add(obj);
      productSearchData['productCategory'] = filterProductsData;
    }
    if (productSearchData['productSearchData'] != "" || productSearchData['productCategory'].length > 0) {
      reset();
      Navigator.of(context).pushNamed('/search');
    }
    // }
  }

  getSelectedCategoriesInfo() {}

  fetchCategoriesDetails() {
    final Map requestObj = {
      'userId': signInDetails['access_token'] != null ? signInDetails['userId'] : null,
    };
    homeScreenServices.getCategoriesAndSubCategoriesInfo(requestObj).then((val) {
      print(val.body);
      final data = json.decode(val.body);
      if (data['categories'] != null) {
        categoriesInfo = data['categories'];
        filterProducts = setSelectedBooleanInFilter(data['categories']);
        setState(() {});
      } else if (data['error'] != null) {
        ApiErros().apiLoggedErrors(data, context, scafflodkey);
      }
    }, onError: (err) {
      ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
    });
  }

  getProductResultsUsingCategory(String categoryName) {
    filterProducts.forEach((val) {
      if (val['categoryName'] == categoryName) {
        setState(() {
          val['isSelected'] = true;
          // if (val['subCategories'] != null) {
          //   setSubcategoriesChecked(categoryName);
          // }
        });
      }
    });
  }

  setSubcategoriesChecked(String categoryName) {
    subCategoriesList.forEach((val) {
      if (val['path'].toString().startsWith(categoryName)) {
        val['isChecked'] = true;
      }
    });
  }

  clearSearchField() {
    searchFieldController.clear();
    setState(() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
  }

  List<Widget> getCategoriesInfo() {
    return filterProducts.map((res) {
      // print(res);
      return GestureDetector(
          onTap: () {
            clearSearchField();
            getProductResultsUsingCategory(res['categoryName']);
            getSearchedData(res['categoryId']);
          },
          child: Container(
              width: MediaQuery.of(context).size.width / 4.0,
              // margin: EdgeInsets.only(left: 1, right: 1),
              child: Column(
                children: <Widget>[
                  Container(
                      child: res['categoryName'] != "Favorites"
                          ? Container(
                              decoration: new BoxDecoration(borderRadius: new BorderRadius.all(Radius.circular(50.0)), boxShadow: [
                                new BoxShadow(
                                  color: Colors.grey.shade400,
                                  offset: Offset(1, 2),
                                  blurRadius: 2,
                                )
                              ]),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: CachedNetworkImage(
                                    imageUrl: res['resourceUrl'],
                                    fit: BoxFit.fill,
                                    height: 50,
                                    width: 50,
                                  )),
                            )
                          : Container(
                              decoration: new BoxDecoration(color: Colors.white, borderRadius: new BorderRadius.all(Radius.circular(50.0)), boxShadow: [
                                new BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: Offset(1, 2),
                                  blurRadius: 2,
                                )
                              ]),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Icon(
                                    Icons.star_border,
                                    size: 50,
                                  )),
                            )),
                  AppStyles().customPadding(1),
                  Container(
                    child: splitAndDisplay(res["categoryName"]),
                    // child: splitAndDisplay('Corn Bales'),
                  )
                ],
              )));
    }).toList();
  }

  Widget splitAndDisplay(String categoryName) {
    if (categoryName.contains(" ")) {
      //Assuming Category Name will be only 2 words
      List<String> _splitNames = categoryName.split(" ");
      List<Widget> _widgets = [];
      _splitNames.forEach((res) {
        _widgets.add(Text(res, textAlign: TextAlign.center, style: appFonts.getTextStyle('homescreen_categories_name_style')));
      });
      return Column(
        children: _widgets,
      );
    } else {
      return Text(categoryName, textAlign: TextAlign.center, style: appFonts.getTextStyle('homescreen_categories_name_style'));
    }
  }

  // displaying Categories on top
  Widget showCategories() {
    return Container(
        // width: 80,
        width: MediaQuery.of(context).size.width - 10,
        height: 82,
        margin: EdgeInsets.only(left: 0, right: 0, top: 18),
        // alignment: Alignment.,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            Container(
                child: Row(
              children: <Widget>[
                Container(
                    height: 82,
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: getCategoriesInfo().length,
                      separatorBuilder: (BuildContext context, int index) => SizedBox(width: 15),
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(width: 50, child: getCategoriesInfo()[index]);
                      },
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                    )),
                Container(
                  width: MediaQuery.of(context).size.width / 4.0,
                  // margin: EdgeInsets.only(left: 1, right: 1),
                  child: GestureDetector(
                    onTap: () {
                      RenderBox box = productListKey.currentContext.findRenderObject();
                      Offset position = box.localToGlobal(Offset.zero);
                      scrollController.jumpTo(position.direction + 300);
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                            // height: 50,
                            // width: 50,
                            decoration: BoxDecoration(borderRadius: new BorderRadius.all(Radius.circular(50.0)), boxShadow: [
                              new BoxShadow(
                                color: Colors.grey.shade400,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              )
                            ]),

                            // child: Center(
                            //     child: Text(
                            //   "A",
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.w700,
                            //       color: Colors.white,
                            //       fontSize: 45),
                            // )),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: CachedNetworkImage(
                                  imageUrl: 'https://feednextmedia.s3.ap-south-1.amazonaws.com/CAT-Icon-All-01.jpg',
                                  fit: BoxFit.fill,
                                  height: 5,
                                  width: 5,
                                ))),
                        AppStyles().customPadding(1),
                        Container(
                          // padding: EdgeInsets.only(top: 1),
                          child: Text(
                            'All',
                            textAlign: TextAlign.center,
                            style: AppFonts().getTextStyle('homescreen_categories_name_style'),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ))
          ],
        ));
  }

  // Repeat previous order
  repeatPreviousOrder(int orderId, bool isCartDelete) {
    final Map requestObj = {
      'cartDelete': isCartDelete,
      'orderId': orderId
    };
    // Navigator.pop(context);
    displayLoadingIcon(context);
    print(requestObj);
    orderTrackingService.repeatOrderDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      print('ghj');
      print(data);
      Navigator.pop(context);
      if (data['addressId'] != null) {
        // selectedDeliveryAddress = {};
        // selectedDeliveryAddress = data['addressDeatils'];
        isRepeatPreviousOrder = true;
        repeatPreviousOrderAddressId = data['addressId'];
        setState(() {
          noOfProductsAddedInCart = int.parse(data['noOfItemsInCart']);
        });
        Navigator.popAndPushNamed(context, '/deliveryaddress');
        // if (data['isSubscribedOrder'] != null && data['isSubscribedOrder']) {
        //   displaySubscriptionPopup(context,
        //       "You have subscribed this order. Do you want repeat this order?");
        // } else {

        // }
        // fetchCartDetails();
      } else if (data['addressId'] == null && data['noOfItemsInCart'] != null) {
        isRepeatPreviousOrder = true;
        setState(() {
          noOfProductsAddedInCart = int.parse(data['noOfItemsInCart']);
        });
        // if (data['isSubscribedOrder'] != null && data['isSubscribedOrder']) {
        //   displaySubscriptionPopup(context,
        //       "You have subscribed this order. Do you want repeat this order?");
        // } else {
        Navigator.popAndPushNamed(context, '/deliveryaddress');
        // }
        // Navigator.popAndPushNamed(context, '/deliveryaddress');
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          Navigator.pop(context);
          if (RefreshTokenService().getAccessTokenFromData(refreshTokenData, context, setState)) {
            repeatPreviousOrder(orderId, isCartDelete);
          }
        });
      } else if (data['error'] != null) {
        // Navigator.pop(context);
        ApiErros().apiLoggedErrors(data, context, scafflodkey);
      }
    }, onError: (err) {
      Navigator.pop(context);
      // setState(() {
      //   isLoading = false;
      // });
      ApiErros().apiErrorNotifications(err, context, '/yourorders', scafflodkey);
    });
  }

  displayLoadingIcon(context) {
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
                child: customizedCircularLoadingIconWithColorAndSize(50, Colors.white),
              ));
        });
  }

  displaySubscriptionPopup(context, String message, int orderId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: AlertDialog(
                // backgroundColor: Colors.transparent,
                // elevation: 100,
                // contentPadding: EdgeInsets.only(bottom: 5),

                // content: ,
                title:
                    //  Container(
                    //     // height: 40,
                    //     margin: EdgeInsets.only(left: 10),
                    // color: Colors.red[800],
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   // crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: <Widget>[
                    //     // Pad ding(padding: EdgeInsets.only(top: 5)),
                    Text(
                  "Subscription Information",
                  style: appFonts.getTextStyle('home_screen_repeat_previous_order_popup_heading_style'),
                ),
                // ],

                content: Container(
                    color: Colors.white,
                    child: Row(children: [
                      Container(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: Icon(Icons.info, size: 30),
                      ),
                      Flexible(
                        // margin: EdgeInsets.only(
                        //     bottom: 5, right: 10, left: 10, top: 5),
                        child: Text(
                          message,
                          style: appFonts.getTextStyle('home_screen_repeat_previous_order_popup_content_style'),
                          softWrap: true,
                        ),
                      ),
                    ])),

                // Container(
                //   margin: EdgeInsets.only(top: 20),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: <Widget>[

                //     ],
                //   ),
                // )

                actions: <Widget>[
                  // RaisedButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: Text("Cancel"),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.only(right: 7),
                  // ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // repeatPreviousOrder(null, false);
                    },
                    child: Text("No"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 7),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (noOfProductsAddedInCart > 0) {
                        displayRepeatOrderPopup(context, "You have some products in the cart. Do you want clear the cart to repeat this order?", orderId);
                      } else {
                        repeatPreviousOrder(orderId, true);
                      }
                      // repeatPreviousOrder(null, true);
                    },
                    child: Text("Yes"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                  ),
                ],
              ));
        });
  }

  displayAppUpdatePopup() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {
                fetchBannerDetails();
                return Future.value(true);
              },
              child: AlertDialog(
                title: Text(
                  "FeedNext Update",
                  style: appFonts.getTextStyle('home_screen_repeat_previous_order_popup_heading_style'),
                ),
                content: Container(
                    color: Colors.white,
                    child: Row(children: [
                      Flexible(
                        child: Text(
                          appUpdateMessage,
                          style: appFonts.getTextStyle('home_screen_repeat_previous_order_popup_content_style'),
                          softWrap: true,
                        ),
                      ),
                    ])),
                actions: <Widget>[
                  Container(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        fetchBannerDetails();
                      },
                      child: Text(
                        'Ok',
                        style: appFonts.getTextStyle('button_text_color_white'),
                      ),
                    ),
                  )
                ],
              ));
        });
  }

  getAddress(bool isMoreDataLoading) {
    print("into get address function");
    Map obj = {
      "limit": limit,
      "pageNumber": pageNo
    };
    if (!isMoreDataLoading) {
      setState(() {
        isAddressLoading = true;
      });
    } else {
      setState(() {
        isMoreAddressListLoading = true;
      });
    }
    AddressServices().getAddressDetails(obj).then((res) {
      final addressData = json.decode(res.body);

      print('address');
      print("i am here");
      print(addressData);

      if (addressData['addressList'] != null && addressData['addressList'].length > 0) {
        setState(() {
          if (!isMoreDataLoading) {
            addressList = addressData['addressList'];
          } else {
            addressData['addressList'].forEach((val) {
              addressList.add(val);
            });
          }
          setState(() {});
          // print(changeSubscriptionAddress['addressId']);
          // print(selectedDeliveryAddress["addressId"]);
          if (isAddressEditing || isSubscriptionAddressEditing || isRepeatOrder || isRepeatPreviousOrder || selectedDeliveryAddress["addressId"] != null) {
            if (isAddressEditing) {
              selectedRadio = addressList.indexWhere((val) => val['addressId'] == editAddressDetails['addressId']);
            } else if (isRepeatOrder && repeatOrderAddressId > 0) {
              selectedRadio = addressList.indexWhere((val) => val['addressId'] == repeatOrderAddressId);
            } else if (selectedDeliveryAddress["addressId"] != null) {
              selectedRadio = addressList.indexWhere((val) => val['addressId'] == selectedDeliveryAddress["addressId"]);
            } else if (isRepeatPreviousOrder && repeatPreviousOrderAddressId > 0) {
              selectedRadio = addressList.indexWhere((val) => val['addressId'] == repeatPreviousOrderAddressId);
            } else {
              print(addressList.indexWhere((val) => val['addressId'] == changeSubscriptionAddress['addressId']));
              selectedRadio = addressList.indexWhere((val) => val['addressId'] == changeSubscriptionAddress['addressId']);
            }
          }
          totalNumberOfAddresses = addressData['count'];
          print(addressData['count']);
          print(addressList.length);
          scrollController
            ..addListener(() {
              if (totalNumberOfAddresses > addressList.length && !isMoreAddressListLoading && scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                // print('data');
                pageNo = pageNo + 1;
                getAddress(true);
              }
            });
          // print(addressList[0]['communicationAddress']);
        });
      } else if (addressData['error'] != null && addressData['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final data = json.decode(res.body);
          // print(data);
          if (RefreshTokenService().getAccessTokenFromData(data, context, setState)) {
            getAddress(false);
          }
        });
      } else if (addressData['error'] != null) {
        apiErros.apiLoggedErrors(addressData, context, scafFoldKey);
      }
      setState(() {
        isAddressLoading = false;
        isMoreAddressListLoading = false;
      });
      // print(addressList);
      // print(addressList[0]['city']);
      // print(addressList.length);
    }, onError: (err) {
      setState(() {
        isAddressLoading = false;
      });
      Navigator.pop(context);
      apiErros.apiErrorNotifications(err, context, '/deliveryaddress', scafFoldKey);
    });
  }

  displayRepeatOrderPopup(context, String message, int orderId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: AlertDialog(
                // backgroundColor: Colors.transparent,
                // elevation: 100,
                // contentPadding: EdgeInsets.only(bottom: 5),

                // content: ,
                title:
                    //  Container(
                    //     // height: 40,
                    //     margin: EdgeInsets.only(left: 10),
                    // color: Colors.red[800],
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   // crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: <Widget>[
                    //     // Pad ding(padding: EdgeInsets.only(top: 5)),
                    Text(
                  "Repeat Previous Order",
                  style: appFonts.getTextStyle('home_screen_repeat_previous_order_popup_heading_style'),
                ),
                // ],

                content: Container(
                    color: Colors.white,
                    child: Row(children: [
                      Container(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: Icon(
                          Icons.info,
                          size: 30,
                        ),
                      ),
                      Flexible(
                        // margin: EdgeInsets.only(
                        //     bottom: 5, right: 10, left: 10, top: 5),
                        child: Text(
                          message,
                          style: appFonts.getTextStyle('home_screen_repeat_previous_order_popup_content_style'),
                          softWrap: true,
                        ),
                      ),
                    ])),

                // Container(
                //   margin: EdgeInsets.only(top: 20),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: <Widget>[

                //     ],
                //   ),
                // )

                actions: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 7),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      repeatPreviousOrder(orderId, false);
                    },
                    child: Text("No"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 7),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      repeatPreviousOrder(orderId, true);
                    },
                    child: Text("Yes"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                  ),
                ],
              ));
        });
  }

  List<Widget> makeAddressCards(List addressList) {
    List<Widget> ans = [];
    for (int i = 0; i < addressList.length; i++) {
      print(pressed);
      ans.add(DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: pressed == i ? Colors.yellow : Colors.black,
              width: 1,
            ),
          ),
          child: GestureDetector(
              onTap: () {
                print("dinesh");
                print("pressed" + i.toString());
                setState(() {
                  pressed = i;
                });
              },
              child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(children: [
                        Align(alignment: Alignment.centerLeft, child: Text(addressList[i]['doorNumber'])),
                        Align(alignment: Alignment.centerLeft, child: Text(addressList[i]['street'])),
                        Align(alignment: Alignment.centerLeft, child: Text(addressList[i]['city'])),
                        Align(alignment: Alignment.centerLeft, child: Text(addressList[i]['state'])),
                        Align(alignment: Alignment.centerLeft, child: Text(addressList[i]['pincode'])),
                        Align(alignment: Alignment.centerLeft, child: Text(addressList[i]['mobileNo']))
                      ]))))));
      ans.add(SizedBox(width: 50));
    }
    return ans;
  }

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          print("number of addresses");
          print(addressList.length);
          print(makeAddressCards(addressList));
          return FractionallySizedBox(
              heightFactor: 1,
              child: Column(children: [
                Padding(padding: EdgeInsets.all(15), child: Align(alignment: Alignment.centerLeft, child: Text("Choose your location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))),
                Padding(padding: EdgeInsets.only(left: 15), child: Align(alignment: Alignment.centerLeft, child: Text("Select a delivery location to see product availability and delivery options", style: TextStyle(fontSize: 15)))),
                Padding(padding: EdgeInsets.all(15), child: Align(alignment: Alignment.centerLeft, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Align(alignment: Alignment.centerLeft, child: Row(children: makeAddressCards(addressList)))))),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showPincode(fun);
                        },
                        child: Row(children: [
                          Icon(Icons.location_on_rounded, color: Colors.blue),
                          SizedBox(width: 5),
                          Text("Enter an Indian pincode", style: TextStyle(color: Colors.blue))
                        ]))),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showCurrentLocation(fun);
                        },
                        child: Row(children: [
                          Icon(Icons.location_searching_sharp, color: Colors.blue),
                          SizedBox(width: 5),
                          Text("Use my current location", style: TextStyle(color: Colors.blue))
                        ])))
              ]));
        });
  }

  String textFun(bool BOOL) {
    if (BOOL) return textInLocation + place + " " + pincode;
    return textInLocation;
  }

  showErrorNotifications(message, context, GlobalKey<ScaffoldState> scafFlodKey) {
    final snackBar = SnackBar(
      backgroundColor: Colors.grey[100],
      // shape: ,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      content: Text(message, textAlign: TextAlign.center, style: AppFonts().getTextStyle('error_notifications_text_style')),
      duration: Duration(seconds: 3),
    );

    // Find the Scaffold in the widget tree and use
    // it to show a SnackBar.
    print("dinnu thopu");
    print(scafFlodKey);
    print(scafFlodKey.currentState);
    if (scafFlodKey != null && scafFlodKey.currentState != null) {
      scafFlodKey.currentState.showSnackBar(snackBar);
      Navigator.pop(context);
      pincode = "";
      fun();
    }
  }

  void getPlace(VoidCallback fun, GlobalKey<ScaffoldState> scafflodKey) async {
    isLoading = true;
    fun();
    var response = await http.get(Uri.parse('https://api.worldpostallocations.com/pincode?postalcode=' + pincode + '&countrycode=IN'));
    // var response = await htpp.get(Uri.parse('http://www.postalpincode.in/api/pincode/521001'));
    Map<String, dynamic> respons = jsonDecode(response.body);
    if (respons['result'].length > 0) {
      place = respons['result'][0]['province'];
      print("i am here");
      fun();
      print(place);
      isLoading = false;
      fun();
      Navigator.pop(context);
    } else {
      print("here error notification");
      showErrorNotifications("Pincode doesn't exist", context, scafflodKey);
    }
  }

  void _showPincode(VoidCallback fun) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return FractionallySizedBox(
              heightFactor: 0.6,
              child: Column(children: [
                Padding(padding: EdgeInsets.all(15), child: Align(alignment: Alignment.centerLeft, child: Text("Enter an Indian pincode", style: TextStyle(fontSize: 20)))),
                Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                          ),
                        ),
                        height: 40,
                        width: 330,
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextFormField(
                                  key: passwordFormKey,
                                  style: TextStyle(fontSize: 20),
                                  decoration: new InputDecoration(border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, contentPadding: EdgeInsets.only(left: 5, bottom: 11, top: 11, right: 15)),
                                  onSaved: (String value) {
                                    pincode = value;
                                  },
                                  validator: (value) => GlobalValidations().pincodeValidations(value),
                                ))))),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: ButtonTheme(
                        minWidth: 330.0,
                        height: 40.0,
                        child: isLoading
                            ? CircularProgressIndicator(
                                semanticsLabel: 'Linear progress indicator',
                              )
                            : RaisedButton(
                                child: Text('Apply'),
                                onPressed: () {
                                  final form = passwordFormKey.currentState;
                                  print(form);
                                  if (form.validate()) {
                                    form.save();
                                    getPlace(fun, scafFoldKey);
                                    fun();
                                  } else {}
                                },
                              )))
              ]));
        });
  }

  void getCoordinatesAndPlace() async {
    print("called get coordinates");
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    // print(_serviceEnabled);
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    print("i am here");
    Navigator.pop(context);
    bool tmp = await p.Permission.location.request().isGranted;
    print(tmp);
    _permissionGranted = await location.hasPermission();
    if (await p.Permission.location.request().isGranted) {
      print("i am here");
      print(tmp);
      print(_permissionGranted);
      if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
        print("requesting");
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    } else {
      print("permission denied");
    }

    _locationData = await location.getLocation();
    double lattitude = _locationData.latitude;
    double longitude = _locationData.longitude;
    List<g.Placemark> placemarks = await g.placemarkFromCoordinates(lattitude, longitude);
    g.Placemark temp = placemarks[0];
    place = temp.name;
  }

  void _showCurrentLocation(VoidCallback fun) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          double c_width = MediaQuery.of(context).size.width * 0.8;
          return StatefulBuilder(builder: (context, setstate) {
            return FractionallySizedBox(
                heightFactor: 0.9,
                child: Column(children: [
                  Padding(padding: EdgeInsets.all(15), child: Text("Allow location access to improve shopping experience", style: TextStyle(fontSize: 20))),
                  Padding(padding: EdgeInsets.all(15), child: Text("We use your location to improve your shopping experience, ensuring you only see items or products and delivery options available in your place.", style: TextStyle(fontSize: 15))),
                  new Container(
                      child: Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: Checkbox(
                            checkColor: Colors.white,
                            value: isChecked,
                            onChanged: (bool value) {
                              setstate(() {
                                isChecked = value;
                              });
                            },
                          )),
                      Flexible(child: Padding(padding: EdgeInsets.all(0), child: Text("Allow this FeedNext app to access your location and skip this step in the future.")))
                    ],
                  )),
                  ListTile(
                      title: Row(children: [
                    RaisedButton(
                      color: Colors.yellow,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(width: MediaQuery.of(context).size.width * 0.38, height: 50, child: Center(child: Text("Not now"))),
                    ),
                    SizedBox(width: 10),
                    RaisedButton(
                      color: mainAppColor,
                      onPressed: () {
                        getCoordinatesAndPlace();
                        fun();
                      },
                      child: SizedBox(width: MediaQuery.of(context).size.width * 0.38, height: 50, child: Center(child: Text("Allow access"))),
                    )
                  ]))
                ]));
          });
        });
  }

  Widget showLocation() {
    return Container(
        height: 40,
        width: 10000,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Icon(Icons.location_on_rounded),
                  Text(textFun(BOOL), textAlign: TextAlign.left),
                  GestureDetector(
                      onTap: () {
                        _showModalSheet();
                      },
                      child: Icon(Icons.keyboard_arrow_down_outlined))
                ]))),
        color: Color(0xff90ee90));
  }

  checkPreviousOrderLinkedWithSubscription() {
    final Map requestObj = {
      "orderId": null
    };
    displayLoadingIcon(context);
    orderTrackingService.checkOrderLinkedWithSubscription(requestObj).then((val) {
      final data = json.decode(val.body);
      print(data);
      print(data['orderId']);
      if (data['havingSubscribedOrders'] != null && data['havingSubscribedOrders']) {
        Navigator.of(context).pop();
        displaySubscriptionPopup(context, "You have subscribed this order. Do you want repeat this order?", data['orderId']);
      } else if (data['havingSubscribedOrders'] != null && !data['havingSubscribedOrders'] && data['status'] == null) {
        Navigator.of(context).pop();
        if (noOfProductsAddedInCart > 0) {
          displayRepeatOrderPopup(context, "You have some products in the cart. Do you want clear the cart to repeat this order?", data['orderId']);
        } else {
          repeatPreviousOrder(data['orderId'], true);
        }
      } else if (data['status'] != null && data['status'] == "NOPREVIOUSORDERS") {
        Navigator.of(context).pop();
        clearErrorMessages(scafflodkey);
        showErrorNotifications("You don't have any previous orders", context, scafflodkey);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.of(context).pop();
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService().getAccessTokenFromData(refreshTokenData, context, setState)) {
            checkPreviousOrderLinkedWithSubscription();
          }
        });
      } else if (data['error'] != null) {
        Navigator.of(context).pop();
        ApiErros().apiLoggedErrors(data, context, scafflodkey);
      }
    }, onError: (err) {
      Navigator.of(context).pop();
      ApiErros().apiErrorNotifications(err, context, '/home', scafflodkey);
    });
  }

  void fun() {
    setState(() {
      BOOL = true;
    });
  }

  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // backgroundColor: Colors.grey[100],
      key: scafFoldKey,
      appBar: appBarWidgetWithIconsAnSearchbox(context, false, this.setState, false, '/home', searchFieldKey, searchFieldController, searchFocusNode),
      drawer: appBarDrawer(context, this.setState, scafflodkey),
      // endDrawer: filterDrawer(
      //     this.setState, context, scafflodkey, false, searchFieldController),
      body: !bannerScreenLoading
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(children: [
                // Text("example"),
                // showSearch()
                AppStyles().customPadding(1),
                // Container(
                //     height: 40,
                //     margin: EdgeInsets.only(left: 5, right: 5),
                //     child: Row(children: [
                //       Expanded(
                //           // flex: 8,
                //           child: TextFormField(
                //               cursorColor: mainAppColor,
                //               controller: searchFieldController,
                //               key: searchFieldKey,
                //               focusNode: searchFocusNode,
                //               onFieldSubmitted: (val) {
                //                 getSearchedData(null);
                //                 setState(() {
                //                   // searchFocusNode.unfocus();
                //                   // searchFieldKey.currentState?.reset();
                //                   searchFieldController.text = "";
                //                   // print("object lascaso de pal");
                //                   // searchFieldController.clear();
                //                 });
                //               },
                //               decoration: InputDecoration(
                //                   counterText: "",
                //                   // alignLabelWithHint: true,
                //                   hintText: "Search",
                //                   border: AppStyles().searchBarBorder,
                //                   // prefix: Text("+91 "),
                //                   contentPadding:
                //                       EdgeInsets.fromLTRB(14, 0, 0, 0),
                //                   focusedBorder:
                //                       AppStyles().focusedSearchBorder,
                //                   suffixIcon: IconButton(
                //                     padding: EdgeInsets.all(0),
                //                     icon: Icon(Icons.search),
                //                     onPressed: () {
                //                       getSearchedData(null);
                //                       setState(() {
                //                         // searchFocusNode.unfocus();
                //                         // searchFieldKey.currentState?.reset();
                //                         searchFieldController.text = "";
                //                         // print("object lascaso de pal");
                //                         // searchFieldController.clear();
                //                       });
                //                     },
                //                     color: mainAppColor,
                //                     tooltip: 'Search',
                //                     // iconSize: 24,
                //                   )))),
                //       // Expanded(
                //       //     child: IconButton(
                //       //   padding: EdgeInsets.all(0),
                //       //   icon: Icon(Icons.filter_list),
                //       //   onPressed: () {
                //       //     scafflodkey.currentState.openEndDrawer();
                //       //   },
                //       //   color: mainAppColor,

                //       //   tooltip: 'Filter',
                //       //   // iconSize: 14,
                //       // )),
                //       // child: FlatButton.icon(
                //       //   icon: Icon(Icons.filter_list),
                //       //   onPressed: () {},
                //       //   label: Text("Filter"),
                //       // ),
                //       // )
                //     ])),
                // Expanded(child: ListView.builder(
                //     itemBuilder: (BuildContext context, int index) {
                //   return null;
                // })),
                // SingleChildScrollView(
                //     physics: AlwaysScrollableScrollPhysics(),
                //     // scrollDirection: Axis.vertical,
                //     primary: true,
                //     child: Column(children: [

                // Expanded(
                //     child: ListView(
                //         physics: AlwaysScrollableScrollPhysics(),
                //         children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: 1,
                        controller: scrollController,
                        itemBuilder: (BuildContext context, int i) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            showLocation(),
                            showCategories(),
                            // Divider(
                            //   thickness: 1.5,
                            // ),
                            carouselDetails != null && carouselDetails.length > 0
                                ? new Container(
                                    // padding: const EdgeInsets.all(15.0),
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(top: 7.0),
                                    // padding: const EdgeInsets.only(
                                    //     left: 0.0, right: 0.0, bottom: 5.0, top: 5.0),
                                    // height: 75,
                                    height: MediaQuery.of(context).size.width / 2,
                                    child: new ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: getCarouselData(),
                                      // banner,
                                    ),
                                  )
                                : customizedCircularLoadingIcon(25),
                            Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                            ),
                            // Divider(
                            //   thickness: 1.5,
                            // ),
                            Container(
                              // margin:
                              //     EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              child: RaisedButton(
                                onPressed: () {
                                  if (signInDetails['access_token'] == null || signInDetails['access_token'] == "") {
                                    Navigator.pushNamed(context, '/login');
                                  } else {
                                    checkPreviousOrderLinkedWithSubscription();
                                    // if (noOfProductsAddedInCart > 0) {
                                    //   displayRepeatOrderPopup(
                                    //     context,
                                    //     "You have some products in the cart. Do you want clear the cart to repeat this order?",
                                    //   );
                                    // } else {
                                    //   repeatPreviousOrder(null, true);
                                    // }
                                  }
                                },
                                child: Text(
                                  "Repeat Previous Order",
                                  style: appFonts.getTextStyle('home_screen_repeat_previous_order_button_style'),
                                ),
                                color: mainYellowColor,
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 4, right: MediaQuery.of(context).size.width / 4),
                              ),
                            ),
                            // Divider(
                            //   thickness: 1.5,
                            // ),
                            Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                            ),
                            Container(
                                key: productListKey,
                                child: showProductDetails(
                                  productDetails,
                                  this.setState,
                                  productShowMoreOrLess,
                                  NeverScrollableScrollPhysics(),
                                  true,
                                  context,
                                  '/home',
                                )),
                            isMoreProductsLoading
                                ? Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Center(
                                      child: customizedCircularLoadingIcon(30),
                                    ),
                                  )
                                : Container(),
                          ]);
                        })
                    // ]))
                    // ]))
                    // Image(
                    //   image: NetworkImage(
                    //       "https://cogninelabs.s3.ap-south-1.amazonaws.com/cognine+logo.jpg"),
                    // ),
                    // RaisedButton(
                    //   onPressed: () {
                    //     getInfoUsingAccessToken();
                    //   },
                    //   child: Text("Click me"),
                    // ),
                    // RaisedButton(
                    //   onPressed: () {
                    //     // getInfoUsingAccessToken();
                    //     SharedPreferenceService().removeUserInfo();
                    //     // Navigator.pushNamed(context, "/login");
                    //     Navigator.pushNamedAndRemoveUntil(
                    //         context, '/login', ModalRoute.withName('/login'));
                    //   },
                    //   child: Text("Log out"),
                    // ),
                    // Text(resValue),
                    )
              ]))
          : Center(child: circularLoadingIcon()),
    );
  }
}
