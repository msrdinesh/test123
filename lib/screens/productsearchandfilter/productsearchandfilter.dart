import 'package:flutter/material.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
// import 'package:cornext_mobile/services/baseService/baseservice.dart';
import 'dart:convert';
// import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
// import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
// import 'package:cornext_mobile/models/signinmodel.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
// import 'package:carousel_pro/carousel_pro.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:badges/badges.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

class ProductSearchAndFilterPage extends StatefulWidget {
  @override
  ProductSearchAndFilter createState() => ProductSearchAndFilter();
}

class ProductSearchAndFilter extends State<ProductSearchAndFilterPage> {
  final scafflodkey = GlobalKey<ScaffoldState>();
  bool productDetailsLoading = false;
  List productShowMoreOrLess = [];
  List productDetails = [];
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  final ErrorMessages errorMessages = ErrorMessages();
  final ScrollController scrollController = ScrollController();
  int limit = 15;
  int pageNo = 1;
  int totalNumberOfProducts = 0;
  bool isMoreProductsLoading = false;
  List subCategoriesForDisplay = [];
  bool isFilterScreenOpened = false;
  final AppFonts appFonts = AppFonts();

  @override
  void initState() {
    super.initState();
    setState(() {
      searchFieldController.text = productSearchData['productSearchData'];
    });
    fetchProductListDetails(false);
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
    setState(() {
      subCategoriesForDisplay = [];
    });

    Map requestObj = {
      "pageNumber": pageNo,
      "limit": limit,
      "screenName": "HS"
    };

    if (productSearchData['productSearchData'] != '') {
      requestObj['productSearchData'] = productSearchData['productSearchData'];
    } else {
      requestObj['productSearchData'] = "";
    }
    if (productSearchData['productCategory'] != null && productSearchData['productCategory'].length > 0) {
      requestObj['userId'] = checkFavorites() ? signInDetails['userId'] : null;
      requestObj['productCategory'] = productSearchData['productCategory'];
    }

    if (requestObj['productCategory'] != null && requestObj['productCategory'].length > 0) {
      getSubCategoriesBasedOnCategories(requestObj['productCategory']);
    }

    print(requestObj);

    // if (signInDeatils['access_token'] != null) {
    //   HomeScreenServices().getProductListDetailsAfterLogin(requestObj).then(
    //       (val) {
    //     final data = json.decode(val.body);
    //     print(data);
    //     if (data['listOfProducts'] != null) {
    //       // if(data['listOfProducts'])
    //       // showProductDetailsInfo();
    //       setState(() {
    //         if (!isMoreData) {
    //           productDetails = data['listOfProducts'];
    //         } else {
    //           data['listOfProducts'].forEach((val) {
    //             productDetails.add(val);
    //           });
    //         }
    //         print(data['productCount']);
    //         totalNumberOfProducts = data['productCount'];
    //         setState(() {});
    //         setState(() {
    //           initializeShowMoreOrLessBooleans();
    //           showProductDetails(
    //             productDetails,
    //             this.setState,
    //             productShowMoreOrLess,
    //             AlwaysScrollableScrollPhysics(),
    //             false,
    //             context,
    //             '/search',
    //           );
    //         });

    //         scrollController.addListener(() {
    //           if (totalNumberOfProducts > productDetails.length &&
    //               !isMoreProductsLoading &&
    //               scrollController.position.pixels ==
    //                   scrollController.position.maxScrollExtent) {
    //             pageNo = pageNo + 1;
    //             fetchProductListDetails(true);
    //           }
    //         });
    //       });
    //     }
    //     setState(() {
    //       productDetailsLoading = false;
    //       isMoreProductsLoading = false;
    //     });
    //   }, onError: (err) {
    //     ApiErros().apiErrorNotifications(err, context, '/search');
    //     setState(() {
    //       productDetailsLoading = false;
    //       isMoreProductsLoading = false;
    //     });
    //   });
    // } else {
    HomeScreenServices().getProductListDetails(requestObj).then((val) {
      // print(val.body);
      final data = json.decode(val.body);
      if (data['listOfProducts'] != null) {
        // if(data['listOfProducts'])
        // showProductDetailsInfo();
        setState(() {
          if (!isMoreData) {
            productDetails = data['listOfProducts'];
          } else {
            data['listOfProducts'].forEach((val) {
              productDetails.add(val);
            });
          }
          totalNumberOfProducts = data['productCount'];
          setState(() {});
          setState(() {
            initializeShowMoreOrLessBooleans();
            showProductDetails(productDetails, this.setState, productShowMoreOrLess, AlwaysScrollableScrollPhysics(), false, context, '/search');
          });
          scrollController.addListener(() {
            if (totalNumberOfProducts > productDetails.length && !isMoreProductsLoading && scrollController.position.pixels == scrollController.position.maxScrollExtent) {
              pageNo = pageNo + 1;
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
      ApiErros().apiErrorNotifications(err, context, '/search', scafflodkey);
      setState(() {
        productDetailsLoading = false;
        isMoreProductsLoading = false;
      });
    });
    // }
  }

  checkFavorites() {
    bool isFavorites = false;
    productSearchData['productCategory'].toList().forEach((val) {
      // if(val[''])
      int index = filterProducts.indexWhere((res) => res['categoryId'] == val['categoryId']);
      if (filterProducts[index]['categoryName'] == "Favorites") {
        isFavorites = true;
        productSearchData['productCategory'].removeAt(productSearchData['productCategory'].indexOf(val));
      }
    });
    print(isFavorites);
    return isFavorites;
  }

  initializeShowMoreOrLessBooleans() {
    productDetails.forEach((val) {
      setState(() {
        productShowMoreOrLess.add(false);
      });
    });
  }

  getSearchedData() {
    // if (searchFieldController.text.trim() != '') {
    //   productSearchData['productSearchData'] =
    //       searchFieldController.text.trim();
    //   List filterProductsData = [];
    //   filterProducts.forEach((val) {
    //     if (val['isSelected']) {
    //       Map obj = {'productCategoryId': val['productCategoryId']};
    //       filterProductsData.add(obj);
    //     }
    //   });
    //   if (filterProductsData.length > 0) {
    //     productSearchData['productCategoryInfo'] = filterProductsData;
    //   }
    //   fetchProductListDetails();
    // } else {
    applyFilter(false);
    // }
  }

  applyFilter(bool isApplyFilterBtnClicked) {
    setState(() {
      productSearchData['productCategory'] = [];
      subCategoriesList.forEach((val) {
        val['manualSelection'] = false;
      });
    });
    List filterProductsData = getSelectedCategoryInfo();
    if (searchFieldController.text.trim() != '') {
      productSearchData['productSearchData'] = searchFieldController.text.trim();
    } else {
      productSearchData['productSearchData'] = "";
      // searchFieldController.text.trim();
    }
    // bool isFavorites = false;
    // filterProducts.forEach((val) {
    //   if (val['isSelected']) {
    //     if (val['filterData'] == 'Favorites') {
    //       isFavorites = true;
    //     } else {
    //       Map obj = {'productCategoryId': val['productCategoryId']};
    //       filterProductsData.add(obj);
    //     }
    //   }
    // });
    // print(filterProductsData);
    // if (filterProductsData.length > 0 ||
    //     searchFieldController.text.trim() != '' ||
    //     isApplyFilterBtnClicked) {
    productSearchData['productCategory'] = filterProductsData;
    // print(productSearchData);
    // productSearchData['isFavorites'] = isFavorites;
    if (isApplyFilterBtnClicked) {
      Navigator.pop(context);
      isFilterScreenOpened = false;
    }
    pageNo = 1;
    setState(() {});
    fetchProductListDetails(false);
    // }
  }

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
    if (!isFilterScreenOpened) {
      clearFilterData(this.setState);
      productSearchData['productSearchData'] = "";
      productSearchData['productCategory'] = [];
    } else {
      setState(() {
        isFilterScreenOpened = false;
      });
    }
    return true;
  }

  List getSubCategoriesUsingCategoryInfo(String categoryName) {
    List returnList = [];
    subCategoriesList.forEach((val) {
      if (val['path'].toString().startsWith(categoryName)) {
        returnList.add(val);
      }
    });
    return returnList;
  }

  List getSelectedCategoryInfo() {
    List selectedCategories = [];
    filterProducts.forEach((val) {
      if (val['isSelected']) {
        Map obj = {
          'categoryId': val['categoryId']
        };
        if (val['subCategories'] != null) {
          List subCategoriesOfCurrentCategory = getSelectedSubCategoriesOfCurrentCategory(val['categoryName']);
          if (subCategoriesOfCurrentCategory.length > 0) {
            obj['subCategories'] = subCategoriesOfCurrentCategory;
          }
          // Uncomment this to highlight subcategories
          // else {
          //   setSubCategoriesOnSelectionOfCategory(val['categoryName']);
          //   List subCategoriesOfCurrentCategory =
          //       getSelectedSubCategoriesOfCurrentCategory(val['categoryName']);
          //   obj['subCategories'] = subCategoriesOfCurrentCategory;
          // }
          // upto here
        }
        selectedCategories.add(obj);
      }
    });
    return selectedCategories;
  }

  List getSelectedSubCategoriesOfCurrentCategory(String categoryName) {
    List selectedSubCategories = [];
    subCategoriesList.forEach((val) {
      if (val['path'].toString().indexOf(categoryName) != -1) {
        if (val['isChecked']) {
          Map obj = {
            'subCategoryId': val['subCategoryId']
          };
          selectedSubCategories.add(obj);
        }
      }
    });
    return selectedSubCategories;
  }

  setSubCategoriesOnSelectionOfCategory(String categoryName) {
    subCategoriesList.forEach((val) {
      if (val['path'].toString().startsWith(categoryName) && !val['manualSelection']) {
        val['isChecked'] = true;
      }
    });
  }

  Widget displaySubCategoriesUsingCategoryInfo(bool isChecked, String categoryName) {
    List subCategories = getSubCategoriesUsingCategory(categoryName);
    return ListView.builder(
        itemCount: subCategories.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(children: <Widget>[
                Container(
                    height: 40,
                    child: CheckboxListTile(
                      value: subCategories[index]['isChecked'],
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: mainAppColor,
                      onChanged: (val) {
                        setState(() {
                          subCategories[index]['isChecked'] = val;
                        });
                        // if (filterProducts[index]['subCategories'] != null) {
                        //   displaySubCategoriesUsingCategory(
                        //       filterProducts[index]['subCategories']);
                        // }
                      },
                      title: Text(subCategories[index]['subCategoryName']),
                    )),
              ]));
        });
  }

  getSubCategoriesBasedOnCategories(List categoryList) {
    filterProducts.forEach((obj) {
      if (obj['categoryId'] != null && categoryList.indexWhere((val) => val['categoryId'] == obj['categoryId']) != -1) {
        List currentSubCategories = getSubCategoriesUsingCategory(obj['categoryName']);
        setState(() {
          currentSubCategories.forEach((val) {
            subCategoriesForDisplay.add(val);
          });
        });
      }
    });
  }

  List<Widget> displaySubCategories() {
    return subCategoriesForDisplay.map((res) {
      return GestureDetector(
          onTap: () {
            getProductDetailsUsingSubCategories(res);
          },
          child: Container(
              width: MediaQuery.of(context).size.width / 4.2,
              margin: EdgeInsets.only(left: 1, right: 1),
              child: Column(
                children: <Widget>[
                  Container(
                      child: res['resourceUrl'] != null
                          ?
                          // res['isChecked'] != null && !res['isChecked']
                          //     ?
                          Container(
                              decoration: BoxDecoration(border: res['isChecked'] != null && res['isChecked'] ? Border.all(color: mainAppColor, width: 2) : Border.all(color: Colors.white, width: 0), borderRadius: new BorderRadius.all(Radius.circular(50.0)), boxShadow: [
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
                                  )))
                          // : Card(
                          //     child: CachedNetworkImage(
                          //       imageUrl: res['resourceUrl'],
                          //       fit: BoxFit.fill,
                          //       height: 50,
                          //       width: 50,
                          //     ),
                          //     // elevation: 5.0,
                          //     shape: CircleBorder(
                          //         side: BorderSide(
                          //             color: mainAppColor, width: 2)),
                          //     clipBehavior: Clip.antiAlias,
                          //   )
                          : Container()),
                  AppStyles().customPadding(1),
                  Container(
                    child: splitAndDisplay(res["subCategoryName"], res['isChecked']),
                  )
                ],
              )));
    }).toList();
  }

  Widget splitAndDisplay(String subCategoryName, bool isCheked) {
    if (subCategoryName.contains(" ")) {
      //Assuming Category Name will be only 2 words
      List<String> _splitNames = subCategoryName.split(" ");
      List<Widget> _widgets = [];
      _splitNames.forEach((res) {
        _widgets.add(Text(
          res,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: isCheked != null && isCheked ? FontWeight.w700 : FontWeight.normal),
        ));
      });
      return Column(
        children: _widgets,
      );
    } else {
      return Text(
        subCategoryName,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, fontWeight: isCheked != null && isCheked ? FontWeight.w700 : FontWeight.normal),
      );
    }
  }

  getProductDetailsUsingSubCategories(Map currentSubCategory) {
    print(currentSubCategory);
    print(subCategoriesList);
    setState(() {
      subCategoriesList.forEach((val) {
        if (val['subCategoryId'] == currentSubCategory['subCategoryId']) {
          if (val['isChecked']) {
            val['isChecked'] = false;
            val['manualSelection'] = true;
          } else {
            val['isChecked'] = true;
            val['manualSelection'] = false;
          }
        }
      });
      productDetails = [];
      productSearchData['productCategory'] = [];
      List filterProductsData = getSelectedCategoryInfo();
      if (searchFieldController.text.trim() != '') {
        productSearchData['productSearchData'] = searchFieldController.text.trim();
      } else {
        productSearchData['productSearchData'] = "";
        // searchFieldController.text.trim();
      }
      productSearchData['productCategory'] = filterProductsData;
    });
    fetchProductListDetails(false);
  }

  Widget appBarWidgetForSearchScreen(context, bool showSearchIcon, state, bool isCartPage, String previousRouteName, GlobalKey<FormFieldState> searchFieldKey, TextEditingController searchFieldController, FocusNode searchFocusNode, GlobalKey<ScaffoldState> scaffoldkey) {
    return AppBar(
      // elevation: 100,
      centerTitle: true,
      // title: Row(mainAxisAlignment: MainAxisAlignment.center,
      //     // crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Image(
      //         image: AssetImage(cornextLogoPath),
      //         height: 30,
      //       ),
      //       Text(
      //         headerName,
      //         style: TextStyle(
      //             fontSize: 23,
      //             fontWeight: FontWeight.bold,
      //             fontFamily: "Arial",
      //             wordSpacing: 1.2),
      //       )
      //     ]),
      // title: Column(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   mainAxisSize: MainAxisSize.max,
      //   children: <Widget>[
      //     Image(
      //       image: AssetImage(cornextLogoImagePath),
      //       height: 50,
      //       // fit: BoxFit.fitHeight,
      //     ),
      //   ],
      // ),
      // backgroundColor: Colors.white,
      title: GestureDetector(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'));
        },
        child: Image(
          image: AssetImage(cornextLogoImagePath2),
          fit: BoxFit.cover,
          width: 100,
        ),
      ),

      backgroundColor: mainAppColor,
      brightness: Brightness.dark,
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 35),
        child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(bottom: 4, left: 10, right: 7, top: 0),
            height: 35,
            child: Row(children: [
              Container(
                  // flex: 3,
                  width: MediaQuery.of(context).size.width - 117,
                  child: TextFormField(
                      cursorColor: mainAppColor,
                      controller: searchFieldController,
                      onFieldSubmitted: (val) {
                        getSearchedData();
                      },
                      key: searchFieldKey,
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                          counterText: "",
                          fillColor: Colors.white,
                          filled: true,
                          // alignLabelWithHint: true,
                          hintText: "Search",
                          hintStyle: AppFonts().getTextStyle('hint_style'),
                          border: AppStyles().searchBarBorder,
                          // prefix: Text("+91 "),
                          contentPadding: EdgeInsets.fromLTRB(14, 0, 0, 0),
                          focusedBorder: AppStyles().focusedSearchBorder,
                          suffixIcon: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(Icons.search),
                            onPressed: () {
                              getSearchedData();
                            },
                            color: mainAppColor,
                            tooltip: 'Search',
                            // iconSize: 24,
                          )))),
              Padding(padding: EdgeInsets.only(left: 7)),
              Container(
                width: 87,
                child: RaisedButton(
                  color: mainYellowColor,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.tune,
                        size: 18,
                        color: Colors.black,
                      ),
                      Text(
                        "Filter",
                        style: appFonts.getTextStyle('button_text_color_black'),
                      )
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      isFilterScreenOpened = true;
                    });
                    scaffoldkey.currentState.openEndDrawer();
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 5)),

              // Expanded(
              //     child: IconButton(
              //   padding: EdgeInsets.all(0),
              //   icon: Icon(Icons.filter_list),
              //   onPressed: () {
              //     scaffoldkey.currentState.openEndDrawer();
              //   },
              //   color: mainAppColor,

              //   tooltip: 'Filter',
              //   // iconSize: 14,
              // )),
              // child: FlatButton.icon(
              //   icon: Icon(Icons.filter_list),
              //   onPressed: () {},
              //   label: Text("Filter"),
              // ),
              // )
            ])),
      ),
      actions: <Widget>[
        showSearchIcon
            ? IconButton(
                padding: EdgeInsets.only(bottom: 5, left: 8, top: 10),
                icon: Icon(Icons.search),
                color: Colors.white,
                iconSize: 28,
                onPressed: () {
                  state(() {
                    showOrHideSearchAndFilter = !showOrHideSearchAndFilter;
                  });
                },
              )
            : Container(),
        noOfProductsAddedInCart != null && noOfProductsAddedInCart != 0
            ? Badge(
                // badgeColor: Colors.red[700],
                position: BadgePosition(top: 1.2),
                badgeContent: Text(
                  noOfProductsAddedInCart.toString(),
                  // "100",
                  style: appFonts.getTextStyle('cart_badge_content_color'),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: mainYellowColor,
                  ),
                  padding: EdgeInsets.only(top: 4, right: 8),
                  onPressed: () {
                    showOrHideSearchAndFilter = false;
                    // if (successFlushBar != null ||
                    //     errorFlushBar != null ||
                    //     flushBar != null) {
                    //   clearErrorMessages();
                    //   clearSuccessNotifications();
                    //   closeNotifications();
                    //   successFlushBar = null;
                    //   errorFlushBar = null;
                    //   flushBar = null;
                    // }
                    if (!isCartPage) {
                      previousRouteNameFromCart = '';
                      previousRouteNameFromCart = previousRouteName;
                      Navigator.popAndPushNamed(context, '/cart');
                    } else {
                      Navigator.popAndPushNamed(context, '/cart');
                    }
                  },
                  iconSize: 28,
                  // color: Colors.white,
                ))
            : IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: mainYellowColor,
                ),
                padding: EdgeInsets.only(right: 8),
                onPressed: () {
                  showOrHideSearchAndFilter = false;
                  // if (successFlushBar != null ||
                  //     errorFlushBar != null ||
                  //     flushBar != null) {
                  //   clearErrorMessages();
                  //   clearSuccessNotifications();
                  //   closeNotifications();
                  //   successFlushBar = null;
                  //   errorFlushBar = null;
                  //   flushBar = null;
                  // }
                  if (!isCartPage) {
                    previousRouteNameFromCart = '';
                    previousRouteNameFromCart = previousRouteName;
                    Navigator.popAndPushNamed(context, '/cart');
                  } else {
                    Navigator.popAndPushNamed(context, '/cart');
                  }
                },
                iconSize: 28,
                // color: Colors.white,
              ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onBackButtonPressed,
        child: Scaffold(
          key: scafflodkey,
          appBar: appBarWidgetForSearchScreen(context, false, this.setState, false, '/search', searchFieldKey, searchFieldController, searchFocusNode, scafflodkey),
          endDrawer: Drawer(
              child: Column(children: [
            AppStyles().customPadding(10),
            // Align(
            //   alignment: Alignment.topRight,
            //   child: RaisedButton(
            //     onPressed: () {
            //       clearFilterData(this.setState);
            //     },
            //     child: Text("Clear"),
            //   ),
            // ),
            Expanded(
                child: ListView.builder(
                    itemCount: filterProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          child: Column(
                        children: <Widget>[
                          Container(
                              height: 40,
                              child: CheckboxListTile(
                                value: filterProducts[index]['isSelected'],
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: mainAppColor,
                                onChanged: (val) {
                                  setState(() {
                                    filterProducts[index]['isSelected'] = val;
                                  });
                                  // if (filterProducts[index]['subCategories'] != null) {
                                  //   displaySubCategoriesUsingCategory(
                                  //       filterProducts[index]['subCategories']);
                                  // }
                                },
                                title: Text(filterProducts[index]['categoryName']),
                              )),
                          filterProducts[index]['subCategories'] != null && filterProducts[index]['isSelected']
                              ? displaySubCategoriesUsingCategoryInfo(
                                  filterProducts[index]['isSelected'],
                                  filterProducts[index]['categoryName'],
                                )
                              : Container()
                        ],
                      ));
                    })),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: RaisedButton(
            //     onPressed: () {
            //       applyFilter(true);
            //     },
            //     child: Text(
            //       "Apply",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //     color: mainAppColor,
            //   ),
            // )
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                // alignment: Alignment.topRight,
                margin: EdgeInsets.only(right: 8),
                child: RaisedButton(
                  onPressed: () {
                    clearFilterData(this.setState);
                  },
                  child: Text("Clear"),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                // alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: () {
                    applyFilter(true);
                  },
                  child: Text(
                    "Apply",
                    style: appFonts.getTextStyle('button_text_color_white'),
                  ),
                  color: mainAppColor,
                ),
              )
            ])
          ])),
          body: !productDetailsLoading
              ? GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Column(children: [
                    // Text("example"),
                    // showSearch()
                    AppStyles().customPadding(1),
                    // Container(
                    //     margin: EdgeInsets.only(
                    //       top: 2,
                    //       left: 10,
                    //     ),
                    //     height: 40,
                    //     child: Row(children: [
                    //       Expanded(
                    //           flex: 3,
                    //           child: TextFormField(
                    //               cursorColor: mainAppColor,
                    //               controller: searchFieldController,
                    //               key: searchFieldKey,
                    //               focusNode: searchFocusNode,
                    //               onFieldSubmitted: (val) {
                    //                 getSearchedData();
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
                    //                       getSearchedData();
                    //                     },
                    //                     color: mainAppColor,
                    //                     tooltip: 'Search',
                    //                     // iconSize: 24,
                    //                   )))),
                    //       Padding(padding: EdgeInsets.only(left: 3)),
                    //       Expanded(
                    //         child: RaisedButton(
                    //           color: mainYellowColor,
                    //           child: Row(
                    //             children: <Widget>[
                    //               Icon(
                    //                 Icons.tune,
                    //                 size: 18,
                    //                 // color: ,
                    //               ),
                    //               Text(
                    //                 "Filter",
                    //                 // style: TextStyle(color: mainYellowColor),
                    //               )
                    //             ],
                    //           ),
                    //           onPressed: () {
                    //             setState(() {
                    //               isFilterScreenOpened = true;
                    //             });
                    //             scafflodkey.currentState.openEndDrawer();
                    //           },
                    //         ),
                    //       ),
                    //       Padding(padding: EdgeInsets.only(right: 5)),
                    //       //      RaisedButton.icon(
                    //       //   onPressed: () {
                    //       //     scafflodkey.currentState.openEndDrawer();
                    //       //   },
                    //       //   label: Text(
                    //       //     "filter",
                    //       //     softWrap: true,
                    //       //     style: TextStyle(fontSize: 15),
                    //       //   ),
                    //       //   icon: Icon(
                    //       //     Icons.tune,
                    //       //     size: 15,
                    //       //   ),
                    //       // )
                    //       //  IconButton(
                    //       //   padding: EdgeInsets.all(0),
                    //       //   icon: Icon(Icons.filter_list),
                    //       //   onPressed: () {
                    //       //     scafflodkey.currentState.openEndDrawer();
                    //       //   },
                    //       //   color: mainAppColor,

                    //       //   tooltip: 'Filter',
                    //       //   // iconSize: 14,
                    //       // )

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
                        child: productDetails.length > 0
                            ? SingleChildScrollView(
                                controller: scrollController,
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(children: [
                                  subCategoriesForDisplay.length > 0
                                      ? Container(
                                          width: MediaQuery.of(context).size.width - 10,
                                          height: 86,
                                          margin: EdgeInsets.only(top: 12),
                                          child: ListView(
                                              physics: AlwaysScrollableScrollPhysics(),
                                              // shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              children: displaySubCategories()))
                                      : Container(),
                                  subCategoriesForDisplay.length > 0
                                      ? Divider(
                                          thickness: 2,
                                        )
                                      : Container(),
                                  Container(
                                      // margin:
                                      //     EdgeInsets.only(left: 7, right: 7),
                                      child: showFilterProductDetails(productDetails, this.setState, productShowMoreOrLess, NeverScrollableScrollPhysics(), true, context, '/search')),
                                  isMoreProductsLoading
                                      ? Container(
                                          child: Center(
                                            child: customizedCircularLoadingIcon(30),
                                          ),
                                        )
                                      : Container()
                                ]))
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    //
                                    Text(errorMessages.noResultsFoundMessage,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ))
                                  ],
                                ),
                              ))
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
                  ]))
              : Center(child: circularLoadingIcon()),
        ));
  }
}
