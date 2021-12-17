// import 'dart:convert';

// import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
// import 'package:cornext_mobile/constants/appcolors.dart';
// import 'package:cornext_mobile/constants/appstyles.dart';
// import 'package:cornext_mobile/services/editprofileservice/editprofileservice.dart';
// // import 'package:cornext_mobile/services/editprofileservie/editprofileservice.dart';
// //import 'package:cornext_mobile/constants/appcolors.dart';
// //import 'package:cornext_mobile/constants/appstyles.dart';
// //import 'package:cornext_mobile/constants/appstyles.dart';
// //import 'package:cornext_mobile/constants/imagepaths.dart';
// import 'package:flutter/material.dart';

// bool otherField = false;

// class RefundInitiation extends StatefulWidget {
//   @override
//   _RefundInitiationState createState() => _RefundInitiationState();
// }

// class _RefundInitiationState extends State<RefundInitiation> {
//   final reasoncontroller = TextEditingController();
//   ProfileServies reasonsService = ProfileServies();
//   Map requestObj;
//   // List<String> _reasons = [
//   //   'Bought by mistake',
//   //   'Better price available',
//   //   'Quantity is less than what I ordered',
//   //   'Poor Quality',
//   //   'Part of product is missing',
//   //   'Inaccurate website description',
//   //   'Other'
//   // ]; // Option 2
//   String _selectedreason;
//   int orderId = 1;
//   List data = List();

//   //var items = [];

//   @override
//   initState() {
//     setState(() {
//       getReasons();
//       otherField = false;
//     });

//     super.initState();
//   }

//   getReasons() {
//     reasonsService.getRefundeReasons().then((res) {
//       print(res.body);
//       var reasons = json.decode(res.body);
//       setState(() {
//         data = reasons;
//       });

//       print(data);
//     });
//   }

//   updatereason() {
//     if (!otherField) {
//       requestObj = {"orderId": orderId, "refundReason": _selectedreason};
//     } else {
//       requestObj = {
//         "orderId": orderId,
//         "refundReason": "other",
//         "otherReason": reasoncontroller.text
//       };
//     }
//     reasonsService.updateReasons(requestObj).then((res) {
//       print(res.body);
//     });
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//         resizeToAvoidBottomPadding: false,
//         appBar: appBarWidgetWithIcons(context, true, this.setState, false),
//         body: GestureDetector(
//             onTap: () {
//               FocusScope.of(context).requestFocus(FocusNode());
//             },
//             child: Column(children: <Widget>[
//               Container(
//                   alignment: Alignment.topLeft,
//                   padding: EdgeInsets.fromLTRB(3, 3, 0, 60),
//                   child: Text(
//                     "Refund Initiation Form",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   )),
//               Container(
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
//                   child: SingleChildScrollView(
//                       child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                         Card(
//                           child: Container(
//                             alignment: Alignment.topLeft,
//                             margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.all(5),
//                                   ),

//                                   // Padding(
//                                   // padding: EdgeInsets.all(10),
//                                   //  ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: <Widget>[
//                                       Padding(padding: EdgeInsets.all(2.0)),
//                                       RichText(
//                                           text: TextSpan(
//                                               // style: Theme.of(context)
//                                               //   .textTheme
//                                               // .body1
//                                               // .copyWith(fontSize: 30),
//                                               children: [
//                                             TextSpan(
//                                               text: 'Order ID: ',
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 18),
//                                             ),
//                                             TextSpan(
//                                                 text: '1234',
//                                                 style: TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 16)),
//                                           ])),
//                                     ],
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(3),
//                                   ),

//                                   // mainAxisAlignment:
//                                   // MainAxisAlignment.start,

//                                   Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Padding(padding: EdgeInsets.all(2.0)),
//                                         Text("Request for refund:",
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               fontStyle:
//                                                   FontStyle.normal, // italic
//                                               fontWeight: FontWeight.w500,

//                                               color: Colors.black,
//                                             )),
//                                       ]),
//                                   Padding(
//                                     padding: EdgeInsets.all(3),
//                                   ),
//                                   Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       // crossAxisAlignment: CrossAxiszAlignment.start,
//                                       children: <Widget>[
//                                         Padding(
//                                           padding: EdgeInsets.all(2),
//                                         ),
//                                         Text("Reason:",
//                                             style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 16.0,
//                                                 fontWeight: FontWeight.w400)),
//                                         Padding(
//                                           padding: EdgeInsets.only(
//                                               left: 2, right: 2),
//                                         ),
//                                         Expanded(
//                                           flex: 1,
//                                           child: Container(
//                                             //width: 190,
//                                             height: 35,
//                                             margin: EdgeInsets.only(right: 10),
//                                             child: DropdownButton(
//                                               hint: Text(
//                                                   'choose your problem'), // Not necessary for Option 1
//                                               value: _selectedreason,
//                                               onChanged: (newValue) {
//                                                 setState(() {
//                                                   _selectedreason = newValue;
//                                                   if (_selectedreason ==
//                                                       "other") {
//                                                     setState(() {
//                                                       otherField = true;
//                                                     });
//                                                   } else {
//                                                     setState(() {
//                                                       otherField = false;
//                                                     });
//                                                   }
//                                                 });
//                                               },
//                                               isExpanded: true,
//                                               iconSize: 30,

//                                               isDense: true,
//                                               items: data.map((reason) {
//                                                 return DropdownMenuItem(
//                                                   child: new Text(
//                                                     reason,
//                                                     style: TextStyle(
//                                                         fontSize: 14,
//                                                         height: 2,
//                                                         color: Colors.black),
//                                                   ),
//                                                   value: reason,
//                                                 );
//                                               }).toList(),
//                                             ),
//                                           ),
//                                         ),
//                                       ]),
//                                   Padding(padding: EdgeInsets.all(5)),
//                                   otherField
//                                       ? Row(
//                                           //mainAxisAlignment: MainAxisAlignment.start,
//                                           //crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                               Padding(
//                                                   padding: EdgeInsets.all(2)),
//                                               Text("Other:",
//                                                   style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 16.0)),
//                                               Padding(
//                                                 padding: EdgeInsets.all(2),
//                                               ),
//                                               Expanded(
//                                                 flex: 1,
//                                                 child: TextFormField(
//                                                   maxLines: 3,
//                                                   decoration: InputDecoration(
//                                                       border:
//                                                           OutlineInputBorder(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .all(Radius
//                                                                           .circular(
//                                                                               5)),
//                                                               borderSide:
//                                                                   BorderSide(
//                                                                 color:
//                                                                     mainAppColor,
//                                                               )),
//                                                       // errorMaxLines: 3,
//                                                       focusedBorder: AppStyles()
//                                                           .focusedInputBorder,
//                                                       focusColor: Colors.green,
//                                                       labelText:
//                                                           "Please Enter Reason",
//                                                       counterText: "",
//                                                       contentPadding: AppStyles()
//                                                           .contentPaddingForInput),
//                                                   keyboardType:
//                                                       TextInputType.text,
//                                                   maxLength: 200,
//                                                   cursorColor: mainAppColor,
//                                                   controller: reasoncontroller,
//                                                 ),
//                                               ),
//                                               Padding(
//                                                   padding: EdgeInsets.all(3))
//                                             ])
//                                       : Container(),
//                                   Padding(padding: EdgeInsets.all(3)),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: <Widget>[
//                                       RaisedButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             updatereason();
//                                             reasoncontroller.clear();
//                                             otherField = false;
//                                           });
//                                         },
//                                         shape: new RoundedRectangleBorder(
//                                           borderRadius:
//                                               new BorderRadius.circular(0),
//                                         ),
//                                         color: mainAppColor,
//                                         child: Text(
//                                           "Submit",
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 ]),
//                             // Container()

//                             //Padding(padding: EdgeInsets.all(30)),
//                           ),
//                         ),
//                       ])))
//             ])));
//   }
// }
import 'dart:convert';

import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/refundinitiationservices/refundinitiationservice.dart';

bool otherField = false;

class RefundInitiation extends StatefulWidget {
  @override
  _RefundInitiationState createState() => _RefundInitiationState();
}

class _RefundInitiationState extends State<RefundInitiation> {
  final reasoncontroller = TextEditingController();
  RefundInitiationService reasonsService = RefundInitiationService();
  Map requestObj;
  int orderId = 1;
  List data = List();
  String _selectedreason = '';
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  final scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    setState(() {
      getReasons();
      otherField = false;
    });

    super.initState();
  }

  getReasons() {
    reasonsService.getRefundeReasons().then((res) {
      print(res.body);
      var reasons = json.decode(res.body);
      setState(() {
        data = reasons;
        _selectedreason = data[0];
      });

      print(data);
    });
  }

  updatereason() {
    if (!otherField) {
      requestObj = {"orderId": orderId, "refundReason": _selectedreason};
    } else {
      requestObj = {
        "orderId": orderId,
        "refundReason": "other",
        "otherReason": reasoncontroller.text,
      };
    }
    reasonsService.updateReasons(requestObj).then((res) {
      print(res.body);
    });
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
      // reset();
      // if (_controller != null && _controller.value.initialized) {
      //   _controller.pause();
      // }
      setState(() {
        showOrHideSearchAndFilter = false;
      });
      Navigator.of(context).pushNamed('/search');
    }
  }

  Future<bool> onBackButtonPressed() async {
    // searchFieldKey.currentState?.reset();

    // searchFieldController.text = "";
    reasoncontroller.text = "";
    _selectedreason = data[0];
    //showOrHideSearchAndFilter = false;
    otherField = false;
    // searchFieldController.clear();

    // if (showOrHideSearchAndFilter = false) {
    //  reset();
    // searchFieldController.text = "";
    // }
    setState(() {
      if (showOrHideSearchAndFilter) {
        searchFieldKey.currentState?.reset();
        showOrHideSearchAndFilter = false;
      }
    });

    return true;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onBackButtonPressed,
        child: Scaffold(
            key: scaffoldkey,
            resizeToAvoidBottomPadding: false,
            appBar:
                appBarWidgetWithIcons(context, true, this.setState, false, ''),
            endDrawer: showOrHideSearchAndFilter
                ? filterDrawer(this.setState, context, scaffoldkey, false,
                    searchFieldController)
                : null,
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  AppStyles().customPadding(1),
                  showOrHideSearchAndFilter
                      ? Container(
                          // margin: EdgeInsets.only(left: 55),
                          height: 40,
                          child: Row(children: [
                            Expanded(
                                flex: 8,
                                child: TextFormField(
                                    cursorColor: mainAppColor,
                                    controller: searchFieldController,
                                    onFieldSubmitted: (val) {
                                      //getSearchedData();
                                      //reset();
                                    },
                                    key: searchFieldKey,
                                    focusNode: searchFocusNode,
                                    decoration: InputDecoration(
                                        counterText: "",
                                        // alignLabelWithHint: true,
                                        hintText: "Search",
                                        border: AppStyles().searchBarBorder,
                                        // prefix: Text("+91 "),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(14, 0, 0, 0),
                                        focusedBorder:
                                            AppStyles().focusedSearchBorder,
                                        suffixIcon: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                            getSearchedData();
                                            setState(() {
                                              searchFieldController.text = "";
                                              reasoncontroller.text = "";
                                              otherField = false;
                                              _selectedreason = data[0];

                                              // reset();
                                            });
                                          },
                                          color: mainAppColor,
                                          tooltip: 'Search',
                                          // iconSize: 24,
                                        )))),
                            Expanded(
                                child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.filter_list),
                              onPressed: () {
                                // setState(() {
                                scaffoldkey.currentState.openEndDrawer();
                                setState(() {
                                  reasoncontroller.text = "";
                                  otherField = false;
                                  _selectedreason = data[0];
                                  //searchFieldController.text = "";

                                  // reset();
                                });
                                // scaffoldkey.currentState.openEndDrawer();
                                // });
                              },
                              color: mainAppColor,

                              tooltip: 'Filter',
                              // iconSize: 14,
                            )),
                            // child: FlatButton.icon(
                            //   icon: Icon(Icons.filter_list),
                            //   onPressed: () {},
                            //   label: Text("Filter"),
                            // ),
                            // )
                          ]))
                      : Container(),
                  SingleChildScrollView(
                      child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.fromLTRB(3, 3, 0, 60),
                          child: Text(
                            "Refund Initiation Form",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ))),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                            Card(
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                      ),

                                      // Padding(
                                      // padding: EdgeInsets.all(10),
                                      //  ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(padding: EdgeInsets.all(2.0)),
                                          RichText(
                                              text: TextSpan(
                                                  // style: Theme.of(context)
                                                  //   .textTheme
                                                  // .body1
                                                  // .copyWith(fontSize: 30),
                                                  children: [
                                                TextSpan(
                                                  text: 'Order ID: ',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                                TextSpan(
                                                    text: '1234',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16)),
                                              ])),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(3),
                                      ),

                                      // mainAxisAlignment:
                                      // MainAxisAlignment.start,

                                      // Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.start,
                                      //     children: <Widget>[
                                      //       Padding(
                                      //           padding: EdgeInsets.all(2.0)),
                                      //       Text("Request for refund:",
                                      //           style: TextStyle(
                                      //             fontSize: 18,
                                      //             fontStyle: FontStyle
                                      //                 .normal, // italic
                                      //             fontWeight: FontWeight.w500,

                                      //             color: Colors.black,
                                      //           )),
                                      //     ]),
                                      // Padding(
                                      //   padding: EdgeInsets.all(3),
                                      // ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          // crossAxisAlignment: CrossAxiszAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.all(2),
                                            ),
                                            Text("Reason:",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 2, right: 2),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                //width: 190,
                                                height: 35,
                                                margin:
                                                    EdgeInsets.only(right: 10),
                                                child: DropdownButton(
                                                  hint: Text(
                                                      'choose your problem'), // Not necessary for Option 1
                                                  value: _selectedreason,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      _selectedreason =
                                                          newValue;
                                                      if (_selectedreason ==
                                                          data[3]) {
                                                        setState(() {
                                                          otherField = true;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          otherField = false;
                                                        });
                                                      }
                                                    });
                                                  },
                                                  isExpanded: true,
                                                  iconSize: 30,

                                                  isDense: true,
                                                  items: data.map((reason) {
                                                    return DropdownMenuItem(
                                                      child: new Text(
                                                        reason,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            height: 2,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      value: reason,
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ]),
                                      Padding(padding: EdgeInsets.all(5)),
                                      otherField
                                          ? Row(
                                              //mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(2)),
                                                  Text("Other:",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16.0)),
                                                  Padding(
                                                    padding: EdgeInsets.all(2),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: TextFormField(
                                                      maxLines: 3,
                                                      decoration:
                                                          InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              5)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color:
                                                                            mainAppColor,
                                                                      )),
                                                              // errorMaxLines: 3,
                                                              focusedBorder:
                                                                  AppStyles()
                                                                      .focusedInputBorder,
                                                              focusColor:
                                                                  Colors.green,
                                                              labelText:
                                                                  "Please Enter Reason",
                                                              counterText: "",
                                                              contentPadding:
                                                                  AppStyles()
                                                                      .contentPaddingForInput),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      maxLength: 200,
                                                      cursorColor: mainAppColor,
                                                      controller:
                                                          reasoncontroller,
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(3))
                                                ])
                                          : Container(),
                                      Padding(padding: EdgeInsets.all(3)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          RaisedButton(
                                            onPressed: () {
                                              setState(() {
                                                updatereason();
                                                reasoncontroller.clear();
                                                otherField = false;
                                                if (showOrHideSearchAndFilter) {
                                                  searchFieldKey.currentState
                                                      ?.reset();
                                                  showOrHideSearchAndFilter =
                                                      false;
                                                }
                                              });
                                            },
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      0.0),
                                            ),
                                            color: mainAppColor,
                                            child: Text(
                                              "Submit",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )
                                    ]),
                                // Container()

                                //Padding(padding: EdgeInsets.all(30)),
                              ),
                            ),
                          ])))
                ])))));
  }
}
