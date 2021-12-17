import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/connectivityservice/connectivityservice.dart';

class ApiErros {
  apiErrorNotifications(
      err, context, previousRoute, GlobalKey<ScaffoldState> scaffoldKey) {
    if (err.toString().contains('errno = 101')) {
      previousScreenRouteName = previousRoute;
      // Navigator.of(context).pushNamed('/errorscreen');
      Navigator.of(context).pushReplacementNamed('/errorscreen');
    } else if (err.toString().contains("errno = 113")) {
      showErrorNotifications(
          ErrorMessages().serverSideErrors, context, scaffoldKey);
    } else if (err.toString().contains("errno = 103")) {
      showErrorNotifications(
          ErrorMessages().serverSideErrors, context, scaffoldKey);
    } else if (err.toString().contains("errno = 110")) {
      showErrorNotifications(
          ErrorMessages().connectionTimedOutError, context, scaffoldKey);
    }
  }

  apiLoggedErrors(data, context, GlobalKey<ScaffoldState> scaffoldKey) {
    if (data['error_description'].toString() == "Internal Server Error" ||
        data['error'].toString() == "Internal Server Error") {
      showErrorNotifications(
          ErrorMessages().serverSideErrors, context, scaffoldKey);
    } else if (data['apierror'] != null &&
        data['apierror']['status'] != null &&
        data['apierror']['status'] == "INTERNAL_SERVER_ERROR") {
      showErrorNotifications(
          ErrorMessages().serverSideErrors, context, scaffoldKey);
    }
  }
}
