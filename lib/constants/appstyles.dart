import 'package:flutter/material.dart';
import 'package:cornext_mobile/constants/appcolors.dart';

class AppStyles {
  final borderRadius = BorderRadius.all(Radius.circular(25));
  final focusedBorderColor = OutlineInputBorder(
      borderSide: BorderSide(
    color: mainAppColor,
  ));
  final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: mainAppColor,
      ));
  final focusedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: mainAppColor,
      ));

  Widget customPadding(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
    );
  }

  final contentPaddingForInput = EdgeInsets.all(14);
  final contentPaddingForSmallInput = EdgeInsets.all(5);

  final searchBarBorder =
      OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)));
  final focusedSearchBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(
        color: mainAppColor,
      ));
}
