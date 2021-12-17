import 'dart:convert';
import 'package:web_ffi/web_ffi.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/appcolors.dart';
// import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/services/ordertrackingservices/ordertrackingservice.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
// import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cornext_mobile/services/feedbackservice/feedbackservice.dart';
import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:android_intent/android_intent.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:cornext_mobile/constants/appfonts.dart';

class FeedbackPage extends StatefulWidget {
  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  File _image;
  bool choice = false;
  // int orderId = 2;
// int count = 0;
  bool buttonon = true;
  Uint8List imageInfo = Uint8List(0);
  String base64;
  String base64Image;
  final feedbackKey = GlobalKey<FormFieldState>();
  final feedBackFocusNode = FocusNode();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final searchFieldController = TextEditingController();
  final searchFieldKey = GlobalKey<FormFieldState>();
  final searchFocusNode = FocusNode();
  // Position _currentPosition;
  // String _currentAddress;
// VideoPlayerController controller;
  List<Widget> imageContainers = [];
  List imagesOrVideos = [];
  final TextEditingController feedbackText = TextEditingController();
  final FeedBackServices feedBackServices = FeedBackServices();
  final RefreshTokenService refreshTokenService = RefreshTokenService();
  final ApiErros apiErros = ApiErros();
  final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  List orderedProductList = [];
  final currencyFormatter = NumberFormat('#,##,###.00');
  final OrderTrackingService orderTrackingService = OrderTrackingService();

  bool isLoading = false;
  Map orderDetails = {};
  StreamSubscription<Position> positionStream;
  Map locationDetails = {};
  final AppFonts appFonts = AppFonts();

  void initState() {
// addWidgetIntoImageContainers();

    super.initState();
    getOrderDetails();
    showOrHideSearchAndFilter = false;
    // feedbackText.text = "";
    // _getCurrentLocation();
  }

  void dispose() {
    if (positionStream != null) {
      positionStream.cancel();
    }
    super.dispose();
  }

//Gets order details
  getOrderDetails() {
    setState(() {
      isLoading = true;
    });
    final Map requestObj = {
      'orderId': orderIdForFeedback,
      "screenName": "HS"
    };
    orderTrackingService.getIndividualOrderDetails(requestObj).then((val) {
      final data = json.decode(val.body);
      print(data);
      if (data['listOfProducts'] != null) {
        orderDetails = data;
        orderedProductList = data['listOfProducts'];
        setState(() {});
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (RefreshTokenService().getAccessTokenFromData(refreshTokenData, context, setState)) {
            getOrderDetails();
          }
        });
      } else if (data['error'] != null) {
        apiErros.apiLoggedErrors(data, context, scaffoldkey);
      }
      setState(() {
        isLoading = false;
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      apiErros.apiErrorNotifications(err, context, '/yourorderdetails', scaffoldkey);
    });
  }

// Storing list of images and videos in list
  addWidgetIntoImageContainers(bool isVideo) {
    print(imageContainers.length);
    Widget imageContainerWidget;
// if (_image.path.indexOf("mp4") != -1) {
// showvideo();
// }
    imageContainerWidget = Container(
        child: Container(
      margin: EdgeInsets.only(top: 15, left: 15, right: 10),
      child: _image.path.indexOf("mp4") == -1
          ? Stack(children: [
              showImage(),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                        onTap: () {
                          removeImageFromList(imageContainerWidget);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        )),
                  ))
            ])
          : imageInfo.length > 0
              ? Container(
                  height: 100,
                  width: 150,
                  child: Stack(children: [
                    Image.memory(
                      imageInfo,
                      height: 100,
                      width: 150,
                      fit: BoxFit.fill,
                      frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: child,
                        );
                      },
                    ),
                    Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                              onTap: () {
                                removeImageFromList(imageContainerWidget);
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              )),
                        ))
                  ]))
              : Container(),
// imageContainer(),
    ));
    setState(() {
      imageContainers.add(imageContainerWidget);
    });
  }

// removing Images or videos from list after clicking remove button
  removeImageFromList(Widget image) {
    setState(() {
      int index = imageContainers.indexOf(image);
      print(index);
      imageContainers.removeAt(index);
      imagesOrVideos.removeAt(index);
    });
  }

  Future<Void> _showDialouge(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            // titleTextStyle: TextStyle(backgroundColor: mainYellowColor),
            title: Text(
              "Select one",
              style: appFonts.getTextStyle('feedback_screen_camera_options_text_style'),
            ),
            elevation: 5,
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    title: Text(
                      "Camera",
                      style: appFonts.getTextStyle('feedback_screen_camera_options_text_style'),
                    ),
                    trailing: Icon(Icons.camera_alt),
                    onTap: () {
                      openCamera(context);
                    },
                  ),
                  Divider(
                    height: 1,
                  ),
                  // Divider(
                  //   height: 1,
                  // ),
                  ListTile(
                    title: Text(
                      "video",
                      style: appFonts.getTextStyle('feedback_screen_camera_options_text_style'),
                    ),
                    trailing: Icon(Icons.videocam),
                    onTap: () {
                      openVideo(context);
                    },
                  ),
                  Divider(
                    height: 1,
                  ),
                ],
              ),
            ),
          );
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

// opening phone camera to pick photo
  openCamera(BuildContext context) async {
    // Navigator.of(context).pop();
    displayLoadingIcon(context);
    try {
      File picture = await ImagePicker.pickImage(source: ImageSource.camera);

      setState(() {
        _image = picture;
      });

      List base64Image = await _image.readAsBytes();
      if (_image != null) {
        addWidgetIntoImageContainers(choice);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
      print(base64Image);
      if (base64Image != null) {
        final Map obj = {
          'data': base64Image,
          'image': true
        };
// images[count] = base64Image;
        imagesOrVideos.add(obj);
      }
    } catch (err) {
      Navigator.pop(context);
    }
  }

// opening phone camera to pick video
  openVideo(BuildContext context) async {
    displayLoadingIcon(context);
    try {
      var picture = await ImagePicker.pickVideo(source: ImageSource.camera);
      // Navigator.of(context).pop();
      setState(() {
        _image = picture;
        choice = true;
      });
      List base64Image = await _image.readAsBytes();
      print(base64Image);
      if (_image != null) {
        // addWidgetIntoImageContainers(choice);
        showvideo();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
      // Navigator.of(context).pop();
      if (base64Image != null) {
        final Map obj = {
          'data': base64Image,
          'image': false
        };
        imagesOrVideos.add(obj);
      }
    } catch (err) {
      Navigator.pop(context);
    }
  }

  //Displaying list of images on screen
  Widget showImage() {
    if (_image != null) {
      final Image imageInfo = Image(
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent event) {
          // return circularLoadingIcon();
          // print(event);
          if (event == null) {
            return child;
          }
          return customizedCircularLoadingIcon(20);
        },
        image: FileImage(_image),
        height: 100,
        width: 150,
        fit: BoxFit.fill,
      );
      setState(() {
        buttonon = false;
      });
// count++;
      return imageInfo;
    }
    return Container();
  }

//Displaying list of images on screen
  showvideo() {
    VideoThumbnail.thumbnailData(video: _image.path, imageFormat: ImageFormat.JPEG, quality: 100).then((val) {
      setState(() {
        imageInfo = val;
        addWidgetIntoImageContainers(true);
      });
    });

    return imageInfo;
  }

  List<Widget> getImageConatinersWidgets() {
    return imageContainers.map((val) {
      return val;
    }).toList();
  }

//Send feedback data
  sendFeedBack(Map locationDetails) {
    final Map requestObj = {
      "orderId": orderIdForFeedback,
      "feedbackData": feedbackText.text.trim(),
      "location": locationDetails['pincode'] != null ? locationDetails : null,
      "gallery": imagesOrVideos
    };
    print(requestObj);

    feedBackServices.postFeedBack(requestObj).then((val) {
      final data = json.decode(val.body);
      print(data);
      if (data == "SUCCESS") {
        isFeedBackSubmitted = true;
        Navigator.pop(context);
        Navigator.popAndPushNamed(context, '/yourorders');

        // showSuccessNotifications(
        //     "Thank You For Your Feedback", context, scaffoldkey);
      } else if (data == "FAILED") {
        Navigator.pop(context);
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        Navigator.pop(context);
        refreshTokenService.getAccessTokenUsingRefreshToken().then((res) {
          final refreshTokenData = json.decode(res.body);
          // print(data);
          if (refreshTokenService.getAccessTokenFromData(refreshTokenData, context, setState)) {
            sendFeedBack(locationDetails);
          }
        });
      }
    }, onError: (err) {
      Navigator.pop(context);
      apiErros.apiErrorNotifications(err, context, "/feedback", scaffoldkey);
    });
    // print("object");
  }

//feedback Form field validations
  feedbacktextvalidator(val) {
    if (val.trim() == "") {
      return ErrorMessages().feedbackTextError;
    }
  }

//displays Search field data
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

  formreset() {
    feedBackFocusNode.unfocus();

    // Future.delayed(Duration(milliseconds: 10), () {
    setState(() {
      imageContainers = [];
      imagesOrVideos = [];
      feedbackKey.currentState?.reset();
      feedbackText.text = "";
      // print("GGIYHGUIHUIHHH");
      // print(feedbackText.text);
    });

    // });
  }

  List<Widget> getOrderedProducts() {
    return orderedProductList.map((res) {
      // print(res);
      // double priceOfCurrentProduct = 0.0;
      // if (res['taxpercent'] != null) {
      //   final double taxValue = res['value'] *
      //       int.parse(res['taxpercent'].toString().replaceAll('%', '')) /
      //       100;
      //   setState(() {
      //     priceOfCurrentProduct = res['value'] + taxValue;
      //   });
      //   // print(priceOfCurrentProduct);
      // } else {
      //   setState(() {
      //     priceOfCurrentProduct = res['value'];
      //   });
      // }
      final String imageUrl = res['resourceUrl'];
      return Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
              margin: EdgeInsets.only(top: 5, left: 15, right: 15),
              child: Row(
                children: <Widget>[
                  Container(
                      child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                    // child: Image(
                    //   image: NetworkImage(res['resourceUrl']),
                    //   height: 120,
                    //   width: 120,
                    //   fit: BoxFit.fill,
                    // )),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: MediaQuery.of(context).size.height / (MediaQuery.of(context).size.aspectRatio * 12),
                      width: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.aspectRatio * 6.5),
                      fit: BoxFit.fill,
                      placeholder: (context, imageUrl) => customizedCircularLoadingIcon(15),
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 5),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Container(
                    //   child: Text(
                    //     res['productName'],
                    //     softWrap: true,
                    //     style: TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //         color: mainAppColor),
                    //   ),
                    // ),
                    // res['productDiscount'] != null
                    //     ? Container(
                    //         alignment: Alignment.center,
                    //         // margin: EdgeInsets.only(left: 14),
                    //         child: Text(
                    //           getDiscountedPrice(
                    //               res, priceOfCurrentProduct),
                    //           style: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 16.0),
                    //           // textAlign: TextAlign.justify,
                    //         ))
                    //     : Container(
                    //         alignment: Alignment.center,
                    //         child: res['appliedAgainst'] != null
                    //             ? Center(
                    //                 child: Text(
                    //                 res['currencyRepresentation'] +
                    //                     currencyFormatter
                    //                         .format(priceOfCurrentProduct)
                    //                         .toString() +
                    //                     ' ' +
                    //                     res['appliedAgainst'],
                    //                 textAlign: TextAlign.center,
                    //                 style: TextStyle(
                    //                     fontSize: 16,
                    //                     fontWeight: FontWeight.bold),
                    //               ))
                    //             : Text(
                    //                 res['currencyRepresentation'] +
                    //                     currencyFormatter
                    //                         .format(priceOfCurrentProduct)
                    //                         .toString(),
                    //                 style: TextStyle(
                    //                     fontWeight: FontWeight.bold,
                    //                     // color: Colors.grey[700],
                    //                     fontSize: 16),
                    //               ),
                    //       ),
                    Container(
                        width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / (MediaQuery.of(context).size.aspectRatio * 6.5) - 40,
                        child: RichText(
                          // textAlign: TextAlign.center,
                          softWrap: true,
                          text: TextSpan(style: appFonts.getTextStyle('cart_screen_product_name_default_style'), children: [
                            res['brandName'] != null ? TextSpan(text: res['brandName'] + " ", style: appFonts.getTextStyle('cart_screen_brandname_style')) : TextSpan(),
                            TextSpan(
                                text: res['productName'],
                                style: TextStyle(
                                  color: mainAppColor,
                                )),
                            res['specificationName'] != null ? TextSpan(text: " (" + res['specificationName'] + ")", style: appFonts.getTextStyle('cart_screen_specification_&_type_names_styles')) : TextSpan(),
                            res['productTypeName'] != null ? TextSpan(text: ", " + res['productTypeName'], style: appFonts.getTextStyle('cart_screen_specification_&_type_names_styles')) : TextSpan()
                          ]),
                        )),
                    res['totalAmount'] != null
                        ? Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              res['currencyRepresentation'] + currencyFormatter.format(res['totalAmount']),
                              style: appFonts.getTextStyle('feedback_screen_total_amount_text_style'),
                            ),
                          )
                        : Container(),
                    res['quantity'] != null
                        ? Container(
                            child: RichText(
                              text: TextSpan(style: appFonts.getTextStyle('text_color_black_style'), children: [
                                TextSpan(text: "Quantity : ", style: appFonts.getTextStyle('quantity_field_heading_text_style')),
                                TextSpan(text: res['quantity'].toString(), style: appFonts.getTextStyle('quantity_value_text_style')),
                                res['quantityRepresentation'] != null ? TextSpan(text: " " + res['quantityRepresentation'], style: appFonts.getTextStyle('quantity_value_text_style')) : TextSpan()
                              ]),
                            ),
                          )
                        : Container()
                  ])
                ],
              )));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.popAndPushNamed(context, '/yourorders');
          return Future.value(false);
        },
        child: Scaffold(
            key: scaffoldkey,
            appBar: appBarWidgetWithIconsAnSearchboxAndFilterIcon(context, true, this.setState, false, '/feedback', searchFieldKey, searchFieldController, searchFocusNode, scaffoldkey),
            endDrawer: showOrHideSearchAndFilter ? filterDrawer(this.setState, context, scaffoldkey, false, searchFieldController) : null,
            body: !isLoading
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // showOrHideSearchAndFilter
                    //     ? Container(
                    //         margin: EdgeInsets.only(top: 2, left: 10),
                    //         height: 40,
                    //         width: MediaQuery.of(context).size.width,
                    //         child: Row(children: [
                    //           Expanded(
                    //               flex: 3,
                    //               child: TextFormField(
                    //                   cursorColor: mainAppColor,
                    //                   controller: searchFieldController,
                    //                   onFieldSubmitted: (val) {
                    //                     // reset()\

                    //                     getSearchedData();
                    //                     formreset();
                    //                     // setState(() {
                    //                     //   feedbackKey.currentState.reset();
                    //                     // });
                    //                   },
                    //                   key: searchFieldKey,
                    //                   focusNode: searchFocusNode,
                    //                   decoration: InputDecoration(
                    //                       counterText: "",
                    //                       // alignLabelWithHint: true,
                    //                       hintText: "Search",
                    //                       border:
                    //                           AppStyles().searchBarBorder,
                    //                       // prefix: Text("+91 "),
                    //                       contentPadding:
                    //                           EdgeInsets.fromLTRB(
                    //                               14, 0, 0, 0),
                    //                       focusedBorder: AppStyles()
                    //                           .focusedSearchBorder,
                    //                       suffixIcon: IconButton(
                    //                         padding: EdgeInsets.all(0),
                    //                         icon: Icon(Icons.search),
                    //                         onPressed: () {
                    //                           getSearchedData();
                    //                           formreset();
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
                    //                     style:
                    //                         TextStyle(color: Colors.black),
                    //                   )
                    //                 ],
                    //               ),
                    //               onPressed: () {
                    //                 scaffoldkey.currentState
                    //                     .openEndDrawer();
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
                    //           //     formreset();
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
                    Container(
                      margin: EdgeInsets.only(left: 15, top: 5),
                      child: Text(
                        "Feedback Screen",
                        style: appFonts.getTextStyle('feedback_screen_heading_style'),
                      ),
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Center(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Text(
                            "Purchased Products",
                            style: appFonts.getTextStyle('purchased_products_text_style_in_all_screens'),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        orderedProductList.length > 0
                            ? Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: ListView(physics: NeverScrollableScrollPhysics(), shrinkWrap: true, children: getOrderedProducts()),
                              )
                            : Container(),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(padding: EdgeInsets.only(left: 15)),
                              Container(
                                width: 100,
                                child: Text(
                                  "Order ID  ",
                                  style: appFonts.getTextStyle('order_deatils_display_styles_for_list_view'),
                                ),
                              ),
                              Text(
                                ": " + "0" * (10 - orderIdForFeedback.toString().length) + orderIdForFeedback.toString(),
                                style: appFonts.getTextStyle('order_deatils_display_styles_for_list_view'),
                              )
                            ]),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(padding: EdgeInsets.only(left: 15, top: 15)),
                              Container(
                                width: 100,
                                child: Text(
                                  "Order Date  ",
                                  style: appFonts.getTextStyle('order_deatils_display_styles_for_list_view'),
                                ),
                              ),
                              Text(
                                ': ' + dateFormat.format(DateTime.parse(orderDateForFeedback.toString())),
                                style: appFonts.getTextStyle('order_deatils_display_styles_for_list_view'),
                              )
                            ]),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        orderDetails['orderDetails'] != null
                            ? Container(
                                child: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(left: 15)),
                                  Container(
                                    width: 100,
                                    child: Text("Total amount", style: appFonts.getTextStyle('order_deatils_display_styles_for_list_view')),
                                  ),
                                  Flexible(
                                    child: Text(": "),
                                  ),
                                  Flexible(
                                    child: Text(
                                      orderDetails['orderDetails']['currencyRepresentation'].toString() + currencyFormatter.format(orderDetails['orderDetails']['transactionAmount']),
                                      style: appFonts.getTextStyle('feedback_screen_total_amount_value_styles'),
                                    ),
                                  )
                                ],
                              ))
                            : Container(),
                        // _currentPosition != null
                        //     ? Container(
                        //         margin:
                        //             EdgeInsets.only(top: 10, left: 15),
                        //         child: Text(
                        //           _currentAddress,
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.bold),
                        //         ))
                        // : Container(
                        //     margin:
                        //         EdgeInsets.only(top: 10, left: 15),
                        //     child: Text(
                        //       "Please turn on location",
                        //       style: TextStyle(color: Colors.red),
                        //     )),
                        Container(
                            margin: EdgeInsets.only(top: 10, left: 15),
                            child: Text(
                              "Feedback :",
                              style: appFonts.getTextStyle('feedback_screen_feedback_field_text_style'),
                            )),
                        Padding(padding: EdgeInsets.only(left: 1, top: 10, right: 3)),
                        Container(
                            height: 100,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              key: feedbackKey,
                              focusNode: feedBackFocusNode,
                              maxLines: 10,
                              cursorColor: mainAppColor,
                              controller: feedbackText,
                              validator: (val) => feedbacktextvalidator(val),
                              onChanged: (val) {
                                feedbackKey.currentState.validate();
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter Your Feedback',
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: mainAppColor,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: mainAppColor,
                                    )),

                                // border: OutlineInputBorder(
                                //     borderRadius: BorderRadius.all(Radius.circular(2))),
                                // hoverColor: Colors.green,
                                // focusColor: Colors.green,
                              ),
                            )),
                        Container(child: Wrap(children: getImageConatinersWidgets())),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                        ),
                        Container(
                            child: Center(
                          child: Column(
                            children: <Widget>[
                              RaisedButton.icon(
                                icon: Icon(
                                  Icons.add_a_photo,
                                  // color: Colors.white,
                                ),
                                label: Text(
                                  "Add Photos/Videos ",
                                  // style: TextStyle(color: Colors.white),
                                ),
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(3.0)),
                                color: mainYellowColor,
                                onPressed: () {
                                  feedBackFocusNode.unfocus();
                                  _showDialouge(context);
                                  // setState(() {
                                  // count--;
                                  // });
                                },
                              ),
                              Padding(padding: EdgeInsets.only(top: 5)),
                              RaisedButton(
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(3.0)),
                                color: mainAppColor,
                                padding: EdgeInsets.only(left: 67.3, right: 67.3),
                                child: Text("Submit", style: appFonts.getTextStyle('button_text_color_white')),
                                onPressed: () {
                                  // _getCurrentLocation();
                                  // print(imagesOrVideos.length);
                                  displayLoadingIcon(context);
                                  _getCurrentLocation();
                                  // print(_currentPosition);
                                },
                              ),
                              // RaisedButton(
                              //   padding: EdgeInsets.only(left: 48, right: 48),
                              //   child: Text(" Re-Order ",
                              //       style: TextStyle(color: Colors.white)),
                              //   shape: new RoundedRectangleBorder(
                              //       borderRadius: new BorderRadius.circular(3.0)),
                              //   color: mainAppColor,
                              //   onPressed: () {
                              //     // Navigator.pushNamed(context, '/OfferDetails');
                              //   },
                              // ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                              ),
                              // Text("Thank You For Your Feedback",
                              //     style: TextStyle(
                              //       fontSize: 20,
                              //       fontWeight: FontWeight.bold,
                              //     )),
                              // // Padding(
                              //   padding: EdgeInsets.only(top: 3),
                              // ),
                              InkWell(
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(context, "/home", ModalRoute.withName("/home"));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          "Browse For More Products",
                                          style: appFonts.getTextStyle('browse_for_products_link_style'),
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
                                        ),
                                      )
                                    ],
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                              ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.center,
                              //   crossAxisAlignment:
                              //       CrossAxisAlignment.center,
                              //   children: <Widget>[
                              //     InkWell(
                              //       child: Text(
                              //         "Browse For More Products",
                              //         style: TextStyle(
                              //             color: Colors.blue,
                              //             // fontWeight: FontWeight.bold,
                              //             fontSize: 18),
                              //       ),
                              //       onTap: () {
                              //         Navigator.pushNamed(
                              //             context, '/home');
                              //       },
                              //     ),
                              //     Padding(
                              //         padding: EdgeInsets.only(
                              //             left: 0, top: 2)),
                              //     IconButton(
                              //         icon: Icon(
                              //             Icons.keyboard_arrow_right),
                              //         color: Colors.blue,
                              //         iconSize: 28,
                              //         onPressed: () {
                              //           Navigator.pushNamed(
                              //               context, '/home');
                              //         })
                              //   ],
                              // )
                            ],
                          ),
                        ))
                      ])),
                    ))
                  ])
                : Center(
                    child: customizedCircularLoadingIcon(50),
                  )));
  }

// It opens phone Location settings
  Future openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
    // _getCurrentLocation();
  }

// Checks location permissions and get current geo loaction by stream
  _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    GeolocationStatus geolocationStatus = await geolocator.checkGeolocationPermissionStatus();
    print(geolocationStatus);
    if (geolocationStatus == GeolocationStatus.granted) {
      var isGpsEnabled = await Geolocator().isLocationServiceEnabled();
      print(isGpsEnabled);
      if (isGpsEnabled) {
        print("data");
        if (locationDetails['pincode'] == null) {
          try {
            var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
            positionStream = Geolocator().getPositionStream(locationOptions).listen((Position position) {
              // setState(() {
              //   _currentPosition = position;
              // });
              print(position);
              if (position != null) {
                _getAddressFromLatLng(position);
                positionStream.cancel();
              } else {
                Navigator.pop(context);
              }
            });
          } catch (err) {
            Navigator.pop(context);
            print(err);
          }
        } else {
          if (feedbackKey.currentState.validate() && imagesOrVideos.length > 0) {
            print("sendFeedBAck");
            sendFeedBack(locationDetails);
          } else if (imagesOrVideos.length == 0) {
            Navigator.pop(context);
            showErrorNotifications("Please Add Photos/Videos", context, scaffoldkey);
          } else if (!feedbackKey.currentState.validate()) {
            Navigator.pop(context);
          }
        }
      } else {
        Navigator.pop(context);
        openLocationSetting();
      }
    } else {
      Navigator.pop(context);
      List<PermissionGroup> permissions = [
        PermissionGroup.location
      ];
      final res = await PermissionHandler().requestPermissions(permissions);
      print(res);
      // return null;
      // requestPermission(Permission permission);
      // SimplePermissions.requestPermission(Permission.AccessFineLocation);
    }
  }

// converts lattitude and longitude data into readble address
  _getAddressFromLatLng(Position position) async {
    print('data');
    List<Placemark> p = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = p[0];
    String area = "";
    if (place.subThoroughfare != null && place.subThoroughfare != "") {
      area = area + place.subThoroughfare + ", ";
    }
    if (place.thoroughfare != null && place.thoroughfare != "") {
      area = area + place.thoroughfare + ", ";
    }
    if (place.subLocality != null && place.subLocality != "") {
      area = area + place.subLocality;
    }
    // setState(() {
    locationDetails = {
      "area": area,
      "city": place.locality,
      "district": place.subAdministrativeArea,
      "state": place.administrativeArea,
      "pincode": place.postalCode,
      "country": place.country
    };
    print(locationDetails);

    if (feedbackKey.currentState.validate() && imagesOrVideos.length > 0) {
      print("sendFeedBAck");
      sendFeedBack(locationDetails);
    } else if (imagesOrVideos.length == 0) {
      Navigator.pop(context);
      showErrorNotifications("Please Add Photos/Videos", context, scaffoldkey);
    } else if (!feedbackKey.currentState.validate()) {
      Navigator.pop(context);
    }

    //   setState(() {
    //     _currentAddress =
    //         "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
    //   });
    // } catch (e) {
    //   print(e);
    // }
  }
}
