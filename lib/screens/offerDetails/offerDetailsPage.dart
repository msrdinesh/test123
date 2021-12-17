import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/headernames.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/services/offerDetailService/offerDetailsService.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/services/registrationservices/registrationservice.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

class OfferDeatils extends StatefulWidget {
  @override
  _OfferDeatilsState createState() => _OfferDeatilsState();
}

class _OfferDeatilsState extends State<OfferDeatils> {
  // Map OfferDescription = {};
  String offerDescription = "";
  Map offerDetails = {};
  Image offerImage;
  final OffeerDetailsServices offeerDetailsServices = OffeerDetailsServices();
  bool isOfferDetailsLoaded = false;
  final ApiErros apiErros = ApiErros();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  final AppFonts appFonts = AppFonts();
  @override
  void initState() {
    getOfferDescription();
    // getImage();
    super.initState();
    showOrHideSearchAndFilter = false;
  }

  getOfferDescription() {
    setState(() {
      isOfferDetailsLoaded = true;
    });
    final Map requestObj = {'offerId': offerId, 'screenName': 'HSCAROUSEL'};
    offeerDetailsServices.getOfferDescription(requestObj).then((val) {
      print(val.body);
      setState(() {
        isOfferDetailsLoaded = false;
      });
      final data = json.decode(val.body);
      if (data['imageResourceUrl'] != null) {
        setState(() {
          offerDetails = data;
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
      // print(offerDescription);
    }, onError: (err) {
      setState(() {
        isOfferDetailsLoaded = false;
      });
      apiErros.apiErrorNotifications(
          err, context, '/OfferDetails', scaffoldkey);
    });
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

  reset() {
    searchFieldController.clear();
    searchFieldKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: appBarWidgetWithIconsAnSearchboxAndFilterIcon(
          context,
          true,
          this.setState,
          false,
          '/OfferDetails',
          searchFieldKey,
          searchFieldController,
          searchFocusNode,
          scaffoldkey),
      endDrawer: showOrHideSearchAndFilter
          ? filterDrawer(
              this.setState, context, scaffoldkey, false, searchFieldController)
          : null,
      body: !isOfferDetailsLoaded
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
              Widget>[
              // showOrHideSearchAndFilter
              //     ? Container(
              //         margin: EdgeInsets.only(top: 2, left: 10),
              //         height: 40,
              //         child: Row(children: [
              //           Expanded(
              //               flex: 3,
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
              //           Padding(padding: EdgeInsets.only(left: 3)),
              //           Expanded(
              //             child: RaisedButton(
              //               color: mainYellowColor,
              //               child: Row(
              //                 children: <Widget>[
              //                   Icon(
              //                     Icons.tune,
              //                     size: 18,
              //                     color: Colors.black,
              //                   ),
              //                   Text(
              //                     "Filter",
              //                     style: TextStyle(color: Colors.black),
              //                   )
              //                 ],
              //               ),
              //               onPressed: () {
              //                 scaffoldkey.currentState.openEndDrawer();
              //               },
              //             ),
              //           ),
              //           Padding(padding: EdgeInsets.only(right: 5)),

              //           // Expanded(
              //           //     child: IconButton(
              //           //   padding: EdgeInsets.all(0),
              //           //   icon: Icon(Icons.filter_list),
              //           //   onPressed: () {
              //           //     scaffoldkey.currentState.openEndDrawer();
              //           //   },
              //           //   color: mainAppColor,

              //           //   tooltip: 'Filter',
              //           //   // iconSize: 14,
              //           // )),
              //           // child: FlatButton.icon(
              //           //   icon: Icon(Icons.filter_list),
              //           //   onPressed: () {},
              //           //   label: Text("Filter"),
              //           // ),
              //           // )
              //         ]))
              //     : Container(),
              Padding(padding: EdgeInsets.only(top: 20)),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text(offerDetailsHeaderName,
                    style: appFonts
                        .getTextStyle('offer_details_screen_heading_style')),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.only(top: 10)),
                            offerDetails['imageResourceUrl'] != null
                                ? Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    // color: Colors.black,
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              offerDetails['imageResourceUrl'],
                                          // 'https://feednextmedia.s3.ap-south-1.amazonaws.com/Silage-Bales-Large-03.jpg',
                                          fit: BoxFit.fill,
                                        )),
                                    // decoration: BoxDecoration(
                                    // ),
                                  )
                                : Container(),
                            Padding(padding: EdgeInsets.only(top: 20)),
                            Container(
                              margin: EdgeInsets.only(left: 14, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  offerDetails['description'] != null &&
                                          offerDetails['description'] != ""
                                      ? Text(
                                          'Offer Description',
                                          style: appFonts.getTextStyle(
                                              'offer_details_screen_content_heading_style'),
                                        )
                                      : Container(),
                                  AppStyles().customPadding(2),
                                  //   Text(
                                  //     "Offer Description",
                                  //     style: TextStyle(
                                  //       fontSize: 20,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  Padding(padding: EdgeInsets.only(top: 3)),
                                  offerDetails['description'] != null
                                      ? Text(
                                          offerDetails['description'],

                                          // "Cornext has developed a Silage Baling Machine which can make small bales (60-80 kg) and can be carried by a single person. We strongly believe that with its given features is a great asset to the farmers and forage entrepreneurs.",
                                          softWrap: true,
                                          style: appFonts.getTextStyle(
                                              'offer_details_scren_content_style'),
                                          // textScaleFactor: 1.3,
                                        )
                                      : Container(),
                                ],
                              ),
                            )
                          ])))
            ])
          : Center(
              child: customizedCircularLoadingIcon(50),
            ),
      bottomNavigationBar: signInDetails['access_token'] == null
          ? Row(
              children: <Widget>[
                Container(
                    // alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width - 20,
                    margin: EdgeInsets.only(left: 10),
                    height: 50.0,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          // fit: FlexFit.loose,
                          flex: 2,
                          child: RaisedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    '/home', ModalRoute.withName('/home'));
                              },
                              color: mainYellowColor,
                              child: Text(
                                "Skip",
                                style: appFonts
                                    .getTextStyle('button_text_color_black'),
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Expanded(
                          flex: 2,
                          child: RaisedButton(
                              onPressed: () {
                                editacconutScreen = false;
                                enablefields = true;
                                Navigator.pushNamed(context, '/registration');
                              },
                              color: Colors.green,
                              child: Text(
                                "Register",
                                style: appFonts
                                    .getTextStyle('button_text_color_white'),
                              )),
                        )
                      ],
                    )),
              ],
            )
          : Container(
              height: 1,
            ),
    );
  }
}
