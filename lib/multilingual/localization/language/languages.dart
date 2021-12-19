import 'package:flutter/material.dart';

abstract class Languages {
  static Languages of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get home;
  String get profile;
  String get subscriptions;
  String get yourOrders;
  String get deliveryAddress;
  String get faqs;
  String get logout;
  String get signIn;
  String get cont;
}
