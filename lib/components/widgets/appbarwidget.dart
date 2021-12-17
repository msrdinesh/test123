import 'package:cornext_mobile/services/addressservice/addressservice.dart';
import 'package:flutter/material.dart';
// import 'package:cornext_mobile/constants/appconstants.dart';
import 'package:cornext_mobile/constants/imagepaths.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:badges/badges.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:cornext_mobile/services/registrationservices/registrationservice.dart';
import 'dart:convert';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/appfonts.dart';
// import 'package:cornext_mobile/components/widgets/notifications.dart';
// import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';

int noOfProductsAddedInCart = 0;
bool showOrHideSearchAndFilter = false;
String previousRouteNameFromCart = '';
Map allControllers = {
  'productCarouselVideoControllers': [],
  'testimonialVideoControllers': [],
  'instructionsVideoControllers': []
};

final Widget plainAppBarWidget = AppBar(
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
  title: Image(
    image: AssetImage(cornextLogoImagePath2),
    fit: BoxFit.cover,
    width: 100,
  ),
  backgroundColor: mainAppColor,
  brightness: Brightness.dark,
);

final Widget plainAppBarWithoutImageWidget = AppBar(
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
  backgroundColor: mainAppColor,
  brightness: Brightness.dark,
);

final Widget plainAppBarWidgetWithoutBackButton = AppBar(
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
  title: Image(
    image: AssetImage(cornextLogoImagePath2),
    fit: BoxFit.cover,
    width: 100,
  ),
  backgroundColor: mainAppColor,
  brightness: Brightness.dark,
  automaticallyImplyLeading: false,
);

displayLoadingIcon(context) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 100,
              child: customizedCircularLoadingIconWithColorAndSize(
                  50, Colors.white),
            ));
      });
}

deleteTokenOnLogout(context, scaffoldKey, state) {
  displayLoadingIcon(context);
  SharedPreferenceService().removeUserInfo();
  HomeScreenServices().deleteTokenOnLogout().then((val) {
    dynamic data;
    Navigator.pop(context);
    if (val.body != null && (val.body == "FAILED" || val.body == "SUCCESS")) {
      data = val.body;
    } else {
      data = json.decode(val.body);
    }
    if (data != null && data == 'SUCCESS') {
      state(() {
        signInDetails = {
          "userName": 'Hello, User',
          "userId": "",
        };
        noOfProductsAddedInCart = 0;
      });
      int index = -1;
      filterProducts.forEach((val) {
        if (val['categoryName'] == 'Favorites') {
          index = filterProducts.indexOf(val);
        }
      });
      if (index != -1) {
        state(() {
          filterProducts.removeAt(index);
        });
      }
      Navigator.pushNamed(context, '/login');
    } else if (data != null && data == 'FAILED') {
      showErrorNotifications(
          "Failed to logout. Please try again", context, scaffoldKey);
    } else if (data['error'] != null && data['error'] == "invalid_token") {
      // Navigator.pop(context);
      RefreshTokenService().getAccessTokenUsingRefreshToken().then(
        (res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService()
              .getAccessTokenFromData(refreshTokenData, context, state)) {
            deleteTokenOnLogout(context, scaffoldKey, state);
          }
        },
      );
    } else if (data['error'] != null) {
      // SharedPreferenceService().removeUserInfo();
      state(() {
        signInDetails = {
          "userName": 'Hello, User',
          "userId": "",
        };
        noOfProductsAddedInCart = 0;
      });
      int index = -1;
      filterProducts.forEach((val) {
        if (val['categoryName'] == 'Favorites') {
          index = filterProducts.indexOf(val);
        }
      });
      if (index != -1) {
        state(() {
          filterProducts.removeAt(index);
        });
      }
      Navigator.pushNamed(context, '/login');
      // ApiErros().apiLoggedErrors(data, context, scaffoldKey);
    }
  }, onError: (err) {
    Navigator.pop(context);
    ApiErros().apiErrorNotifications(err, context, '/home', scaffoldKey);
  });
}

Widget appBarWidgetWithIcons(context, bool showSearchIcon, state,
    bool isCartPage, String previousRouteName) {
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
      },
      child: Image(
        image: AssetImage(cornextLogoImagePath2),
        fit: BoxFit.cover,
        width: 100,
      ),
    ),

    backgroundColor: mainAppColor,
    brightness: Brightness.dark,
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
              position: BadgePosition(top: 1.2, right: 10),
              badgeContent: Text(
                noOfProductsAddedInCart.toString(),
                // "100",
                style: AppFonts().getTextStyle('cart_badge_content_color'),
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

Widget appBarDrawer(context, state, GlobalKey<ScaffoldState> scaffoldKey) {
  // if (userName != null) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountEmail: Text(''),
          // accountName: Text(userRegistrationDetails["name"]),
          accountName: Container(
              padding: EdgeInsets.only(top: 18),
              child: Text(
                signInDetails['userName'] != null
                    ? signInDetails['userName']
                    : '',
                style: AppFonts().getTextStyle('appbar_username'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          arrowColor: mainAppColor,
          currentAccountPicture: CircleAvatar(
            radius: 5,
            backgroundColor: Colors.white,
            child: Text(
              signInDetails['userName'] != null
                  ? signInDetails['access_token'] != null
                      ? signInDetails['userName'][0].toString().toUpperCase()
                      : "U"
                  : '',
              style: AppFonts().getTextStyle('appbar_username_circle'),
            ),
          ),
          decoration: BoxDecoration(color: mainAppColor),

          // otherAccountsPictures: <Widget>[
          //   CircleAvatar(
          //     child: Text("B"),
          //     backgroundColor: Colors.white,
          //   ),
          // ],
        ),
        // DrawerHeader(
        //   child: Text(
        //     signInDeatils['userName'] != null ? signInDeatils['userName'] : '',
        //     maxLines: 10,
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   decoration: BoxDecoration(color: mainAppColor),
        // ),

        ListTile(
          title: Text("Home"),
          leading: Icon(Icons.home),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', ModalRoute.withName('/home'));
          },
        ),
        Divider(),
        ListTile(
          title: Text("Profile"),
          leading: Icon(Icons.supervised_user_circle),
          onTap: () {
            if (signInDetails['access_token'] == null) {
              Navigator.popAndPushNamed(context, '/login');
            } else {
              editacconutScreen = true;
              enablefields = false;
              Navigator.popAndPushNamed(context, '/registration');
            }
            // Navigator.pushNamed(context, '/second');
          },
        ),
        Divider(),
        ListTile(
          title: Text("Subscriptions"),
          leading: Icon(Icons.subscriptions),
          onTap: () {
            if (signInDetails['access_token'] == null) {
              Navigator.popAndPushNamed(context, '/login');
            } else {
              Navigator.popAndPushNamed(context, "/subcriptionlist");
            }
          },
        ),
        Divider(),
        ListTile(
          title: Text("Your Orders"),
          leading: Icon(Icons.shopping_basket),
          onTap: () {
            if (signInDetails['access_token'] == null) {
              Navigator.popAndPushNamed(context, '/login');
            } else {
              Navigator.popAndPushNamed(context, "/yourorders");
            }
          },
        ),
        Divider(),
        ListTile(
          title: Text("Delivery Address(es)"),
          leading: Icon(Icons.library_books),
          onTap: () {
            if (signInDetails['access_token'] == null) {
              Navigator.popAndPushNamed(context, '/login');
            } else {
              isDeliveryAddress = true;
              Navigator.popAndPushNamed(context, "/deliveryaddress");
            }
          },
        ),
        Divider(),
        // ListTile(
        //   title: Text("Refund Initiation Form"),
        //   leading: Icon(Icons.forum),
        //   onTap: () {
        //     if (signInDeatils['access_token'] == null) {
        //       Navigator.popAndPushNamed(context, '/login');
        //     } else {
        //       Navigator.pushNamed(context, "/subscriptionconformation");
        //     }
        //     Navigator.pushNamed(context, "/subscriptionconformation");
        //     // Navigator.pushNamed(context, "/login");
        //   },
        // ),
        // Divider(),
        ListTile(
          title: Text("FAQS"),
          leading: Icon(Icons.help),
          onTap: () {
            // if (signInDeatils['access_token'] == null) {
            //   Navigator.popAndPushNamed(context, '/login');
            // } else {
            Navigator.popAndPushNamed(context, "/faqs");
            // }
            // Navigator.pushNamed(context, "/login");
          },
        ),
        Divider(),
        signInDetails['access_token'] != null
            ? ListTile(
                title: Text("Logout"),
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  // Navigator.pushNamed(context, "/login");
                  Navigator.pop(context);
                  deleteTokenOnLogout(context, scaffoldKey, state);
                },
              )
            : ListTile(
                title: Text("Sign In"),
                leading: Icon(Icons.person_add),
                onTap: () {
                  // Navigator.pushNamed(context, "/login");
                  SharedPreferenceService().removeUserInfo();
                  Navigator.popAndPushNamed(context, '/login');
                },
              ),
        Divider()
      ],
    ),
  );
  // }
  // return null;
}

List getSubCategoriesUsingCategory(String categoryName) {
  List returnList = [];
  subCategoriesList.forEach((val) {
    if (val['path'].toString().startsWith(categoryName)) {
      returnList.add(val);
    }
  });
  return returnList;
}

Widget displaySubCategoriesUsingCategory(
    bool isChecked, String categoryName, state) {
  List subCategories = getSubCategoriesUsingCategory(categoryName);
  return ListView.builder(
      itemCount: subCategories.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            // height: 1,
            margin: EdgeInsets.only(left: 10, top: 0),
            child: Column(children: <Widget>[
              Container(
                  height: 40,
                  child: CheckboxListTile(
                    dense: true,
                    value: subCategories[index]['isChecked'],
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: mainAppColor,
                    onChanged: (val) {
                      state(() {
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

Widget filterDrawer(state, context, GlobalKey<ScaffoldState> scaffoldKey,
    bool isSearchScreen, TextEditingController searchController) {
  return Drawer(
      child: Column(children: [
    AppStyles().customPadding(15),
    Expanded(
        child: ListView.builder(
            itemCount: filterProducts.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  Container(
                      height: 40,
                      child: CheckboxListTile(
                        value: filterProducts[index]['isSelected'],
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: mainAppColor,
                        onChanged: (val) {
                          state(() {
                            filterProducts[index]['isSelected'] = val;
                          });
                          // if (filterProducts[index]['subCategories'] != null) {
                          //   displaySubCategoriesUsingCategory(
                          //       filterProducts[index]['subCategories']);
                          // }
                        },
                        title: Text(filterProducts[index]['categoryName']),
                      )),
                  filterProducts[index]['subCategories'] != null &&
                          filterProducts[index]['isSelected']
                      ? displaySubCategoriesUsingCategory(
                          filterProducts[index]['isSelected'],
                          filterProducts[index]['categoryName'],
                          state)
                      : Container()
                ],
              );
            })),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        // alignment: Alignment.topRight,
        margin: EdgeInsets.only(right: 8),
        child: RaisedButton(
          onPressed: () {
            clearFilterData(state);
          },
          child: Text("Clear"),
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: 8),
        // alignment: Alignment.bottomCenter,
        child: RaisedButton(
          // shape: new RoundedRectangleBorder(
          //     borderRadius: new BorderRadius.circular(20.0)),
          onPressed: () {
            applyFilter(
                state, context, scaffoldKey, isSearchScreen, searchController);
          },
          child: Text(
            "Apply",
            style: AppFonts().getTextStyle('button_text_color_white'),
          ),
          color: mainAppColor,
        ),
      )
    ])
  ]));
}

clearFilterData(state) {
  filterProducts.forEach((val) {
    state(() {
      val['isSelected'] = false;
    });
  });

  subCategoriesList.forEach((val) {
    state(() {
      val['isChecked'] = false;
      val['manualSelection'] = false;
    });
  });
}

List getSelectedCategoryInfo() {
  List selectedCategories = [];
  filterProducts.forEach((val) {
    if (val['isSelected']) {
      Map obj = {'categoryId': val['categoryId']};
      if (val['subCategories'] != null) {
        List subCategoriesOfCurrentCategory =
            getSelectedSubCategoriesOfCurrentCategory(val['categoryName']);
        if (subCategoriesOfCurrentCategory.length > 0) {
          obj['subCategories'] = subCategoriesOfCurrentCategory;
        }
        // Uncoomment this to highlight subcatgories by default
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

setSubCategoriesOnSelectionOfCategory(String categoryName) {
  subCategoriesList.forEach((val) {
    val['manualSelection'] = false;
    if (val['path'].toString().startsWith(categoryName)) {
      val['isChecked'] = true;
    }
  });
}

List getSelectedSubCategoriesOfCurrentCategory(String categoryName) {
  List selectedSubCategories = [];
  subCategoriesList.forEach((val) {
    if (val['path'].toString().indexOf(categoryName) != -1) {
      if (val['isChecked']) {
        Map obj = {'subCategoryId': val['subCategoryId']};
        selectedSubCategories.add(obj);
      }
    }
  });
  return selectedSubCategories;
}

applyFilter(state, context, GlobalKey<ScaffoldState> scaffoldKey,
    bool isSearchScreen, TextEditingController searchController) {
  List filterProductsData = getSelectedCategoryInfo();
  if (searchController.text != '') {
    productSearchData['productSearchData'] = searchController.text.trim();
  }
  // bool isFavoritesSelected = false;
  // filterProducts.forEach((val) {
  //   if (val['isSelected']) {
  //     // if (val['productCategoryId']) {
  //     // if (val['categoryName'] == 'Favorites') {
  //     //   isFavoritesSelected = true;
  //     // } else {
  //     //   // print(val);
  //     //   Map obj = {'categoryId': val['productCategoryId']};
  //     //   filterProductsData.add(obj);
  //     // }
  //     // }
  //   }
  // });

  getSelectedCategoryInfo();
  if (filterProductsData.length > 0) {
    productSearchData['productCategory'] = filterProductsData;
    // productSearchData['isFavorites'] = isFavoritesSelected;
    Navigator.pop(context);
    if (!isSearchScreen) {
      state(() {
        searchController.text = '';
      });
      resetAllVideoControllers(allControllers);
      Navigator.of(context).pushNamed('/search');
    }
  }

  // } else {
  //   state(() {
  //     Navigator.pop(context);
  //   });
  // }
}

getSearchedData(
    int categoryId, TextEditingController searchFieldController, context) {
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
    Map obj = {'categoryId': categoryId};
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
  if (productSearchData['productSearchData'] != "" ||
      productSearchData['productCategory'].length > 0) {
    // reset();
    Navigator.of(context).pushNamed('/search');
  }
  // }
}

Widget appBarWidgetWithIconsAnSearchbox(
    context,
    bool showSearchIcon,
    state,
    bool isCartPage,
    String previousRouteName,
    GlobalKey<FormFieldState> searchFieldKey,
    TextEditingController searchFieldController,
    FocusNode searchFocusNode) {
  return AppBar(
    centerTitle: true,
    title: GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
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
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 4, top: 0),
          height: 35,
          child: TextFormField(
              cursorColor: mainAppColor,
              controller: searchFieldController,
              key: searchFieldKey,
              focusNode: searchFocusNode,
              onFieldSubmitted: (val) {
                getSearchedData(null, searchFieldController, context);
                state(() {
                  // searchFocusNode.unfocus();
                  // searchFieldKey.currentState?.reset();
                  searchFieldController.text = "";
                  // print("object lascaso de pal");
                  // searchFieldController.clear();
                });
              },
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  counterText: "",
                  hintStyle: AppFonts().getTextStyle('hint_style'),
                  // alignLabelWithHint: true,
                  hintText: "Search",
                  border: AppStyles().searchBarBorder,
                  // prefix: Text("+91 "),
                  contentPadding: EdgeInsets.only(
                      bottom: 1.0, left: 10, right: 10, top: 1.0),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.search),
                    onPressed: () {
                      getSearchedData(null, searchFieldController, context);
                      state(() {
                        // searchFocusNode.unfocus();
                        // searchFieldKey.currentState?.reset();
                        searchFieldController.text = "";
                        // print("object lascaso de pal");
                        // searchFieldController.clear();
                      });
                    },
                    color: mainAppColor,
                    tooltip: 'Search',
                    // iconSize: 24,
                  )))),
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
              position: BadgePosition(top: 1.2, right: 10),
              badgeContent: Text(
                noOfProductsAddedInCart.toString(),
                // "100",
                style: AppFonts().getTextStyle('cart_badge_content_color'),
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
                    // Navigator.pop(context);
                    Navigator.pushNamed(context, '/cart');
                  } else {
                    // Navigator.pop(context);
                    Navigator.pushNamed(context, '/cart');
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

getSearchedDataForOtherScreens(
    TextEditingController searchFieldController, state, context) {
  if (searchFieldController.text.trim() != '') {
    productSearchData['productSearchData'] = searchFieldController.text.trim();
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
    // reset();
    state(() {
      showOrHideSearchAndFilter = false;
    });
    resetAllVideoControllers(allControllers);
    Navigator.of(context).pushNamed('/search');
  }
}

resetAllVideoControllers(Map videoControllers) {
  print(videoControllers);
  if (videoControllers != null) {
    if (videoControllers['productCarouselVideoControllers'] != null &&
        videoControllers['productCarouselVideoControllers'].length > 0) {
      videoControllers['productCarouselVideoControllers']
          .forEach((videoController) {
        if (videoController['controller'] != null) {
          videoController['controller'].pause();
        }
      });
    }

    if (videoControllers['testimonialVideoControllers'] != null &&
        videoControllers['testimonialVideoControllers'].length > 0) {
      videoControllers['testimonialVideoControllers']
          .forEach((videoController) {
        if (videoController['controller'] != null) {
          videoController['controller'].pause();
        }
      });
    }
    if (videoControllers['instructionsVideoControllers'] != null &&
        videoControllers['instructionsVideoControllers'].length > 0) {
      videoControllers['instructionsVideoControllers']
          .forEach((videoController) {
        if (videoController['controller'] != null) {
          videoController['controller'].pause();
        }
      });
    }
  }
}

Widget appBarWidgetWithIconsAnSearchboxAndFilterIcon(
    context,
    bool showSearchIcon,
    state,
    bool isCartPage,
    String previousRouteName,
    GlobalKey<FormFieldState> searchFieldKey,
    TextEditingController searchFieldController,
    FocusNode searchFocusNode,
    GlobalKey<ScaffoldState> scaffoldkey) {
  return AppBar(
    centerTitle: true,
    title: GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
      },
      child: Image(
        image: AssetImage(cornextLogoImagePath2),
        fit: BoxFit.cover,
        width: 100,
      ),
    ),
    backgroundColor: mainAppColor,
    brightness: Brightness.dark,
    bottom: (showOrHideSearchAndFilter)
        ? PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 35),
            child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(bottom: 4, left: 7, right: 7, top: 0),
                height: 35,
                child: Row(children: [
                  Container(
                      // flex: 3,
                      width: MediaQuery.of(context).size.width - 114,
                      child: TextFormField(
                          cursorColor: mainAppColor,
                          controller: searchFieldController,
                          onFieldSubmitted: (val) {
                            getSearchedDataForOtherScreens(
                                searchFieldController, state, context);
                          },
                          key: searchFieldKey,
                          focusNode: searchFocusNode,
                          decoration: InputDecoration(
                              counterText: "",
                              fillColor: Colors.white,
                              filled: true,
                              // alignLabelWithHint: true,
                              hintStyle: AppFonts().getTextStyle('hint_style'),
                              hintText: "Search",
                              border: AppStyles().searchBarBorder,
                              // prefix: Text("+91 "),
                              contentPadding: EdgeInsets.fromLTRB(14, 0, 0, 0),
                              focusedBorder: AppStyles().focusedSearchBorder,
                              suffixIcon: IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  // getSearchedData();
                                  getSearchedDataForOtherScreens(
                                      searchFieldController, state, context);
                                },
                                color: mainAppColor,
                                tooltip: 'Search',
                                // iconSize: 24,
                              )))),
                  Padding(padding: EdgeInsets.only(left: 7)),
                  Container(
                    width: 88,
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
                            style: AppFonts()
                                .getTextStyle('button_text_color_black'),
                          )
                        ],
                      ),
                      onPressed: () {
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
          )
        : PreferredSize(
            preferredSize: Size(0, 0),
            child: Container(),
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
              position: BadgePosition(top: 1.2, right: 10),
              badgeContent: Text(
                noOfProductsAddedInCart.toString(),
                // "100",
                style: AppFonts().getTextStyle('cart_badge_content_color'),
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
