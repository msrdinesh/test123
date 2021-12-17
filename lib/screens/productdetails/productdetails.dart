// import 'package:cornext_mobile/screens/imageandvideos/data.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cornext_mobile/constants/labelnames.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:cornext_mobile/utils/globalvalidations/globalvalidations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:video_player/video_player.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'dart:convert';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
// import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chewie/chewie.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:intl/intl.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:cornext_mobile/services/connectivityservice/connectivityservice.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/successmessages.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:hardware_buttons/hardware_buttons.dart';
import 'package:cornext_mobile/services/cartservice/cartservice.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:cornext_mobile/constants/appfonts.dart';

class ProductDetailsPage extends StatefulWidget {
  @override
  ProductDetails createState() => ProductDetails();
}

class ProductDetails extends State<ProductDetailsPage> {
  String currentImage = "";
  List productTypes = List();
  Map productDetails = {};
  List productGallery = [];
  List pincodeAvailabilities = [];
  List specificationTypes = List();
  ProductDetailsService productDetailsService = ProductDetailsService();
  bool isProductsLoading = false;
  double priceOfCurrentProduct = 0;
  final searchController = TextEditingController();
  Map productInstructions = {};
  bool showOrHideInstructions = false;
  // bool showOrHideSearchAndFilter = false;
  final scaffoldkey = GlobalKey<ScaffoldState>();
  bool showMoreOrLess = false;
  List _controller = [];
  // ChewieController chewieController;
  // int quantity = 1;
  final quantity = TextEditingController();
  String productSelection;
  String specificationSelection;
  int noOfPersons = 1;
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  double _buttonWidth = 30;
  List productSuggestions = [];
  int numberOfItems = 1;
  final productPincodeController = TextEditingController();
  final unitsController = TextEditingController();
  final unitsFocus = FocusNode();
  final unitsKey = GlobalKey<FormFieldState>();
  final quantityController = TextEditingController();
  final quantityFocus = FocusNode();
  final quantityKey = GlobalKey<FormFieldState>();

  final productPincodeKey = GlobalKey<FormFieldState>();
  FocusNode productPincodeFocus = FocusNode();
  final ApiErros apiErros = ApiErros();
  final currencyFormatter = NumberFormat('#,##,###.00');
  final Connectivity _connectivity = Connectivity();
  final ConnectivityService connectivityService = ConnectivityService();
  bool waitingForInternetConnection = false;
  List listOfUnits = [];
  String currentUnitType;
  bool favoriteProduct = false;
  bool pincodeIsAvailble = false;
  String stockPointAvailabilityCheck = '';
  final instructionsKey = GlobalKey();
  final suggestionsBoxKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  AutoCompleteTextField searchTextField;
  final RefreshTokenService refreshTokenService = RefreshTokenService();
  bool loadingButtonForFavorites = false;
  final ErrorMessages errorMessages = ErrorMessages();
  final SuccessMessages successMessages = SuccessMessages();
  bool loadingIconForFloatingButtons = false;
  bool loadingButtonForProceedToCart = false;
  List specifications = [];
  List productSizes = [];
  String selectedProductSize = '';
  // final hard
  // StreamSubscription _volumeButtonSubscription;
  // double voulmeController = 0.0;
  int _current = 0;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  final AppFonts appFonts = AppFonts();
  final ScrollController suggestionsScroll = ScrollController();
  int totalNumberOfSuggestions = 0;
  bool isMoreSuggestionsLoading = false;
  int suggestionProductsPageNo = 1;
  List testimonialGalleryControllers = [];
  List instructionsGalleryControllers = [];
  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  @override
  void initState() {
    showOrHideSearchAndFilter = false;

    try {
      checkInternetConnection();
      // fetchProductDetails(true);
      // fetchProductListDetails();
      // checkQuantityValidOrNot();
    } catch (err) {
      print(err);
    }
    super.initState();
  }

  checkInternetConnection() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (err) {
      print(err);
    }
    if (!connectivityService.getConnectionStatus(result)) {
      setState(() {
        productGallery = [];
        productDetails = {};
        previousScreenRouteName = '/productdetails';
        Navigator.of(context).pushReplacementNamed('/errorscreen');
      });
    } else {
      fetchProductDetails(true);
      fetchProductListDetails(false);
      checkQuantityValidOrNot();
    }
  }

  getPreviousOrderedPincode() {
    productDetailsService.getPreviousOrderedPinCode().then((val) {
      final data = json.decode(val.body);
      if (data != null && data.runtimeType == int) {
        productPincodeController.text = data.toString();
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService().getAccessTokenFromData(refreshTokenData, context, setState)) {
            getPreviousOrderedPincode();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
    }, onError: (err) {});
  }

  checkQuantityValidOrNot() {
    setState(() {
      GlobalValidations().validateCurrentFieldValidOrNot(quantityFocus, quantityKey);
      GlobalValidations().validateCurrentFieldValidOrNot(unitsFocus, unitsKey);
    });

    validateCurrentPinCodeValidOrNot();
  }

  validateCurrentPinCodeValidOrNot() {
    productPincodeFocus.addListener(() {
      if (!productPincodeFocus.hasFocus) {
        productPincodeKey.currentState.validate();
        if (productPincodeKey.currentState.hasError) {
          setState(() {
            stockPointAvailabilityCheck = '';
          });
        }
        // focusNode.unfocus();
      }
    });
  }

  reset() {
    searchFieldController.clear();
    searchFieldKey.currentState?.reset();
  }

  getSearchedData() {
    if (searchFieldController.text.trim() != '') {
      productSearchData['productSearchData'] = searchFieldController.text.trim();
      List filterProductsData = [];
      filterProducts.forEach((val) {
        if (val['isSelected']) {
          Map obj = {
            'productCategoryId': val['productCategoryId']
          };
          filterProductsData.add(obj);
        }
      });
      if (filterProductsData.length > 0) {
        productSearchData['productCategoryInfo'] = filterProductsData;
      }
      reset();
      _controller.forEach((videoController) {
        if (videoController['controller'] != null && videoController['controller'].value.initialized) {
          videoController['controller'].pause();
        }
      });
      setState(() {
        showOrHideSearchAndFilter = false;
      });
      Navigator.of(context).pushNamed('/search');
    }
  }

  // Fetch product details from back
  fetchProductDetails(bool callSpectifications) {
    setState(() {
      isProductsLoading = true;
      productDetails = {};
      productGallery = [];
      numberOfItems = 1;
      favoriteProduct = false;
      productPincodeController.clear();
      stockPointAvailabilityCheck = '';
    });
    pauseAllVideoControllers();
    productDetailsObject['userId'] = signInDetails['userId'] != null ? signInDetails['userId'] : null;
    productDetailsService.getProductDetails(productDetailsObject).then((res) {
      final data = json.decode(res.body);
      setState(() {
        productDetails = data;
      });
      setState(() {
        isProductsLoading = false;
      });
      // print('dkkd');
      // print(data);
      if (data['productName'] != null) {
        getInstructionsOfCurrentProduct();
        getProductSizes(productDetails['productId']);
        if (signInDetails['access_token'] != null) {
          getPreviousOrderedPincode();
        }
        quantityController.text = '1';
        if (data['productMinimumQuantity'] != null) {
          quantityController.text = data['productMinimumQuantity'].toInt().toString();
        }
        if (data['favoriteProduct'] != null) {
          print(data['favoriteProduct']);
          setState(() {
            favoriteProduct = data['favoriteProduct'];
          });
        }
        setState(() {
          priceOfCurrentProduct = productDetails['value'];
        });
        scrollController.addListener(() {
          if (priceOfCurrentProduct > 0) {
            RenderBox box = productPincodeKey.currentContext.findRenderObject();
            Offset position = box.localToGlobal(Offset.zero);
            if (position.dy - 50 < 0) {
              productPincodeFocus.unfocus();
            }
          }
        });
        // }
        if (data['gallery'] != null && data['gallery']['productGallery'] != null) {
          setState(() {
            data['gallery']['productGallery'].forEach((val) {
              // Uncomment this when ever video required;
              if (!val['image']) {
                setState(() {
                  productGallery.add(val);
                });
              }
            });
            // Uncomment when ever using videos
            initializeVideo();

            data['gallery']['productGallery'].forEach((val) {
              if (val['image']) {
                setState(() {
                  productGallery.add(val);
                });
              }
            });
            if (productDetails['gallery'] != null && productDetails['gallery']['testimonialGallery'] != null && productDetails['gallery']['testimonialGallery'].length > 0) {
              intializeProductTestimonialsOrInstructions(productDetails['gallery']['testimonialGallery'], true);
            }
            // initializeVideo();
            if (productDetails['specifications'] != null && productDetails['specifications'].length > 0 && productDetails['specificationName'] != null) {
              setState(() {
                specifications = productDetails['specifications'];
                specificationSelection = productDetails['specificationId'].toString();
              });
            }
            if (data['havingUnits']) {
              unitsController.text = "1";
              if (data['productMinimumQuantity'] != null) {
                unitsController.text = data['productMinimumQuantity'].toInt().toString();
              }
            }
          });
        }
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/productdetails', scaffoldkey);
      setState(() {
        isProductsLoading = false;
      });
    }).catchError((err) {
      // print(err);
    });
  }

  // getProductDetailsByType(int productTypeId, bool isPageLoading) {
  //   Map obj = {
  //     'productId': productDetailsObject['productId'],
  //     'productTypeId': productTypeId
  //   };
  //   productDetailsService.getProdctDetailsTypes(obj).then((res) {
  //     final producttypedata = json.decode(res.body);
  //     // print('producttypes');
  //     // print(producttypedata);
  //     productTypes = producttypedata['productDataTypes'];
  //     if (isPageLoading) {
  //       productTypes.forEach((res) {
  //         if (res['productTypeId'] == obj['productTypeId']) {
  //           setState(() {
  //             productSelection = res['productTypeId'].toString();
  //             productDetailsObject['productTypeId'] = res['productTypeId'];
  //           });
  //         }
  //       });
  //     }
  //     if (producttypedata['productDataSpecifications'] != null &&
  //         producttypedata['productDataSpecifications'].length > 0) {
  //       setState(() {
  //         if (producttypedata['havingSpecification']) {
  //           setState(() {
  //             specificationTypes = producttypedata['productDataSpecifications'];
  //             specificationSelection =
  //                 specificationTypes[0]['specificationId'].toString();
  //           });
  //         } else {
  //           setState(() {
  //             specificationTypes = [];
  //           });
  //         }
  //       });
  //       if (!isPageLoading) {
  //         productDetailsObject['specificationId'] =
  //             producttypedata['productDataSpecifications'][0]
  //                 ['specificationId'];
  //         if (producttypedata['productDataSpecifications'][0]['units'] !=
  //                 null &&
  //             producttypedata['productDataSpecifications'][0]['units'].length >
  //                 0) {
  //           productDetailsObject['priceId'] =
  //               producttypedata['productDataSpecifications'][0]['units'][0]
  //                   ['priceId'];
  //         } else if (producttypedata['productDataSpecifications'][0]
  //                     ['priceId'] !=
  //                 null &&
  //             producttypedata['productDataSpecifications'][0]['priceId']
  //                     .length >
  //                 0) {
  //           productDetailsObject['priceId'] =
  //               producttypedata['productDataSpecifications'][0]['priceId'][0]
  //                   ['priceId'];
  //         }
  //       }
  //     }
  //     if (!isPageLoading) {
  //       // productDetailsObject['productTypeId'] = int.parse(productSelection);
  //       // if (specificationSelection != null) {
  //       //   productDetailsObject['specificationId'] =
  //       //       int.parse(specificationSelection);
  //       // }
  //       // print(productDetailsObject);
  //       fetchProductDetails(false);
  //     }
  //     // print(productDetailsObject['specificationId']);
  //   });
  // }

  setShowMoreOrLessState(int index, productShowMoreOrLess, state) {
    if (productShowMoreOrLess[index]) {
      state(() {
        productShowMoreOrLess[index] = false;
      });
    } else {
      state(() {
        productShowMoreOrLess[index] = true;
      });
    }
  }

  fetchProductListDetails(bool isMoreData) async {
    // setState(() {
    //   productDetailsLoading = true;
    // });
    if (isMoreData) {
      setState(() {
        isMoreSuggestionsLoading = true;
      });
    }
    final requestObj = {
      "productCategoryName": null,
      "productSearchData": null,
      "pageNumber": suggestionProductsPageNo,
      "limit": 10,
      "screenName": "HS"
    };
    HomeScreenServices().getProductListDetails(requestObj).then((val) {
      print(val.body);
      final data = json.decode(val.body);
      if (data['listOfProducts'] != null) {
        // if(data['listOfProducts'])
        // showProductDetailsInfo();
        setState(() {
          totalNumberOfSuggestions = data['productCount'];
          if (!isMoreData) {
            productSuggestions = data['listOfProducts'];
          } else {
            data['listOfProducts'].forEach((val) {
              productSuggestions.add(val);
            });
          }
          setState(() {
            showSuggestionsForProduct(productSuggestions, this.setState, suggestionsScroll);
          });
        });

        suggestionsScroll.addListener(() {
          // print('err');
          if (totalNumberOfSuggestions > productSuggestions.length && !isMoreSuggestionsLoading && suggestionsScroll.position.pixels == suggestionsScroll.position.maxScrollExtent) {
            // print('err1');
            setState(() {
              suggestionProductsPageNo = suggestionProductsPageNo + 1;
            });
            fetchProductListDetails(true);
          }
        });
      }
      setState(() {
        isMoreSuggestionsLoading = false;
      });
    }, onError: (err) {
      // ApiErros().apiErrorNotifications(err, context);
      // setState(() {
      //   productDetailsLoading = false;
      // });
      setState(() {
        isMoreSuggestionsLoading = false;
      });
    });
  }

  getProductSizes(int productId) {
    final requestObj = {
      "productId": productId
    };
    productDetailsService.getSizesOfCurrentProduct(requestObj).then((val) {
      final data = json.decode(val.body);
      print(data);
      if (data != null && data['listOfSizes'] != null && data['listOfSizes'].length > 0) {
        setState(() {
          productSizes = data['listOfSizes'];
          if (productSizes.length > 0) {
            selectedProductSize = productDetails['productId'].toString();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/productdetails', scaffoldkey);
    });
  }

  initializeVideo() {
    // setState(() {
    //   currentImage = productGallery[0]['resourceUrl'];
    // });
    // print('veera');
    // print(productGallery);
    bool isIntialProductObtained = false;
    productGallery.forEach((res) {
      if (res['resourceUrl'].toString().indexOf('mp4') != -1 && _controller.indexWhere((val) => val['url'] == res['resourceUrl']) == -1) {
        _cacheManager.getSingleFile(res['resourceUrl']).then((cacheVideo) {
          final file = cacheVideo;
          if (file != null) {
            setState(() {
              // print('image');
              // print(currentImage);
              VideoPlayerController _videoController;
              _videoController = VideoPlayerController.file(file)
                ..initialize().then((val) {
                  if (!isIntialProductObtained) {
                    setState(() {
                      _videoController.play();
                      isIntialProductObtained = true;
                    });
                  }
                  Map obj = {
                    'controller': _videoController,
                    'url': res['resourceUrl']
                  };
                  setState(() {
                    _controller.add(obj);
                  });
                });
              if (!isIntialProductObtained && !_videoController.value.isPlaying) {
                _videoController.play();
                isIntialProductObtained = true;
              }
              _videoController.setLooping(true);
              // _videoController.setVolume(0.0);
              // _volumeButtonSubscription =
              //     volumeButtonEvents.listen((VolumeButtonEvent event) {
              //       _volumeButtonSubscription?.cancel();
              //   if (_videoController != null) {
              //     if (event == VolumeButtonEvent.VOLUME_UP && _videoController.value.volume == 0.0) {
              //       // voulmeController = voulmeController + 1;
              //       // setState(() {
              //         _videoController.setVolume(1.0);
              //       // });
              //     }
              //   }
              // });
              // _controller.
              // super.initState();
              // _controller = VideoPlayerController.network(res['resourceUrl']);
              // chewieController = ChewieController(
              //     videoPlayerController: _controller,
              //     aspectRatio: 4 / 3,
              //     allowFullScreen: false,
              //     looping: false);
            });
          } else {
            setState(() {
              // print('image');
              // print(currentImage);
              VideoPlayerController _videoController;
              _videoController = VideoPlayerController.network(res['resourceUrl'])
                ..initialize().then((val) {
                  if (!isIntialProductObtained) {
                    setState(() {
                      _videoController.play();
                      isIntialProductObtained = true;
                    });
                  }
                  Map obj = {
                    'controller': _videoController,
                    'url': res['resourceUrl']
                  };
                  setState(() {
                    _controller.add(obj);
                  });
                });
              if (!isIntialProductObtained && !_videoController.value.isPlaying) {
                _videoController.play();
                isIntialProductObtained = true;
              }
              _videoController.setLooping(true);
              // _videoController.setVolume(0.0);
              File newFile = new File(res['resourceUrl']);
              _cacheManager.putFile(res['resourceUrl'], newFile.readAsBytesSync(), maxAge: Duration(days: 5));
              // _volumeButtonSubscription =
              //     volumeButtonEvents.listen((VolumeButtonEvent event) {
              //       _volumeButtonSubscription?.cancel();
              //   if (_videoController != null) {
              //     if (event == VolumeButtonEvent.VOLUME_UP && _videoController.value.volume == 0.0) {
              //       // voulmeController = voulmeController + 1;
              //       _videoController.setVolume(1.0);
              //     }
              //   }

              // });
              // _controller.
              // super.initState();
              // _controller = VideoPlayerController.network(res['resourceUrl']);
              // chewieController = ChewieController(
              //     videoPlayerController: _controller,
              //     aspectRatio: 4 / 3,
              //     allowFullScreen: false,
              //     looping: false);
            });
          }
        });
      }
    });
  }

  intializeProductTestimonialsOrInstructions(List gallery, bool isTestimonials) {
    gallery.forEach((res) {
      if (res['resourceUrl'].toString().indexOf('mp4') != -1 && ((testimonialGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl']) == -1 && isTestimonials) || (instructionsGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl']) == -1 && !isTestimonials))) {
        _cacheManager.getSingleFile(res['resourceUrl']).then((cacheVideo) {
          final file = cacheVideo;
          if (file != null) {
            setState(() {
              // print('image');
              // print(currentImage);
              VideoPlayerController _videoController;
              _videoController = VideoPlayerController.file(file)
                ..initialize().then((val) {
                  setState(() {
                    _videoController.pause();
                  });
                });
              _videoController.setLooping(true);
              // _videoController.setVolume(0.0);
              // _volumeButtonSubscription =
              //     volumeButtonEvents.listen((VolumeButtonEvent event) {
              //   if (_videoController != null) {
              //     if (event == VolumeButtonEvent.VOLUME_UP) {
              //       // voulmeController = voulmeController + 1;
              //       // setState(() {
              //         _videoController.setVolume(0.0);
              //         _videoController.setVolume(1.0);
              //       // });
              //     }
              //   }
              // });
              Map obj = {
                'controller': _videoController,
                'url': res['resourceUrl']
              };
              if (isTestimonials) {
                setState(() {
                  testimonialGalleryControllers.add(obj);
                });
              } else {
                setState(() {
                  instructionsGalleryControllers.add(obj);
                });
              }
              // _controller.
              // super.initState();
              // _controller = VideoPlayerController.network(res['resourceUrl']);
              // chewieController = ChewieController(
              //     videoPlayerController: _controller,
              //     aspectRatio: 4 / 3,
              //     allowFullScreen: false,
              //     looping: false);
            });
          } else {
            setState(() {
              // print('image');
              // print(currentImage);
              VideoPlayerController _videoController;
              _videoController = VideoPlayerController.network(res['resourceUrl'])
                ..initialize().then((val) {
                  setState(() {
                    _videoController.pause();
                  });
                });
              _videoController.setLooping(true);
              // _videoController.setVolume(0.0);
              File newFile = new File(res['resourceUrl']);
              _cacheManager.putFile(res['resourceUrl'], newFile.readAsBytesSync(), maxAge: Duration(days: 5));
              // _volumeButtonSubscription =
              //     volumeButtonEvents.listen((VolumeButtonEvent event) {
              //   if (_videoController != null) {
              //     if (event == VolumeButtonEvent.VOLUME_UP) {
              //       // voulmeController = voulmeController + 1;
              //       _videoController.setVolume(1.0);
              //     }
              //   }

              // });
              Map obj = {
                'controller': _videoController,
                'url': res['resourceUrl']
              };
              if (isTestimonials) {
                setState(() {
                  testimonialGalleryControllers.add(obj);
                });
              } else {
                setState(() {
                  instructionsGalleryControllers.add(obj);
                });
              }
              // _controller.
              // super.initState();
              // _controller = VideoPlayerController.network(res['resourceUrl']);
              // chewieController = ChewieController(
              //     videoPlayerController: _controller,
              //     aspectRatio: 4 / 3,
              //     allowFullScreen: false,
              //     looping: false);
            });
          }
        });
      }
    });
  }

  pauseAllVideoControllers() {
    _controller.forEach((videoController) {
      if (videoController['controller'] != null && videoController['controller'].value.initialized) {
        setState(() {
          videoController['controller'].pause();
          _current = 0;
          // _controller.initialize();
        });
      }
    });
    testimonialGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null && videoController['controller'].value.initialized) {
        setState(() {
          videoController['controller'].pause();
          // _controller.initialize();
        });
      }
    });
    instructionsGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null && videoController['controller'].value.initialized) {
        setState(() {
          videoController['controller'].pause();
        });
      }
    });
  }

  resetAllControllers() {
    _controller.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].dispose();
      }
    });
    testimonialGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].dispose();
      }
    });
    instructionsGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].dispose();
      }
    });
  }

  // List<Container> _buildListItemsFromFlowers() {
  //   // int index = 0;
  //   return productGallery.map((imageInfo) {
  //     var container = Container(
  //       child: new Row(
  //         children: <Widget>[
  //           GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   currentImage = imageInfo['resourceUrl'];
  //                 });
  //               },
  //               child: new Container(
  //                   margin: new EdgeInsets.all(5.0),
  //                   child: imageInfo['resourceUrl'].indexOf('mp4') == -1
  //                       ? Image(
  //                           image: NetworkImage(imageInfo['resourceUrl']),
  //                           height: 40.0,
  //                           width: 40.0,
  //                         )
  //                       : _controller.value.initialized
  //                           ? Container(
  //                               height: 40.0,
  //                               width: 40.0,
  //                               child: Stack(children: [
  //                                 Center(
  //                                     child: AspectRatio(
  //                                         aspectRatio:
  //                                             _controller.value.aspectRatio,
  //                                         child: VideoPlayer(_controller))),
  //                                 Center(
  //                                     child: Icon(
  //                                   _controller.value.isPlaying
  //                                       ? Icons.pause
  //                                       : Icons.play_arrow,
  //                                   // label: ,
  //                                   color: Colors.white,
  //                                   size: 10,
  //                                 ))
  //                               ]),
  //                             )
  //                           : Container()))
  //         ],
  //       ),
  //     );
  //     // index = index + 1;
  //     return container;
  //   }).toList();
  // }

  getInstructionsOfCurrentProduct() {
    Map obj = {
      'productId': productDetailsObject['productId'],
      'screenName': 'PRD'
    };
    if (productDetailsObject['productTypeId'] != null) {
      obj['productTypeId'] = productDetailsObject['productTypeId'];
    }
    if (productDetailsObject['specificationId'] != null) {
      obj['specificationId'] = productDetailsObject['specificationId'];
    }
    productDetailsService.getProductDetailsInstructions(obj).then((res) {
      // print('hdhdh');
      // print(res.body);
      final data = json.decode(res.body);
      // print(data);
      if (data != null) {
        if (data['instruction'] != null) {
          setState(() {
            productInstructions = data['instruction'];
            if (productInstructions['instructionGallery'] != null && productInstructions['instructionGallery'].length > 0) {
              intializeProductTestimonialsOrInstructions(productInstructions['instructionGallery'], false);
            }
            showOrHideInstructions = true;
          });
        } else if (data['error'] != null) {
          apiErros.apiLoggedErrors(data, context, scaffoldkey);
        }
      }
    });
  }

  checkPincode(String pincode, bool clickedOnAddToCartButton, bool navigateToCart) {
    final requestObj = {
      'userId': signInDetails['userId'] != null ? signInDetails['userId'] : null,
      'productId': productDetails['productId'],
      'pincode': int.parse(pincode),
      'quantity': productDetails['havingUnits'] != null && productDetails['havingUnits'] ? int.parse(unitsController.text.trim()) : int.parse(quantityController.text.trim())
    };
    if (!clickedOnAddToCartButton && !navigateToCart) {
      displayLoadingIcon(context);
    }
    productDetailsService.checkPinCodeAvalibility(requestObj).then((res) {
      final datapincode = json.decode(res.body);
      // pincodeAvailabilities = datapincode;

      // print(datapincode);
      if (!clickedOnAddToCartButton && !navigateToCart) {
        Navigator.pop(context);
      }
      if (datapincode != null && datapincode['status'] == 'AVAILABLE') {
        setState(() {
          pincodeIsAvailble = true;
          // pincodeAvailabilities = datapincode;
          stockPointAvailabilityCheck = 'Stock point is available.';
        });
        if (clickedOnAddToCartButton) {
          if (productDetails['havingUnits'] != null && productDetails['havingUnits'] && unitsKey.currentState.validate() && int.parse(unitsController.text.trim()) > 0) {
            addProductDetailsIntoCart(navigateToCart);
          } else if (productDetails['havingUnits'] != null && !productDetails['havingUnits'] && quantityKey.currentState.validate() && int.parse(quantityController.text.trim()) > 0) {
            addProductDetailsIntoCart(navigateToCart);
          }
        }
      } else if (datapincode != null && datapincode['status'] == 'STOCKNOTAVAILABLE') {
        setState(() {
          pincodeIsAvailble = false;
          stockPointAvailabilityCheck = datapincode['message'];
        });
      } else if (datapincode != null && datapincode['status'] == 'PINCODENOTAVAILABLE') {
        setState(() {
          pincodeIsAvailble = false;
          stockPointAvailabilityCheck = datapincode['message'];
        });
      } else if (datapincode != null && datapincode['error'] != null) {
        apiErros.apiLoggedErrors(datapincode, context, scaffoldkey);
      }
      // print('pincode');
      // print(datapincode);
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/productdetails', scaffoldkey);
    });
  }

  getPinCodeDetails(userDetails) {
    productDetailsService.getPincodeAvailability(userDetails).then((res) {
      // print(res.body);
      final datapincode = json.decode(res.body);
      // print('pincode');
      // print(datapincode);
      if (datapincode['listOfPincodes'] != null) {
        setState(() {
          pincodeAvailabilities = datapincode['listOfPincodes'];
        });
      } else if (datapincode['error'] != null) {
        apiErros.apiLoggedErrors(datapincode, context, scaffoldkey);
      }
    }, onError: (err) {
      apiErros.apiErrorNotifications(err, context, '/productdetails', scaffoldkey);
    });
  }

  @override
  void dispose() {
    resetAllControllers();
    allControllers = {};
    super.dispose();
  }

  playOrPauseVideo(String url) {
    _controller.forEach((videoController) {
      if (videoController['url'] == url && videoController['controller'].value.isPlaying) {
        setState(() {
          // print("kdkdkd");
          // _controller.pause();
          videoController['controller'].pause();
        });
      } else if (videoController['url'] == url && !videoController['controller'].value.isPlaying) {
        setOtherVideosOnPause();
        setState(() {
          videoController['controller'].play();
        });
      }
    });
  }

  playOrPauseVideoForTestimonialsOrInstructions(String url, bool isTestimonials) {
    if (isTestimonials) {
      testimonialGalleryControllers.forEach((videoController) {
        if (videoController['url'] == url && videoController['controller'].value.isPlaying) {
          setState(() {
            // print("kdkdkd");
            // _controller.pause();
            videoController['controller'].pause();
          });
        } else if (videoController['url'] == url) {
          setState(() {
            setAllVideosOnPause();
            videoController['controller'].play();
          });
        }
      });
    } else {
      instructionsGalleryControllers.forEach((videoController) {
        if (videoController['url'] == url && videoController['controller'].value.isPlaying) {
          setState(() {
            // print("kdkdkd");
            // _controller.pause();
            videoController['controller'].pause();
          });
        } else if (videoController['url'] == url) {
          setState(() {
            setAllVideosOnPause();
            videoController['controller'].play();
          });
        }
      });
    }
  }

  setOtherVideosOnPause() {
    testimonialGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].pause();
      }
    });
    instructionsGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].pause();
      }
    });
  }

  setAllVideosOnPause() {
    _controller.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].pause();
      }
    });
    testimonialGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].pause();
      }
    });
    instructionsGalleryControllers.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].pause();
      }
    });
  }

  List<Widget> getProductImages() {
    List<Widget> details = [];
    if (_controller.length > 0) {
      setState(() {
        allControllers['productCarouselVideoControllers'] = _controller;
      });
    }
    productGallery.forEach((res) {
      if (res['resourceUrl'].toString().trim().indexOf('mp4') != -1) {
        // Uncomment this when ever video required
        print('Current');
        if (_controller.indexWhere((val) => val['url'] == res['resourceUrl']) != -1 && _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'] != null) {
          print(_controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.initialized);
        }
        details.add(
          GestureDetector(
              onTap: () {
                playOrPauseVideo(res['resourceUrl']);
              },
              child: _controller.indexWhere((val) => val['url'] == res['resourceUrl']) != -1 && _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'] != null && _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.initialized
                  ? Container(
                      // flex: 5,
                      // height: 300,
                      constraints: BoxConstraints(maxHeight: 250),
                      child: Stack(children: [
                        Center(child: AspectRatio(aspectRatio: _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.aspectRatio, child: VideoPlayer(_controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller']))),
                        Center(
                            child: Icon(
                          _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.isPlaying ? Icons.pause : Icons.play_arrow,
                          // label: ,
                          color: Colors.white,
                          size: 40,
                        ))
                      ]),
                    )
                  : Center(
                      child: customizedCircularLoadingIcon(30),
                    )),
        );
      } else {
        // details.add(Image(
        //   image: NetworkImage(res['resourceUrl']),
        //   fit: BoxFit.contain,
        //   width: MediaQuery.of(context).size.width,
        // ));
        final String imageUrl = res['resourceUrl'];
        details.add(CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width,
          placeholder: (context, url) => customizedCircularLoadingIcon(25),
        ));
      }
    });
    return details;
  }

  List<Widget> getTestimonialImagesOrVideos(List gallery) {
    List<Widget> details = [];
    gallery.forEach((res) {
      if (res['resourceUrl'].toString().trim().indexOf('mp4') != -1) {
        // Uncomment this when ever video required

        details.add(
          GestureDetector(
              onTap: () {
                playOrPauseVideoForTestimonialsOrInstructions(res['resourceUrl'], true);
              },
              child: testimonialGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl']) != -1 && testimonialGalleryControllers[testimonialGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'] != null && testimonialGalleryControllers[testimonialGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.initialized
                  ? Container(
                      // flex: 5,
                      // height: 300,
                      constraints: BoxConstraints(maxHeight: 250),
                      child: Stack(children: [
                        Center(child: AspectRatio(aspectRatio: testimonialGalleryControllers[testimonialGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.aspectRatio, child: VideoPlayer(testimonialGalleryControllers[testimonialGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller']))),
                        Center(
                            child: Icon(
                          testimonialGalleryControllers[testimonialGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.isPlaying ? Icons.pause : Icons.play_arrow,
                          // label: ,
                          color: Colors.white,
                          size: 40,
                        ))
                      ]),
                    )
                  : Center(
                      child: customizedCircularLoadingIcon(30),
                    )),
        );
      } else {
        // details.add(Image(
        //   image: NetworkImage(res['resourceUrl']),
        //   fit: BoxFit.contain,
        //   width: MediaQuery.of(context).size.width,
        // ));
        final String imageUrl = res['resourceUrl'];
        details.add(CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width,
          placeholder: (context, url) => customizedCircularLoadingIcon(25),
        ));
      }
    });
    return details;
  }

  List<Widget> getInstructionsImagesOrVideos(List gallery) {
    List<Widget> details = [];
    gallery.forEach((res) {
      if (res['resourceUrl'].toString().trim().indexOf('mp4') != -1) {
        // Uncomment this when ever video required

        details.add(
          GestureDetector(
              onTap: () {
                playOrPauseVideoForTestimonialsOrInstructions(res['resourceUrl'], false);
              },
              child: instructionsGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl']) != -1 && instructionsGalleryControllers[instructionsGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'] != null && instructionsGalleryControllers[instructionsGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.initialized
                  ? Container(
                      // flex: 5,
                      // height: 300,
                      constraints: BoxConstraints(maxHeight: 250),
                      child: Stack(children: [
                        Center(child: AspectRatio(aspectRatio: instructionsGalleryControllers[instructionsGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.aspectRatio, child: VideoPlayer(instructionsGalleryControllers[instructionsGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller']))),
                        Center(
                            child: Icon(
                          instructionsGalleryControllers[instructionsGalleryControllers.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.isPlaying ? Icons.pause : Icons.play_arrow,
                          // label: ,
                          color: Colors.white,
                          size: 40,
                        ))
                      ]),
                    )
                  : Center(
                      child: customizedCircularLoadingIcon(30),
                    )),
        );
      } else {
        // details.add(Image(
        //   image: NetworkImage(res['resourceUrl']),
        //   fit: BoxFit.contain,
        //   width: MediaQuery.of(context).size.width,
        // ));
        final String imageUrl = res['resourceUrl'];
        details.add(CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width,
          placeholder: (context, url) => customizedCircularLoadingIcon(25),
        ));
      }
    });
    return details;
  }

  Widget getInstructionsOrTestimonialImages(List images, bool isTestimonials) {
    if (isTestimonials && testimonialGalleryControllers.length > 0) {
      setState(() {
        allControllers['testimonialVideoControllers'] = testimonialGalleryControllers;
      });
    } else if (instructionsGalleryControllers.length > 0) {
      setState(() {
        allControllers['instructionsVideoControllers'] = instructionsGalleryControllers;
      });
    }
    return CarouselSlider(
      viewportFraction: 1.0,
      aspectRatio: 2.0,
      items: isTestimonials ? getTestimonialImagesOrVideos(images) : getInstructionsImagesOrVideos(images),
      onPageChanged: (index) {
        onTestimonialOrInstructionsPageChange(isTestimonials);
      },
    );
  }

  onTestimonialOrInstructionsPageChange(bool isTestimonial) {
    if (isTestimonial) {
      testimonialGalleryControllers.forEach((videoController) {
        if (videoController['controller'] != null) {
          videoController['controller'].pause();
        }
      });
    } else {
      instructionsGalleryControllers.forEach((videoController) {
        if (videoController['controller'] != null) {
          videoController['controller'].pause();
        }
      });
    }
  }

  expandProductDetailsGallery() {
    productGalleryList = productGallery;
    Navigator.pushNamed(context, '/productvideosandimages');
  }

  Widget getCarousel() {
    return Stack(children: [
      GestureDetector(
          onTap: () {
            expandProductDetailsGallery();
          },
          child: new CarouselSlider(
            items: getProductImages(),
            viewportFraction: 1.0,
            aspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 2.0 : 5.0,
          )),
      Positioned(
          // top: 10,

          bottom: -10.0,
          right: 0.0,
          left: 0.0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: productGallery.map((val) {
                return val['resourceUrl'].toString().indexOf('mp4') == -1
                    ? Container(
                        width: 8.0,
                        height: 8.0,
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: productGallery.indexOf(val) == _current ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4),
                        ))
                    : productGallery.indexOf(val) == _current
                        ? Icon(
                            Icons.play_arrow,
                            size: 14,
                          )
                        : Icon(
                            Icons.play_arrow,
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            size: 14,
                          );
              }).toList()))
    ]);
  }

  // resetCurrentValues(){

  // }

  Future<bool> onBackButtonPressed() async {
    // print("enter");
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   // Fluttertoast.showToast(msg: exit_warning);
    //   return Future.value(false);
    // }
    // return Future.value(true);
    // print(AppVariables().previousRouteNames['previousRouteName']);
    // if (AppVariables().previousRouteNames['previousRouteName'] != '' &&
    //     (AppVariables().previousRouteNames['previousRouteName'] ==
    //             '/newpassword' ||
    //         AppVariables().previousRouteNames['previousRouteName'] ==
    //             '/otpvalidation')) {
    //   setState(() {
    //     // Navigator.pushNamedAndRemoveUntil(context, '', predicate)
    //     Navigator.pushNamed(context, "/home");
    //     return Future.value(true);
    //   });
    // }
    // previousProductDetailsObject.forEach((val) {
    //   if (val['isactive']) {
    //     productDetailsObject = val;
    //     // Navigator.of(context).pushNamed('/productdetails');
    //   }
    // });
    // productPincodeFocus.unfocus();
    // print('gdhj');
    // if (successFlushBar != null || errorFlushBar != null || flushBar != null) {
    //   clearErrorMessages();
    //   clearSuccessNotifications();
    //   closeNotifications();
    //   successFlushBar = null;
    //   errorFlushBar = null;
    //   flushBar = null;
    //   onBackButtonPressed();
    //   return false;
    // }
    print(previousRouteName);
    if (previousProductDetails.length > 0) {
      setState(() {
        // print(previousProductDetails);
        productDetailsObject = previousProductDetails[previousProductDetails.length - 1];
        previousProductDetails.removeAt(previousProductDetails.length - 1);
        // if (signInDeatils['access_token'] != null) {
        //   productDetailsObject['userId'] = signInDeatils['userId'];
        // } else {
        //   productDetailsObject['userId'] = null;
        // }
        fetchProductDetails(true);
        // Navigator.popAndPushNamed(context, '/productdetails');
      });
      return false;
    } else if (isProductsLoading) {
      return false;
    } else if (previousRouteName == '/search') {
      // isComingFromProductSearch = true;
      previousRouteName = '';
      List filterProductsData = getSelectedCategoryInfo();
      productSearchData['productCategory'] = filterProductsData;
      Navigator.popAndPushNamed(context, '/search');
      return false;
    } else if (previousRouteName == '/home') {
      previousRouteName = '';
      Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName("/home"));
      return false;
    } else if (previousRouteName == '/cart') {
      previousRouteName = '';
      Navigator.popAndPushNamed(context, '/cart');
      return false;
    } else {
      showOrHideSearchAndFilter = false;
      Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName("/home"));
      return false;
    }
    // return false;
  }

  List<Widget> getAnimalIcons(List animalInfo) {
    return animalInfo.map((val) {
      // return Image(
      //   image: NetworkImage(val.toString()),
      //   height: 15,
      //   width: 25,
      // );
      final String imageUrl = val.toString();
      return val.indexOf('Other') != -1 && val.indexOf('Icon') != -1
          ? Container(
              margin: EdgeInsets.only(right: 7),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 20,
                width: 50,
              ))
          : Container(
              margin: EdgeInsets.only(right: 10),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 20,
                width: 25,
              ));
    }).toList();
  }

  addProductIntoCart(bool navigateToCart) {
    // if ( != null) {
    if (productPincodeKey.currentState.validate()) {
      if (productDetails['havingUnits'] != null && productDetails['havingUnits'] && unitsKey.currentState.validate() && int.parse(unitsController.text.trim()) > 0) {
        checkPincode(productPincodeController.text.trim(), true, navigateToCart);
      } else if (productDetails['havingUnits'] != null && !productDetails['havingUnits'] && quantityKey.currentState.validate() && int.parse(quantityController.text.trim()) > 0) {
        checkPincode(productPincodeController.text.trim(), true, navigateToCart);
      }
    } else {
      if (productPincodeKey != null) {
        RenderBox box = productPincodeKey.currentContext.findRenderObject();
        Offset position = box.localToGlobal(Offset.zero);
        scrollController.jumpTo(position.direction + 300);
      }
    }
    // }
  }

  addProductDetailsIntoCart(
    bool navigateToCart,
  ) {
    Map returnObj = {
      "cart": []
    };
    Map obj = {
      "productId": productDetails['productId'],
    };
    if (productDetails['productTypeId'] != null) {
      obj['productTypeId'] = productDetails['productTypeId'];
    }
    if (productDetails['brandId'] != null) {
      obj['brandId'] = productDetails['brandId'];
    }
    if (productDetails['specificationId'] != null) {
      obj['specificationId'] = productDetails['specificationId'];
    }
    if (currentUnitType != null) {
      obj['priceId'] = int.parse(currentUnitType);
    } else if (productDetails['priceId'] != null) {
      obj['priceId'] = productDetails['priceId'];
    }
    if (productDetails['havingUnits'] != null && productDetails['havingUnits']) {
      obj['quantity'] = double.parse(unitsController.text.trim());
    } else {
      obj['quantity'] = double.parse(quantityController.text.trim());
    }
    obj['isAppend'] = true;
    returnObj['cart'].add(obj);
    if (!navigateToCart) {
      setState(() {
        loadingIconForFloatingButtons = true;
      });
    } else {
      setState(() {
        loadingButtonForProceedToCart = true;
      });
    }

    if (signInDetails['access_token'] != null) {
      productDetailsService.addProductIntoCart(returnObj).then((res) {
        // print(res.body);
        // final data = json.decode(res.body);
        dynamic data;
        if (res.body != null && res.body == "FAILED") {
          data = res.body;
        } else {
          data = json.decode(res.body);
        }
        print(data);
        if (data.runtimeType == int && data > 0) {
          setState(() {
            noOfProductsAddedInCart = data;
          });
          if (navigateToCart) {
            unitsKey.currentState?.reset();
            quantityKey.currentState?.reset();
            productPincodeKey.currentState?.reset();
            stockPointAvailabilityCheck = '';
            previousRouteNameFromCart = '';
            previousRouteNameFromCart = '/productdetails';
            Navigator.popAndPushNamed(context, "/cart");
          } else {
            clearSuccessNotifications(scaffoldkey);
            showSuccessNotifications(successMessages.addedToCartMessage, context, scaffoldkey);
            if (suggestionsBoxKey != null) {
              RenderBox box = suggestionsBoxKey.currentContext.findRenderObject();
              Offset position = box.localToGlobal(Offset.zero);
              scrollController.jumpTo(position.distance + position.dy);
            }
          }
        } else if (data == 'FAILED') {}
        setState(() {
          loadingButtonForProceedToCart = false;
          loadingIconForFloatingButtons = false;
        });
      }, onError: (err) {
        print(err);
        setState(() {
          loadingButtonForProceedToCart = false;
          loadingIconForFloatingButtons = false;
        });
        apiErros.apiErrorNotifications(err, context, '/productdetails', scaffoldkey);
      });
    } else {
      // obj['resourceUrl']
      // bool findIsProductIdentified = false;
      // storeCartDetails.forEach((val))
      if (storeCartDetails.length <= 0 || storeCartDetails.indexWhere((val) => val['productId'] == productDetails['productId']) == -1) {
        Map cachedObj = productDetails;
        List productGallery = productDetails['gallery']['productGallery'];
        cachedObj['resourceUrl'] = productGallery[productGallery.indexWhere((val) => val['priority'] != null && val['priority'] && val['image'])]['resourceUrl'];
        cachedObj.remove('gallery');
        cachedObj.remove("testimonialDescription");
        cachedObj.remove('instructionData');
        cachedObj.remove('productDescription');
        cachedObj.remove('favoriteProduct');
        if (productDetails['havingUnits'] != null && productDetails['havingUnits']) {
          cachedObj['quantity'] = int.parse(unitsController.text.trim());
        } else {
          cachedObj['quantity'] = int.parse(quantityController.text.trim());
        }
        storeCartDetails.add(cachedObj);
        setState(() {
          noOfProductsAddedInCart = storeCartDetails.length;
        });
        setState(() {
          loadingButtonForProceedToCart = false;
          loadingIconForFloatingButtons = false;
        });
        if (navigateToCart) {
          unitsKey.currentState?.reset();
          quantityKey.currentState?.reset();
          productPincodeKey.currentState?.reset();
          stockPointAvailabilityCheck = '';
          previousRouteNameFromCart = '';
          previousRouteNameFromCart = '/productdetails';
          Navigator.popAndPushNamed(context, "/cart");
        } else {
          clearSuccessNotifications(scaffoldkey);
          showSuccessNotifications(successMessages.addedToCartMessage, context, scaffoldkey);
          if (suggestionsBoxKey != null) {
            RenderBox box = suggestionsBoxKey.currentContext.findRenderObject();
            Offset position = box.localToGlobal(Offset.zero);
            scrollController.jumpTo(position.distance + position.dy);
          }
        }
      } else {
        int identifiedIndex = storeCartDetails.indexWhere((val) => val['productId'] == productDetails['productId']);
        if (productDetails['havingUnits'] != null && productDetails['havingUnits']) {
          storeCartDetails[identifiedIndex]['quantity'] = storeCartDetails[identifiedIndex]['quantity'] + int.parse(unitsController.text.trim());
        } else {
          storeCartDetails[identifiedIndex]['quantity'] = storeCartDetails[identifiedIndex]['quantity'] + int.parse(quantityController.text.trim());
        }
        setState(() {
          loadingButtonForProceedToCart = false;
          loadingIconForFloatingButtons = false;
        });
        if (navigateToCart) {
          unitsKey.currentState?.reset();
          quantityKey.currentState?.reset();
          productPincodeKey.currentState?.reset();
          stockPointAvailabilityCheck = '';
          previousRouteNameFromCart = '';
          previousRouteNameFromCart = '/productdetails';
          Navigator.popAndPushNamed(context, "/cart");
        } else {
          clearSuccessNotifications(scaffoldkey);
          showSuccessNotifications(successMessages.addedToCartMessage, context, scaffoldkey);
          if (suggestionsBoxKey != null) {
            RenderBox box = suggestionsBoxKey.currentContext.findRenderObject();
            Offset position = box.localToGlobal(Offset.zero);
            scrollController.jumpTo(position.direction + 1030);
          }
        }
      }
      // storeCartDetails.add(cachedObj);
      // cachedObj['resourceUrl'] =
    }
  }

  addOrDeleteFromFavorites(bool isAdding) {
    Map requestObj = {
      'productId': productDetails['productId']
    };
    if (productDetails['productTypeId'] != null) {
      requestObj['productTypeId'] = productDetails['productTypeId'];
    }
    if (productDetails['brandId'] != null) {
      requestObj['brandId'] = productDetails['brandId'];
    }
    if (productDetails['specificationId'] != null) {
      requestObj['specificationId'] = productDetails['specificationId'];
    }
    if (currentUnitType != null) {
      requestObj['priceId'] = int.parse(currentUnitType);
    } else if (productDetails['priceId'] != null) {
      requestObj['priceId'] = productDetails['priceId'];
    }
    setState(() {
      loadingButtonForFavorites = true;
    });
    if (isAdding) {
      Map obj = {
        'favourites': []
      };
      obj['favourites'].add(requestObj);
      productDetailsService.addProductIntoFavorites(obj).then((res) {
        final data = json.decode(res.body);
        if (data != null && data == 'SUCCESS') {
          setState(() {
            clearErrorMessages(scaffoldkey);
            clearSuccessNotifications(scaffoldkey);
            showSuccessNotifications(successMessages.addedToFavoritesSuccessMessage, context, scaffoldkey);
            favoriteProduct = true;
          });
        } else if (data != null && data == "FAILED") {
        } else if (data['error'] != null && data['error'] == "invalid_token") {
          setState(() {
            loadingButtonForFavorites = false;
          });
          refreshTokenService.getAccessTokenUsingRefreshToken().then((res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
              addOrDeleteFromFavorites(isAdding);
            }
          });
        }
        setState(() {
          loadingButtonForFavorites = false;
        });
      }, onError: (err) {
        setState(() {
          loadingButtonForFavorites = false;
        });
        ApiErros().apiErrorNotifications(err, context, '/productdetails', scaffoldkey);
      });
    } else {
      productDetailsService.deleteProductFromFavorites(requestObj).then((res) {
        final data = json.decode(res.body);
        if (data != null && data == 'SUCCESS') {
          setState(() {
            clearErrorMessages(scaffoldkey);
            clearSuccessNotifications(scaffoldkey);
            showErrorNotifications(errorMessages.removedFromFavoritesMessage, context, scaffoldkey);
            favoriteProduct = false;
          });
        } else if (data != null && data == "FAILED") {
        } else if (data['error'] != null && data['error'] == "invalid_token") {
          setState(() {
            loadingButtonForFavorites = false;
          });
          refreshTokenService.getAccessTokenUsingRefreshToken().then((res) {
            final refreshTokenData = json.decode(res.body);
            // print(data);
            if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
              addOrDeleteFromFavorites(isAdding);
            }
          });
        }
        setState(() {
          loadingButtonForFavorites = false;
        });
      }, onError: (err) {
        setState(() {
          loadingButtonForFavorites = false;
        });
        ApiErros().apiErrorNotifications(err, context, '/productdetails', scaffoldkey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && productGallery.length > 0 && productGallery[_current] != null && productGallery[_current]['resourceUrl'].indexOf('mp4') == -1) {
      _controller.forEach((videoController) {
        if (videoController['controller'] != null) {
          videoController['controller'].pause();
        }
      });
    }

    print(productDetails);
    print(priceOfCurrentProduct);

    return Scaffold(
      key: scaffoldkey,
      appBar: appBarWidgetWithIconsAnSearchboxAndFilterIcon(context, true, this.setState, false, '/productdetails', searchFieldKey, searchFieldController, searchFocusNode, scaffoldkey),
      endDrawer: showOrHideSearchAndFilter ? filterDrawer(this.setState, context, scaffoldkey, false, searchFieldController) : null,
      body: WillPopScope(
          onWillPop: onBackButtonPressed,
          // child: SingleChildScrollView(
          child: !isProductsLoading && productDetails['productName'] != null
              ? GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  // Text("example"),
                  // showSearch()
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AppStyles().customPadding(1),
                    Expanded(
                        child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                              AppStyles().customPadding(3),
                              productDetails['productName'] != null
                                  ? Container(
                                      margin: EdgeInsets.only(left: 14),
                                      alignment: Alignment.topLeft,
                                      child: Row(children: [
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: RichText(
                                                textAlign: TextAlign.start,
                                                softWrap: true,
                                                text: TextSpan(style: appFonts.getTextStyle('product_details_screen_product_name_default_styles'), children: [
                                                  productDetails['brandName'] != null ? TextSpan(text: productDetails['brandName'] + " ", style: appFonts.getTextStyle('cart_screen_brandname_style')) : TextSpan(),
                                                  TextSpan(
                                                      text: productDetails['productName'],
                                                      style: TextStyle(
                                                        color: mainAppColor,
                                                      )),
                                                  productDetails['specificationName'] != null ? TextSpan(text: " (" + productDetails['specificationName'] + ")", style: appFonts.getTextStyle('product_details_screen_product_specification_styles')) : TextSpan(),
                                                  productDetails['productTypeName'] != null ? TextSpan(text: ", " + productDetails['productTypeName'], style: appFonts.getTextStyle('product_details_screen_product_specification_styles')) : TextSpan()
                                                ]),
                                              )),
                                        ),
                                        signInDetails['access_token'] != null
                                            ? !loadingButtonForFavorites
                                                ? Expanded(
                                                    child: favoriteProduct
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                // favoriteProduct = false;
                                                                addOrDeleteFromFavorites(false);
                                                              });
                                                            },
                                                            child: Icon(
                                                              Icons.star,
                                                              color: Colors.red,
                                                            ))
                                                        : GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                // favoriteProduct = true;
                                                                addOrDeleteFromFavorites(true);
                                                              });
                                                            },
                                                            child: Icon(
                                                              Icons.star_border,
                                                            )),
                                                  )
                                                : Expanded(
                                                    child: customizedCircularLoadingIcon(25),
                                                  )
                                            : Container()
                                      ]))
                                  : Container(),
                              productDetails['gallery'] != null && productDetails['gallery']['animalGallery'] != null && productDetails['gallery']['animalGallery'].length > 0 ? AppStyles().customPadding(3) : Container(),
                              productDetails['gallery'] != null && productDetails['gallery']['animalGallery'] != null && productDetails['gallery']['animalGallery'].length > 0
                                  ? Container(
                                      margin: EdgeInsets.only(left: 14),
                                      child: Row(
                                        children: getAnimalIcons(productDetails['gallery']['animalGallery']),
                                      ))
                                  : Container(),
                              AppStyles().customPadding(5),
                              Container(
                                height: MediaQuery.of(context).size.height / 3.3,
                                child: getCarousel(),
                              ),
                              Divider(
                                thickness: 2,
                              ),

                              productInstructions['instructionData'] != null
                                  ? Container(
                                      alignment: Alignment(1, 1),
                                      padding: EdgeInsets.only(right: 18),
                                      child: InkWell(
                                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                          Text(
                                            "How To Use?",
                                            style: appFonts.getTextStyle('skip_link_style'),
                                          ),
                                        ]),
                                        onTap: () {
                                          setState(() {
                                            showOrHideInstructions = true;
                                          });
                                          if (instructionsKey != null) {
                                            RenderBox box = instructionsKey.currentContext.findRenderObject();
                                            Offset position = box.localToGlobal(Offset.zero);
                                            scrollController.jumpTo(position.dy - 100);
                                          }
                                        },
                                      ),
                                    )
                                  : Container(),
                              Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                // AppStyles().customPadding(2),
                                productDetails['discountPrice'] != null && priceOfCurrentProduct > 0
                                    ? Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(left: 14),
                                        child: Text(
                                          productDetails['appliedAgainst'] != null ? productDetails['currencyRepresentation'] + currencyFormatter.format(productDetails['discountPrice']) + ' ' + productDetails['appliedAgainst'] : productDetails['currencyRepresentation'] + currencyFormatter.format(productDetails['discountPrice']),
                                          style: appFonts.getTextStyle('product_details_price_style'),
                                          // textAlign: TextAlign.justify,
                                        ))
                                    : Container(),
                              ]),
                              AppStyles().customPadding(1),
                              priceOfCurrentProduct > 0
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        AppStyles().customPadding(7),
                                        productDetails['discountPrice'] != null && priceOfCurrentProduct > 0
                                            ? Flexible(
                                                child: Text(
                                                  "MRP:  ",
                                                  style: appFonts.getTextStyle('product_details_orginal_price_heading_style'),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : Container(),
                                        productDetails['discountPrice'] != null && priceOfCurrentProduct > 0
                                            ? Container(
                                                child: productDetails['appliedAgainst'] != null
                                                    ? Text(
                                                        productDetails['currencyRepresentation'].toString() + currencyFormatter.format(priceOfCurrentProduct) + ' ' + productDetails['appliedAgainst'],
                                                        // textAlign: TextAlign.center,
                                                        style: appFonts.getTextStyle('product_details_orginal_price_style'),
                                                      )
                                                    : Text(
                                                        productDetails['currencyRepresentation'] + currencyFormatter.format(priceOfCurrentProduct),
                                                        // textAlign: TextAlign.center,
                                                        style: appFonts.getTextStyle('product_details_orginal_price_style'),
                                                      ),
                                              )
                                            : Flexible(
                                                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                  productDetails['appliedAgainst'] != null
                                                      ? Text(
                                                          productDetails['currencyRepresentation'] + currencyFormatter.format(priceOfCurrentProduct) + ' ' + productDetails['appliedAgainst'],
                                                          style: appFonts.getTextStyle('product_details_price_style'),
                                                        )
                                                      : Text(
                                                          productDetails['currencyRepresentation'] + currencyFormatter.format(priceOfCurrentProduct),
                                                          textAlign: TextAlign.center,
                                                          style: appFonts.getTextStyle('product_details_price_style'),
                                                        ),
                                                ]),
                                              ),
                                        AppStyles().customPadding(4),
                                        productDetails['discountPrice'] != null
                                            ? Text(
                                                "Save: " + getSavedAmount(productDetails, priceOfCurrentProduct),
                                                style: appFonts.getTextStyle('product_details_discount_amount_style'),
                                              )
                                            : Container(),
                                      ],
                                    )
                                  : Container(),
                              productDetails['discountPrice'] != null && productDetails['units'] != null && productDetails['minimumQuantity'] != null
                                  ? Container(
                                      margin: EdgeInsets.only(left: 13, top: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                            flex: 1,
                                            child: Icon(
                                              Icons.info,
                                              size: 17,
                                              color: orangeColor,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 5),
                                          ),
                                          Flexible(
                                            flex: 5,
                                            child: Text(
                                              productDetails['units'] == 'Metric Ton' ? "You will get " + getSavedAmount(productDetails, priceOfCurrentProduct) + " discount on purchasing of " + (productDetails['minimumQuantity'] / 1000).toString() + " " + productDetails['units'].toString() + " or above" : "You will get " + getSavedAmount(productDetails, priceOfCurrentProduct) + " discount on purchasing of " + productDetails['minimumQuantity'].toString() + " " + productDetails['units'].toString() + " or above",
                                              style: appFonts.getTextStyle('product_details_discount_amount_note_message_style'),
                                            ),
                                          )
                                        ],
                                      ))
                                  : Container(),
                              priceOfCurrentProduct > 0 ? AppStyles().customPadding(4) : Container(),
                              priceOfCurrentProduct > 0 ? AppStyles().customPadding(6) : Container(),
                              productSizes.length > 0 && priceOfCurrentProduct > 0
                                  ? Row(children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 14,
                                        ),
                                      ),
                                      Container(
                                        // flex: 2,
                                        width: 110,
                                        child: Text(
                                          "Product Size",
                                          style: appFonts.getTextStyle('product_details_product_info_headings_style'),
                                          // textAlign: TextAlign.right,
                                        ),
                                        padding: EdgeInsets.only(right: 1),
                                      ),
                                      Container(
                                        child: Text(": "),
                                      ),
                                      Container(
                                          width: 150,
                                          height: 40,
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            items: productSizes.map((productSize) {
                                              return new DropdownMenuItem(
                                                child: new Text(
                                                  productSize['size'].toString(),
                                                  style: TextStyle(fontSize: 15.0),
                                                ),
                                                value: productSize['productId'].toString(),
                                              );
                                            }).toList(),
                                            onChanged: (newVal) {
                                              setState(() {
                                                selectedProductSize = newVal;
                                                print(selectedProductSize);
                                                if (productDetails['productId'].toString() != newVal) {
                                                  productDetailsObject['productId'] = int.parse(newVal);
                                                  fetchProductDetails(false);
                                                }
                                              });
                                            },
                                            value: selectedProductSize,
                                          ))
                                    ])
                                  : Container(),

                              productDetails['productTypeName'] != null && priceOfCurrentProduct > 0
                                  ? Row(children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 14,
                                        ),
                                      ),
                                      Container(
                                        // flex: 2,
                                        width: 110,
                                        child: Text("Product Type", style: appFonts.getTextStyle('product_details_product_info_headings_style')),
                                        padding: EdgeInsets.only(right: 6),
                                      ),
                                      Container(
                                        child: Text(": "),
                                      ),
                                      Container(
                                        child: Text(productDetails['productTypeName']),
                                      )
                                    ])
                                  : Container(),
                              priceOfCurrentProduct > 0 ? AppStyles().customPadding(2) : Container(),

                              priceOfCurrentProduct > 0 ? AppStyles().customPadding(2) : Container(),

                              priceOfCurrentProduct > 0
                                  ? Row(children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 14, top: 5),
                                      ),
                                      Container(
                                        width: 110,
                                        child: Text(
                                          "Quantity",
                                          style: appFonts.getTextStyle('product_details_product_info_headings_style'),
                                        ),
                                      ),
                                      Container(
                                        child: Text(": "),
                                      ),
                                      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Row(children: [
                                          productDetails['havingUnits'] != null && !productDetails['havingUnits']
                                              ? Container(
                                                  margin: EdgeInsets.only(right: 25),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: quantityKey.currentState != null && quantityKey.currentState.hasError ? Colors.red : Colors.grey[300], width: quantityKey.currentState != null && quantityKey.currentState.hasError ? 1 : 2),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.symmetric(vertical: 0.3),
                                                  width: 115,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: _buttonWidth,
                                                        height: _buttonWidth,
                                                        child: FlatButton(
                                                            padding: EdgeInsets.all(0),
                                                            onPressed: () {
                                                              quantityFocus.unfocus();
                                                              if (numberOfItems > 1) {
                                                                setState(() {
                                                                  numberOfItems--;
                                                                  quantityController.text = numberOfItems.toString();
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
                                                            controller: quantityController,
                                                            focusNode: quantityFocus,
                                                            key: quantityKey,
                                                            validator: (val) => GlobalValidations().quantityValidations(val.trim(), productDetails['productMinimumQuantity'] != null ? productDetails['productMinimumQuantity'].toInt() : null, productDetails['units']),
                                                            decoration: InputDecoration(isDense: true, border: InputBorder.none, counterText: "", errorStyle: appFonts.getTextStyle('hide_error_messages_for_formfields')),
                                                            // textAlignVertical: TextAlignVertical.center,
                                                            // keyboardType:
                                                            //     TextInputType.numberWithOptions(
                                                            //         decimal: true,
                                                            //         signed: false),
                                                            keyboardType: TextInputType.number,

                                                            textAlign: TextAlign.center,
                                                            onChanged: (val) {
                                                              if (val != '' && int.parse(val) != null && int.parse(val) > 0) {
                                                                setState(() {
                                                                  numberOfItems = int.parse(val);
                                                                });
                                                              } else if (val != '' && int.parse(val) != null && int.parse(val) == 0) {
                                                                setState(() {
                                                                  numberOfItems = 0;
                                                                });
                                                              }
                                                            },
                                                          )),
                                                      SizedBox(
                                                        width: _buttonWidth,
                                                        height: _buttonWidth,
                                                        child: FlatButton(
                                                          padding: EdgeInsets.all(0),
                                                          onPressed: () {
                                                            quantityFocus.unfocus();
                                                            if (numberOfItems < 9999) {
                                                              setState(() {
                                                                numberOfItems++;
                                                                quantityController.text = numberOfItems.toString();
                                                              });
                                                            }
                                                            quantityKey.currentState?.validate();
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
                                                  width: 95,
                                                  child: TextFormField(
                                                    controller: unitsController,
                                                    decoration: InputDecoration(
                                                        border: AppStyles().inputBorder,
                                                        // errorMaxLines: 3,
                                                        errorStyle: appFonts.getTextStyle('hide_error_messages_for_formfields'),
                                                        // errorText: "",
                                                        isDense: true,
                                                        focusedBorder: AppStyles().focusedInputBorder,
                                                        // labelText: pincodeLabelName + " *",
                                                        counterText: "",
                                                        contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 11)),
                                                    cursorColor: mainAppColor,
                                                    validator: (value) => GlobalValidations().quantityValidations(value.trim(), productDetails['productMinimumQuantity'] != null ? productDetails['productMinimumQuantity'].toInt() : null, productDetails['units']),
                                                    maxLength: 4,
                                                    keyboardType: TextInputType.number,
                                                    focusNode: unitsFocus,
                                                    key: unitsKey,
                                                  ),
                                                ),
                                          productDetails['havingUnits'] != null && productDetails['havingUnits']
                                              ? Container(
                                                  // color: Colors.grey,

                                                  margin: EdgeInsets.only(left: 8),

                                                  // margin: EdgeInsets.only(
                                                  //     left: 0,
                                                  //     right: MediaQuery.of(context).size.width / 4),
                                                  child: new Text(
                                                    productDetails['units'],
                                                    style: TextStyle(fontSize: 15.0),
                                                  ),
                                                )
                                              : Container(),
                                        ]),
                                        productDetails['havingUnits'] != null && !productDetails['havingUnits'] && quantityKey.currentState != null && quantityKey.currentState.hasError
                                            ? Container(
                                                padding: EdgeInsets.only(left: 0),
                                                width: MediaQuery.of(context).size.width - 135,
                                                child: Text(
                                                  quantityKey.currentState.errorText,
                                                  maxLines: 2,
                                                  style: appFonts.getTextStyle('text_color_red_style'),
                                                ),
                                              )
                                            : Container(),
                                        productDetails['havingUnits'] != null && productDetails['havingUnits'] && unitsKey.currentState != null && unitsKey.currentState.hasError
                                            ? Container(
                                                width: MediaQuery.of(context).size.width - 135,
                                                child: Text(
                                                  unitsKey.currentState.errorText,
                                                  maxLines: 2,
                                                  style: appFonts.getTextStyle('text_color_red_style'),
                                                ),
                                              )
                                            : Container(),
                                      ])
                                    ])
                                  : Container(),
                              priceOfCurrentProduct > 0 ? AppStyles().customPadding(2) : Container(),
                              priceOfCurrentProduct > 0
                                  ? new Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(left: 15),
                                        ),
                                        Container(
                                          width: 110,
                                          child: new Text(
                                            "Deliver To",
                                            style: appFonts.getTextStyle('product_details_product_info_headings_style'),
                                            textAlign: TextAlign.justify,

                                            // textAlign: TextAlign.right,
                                          ),
                                          padding: EdgeInsets.only(top: 15),
                                        ),
                                        Container(child: Text(": "), padding: EdgeInsets.only(top: 15)),
                                        Container(
                                            width: MediaQuery.of(context).size.width - 110 - 30,
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                              Row(children: [
                                                new Container(
                                                    // height: 200,
                                                    // padding: EdgeInsets.only(top: 10)
                                                    // width: 150,
                                                    width: 95,
                                                    child: TypeAheadFormField(
                                                      validator: (val) => GlobalValidations().pincodeValidations(val.trim()),
                                                      key: productPincodeKey,
                                                      hideSuggestionsOnKeyboardHide: true,
                                                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                                        elevation: 0,

                                                        // shadowColor: Colors.red,
                                                        hasScrollbar: true,
                                                      ),

                                                      // errorBuilder: ,
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        style: TextStyle(fontSize: 14),

                                                        decoration: InputDecoration(
                                                            isDense: true,
                                                            border: AppStyles().inputBorder,
                                                            errorStyle: appFonts.getTextStyle('hide_error_messages_for_formfields'),
                                                            // errorText: "",
                                                            focusedBorder: AppStyles().focusedInputBorder,
                                                            labelText: pincodeLabelName,
                                                            counterText: "",
                                                            contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 12)),
                                                        controller: productPincodeController,
                                                        cursorColor: mainAppColor,
                                                        // validator: (val) => GlobalValidations()
                                                        //     .pincodeValidations(val.trim()),
                                                        maxLength: 6,

                                                        keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                                                        onChanged: (val) {
                                                          // print('changedValue');
                                                          setState(() {
                                                            if (val.trim().length >= 3) {
                                                              getPinCodeDetails(val);
                                                              // print(pincodeAvailabilities);
                                                            } else {
                                                              // print('no value');
                                                            }
                                                          });
                                                        },
                                                        focusNode: productPincodeFocus,
                                                        // key: productPincodeKey,
                                                      ),
                                                      // hideOnEmpty: true,

                                                      suggestionsCallback: (pattern) {
                                                        // RenderBox box = instructionsKey
                                                        //     .currentContext
                                                        //     .findRenderObject();
                                                        // Offset position =
                                                        //     box.localToGlobal(Offset.zero);

                                                        if (pattern.trim().length > 3 && pincodeAvailabilities.length > 0)
                                                          return pincodeAvailabilities;
                                                        else
                                                          return null;
                                                      },
                                                      itemBuilder: (context, suggestion) {
                                                        return ListTile(
                                                          title: Text(suggestion.toString()),
                                                        );
                                                      },
                                                      transitionBuilder: (context, suggestionsBox, controller) {
                                                        return suggestionsBox;
                                                      },
                                                      onSuggestionSelected: (suggestion) {
                                                        this.productPincodeController.text = suggestion.toString();
                                                      },
                                                      autoFlipDirection: false,

                                                      // validator: (value) {
                                                      //   if (value.isEmpty) {
                                                      //     return 'Please select a city';
                                                      //   }
                                                      // },
                                                    )
                                                    //flexible
                                                    ),
                                                AppStyles().customPadding(4),
                                                new Container(
                                                  // padding: EdgeInsets.only(top: 10),
                                                  // width: 128.0,
                                                  // height: 28.0,
                                                  child: RaisedButton(
                                                    // color: Colors.orange,
                                                    // shape: new RoundedRectangleBorder(
                                                    // side: BorderSide(color: Colors.red),

                                                    //   borderRadius:
                                                    //       new BorderRadius.circular(30.0),
                                                    // ),

                                                    // color:
                                                    //     pincodeIsAvailble ? Colors.green : Colors.blue,
                                                    onPressed: () {
                                                      // Map userDetails = {
                                                      //   'pincode': productPincodeController.text.trim()
                                                      // };
                                                      // print(pincodeIsAvailble);
                                                      // productPincodeKey.currentState
                                                      //     .validate();
                                                      String pincode = productPincodeController.text.trim();
                                                      setState(() {
                                                        if (productPincodeKey.currentState != null && !productPincodeKey.currentState.hasError && productPincodeKey.currentState.validate()) {
                                                          if (productDetails['havingUnits'] != null && productDetails['havingUnits'] && unitsKey.currentState.validate() && int.parse(unitsController.text.trim()) > 0) {
                                                            checkPincode(pincode, false, false);
                                                          } else if (productDetails['havingUnits'] != null && !productDetails['havingUnits'] && quantityKey.currentState.validate() && int.parse(quantityController.text.trim()) > 0) {
                                                            checkPincode(pincode, false, false);
                                                          }
                                                        }
                                                      });
                                                      //  if (productPincodeKey.currentState !=
                                                      //         null &&
                                                      //     !productPincodeKey
                                                      //         .currentState.hasError &&
                                                      //     productPincodeKey.currentState
                                                      //         .validate()) {
                                                      //   checkPincode(pincode, false, false);
                                                      // }
                                                      FocusScope.of(context).unfocus();
                                                    },
                                                    // color: mainAppColor,
                                                    // shape: ,
                                                    // clipBehavior: Clip.antiAlias,

                                                    child: Text("Check", style: TextStyle(color: Colors.black, fontSize: 15.0)),
                                                  ),
                                                ),
                                              ]),
                                              productPincodeKey.currentState != null && !productPincodeKey.currentState.hasError
                                                  ? Container(
                                                      width: 220,
                                                      child: Text(
                                                        stockPointAvailabilityCheck,
                                                        textAlign: TextAlign.start,
                                                        // softWrap: true,
                                                        maxLines: 4,
                                                        style: TextStyle(
                                                          color: stockPointAvailabilityCheck != ''
                                                              ? pincodeIsAvailble
                                                                  ? mainAppColor
                                                                  : Colors.red
                                                              : null,
                                                        ),
                                                      ))
                                                  : Container(),
                                              productPincodeKey.currentState != null && productPincodeKey.currentState.hasError
                                                  ? Text(
                                                      productPincodeKey.currentState.errorText,
                                                      maxLines: 4,
                                                      style: appFonts.getTextStyle('text_color_red_style'),
                                                    )
                                                  : Container(),
                                            ])), //container
                                      ], //widget
                                    )
                                  : Container(),
                              priceOfCurrentProduct > 0 ? AppStyles().customPadding(3) : Container(),
                              priceOfCurrentProduct <= 0
                                  ? Row(
                                      children: [
                                        AppStyles().customPadding(7),
                                        Text(
                                          "Coming Soon",
                                          style: AppFonts().getTextStyle('product_list_price_style'),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              // ),
                              productDetails['productDescription'] != null
                                  ? Divider(
                                      thickness: 3,
                                    )
                                  : Container(),
                              // AppStyles().customPadding(2),
                              productDetails['productDescription'] != null
                                  ? Container(
                                      margin: EdgeInsets.only(left: 14, right: 12),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                        Text(
                                          'Product Description',
                                          style: appFonts.getTextStyle('product_details_headings_style'),
                                        ),
                                        AppStyles().customPadding(2),

                                        // showMoreOrLess
                                        //     ?
                                        Column(children: [
                                          Text(
                                            productDetails['productDescription'].toString(),
                                            textAlign: TextAlign.justify,
                                            // textScaleFactor: 1,
                                            style: appFonts.getTextStyle('product_details_content_styles'),
                                            // maxLines: 2,
                                          ),

                                          // InkWell(
                                          //   child: Row(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.end,
                                          //       children: [
                                          //         Icon(
                                          //           Icons.expand_less,
                                          //           size: 30,
                                          //         )
                                          //       ]),
                                          //   onTap: () {
                                          //     setState(() {
                                          //       showMoreOrLess = false;
                                          //     });
                                          //   },
                                          // )
                                        ])
                                        //       : Column(
                                        //           crossAxisAlignment:
                                        //               CrossAxisAlignment.start,
                                        //           children: [
                                        //             Text(productDetails[
                                        //                             'productDescription']
                                        //                         .toString()
                                        //                         .substring(0, 50) +
                                        //                     '....'
                                        //                 // maxLines: 2,
                                        //                 ),
                                        //             InkWell(
                                        //               child: Row(
                                        //                   mainAxisAlignment:
                                        //                       MainAxisAlignment.end,
                                        //                   children: [
                                        //                     Icon(
                                        //                       Icons.expand_more,
                                        //                       size: 28,
                                        //                     )
                                        //                   ]),
                                        //               onTap: () {
                                        //                 setState(() {
                                        //                   showMoreOrLess = true;
                                        //                 });
                                        //               },
                                        //             )
                                        //           ],
                                        //         ),
                                        //   // AppStyles().customPadding(40)
                                        // ]))
                                      ]))
                                  : Container(),

                              // ),
                              // AppStyles().customPadding(5),

                              (productInstructions['instructionData'] != null) || (productInstructions['instructionGallery'] != null && productInstructions['instructionGallery'].length > 0)
                                  ? Divider(
                                      thickness: 3,
                                    )
                                  : Container(),

                              Container(
                                  key: instructionsKey,
                                  margin: EdgeInsets.only(left: 14, right: 12),
                                  child: productInstructions['instructionData'] != null
                                      ? Column(children: [
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Instructions",
                                                style: appFonts.getTextStyle('product_details_headings_style'),
                                              )),
                                          Container(
                                            child: Text(
                                              productInstructions['instructionData'],
                                              textAlign: TextAlign.justify,
                                              style: appFonts.getTextStyle('product_details_content_styles'),
                                            ),
                                          ),
                                        ])
                                      : Container()),
                              productInstructions['instructionGallery'] != null && productInstructions['instructionGallery'].length > 0
                                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      productInstructions['instructionData'] == null
                                          ? Container(
                                              margin: EdgeInsets.only(left: 14, right: 12),
                                              child: Text(
                                                "Instructions",
                                                style: appFonts.getTextStyle('product_details_headings_style'),
                                              ))
                                          : Container(),
                                      Container(
                                        height: MediaQuery.of(context).size.height / 3.3,
                                        margin: EdgeInsets.only(top: 10),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(5), child: getInstructionsOrTestimonialImages(productInstructions['instructionGallery'], false)),
                                      )
                                    ])
                                  : Container(),
                              (productDetails['testimonialDescription'] != null) || (productDetails['gallery'] != null && productDetails['gallery']['testimonialGallery'] != null && productDetails['gallery']['testimonialGallery'].length > 0) ? Divider(thickness: 3) : Container(),
                              productDetails['testimonialDescription'] != null
                                  ? Container(
                                      margin: EdgeInsets.only(top: 1, left: 15, right: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Testimonials",
                                            style: appFonts.getTextStyle('product_details_headings_style'),
                                          ),
                                          Text(
                                            productDetails['testimonialDescription'],
                                            textAlign: TextAlign.justify,
                                            // overflow: 2,
                                            style: appFonts.getTextStyle('product_details_content_styles'),
                                          ),
                                        ],
                                      ))
                                  : Container(),
                              productDetails['gallery'] != null && productDetails['gallery']['testimonialGallery'] != null && productDetails['gallery']['testimonialGallery'].length > 0
                                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                      productDetails['testimonialDescription'] == null
                                          ? Container(
                                              margin: EdgeInsets.only(top: 1, left: 15, right: 15),
                                              child: Text(
                                                "Testimonials",
                                                style: appFonts.getTextStyle('product_details_headings_style'),
                                              ))
                                          : Container(),
                                      Container(
                                        height: MediaQuery.of(context).size.height / 3.3,
                                        margin: EdgeInsets.only(top: 10),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: getInstructionsOrTestimonialImages(productDetails['gallery']['testimonialGallery'], true)),
                                      )
                                    ])
                                  : Container(),
                              Divider(
                                thickness: 3,
                              ),

                              // : Container(),

                              // AppStyles().customPadding(1),
                              Row(children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 14),
                                ),
                                Flexible(
                                  // flex: 2,
                                  child: Text(
                                    "Suggestions",
                                    style: appFonts.getTextStyle('product_details_headings_style'),
                                  ),
                                ),

                                // showProductDetails(productDetails, state,
                                //     productShowMoreOrLess, scrollPhysics, shrinkable)
                              ]),
                              AppStyles().customPadding(2),
                              Container(
                                  // constraints: BoxConstraints(minHeight: 300),
                                  key: suggestionsBoxKey,
                                  margin: EdgeInsets.only(left: 12, right: 12),
                                  height: 345,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(children: [
                                    Expanded(
                                        // constraints: BoxConstraints(minHeight: 300),
                                        // height: 298,
                                        child: showSuggestionsForProduct(productSuggestions, this.setState, suggestionsScroll)),
                                    isMoreSuggestionsLoading
                                        ? Container(
                                            height: 298,
                                            margin: EdgeInsets.only(top: 5),
                                            child: Center(
                                              child: customizedCircularLoadingIcon(30),
                                            ),
                                          )
                                        : Container(),
                                  ])),

                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              )
                            ])))
                  ]))
              // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              : Center(
                  child: circularLoadingIcon(),
                )),
      bottomNavigationBar: Row(
        children: <Widget>[
          Container(
              // alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              height: priceOfCurrentProduct > 0 ? 50.0 : 1,
              child: priceOfCurrentProduct > 0
                  ? Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        !loadingIconForFloatingButtons
                            ? Expanded(
                                // fit: FlexFit.loose,
                                flex: 2,
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      addProductIntoCart(false);
                                      // Navigator.pushNamed(context, '/cart');
                                    });
                                  },
                                  color: mainYellowColor,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          "Add To Cart",
                                          style: appFonts.getTextStyle('button_text_color_black'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                flex: 2,
                                child: RaisedButton(
                                  onPressed: () {},
                                  color: Colors.grey,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        customizedCircularLoadingIconWithColorAndSize(25, Colors.white),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          "Loading",
                                          style: appFonts.getTextStyle('button_text_color_white'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        !loadingButtonForProceedToCart
                            ? Expanded(
                                flex: 2,
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      addProductIntoCart(true);
                                    });
                                  },
                                  color: Colors.green,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          "Buy Now",
                                          style: appFonts.getTextStyle('button_text_color_white'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                flex: 2,
                                child: RaisedButton(
                                  onPressed: () {},
                                  color: Colors.grey,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        customizedCircularLoadingIconWithColorAndSize(25, Colors.white),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          "Loading",
                                          style: appFonts.getTextStyle('button_text_color_white'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    )
                  : Container()),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
