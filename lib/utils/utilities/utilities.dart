import 'dart:convert';

class Utilities {
  String passwordEncode(String password) {
    var encoded = base64Encode(utf8.encode(password));
    String encodedPassword = encoded.replaceAll('/', '');
    encodedPassword = encodedPassword.replaceAll('+', '');
    encodedPassword = encodedPassword.replaceAll('=', '');
    return encodedPassword;
  }
}
