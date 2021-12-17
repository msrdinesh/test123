import 'package:connectivity/connectivity.dart';

String previousScreenRouteName = '';

class ConnectivityService {
  bool getConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        // print('No internet');
        return false;
        break;
      case ConnectivityResult.mobile:
        return true;
        break;
      case ConnectivityResult.wifi:
        return true;
        break;
      default:
        return false;
        break;
    }
  }
}
