import 'package:flutter/material.dart';
// import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'package:intl/intl.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:cornext_mobile/constants/appfonts.dart';

// List productDetails = [];
Map productSearchData = {"productSearchData": "", "productCategory": []};
String previousRouteName = '';
showFilterProductDetails(
  List productDetails,
  state,
  productShowMoreOrLess,
  ScrollPhysics scrollPhysics,
  bool shrinkable,
  BuildContext context,
  String routeName,
) {
  return ListView.builder(
    physics: scrollPhysics,
    shrinkWrap: shrinkable,
    itemCount: productDetails.length,
    itemBuilder: (BuildContext context, int index) {
      // print(productDetails[index]);
      final currencyFormatter = NumberFormat('#,##,###.00');
      double priceOfCurrentProduct = 0;
      // if (productDetails[index]['taxpercent'] != null) {
      //   final double taxValue = productDetails[index]['value'] *
      //       int.parse(productDetails[index]['taxpercent']
      //           .toString()
      //           .replaceAll('%', '')) /
      //       100;
      //   priceOfCurrentProduct = productDetails[index]['value'] + taxValue;
      // }
      // else {
      priceOfCurrentProduct = productDetails[index]['value'];
      // }
      return GestureDetector(
          onTap: () {
            if (productDetails[index]['productId'] != null) {
              productDetailsObject['productId'] =
                  productDetails[index]['productId'];
            }
            if (productDetails[index]['productTypeId'] != null) {
              productDetailsObject['productTypeId'] =
                  productDetails[index]['productTypeId'];
            }
            if (productDetails[index]['specificationId'] != null) {
              productDetailsObject['specificationId'] =
                  productDetails[index]['specificationId'];
            }
            productDetailsObject['screenName'] = 'PRD';
            previousRouteName = routeName;
            if (routeName == '/search') {
              Navigator.of(context).popAndPushNamed('/productdetails');
            } else {
              Navigator.of(context).pushNamed('/productdetails');
            }
          },
          child: Card(
              elevation: 2,
              // constraints: BoxConstraints(minHeight: 100),
              child: Column(
                // crossAxisAlignment:,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          // flex: 1,
                          width: 150,
                          height: 150,
                          margin: EdgeInsets.only(right: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5)),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: productDetails[index]['resourceUrl'],
                              placeholder: (context, imageUrl) =>
                                  customizedCircularLoadingIcon(15),
                            ),
                          )),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                                // textAlign: TextAlign.center,
                                softWrap: true,
                                // maxLines: 2,
                                // overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                    style: AppFonts().getTextStyle(
                                        'product_list_row_brand_name_style'),
                                    children: [
                                      productDetails[index]['brandName'] != null
                                          ? TextSpan(
                                              text: productDetails[index]
                                                          ['brandName']
                                                      .toString()
                                                      .toUpperCase() +
                                                  " ",
                                            )
                                          : TextSpan()
                                    ])),
                            RichText(
                              // textAlign: TextAlign.center,
                              softWrap: true,
                              // maxLines: 2,
                              // overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  style: AppFonts().getTextStyle(
                                      'product_list_row_product_name_style'),
                                  children: [
                                    TextSpan(
                                      text: productDetails[index]
                                          ['productName'],
                                    ),
                                    // productDetails[index]['specificationName'] !=
                                    //         null
                                    //     ? TextSpan(
                                    //         text: " (" +
                                    //             productDetails[index]
                                    //                 ['specificationName'] +
                                    //             ")",
                                    //         style: TextStyle(
                                    //             color: Colors.black, fontSize: 15))
                                    //     : TextSpan(),
                                    productDetails[index]['productTypeName'] !=
                                            null
                                        ? TextSpan(
                                            text: " - " +
                                                productDetails[index]
                                                    ['productTypeName'])
                                        : TextSpan(),
                                    productDetails[index]
                                                ['specificationName'] !=
                                            null
                                        ? TextSpan(
                                            text: " - " +
                                                productDetails[index]
                                                    ['specificationName'],
                                          )
                                        : TextSpan(),
                                  ]),
                            ),

                            AppStyles().customPadding(2),
                            productDetails[index]['animalImages'] != null
                                ? Container(
                                    width: MediaQuery.of(context).size.width -
                                        150 -
                                        5,
                                    height: 15,
                                    child: ListView(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      scrollDirection: Axis.horizontal,
                                      children: getAnimalIconsForRowWise(
                                          productDetails[index]
                                              ['animalImages']),
                                    ),
                                  )
                                : Container(),
                            // AppStyles().customPadding(3),
                            // productDetails[index]['brandName'] != null
                            //     ? Container(
                            //         child: Text(
                            //           productDetails[index]['brandName'],
                            //           style: TextStyle(
                            //               color: orangeColor, fontSize: 15),
                            //         ),
                            //       )
                            //     : Container(),
                            AppStyles().customPadding(2),
                            productDetails[index]['size'] != null &&
                                    productDetails[index]['size'] != ""
                                ? Container(
                                    margin: EdgeInsets.only(
                                        left: 7, top: 2, bottom: 2, right: 5),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Size: ',
                                        ),
                                        Text(
                                          productDetails[index]['size'],
                                          // productDetails[index]['units'] != null && productDetails[index]['units'] != "" ? productDetails[index]['size'] + " " + productDetails[index]['units'] :productDetails[index]['size'] ,
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            AppStyles().customPadding(2),
                            productDetails[index]['discountPrice'] != null
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(left: 7),
                                    child: RichText(
                                        textAlign: TextAlign.left,
                                        softWrap: true,
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: "Offer Price: ",
                                              style: AppFonts().getTextStyle(
                                                  'product_list_price_style_label')),
                                          TextSpan(
                                            text: productDetails[index]
                                                        ['appliedAgainst'] !=
                                                    null
                                                ? productDetails[index][
                                                        'currencyRepresentation'] +
                                                    currencyFormatter.format(
                                                        productDetails[index]
                                                            ['discountPrice']) +
                                                    ' ' +
                                                    productDetails[index]
                                                        ['appliedAgainst']
                                                : productDetails[index][
                                                        'currencyRepresentation'] +
                                                    currencyFormatter.format(
                                                        productDetails[index]
                                                            ['discountPrice']),
                                            style: AppFonts().getTextStyle(
                                                'product_list_price_style'),
                                            // textAlign: TextAlign.justify,
                                          ),
                                          // TextSpan(
                                          //     text: " (" +
                                          //         productDetails[index]
                                          //                 ['productDiscount']
                                          //             .toString() +
                                          //         ' off' +
                                          //         ")",
                                          //     style: AppFonts().getTextStyle(
                                          //         'product_list_discount_value_style'))
                                        ])))
                                : Container(),
                            AppStyles().customPadding(2),
                            priceOfCurrentProduct != -1
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(left: 7),
                                    child: RichText(
                                      // textAlign: TextAlign.center,
                                      softWrap: true,
                                      text: TextSpan(
                                          style: AppFonts().getTextStyle(
                                              'text_color_black_with_font_family'),
                                          children: [
                                            // AppStyles().customPadding(8),

                                            productDetails[index]
                                                        ['discountPrice'] !=
                                                    null
                                                ? productDetails[index][
                                                            'appliedAgainst'] !=
                                                        null
                                                    ? TextSpan(
                                                        children: [
                                                          TextSpan(
                                                              text: 'MRP: ',
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_size_and_price_fields_styles')),
                                                          TextSpan(
                                                            text: productDetails[
                                                                            index]
                                                                        [
                                                                        'currencyRepresentation']
                                                                    .toString() +
                                                                currencyFormatter
                                                                    .format(
                                                                        priceOfCurrentProduct) +
                                                                ' ' +
                                                                productDetails[
                                                                        index][
                                                                    'appliedAgainst'],
                                                            // textAlign: TextAlign.center,
                                                            style: AppFonts()
                                                                .getTextStyle(
                                                                    'product_list_orginal_price_style'),
                                                          )
                                                        ],
                                                      )
                                                    : TextSpan(
                                                        children: [
                                                          TextSpan(
                                                              text: 'MRP: ',
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_size_and_price_fields_styles')),
                                                          TextSpan(
                                                            text: productDetails[
                                                                            index]
                                                                        [
                                                                        'currencyRepresentation']
                                                                    .toString() +
                                                                currencyFormatter
                                                                    .format(
                                                                        priceOfCurrentProduct),
                                                            // textAlign: TextAlign.center,
                                                            style: AppFonts()
                                                                .getTextStyle(
                                                                    'product_list_orginal_price_style'),
                                                          )
                                                        ],
                                                      )
                                                // : Container()
                                                : productDetails[index][
                                                            'appliedAgainst'] !=
                                                        null
                                                    ? TextSpan(
                                                        children: [
                                                          TextSpan(
                                                              text: 'MRP: ',
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_price_style_label')),
                                                          TextSpan(
                                                            text: productDetails[
                                                                        index][
                                                                    'currencyRepresentation'] +
                                                                currencyFormatter
                                                                    .format(
                                                                        priceOfCurrentProduct) +
                                                                ' ' +
                                                                productDetails[
                                                                        index][
                                                                    'appliedAgainst'],
                                                            style: AppFonts()
                                                                .getTextStyle(
                                                                    'product_list_price_style'),
                                                          ),
                                                        ],
                                                      )
                                                    : TextSpan(children: [
                                                        TextSpan(
                                                            text: 'MRP: ',
                                                            style: AppFonts()
                                                                .getTextStyle(
                                                                    'product_list_price_style_label')),
                                                        TextSpan(
                                                          text: productDetails[
                                                                      index][
                                                                  'currencyRepresentation'] +
                                                              currencyFormatter
                                                                  .format(
                                                                      priceOfCurrentProduct)
                                                                  .toString(),
                                                          style: AppFonts()
                                                              .getTextStyle(
                                                                  'product_list_price_style'),
                                                        )
                                                      ]),
                                            // productDetails[index]
                                            //             ['productDiscount'] !=
                                            //         null
                                            //     ? TextSpan(
                                            //         text: ' ' +
                                            //             getSavedAmount(
                                            //                 productDetails[index],
                                            //                 priceOfCurrentProduct),
                                            //         // softWrap: true,
                                            //         style: TextStyle(
                                            //             fontStyle:
                                            //                 FontStyle.italic,
                                            //             fontSize: 15,
                                            //             color: orangeColor),
                                            //       )
                                            //     : TextSpan(),
                                          ]),
                                    ))
                                : Text(
                                    "Coming Soon",
                                    style: AppFonts().getTextStyle(
                                        'product_list_price_style'),
                                  ),

                            // productDetails[index]['productDiscount'] != null
                            //     ? Container(
                            //         alignment: Alignment.topLeft,
                            //         // margin: EdgeInsets.only(left: 14),
                            //         child: Text(
                            //           getDiscountedPrice(productDetails[index],
                            //               priceOfCurrentProduct),
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               fontSize: 18.0),
                            //           // textAlign: TextAlign.justify,
                            //         ))
                            //     : Container(),
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: <Widget>[
                            //     // AppStyles().customPadding(8),
                            //     productDetails[index]['productDiscount'] != null
                            //         ? Container(
                            //             // margin: EdgeInsets.only(top: 5),
                            //             child: productDetails[index]
                            //                         ['appliedAgainst'] !=
                            //                     null
                            //                 ? Text(
                            //                     productDetails[index][
                            //                                 'currencyRepresentation']
                            //                             .toString() +
                            //                         priceOfCurrentProduct
                            //                             .toString() +
                            //                         productDetails[index]
                            //                             ['appliedAgainst'],
                            //                     // textAlign: TextAlign.center,
                            //                     style: TextStyle(
                            //                         decoration:
                            //                             TextDecoration.lineThrough,
                            //                         // fontWeight: FontWeight.bold,
                            //                         color: Colors.grey[700],
                            //                         fontSize: 15),
                            //                   )
                            //                 : Text(
                            //                     productDetails[index]
                            //                             ['currencyRepresentation'] +
                            //                         priceOfCurrentProduct
                            //                             .toString(),
                            //                     // textAlign: TextAlign.center,
                            //                     style: TextStyle(
                            //                         decoration:
                            //                             TextDecoration.lineThrough,
                            //                         // fontWeight: FontWeight.bold,
                            //                         color: Colors.grey[700],
                            //                         fontSize: 15),
                            //                   ),
                            //           )
                            //         // : Container()
                            //         : Flexible(
                            //             child: productDetails[index]
                            //                         ['appliedAgainst'] !=
                            //                     null
                            //                 ? Text(
                            //                     productDetails[index]
                            //                             ['currencyRepresentation'] +
                            //                         priceOfCurrentProduct
                            //                             .toString() +
                            //                         productDetails[index]
                            //                             ['appliedAgainst'],
                            //                     style: TextStyle(
                            //                         fontSize: 18,
                            //                         fontWeight: FontWeight.bold),
                            //                   )
                            //                 : Text(
                            //                     productDetails[index]
                            //                             ['currencyRepresentation'] +
                            //                         priceOfCurrentProduct
                            //                             .toString(),
                            //                     textAlign: TextAlign.center,
                            //                     style: TextStyle(
                            //                         fontWeight: FontWeight.bold,
                            //                         // color: Colors.grey[700],
                            //                         fontSize: 18),
                            //                   ),
                            //           ),
                            //     AppStyles().customPadding(3),
                            //     productDetails[index]['productDiscount'] != null
                            //         ? Text(
                            //             "Save: " +
                            //                 getSavedAmount(productDetails[index],
                            //                     priceOfCurrentProduct),
                            //             style: TextStyle(
                            //                 fontStyle: FontStyle.italic,
                            //                 fontSize: 15,
                            //                 color: orangeColor),
                            //           )
                            //         : Container(),
                            //   ],
                            // ),
                            // AppStyles().customPadding(4),
                            // // ),
                            // productDetails[index]['productDescription'] != null
                            //     ? Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //             Text(
                            //               'Product Description:',
                            //               style: TextStyle(
                            //                   fontWeight: FontWeight.bold),
                            //             ),
                            //             productShowMoreOrLess[index]
                            //                 ? Column(children: [
                            //                     Text(productDetails[index]
                            //                                 ['productDescription']
                            //                             .toString()
                            //                         // maxLines: 2,
                            //                         ),
                            //                     InkWell(
                            //                       child: Row(
                            //                           mainAxisAlignment:
                            //                               MainAxisAlignment.end,
                            //                           children: [
                            //                             Text(
                            //                               'Show less',
                            //                               style: TextStyle(
                            //                                   color: Colors.blue),
                            //                             )
                            //                           ]),
                            //                       onTap: () {
                            //                         setShowMoreOrLessState(
                            //                             index,
                            //                             productShowMoreOrLess,
                            //                             state);
                            //                       },
                            //                     )
                            //                   ])
                            //                 : Column(children: [
                            //                     Text(productDetails[index][
                            //                                     'productDescription']
                            //                                 .toString()
                            //                                 .substring(0, 50) +
                            //                             '....'
                            //                         // maxLines: 2,
                            //                         ),
                            //                     InkWell(
                            //                       child: Row(
                            //                           mainAxisAlignment:
                            //                               MainAxisAlignment.end,
                            //                           children: [
                            //                             Text(
                            //                               'Show more',
                            //                               style: TextStyle(
                            //                                   color: Colors.blue),
                            //                             )
                            //                           ]),
                            //                       onTap: () {
                            //                         setShowMoreOrLessState(
                            //                             index,
                            //                             productShowMoreOrLess,
                            //                             state);
                            //                       },
                            //                     )
                            //                   ])
                            //           ])
                            //     : Container()
                          ],
                        ),
                      )
                      // Column(children: [
                      // ])
                    ],
                  ),
                  // ),
                  // Container(
                  //     // child: productDetails[index][''],
                  //     )
                ],
              )));
    },
  );
}

showProductDetails(
  List productDetails,
  state,
  productShowMoreOrLess,
  ScrollPhysics scrollPhysics,
  bool shrinkable,
  context,
  String routeName,
) {
  // final gridKey = GlobalKey();
  return Container(
      margin: EdgeInsets.only(left: 12, right: 12),
      child: GridView.count(
          physics: scrollPhysics,
          shrinkWrap: shrinkable,
          // controller: scrollController,
          // key: gridKey,
          crossAxisCount: 2,
          // childAspectRatio: MediaQuery.of(context).size.aspectRatio / 0.7,
          childAspectRatio: MediaQuery.of(context).orientation ==
                  Orientation.portrait
              ? ((MediaQuery.of(context).size.width - 24 - 10) / 2) /
                  (((MediaQuery.of(context).size.width - 24 - 10) / 2.1) + 180)
              : 1.1,
          // cacheExtent: 20,
          children: List.generate(
            productDetails.length,
            (int index) {
              // print(productDetails[index]);
              double priceOfCurrentProduct = 0;
              final currencyFormatter = NumberFormat('#,##,###.00');
              // if (productDetails[index]['taxpercent'] != null) {
              //   final double taxValue = productDetails[index]['value'] *
              //       int.parse(productDetails[index]['taxpercent']
              //           .toString()
              //           .replaceAll('%', '')) /
              //       100;
              //   priceOfCurrentProduct =
              //       productDetails[index]['value'] + taxValue;
              // } else {
              priceOfCurrentProduct = productDetails[index]['value'];
              // }

              final String imageUrl = productDetails[index]['resourceUrl'];
              return Card(
                  // margin: EdgeInsets.only(left: 7, top: 7),
                  // width: 150,
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.grey[300]),
                  //   borderRadius: BorderRadius.circular(5.0),
                  // ),
                  elevation: 2,
                  child: GestureDetector(
                    onTap: () {
                      if (productDetails[index]['productId'] != null) {
                        productDetailsObject['productId'] =
                            productDetails[index]['productId'];
                      }
                      if (productDetails[index]['productTypeId'] != null) {
                        productDetailsObject['productTypeId'] =
                            productDetails[index]['productTypeId'];
                      }
                      if (productDetails[index]['specificationId'] != null) {
                        productDetailsObject['specificationId'] =
                            productDetails[index]['specificationId'];
                      }
                      if (productDetails[index]['priceId'] != null) {
                        productDetailsObject['priceId'] =
                            productDetails[index]['priceId'];
                      }
                      if (signInDetails['access_token'] != null) {
                        productDetailsObject['userId'] =
                            signInDetails['userId'];
                      } else {
                        productDetailsObject['userId'] = null;
                      }
                      productDetailsObject['screenName'] = 'PRD';
                      previousRouteName = routeName;
                      if (routeName == '/search') {
                        Navigator.of(context)
                            .popAndPushNamed('/productdetails');
                      } else {
                        Navigator.of(context).pushNamed('/productdetails');
                      }
                    },

                    child: Column(
                      // crossAxisAlignment:,
                      children: <Widget>[
                        Container(
                            // flex: 1,
                            // width: gridKey.currentContext != null
                            //     ? gridKey.currentContext.size.width
                            //     : 185,
                            // height: gridKey != null
                            //     ? gridKey.currentContext.size.height / 2
                            //     : 120,
                            // width: 185,
                            width:
                                (MediaQuery.of(context).size.width - 24 - 10) /
                                    2,
                            height:
                                (MediaQuery.of(context).size.width - 24 - 10) /
                                    2.1,
                            // margin: EdgeInsets.only(right: 5),
                            // padding: EdgeInsets.only(top:),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: imageUrl,
                                placeholder: (context, imageUrl) =>
                                    customizedCircularLoadingIcon(15),
                              ),
                              // width: 20,
                              // height: 20,
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      left: 5, right: 5, top: 4, bottom: 4),
                                  child: RichText(
                                    // textAlign: TextAlign.center,
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        style: AppFonts().getTextStyle(
                                            'product_list_tile_product_name_style'),
                                        children: [
                                          productDetails[index]['brandName'] !=
                                                  null
                                              ? TextSpan(
                                                  text: productDetails[index]
                                                          ['brandName'] +
                                                      " ",
                                                )
                                              : TextSpan(),
                                          TextSpan(
                                              text: productDetails[index]
                                                  ['productName']),
                                          productDetails[index]
                                                      ['productTypeName'] !=
                                                  null
                                              ? TextSpan(
                                                  text: ", " +
                                                      productDetails[index]
                                                          ['productTypeName'],
                                                )
                                              : TextSpan(),
                                          productDetails[index]
                                                      ['specificationName'] !=
                                                  null
                                              ? TextSpan(
                                                  text: " - " +
                                                      productDetails[index]
                                                          ['specificationName'],
                                                )
                                              : TextSpan(),
                                        ]),
                                  )),
                              AppStyles().customPadding(4),
                              productDetails[index]['animalImages'] != null
                                  ? Container(
                                      width:
                                          (MediaQuery.of(context).size.width -
                                                  24 -
                                                  10) /
                                              2,
                                      height: 20,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: getAnimalInfo(
                                            productDetails[index]
                                                ['animalImages']),
                                      ))
                                  : Container(),
                              AppStyles().customPadding(4),
                              productDetails[index]['size'] != null &&
                                      productDetails[index]['size'] != ""
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(left: 7, right: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Size: ',
                                            style: AppFonts().getTextStyle(
                                                'product_list_price_style_label'),
                                          ),
                                          Text(productDetails[index]['size'],
                                              style: AppFonts().getTextStyle(
                                                  'product_list_price_style_label'))
                                        ],
                                      ),
                                    )
                                  : Container(),
                              productDetails[index]['size'] != null &&
                                      productDetails[index]['size'] != ""
                                  ? AppStyles().customPadding(4)
                                  : Container(),
                              productDetails[index]['discountPrice'] != null
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 7),
                                      child: RichText(
                                          textAlign: TextAlign.left,
                                          softWrap: true,
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text: 'Offer Price: ',
                                                style: AppFonts().getTextStyle(
                                                    'product_list_price_style_label')),
                                            TextSpan(
                                                text: productDetails[index]['appliedAgainst'] != null
                                                    ? productDetails[index][
                                                            'currencyRepresentation'] +
                                                        currencyFormatter.format(
                                                            productDetails[index]
                                                                [
                                                                'discountPrice']) +
                                                        ' ' +
                                                        productDetails[index]
                                                            ['appliedAgainst']
                                                    : productDetails[index][
                                                            'currencyRepresentation'] +
                                                        currencyFormatter.format(
                                                            productDetails[index]
                                                                ['discountPrice']),
                                                style: AppFonts().getTextStyle('product_list_price_style')
                                                // textAlign: TextAlign.justify,
                                                ),
                                          ])))
                                  : Container(),
                              AppStyles().customPadding(3),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 7),
                                  child: RichText(
                                    // textAlign: TextAlign.center,
                                    softWrap: true,
                                    text: TextSpan(
                                        style: AppFonts().getTextStyle(
                                            'text_color_black_with_font_family'),
                                        children: [
                                          // AppStyles().customPadding(8),

                                          priceOfCurrentProduct != -1
                                              ? productDetails[index]
                                                          ['discountPrice'] !=
                                                      null
                                                  ? productDetails[index][
                                                              'appliedAgainst'] !=
                                                          null
                                                      ? TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: 'MRP: ',
                                                                style: AppFonts()
                                                                    .getTextStyle(
                                                                        'product_list_size_and_price_fields_styles')),
                                                            TextSpan(
                                                              text: productDetails[
                                                                              index]
                                                                          [
                                                                          'currencyRepresentation']
                                                                      .toString() +
                                                                  currencyFormatter
                                                                      .format(
                                                                          priceOfCurrentProduct) +
                                                                  ' ' +
                                                                  productDetails[
                                                                          index]
                                                                      [
                                                                      'appliedAgainst'],
                                                              // textAlign: TextAlign.center,
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_orginal_price_style'),
                                                            )
                                                          ],
                                                        )
                                                      : TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: 'MRP: ',
                                                                style: AppFonts()
                                                                    .getTextStyle(
                                                                        'product_list_size_and_price_fields_styles')),
                                                            TextSpan(
                                                              text: productDetails[
                                                                              index]
                                                                          [
                                                                          'currencyRepresentation']
                                                                      .toString() +
                                                                  currencyFormatter
                                                                      .format(
                                                                          priceOfCurrentProduct),
                                                              // textAlign: TextAlign.center,
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_orginal_price_style'),
                                                            )
                                                          ],
                                                        )
                                                  // : Container()
                                                  : productDetails[index][
                                                              'appliedAgainst'] !=
                                                          null
                                                      ? TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'MRP: ',
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_price_style_label'),
                                                            ),
                                                            TextSpan(
                                                              text: productDetails[
                                                                          index]
                                                                      [
                                                                      'currencyRepresentation'] +
                                                                  currencyFormatter
                                                                      .format(
                                                                          priceOfCurrentProduct) +
                                                                  ' ' +
                                                                  productDetails[
                                                                          index]
                                                                      [
                                                                      'appliedAgainst'],
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_price_style'),
                                                            )
                                                          ],
                                                        )
                                                      : TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'MRP: ',
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_price_style_label'),
                                                            ),
                                                            TextSpan(
                                                              text: productDetails[
                                                                          index]
                                                                      [
                                                                      'currencyRepresentation'] +
                                                                  currencyFormatter
                                                                      .format(
                                                                          priceOfCurrentProduct)
                                                                      .toString(),
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_price_style'),
                                                            ),
                                                          ],
                                                        )
                                              : TextSpan(
                                                  text: "Coming Soon",
                                                  style: AppFonts().getTextStyle(
                                                      'product_list_price_style'),
                                                )
                                        ]),
                                  )),
                            ],
                          ),
                        )
                        // Column(children: [
                        // ])
                      ],
                    ),

                    // ),
                    // Container(
                    //     // child: productDetails[index][''],
                    //     )
                  ));
            },
          )));
}

showSuggestionsForProduct(
    List productDetails, state, ScrollController suggestionsScroll) {
  return ListView.builder(
    physics: AlwaysScrollableScrollPhysics(),
    // shrinkWrap: shrinkable,
    itemCount: productDetails.length,
    scrollDirection: Axis.horizontal,
    controller: suggestionsScroll,
    itemBuilder: (BuildContext context, int index) {
      // print(productDetails[index]);
      final currencyFormatter = NumberFormat('#,##,###.00');
      double priceOfCurrentProduct = 0;
      // if (productDetails[index]['taxpercent'] != null) {
      //   final double taxValue = productDetails[index]['value'] *
      //       int.parse(productDetails[index]['taxpercent']
      //           .toString()
      //           .replaceAll('%', '')) /
      //       100;
      //   priceOfCurrentProduct = productDetails[index]['value'] + taxValue;
      // } else {
      priceOfCurrentProduct = productDetails[index]['value'];
      // }

      final String imageUrl = productDetails[index]['resourceUrl'];
      return GestureDetector(
          onTap: () {
            final obj = {
              'userId': productDetailsObject['userId'] != null
                  ? productDetailsObject['userId']
                  : null,
              'priceId': productDetailsObject['priceId'] != null
                  ? productDetailsObject['priceId']
                  : null,
              'productId': productDetailsObject['productId'],
              'productTypeId': productDetailsObject['productTypeId'],
              'specificationId': productDetailsObject['specificationId'],
              'screenName': 'PRD'
            };
            if (previousProductDetails.indexWhere(
                    (val) => val['productId'] == obj['productId']) ==
                -1) {
              previousProductDetails.add(obj);
            }
            if (productDetails[index]['productId'] != null) {
              productDetailsObject['productId'] =
                  productDetails[index]['productId'];
            }
            if (productDetails[index]['productTypeId'] != null) {
              productDetailsObject['productTypeId'] =
                  productDetails[index]['productTypeId'];
            } else {
              productDetailsObject['productTypeId'] = null;
            }
            if (productDetails[index]['specificationId'] != null) {
              productDetailsObject['specificationId'] =
                  productDetails[index]['specificationId'];
            } else {
              productDetailsObject['specificationId'] = null;
            }
            if (productDetails[index]['priceId'] != null) {
              productDetailsObject['priceId'] =
                  productDetails[index]['priceId'];
            } else {
              productDetailsObject['priceId'] = null;
            }

            if (signInDetails['access_token'] != null) {
              productDetailsObject['userId'] = signInDetails['userId'];
            } else {
              productDetailsObject['userId'] = null;
            }
            productDetailsObject['screenName'] = 'PRD';
            // Navigator.of(context).pushNamed('/productdetails');
            // Navigator.of(context).pop();
            state(() {
              showOrHideSearchAndFilter = false;
            });
            Navigator.of(context).popAndPushNamed('/productdetails');
          },
          child: Container(
              width: 160,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  elevation: 4.0,
                  // constraints: BoxConstraints(minHeight: 100),
                  child: Column(children: <Widget>[
                    Container(
                        // flex: 1,
                        width: 150,
                        height: 150,
                        // margin: EdgeInsets.only(right: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          // child: Image(
                          //   image: NetworkImage(
                          //       productDetails[index]['resourceUrl']),
                          //   fit: BoxFit.fill,
                          //   // width: 20,
                          //   // height: 20,
                          // )
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.fill,
                            placeholder: (context, url) =>
                                customizedCircularLoadingIcon(15),
                          ),
                        )),
                    // Text(
                    //   productDetails[index]['productName'],
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 16,
                    //       color: secondaryGreenColor),
                    // ),
                    Expanded(
                        flex: 4,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // productDetails[index]['brandName'] !=
                              //                     null
                              //                 ? Container(
                              //   color: Colors.lightGreen[300],
                              //   height: 25,
                              //   padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                              //   margin: EdgeInsets.only(left: 5,right: 5,top: 4,bottom: 4),
                              //   child:  Text(
                              //                     productDetails[index]
                              //                             ['brandName'] +
                              //                         " ",
                              //                         style: TextStyle(fontWeight: FontWeight.w100,color: Colors.black54),
                              //                   )
                              //                 ,
                              // ) : Container(),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  // child: Text(
                                  //   productDetails[index]['productName'],
                                  //   textAlign: TextAlign.center,
                                  //   style: TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 16,
                                  //       fontFamily: 'Open Sans',
                                  //       // fontStyle: FontStyle.italic,
                                  //       color: secondaryGreenColor),
                                  // )
                                  margin: EdgeInsets.only(
                                      left: 5, right: 5, top: 4, bottom: 4),
                                  child: RichText(
                                    // textAlign: TextAlign.center,
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        style: AppFonts().getTextStyle(
                                            'product_list_tile_product_name_style'),
                                        children: [
                                          productDetails[index]['brandName'] !=
                                                  null
                                              ? TextSpan(
                                                  text: productDetails[index]
                                                          ['brandName'] +
                                                      " ",
                                                )
                                              : TextSpan(),
                                          TextSpan(
                                            text: productDetails[index]
                                                ['productName'],
                                          ),
                                          productDetails[index]
                                                      ['productTypeName'] !=
                                                  null
                                              ? TextSpan(
                                                  text: ", " +
                                                      productDetails[index]
                                                          ['productTypeName'],
                                                )
                                              : TextSpan(),
                                          productDetails[index]
                                                      ['specificationName'] !=
                                                  null
                                              ? TextSpan(
                                                  text: " - " +
                                                      productDetails[index]
                                                          ['specificationName'],
                                                )
                                              : TextSpan(),
                                        ]),
                                  )),

                              // AppStyles().customPadding(3),
                              AppStyles().customPadding(4),
                              // productDetails[index]['animalImages'] != null
                              //     ? Padding(
                              //         padding:
                              //             EdgeInsets.only(top: 5, bottom: 5))
                              //     : Container(),
                              productDetails[index]['animalImages'] != null
                                  ? Container(
                                      width: 150,
                                      height: 20,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: getAnimalInfo(
                                            productDetails[index]
                                                ['animalImages']),
                                      ))
                                  : Container(),
                              productDetails[index]['size'] != null &&
                                      productDetails[index]['size'] != ""
                                  ? AppStyles().customPadding(4)
                                  : Container(),
                              productDetails[index]['size'] != null &&
                                      productDetails[index]['size'] != ""
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(left: 7, right: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Size: ',
                                            style: AppFonts().getTextStyle(
                                                'product_list_price_style_label'),
                                          ),
                                          Text(
                                            productDetails[index]['size'],
                                            style: AppFonts().getTextStyle(
                                                'product_list_price_style_label'),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                              AppStyles().customPadding(4),
                              productDetails[index]['discountPrice'] != null
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 7),
                                      child: RichText(
                                          textAlign: TextAlign.left,
                                          softWrap: true,
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text: 'Offer Price: ',
                                                style: AppFonts().getTextStyle(
                                                    'product_list_price_style_label')),
                                            TextSpan(
                                              text: productDetails[index]
                                                          ['appliedAgainst'] !=
                                                      null
                                                  ? productDetails[index]['currencyRepresentation'] +
                                                      currencyFormatter.format(
                                                          productDetails[index][
                                                              'discountPrice']) +
                                                      ' ' +
                                                      productDetails[index]
                                                          ['appliedAgainst']
                                                  : productDetails[index][
                                                          'currencyRepresentation'] +
                                                      currencyFormatter.format(
                                                          productDetails[index]
                                                              ['discountPrice']),
                                              style: AppFonts().getTextStyle(
                                                  'product_list_price_style'),
                                              // textAlign: TextAlign.justify,
                                            ),
                                            // TextSpan(
                                            //     text: " (" +
                                            //         productDetails[index]
                                            //                 ['productDiscount']
                                            //             .toString() +
                                            //         ' off' +
                                            //         ")",
                                            //     style: AppFonts().getTextStyle(
                                            //         'product_list_discount_value_style'))
                                          ])))
                                  : Container(),
                              AppStyles().customPadding(3),
                              priceOfCurrentProduct > 0
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 7),
                                      child: RichText(
                                        // textAlign: TextAlign.center,
                                        softWrap: true,
                                        text: TextSpan(
                                            style: AppFonts().getTextStyle(
                                                'text_color_black_with_font_family'),
                                            children: [
                                              // AppStyles().customPadding(8),

                                              productDetails[index]
                                                          ['discountPrice'] !=
                                                      null
                                                  ? productDetails[index][
                                                              'appliedAgainst'] !=
                                                          null
                                                      ? TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: 'MRP: ',
                                                                style: AppFonts()
                                                                    .getTextStyle(
                                                                        'product_list_size_and_price_fields_styles')),
                                                            TextSpan(
                                                              text: productDetails[
                                                                              index]
                                                                          [
                                                                          'currencyRepresentation']
                                                                      .toString() +
                                                                  currencyFormatter
                                                                      .format(
                                                                          priceOfCurrentProduct) +
                                                                  ' ' +
                                                                  productDetails[
                                                                          index]
                                                                      [
                                                                      'appliedAgainst'],
                                                              // textAlign: TextAlign.center,
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_orginal_price_style'),
                                                            )
                                                          ],
                                                        )
                                                      : TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: 'MRP: ',
                                                                style: AppFonts()
                                                                    .getTextStyle(
                                                                        'product_list_size_and_price_fields_styles')),
                                                            TextSpan(
                                                              text: productDetails[
                                                                              index]
                                                                          [
                                                                          'currencyRepresentation']
                                                                      .toString() +
                                                                  currencyFormatter
                                                                      .format(
                                                                          priceOfCurrentProduct),
                                                              // textAlign: TextAlign.center,
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_orginal_price_style'),
                                                            )
                                                          ],
                                                        )
                                                  // : Container()
                                                  : productDetails[index][
                                                              'appliedAgainst'] !=
                                                          null
                                                      ? TextSpan(children: [
                                                          TextSpan(
                                                              text: 'MRP: ',
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_price_style_label')),
                                                          TextSpan(
                                                            text: productDetails[
                                                                        index][
                                                                    'currencyRepresentation'] +
                                                                currencyFormatter
                                                                    .format(
                                                                        priceOfCurrentProduct) +
                                                                ' ' +
                                                                productDetails[
                                                                        index][
                                                                    'appliedAgainst'],
                                                            style: AppFonts()
                                                                .getTextStyle(
                                                                    'product_list_price_style'),
                                                          )
                                                        ])
                                                      : TextSpan(children: [
                                                          TextSpan(
                                                              text: 'MRP: ',
                                                              style: AppFonts()
                                                                  .getTextStyle(
                                                                      'product_list_price_style_label')),
                                                          TextSpan(
                                                            text: productDetails[
                                                                        index][
                                                                    'currencyRepresentation'] +
                                                                currencyFormatter
                                                                    .format(
                                                                        priceOfCurrentProduct)
                                                                    .toString(),
                                                            style: AppFonts()
                                                                .getTextStyle(
                                                                    'product_list_price_style'),
                                                          )
                                                        ]),
                                              // productDetails[index]
                                              //             ['productDiscount'] !=
                                              //         null
                                              //     ? TextSpan(
                                              //         text: ' ' +
                                              //             getSavedAmount(
                                              //                 productDetails[index],
                                              //                 priceOfCurrentProduct),
                                              //         // softWrap: true,
                                              //         style: TextStyle(
                                              //             fontStyle:
                                              //                 FontStyle.italic,
                                              //             fontSize: 15,
                                              //             color: orangeColor),
                                              //       )
                                              //     : TextSpan(),
                                            ]),
                                      ))
                                  : Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 7),
                                      child: RichText(
                                          // textAlign: TextAlign.center,
                                          softWrap: true,
                                          text: TextSpan(
                                              style: AppFonts().getTextStyle(
                                                  'text_color_black_with_font_family'),
                                              children: [
                                                TextSpan(
                                                  text: "Coming Soon",
                                                  style: AppFonts().getTextStyle(
                                                      'product_list_price_style'),
                                                ),
                                              ]))),
                            ])),
                    // productDetails[index]['taxpercent'] != null
                    //     ? Text(
                    //         " +" +
                    //             productDetails[index]['taxpercent'] +
                    //             " " +
                    //             productDetails[index]['taxRepresentation'],
                    //         style: TextStyle(
                    //             // fontWeight: FontWeight.w500
                    //             ))
                    //     : Text(''),
                  ]))));
    },
  );
}

String getDiscountedPrice(productInfo, double productPrice) {
  // if(productInfo[''])
  final currencyFormatter = NumberFormat('#,##,###.00');
  final double discountedValue = productPrice *
      int.parse(productInfo['productDiscount'].toString().replaceAll('%', '')) /
      100;
  final double discountedPrice = productPrice - discountedValue;
  String productValue = '';
  if (productInfo['appliedAgainst'] != null) {
    productValue = productInfo['currencyRepresentation'] +
        currencyFormatter.format(discountedPrice).toString() +
        " " +
        productInfo['appliedAgainst'];
  } else {
    productValue = productInfo['currencyRepresentation'] +
        currencyFormatter.format(discountedPrice).toString();
  }
  return productValue;
}

getSavedAmount(productInfo, double productPrice) {
  final currencyFormatter = NumberFormat('#,##,###.00');
  // final double discountedValue = productPrice *
  //     int.parse(productInfo['productDiscount'].toString().replaceAll('%', '')) /
  //     100;
  final double discountedValue = productPrice - productInfo['discountPrice'];
  String savedValue = '';
  if (productInfo['appliedAgainst'] != null) {
    savedValue = productInfo['currencyRepresentation'].toString() +
        currencyFormatter.format(discountedValue) +
        " " +
        productInfo['appliedAgainst'];
  } else {
    savedValue = productInfo['currencyRepresentation'].toString() +
        currencyFormatter.format(discountedValue).toString();
  }
  return savedValue;
}

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

List<Container> getAnimalInfo(List animalsInfo) {
  // print(animalsInfo);
  return animalsInfo.map((val) {
    return val.indexOf('Other') != -1 && val.indexOf('Icon') != -1
        ? Container(
            margin: EdgeInsets.only(right: 2, left: 5),
            child: CachedNetworkImage(
              imageUrl: val,
              height: 20,
              width: 50,
            ))
        : Container(
            margin: EdgeInsets.only(right: 5, left: 5),
            child: CachedNetworkImage(
              imageUrl: val,
              height: 20,
              width: 25,
            ));
  }).toList();
}

List<Container> getAnimalIconsForRowWise(List animalsInfo) {
  // print(animalsInfo);
  return animalsInfo.map((val) {
    return val.indexOf('Other') != -1 && val.indexOf('Icon') != -1
        ? Container(
            margin: EdgeInsets.only(right: 2, left: 5),
            child: CachedNetworkImage(
              imageUrl: val,
              height: 15,
              width: 50,
            ))
        : Container(
            margin: EdgeInsets.only(right: 5, left: 5),
            child: CachedNetworkImage(
              imageUrl: val,
              height: 15,
              width: 25,
            ));
  }).toList();
}
