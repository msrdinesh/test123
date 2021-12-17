import 'package:cornext_mobile/constants/regularexpression.dart';
import 'package:cornext_mobile/constants/errormessages.dart';
import 'package:cornext_mobile/components/widgets/notifications.dart';
import 'package:flutter/material.dart';

class GlobalValidations {
  String passwordValidations(
      String val,
      TextEditingController confirmPasswordController,
      GlobalKey<FormFieldState> confirmPasswordkey) {
    print(confirmPasswordController.text.trim());
    if (val == "") {
      return ErrorMessages().passwordNotEnteredError;
    } else if (val.toLowerCase().indexOf(RegExp(r'[a-z]')) == -1 ||
        val.indexOf(RegExp(r'[0-9]')) == -1 ||
        val.length < 6) {
      return ErrorMessages().passwordValidationError;
    } else if (val != '' && confirmPasswordController.text.trim() != '') {
      confirmPasswordkey.currentState?.validate();
    }
    return null;
  }

  String signInPasswordValidations(String val) {
    if (val == "") {
      return ErrorMessages().passwordNotEnteredError;
    }
    return null;
  }

  String mobileValidations(
    String val,
    // TextEditingController alternateMobileNoContoller,
    // GlobalKey<FormFieldState> alternateMobileNoKey) {
  ) {
    if (val == "") {
      return ErrorMessages().mobileNoNotEnteredError;
    } else if (val.length < 10) {
      return ErrorMessages().mobileNoValidationError;
    } else if (!indianMobileNoRegex.hasMatch(val)) {
      return ErrorMessages().mobileNoValidationError;
    }

    // if (val != '' && alternateMobileNoContoller.text.trim() != '') {
    //   alternateMobileNoKey.currentState?.validate();
    // }
    return null;
  }

  String mobileValidationsReg(
      String val,
      TextEditingController alternateMobileNoContoller,
      GlobalKey<FormFieldState> alternateMobileNoKey) {
    if (val == "") {
      return ErrorMessages().mobileNoNotEnteredError;
    } else if (val.length < 10) {
      return ErrorMessages().mobileNoValidationError;
    } else if (!indianMobileNoRegex.hasMatch(val)) {
      return ErrorMessages().mobileNoValidationError;
    }

    if (val != '' && alternateMobileNoContoller.text.trim() != '') {
      alternateMobileNoKey.currentState?.validate();
    }
    return null;
  }

  String signInmobileValidations(val) {
    if (val == "") {
      return ErrorMessages().mobileNoNotEnteredError;
    } else if (val.length < 10) {
      return ErrorMessages().mobileNoValidationError;
    }
    return null;
  }

  String animalFieldValidations(String val, String animalName) {
    // if(val == ""){
    //   return Error
    // }
    // print(val);
    if ((!onlyNumberRegex.hasMatch(val) && val.trim() != '') ||
        val.contains('.') ||
        val.contains('-') ||
        val.contains(' ') ||
        val.toLowerCase().indexOf(RegExp(r'[a-z,-.@_+*^%$#@!&]')) != -1) {
      return ErrorMessages().animalFieldErrorMessage;
    } else if (val.trim() == "") {
      return ErrorMessages().animalFieldNotEnteredError;
    }
    return null;
  }

  String quantityValidations(String val, int minimumQuantity, String unit) {
    // if(val == ""){
    //   return Error
    // }
    // print(val);
    if ((!onlyNumberRegex.hasMatch(val) && val != '') ||
        val.contains('.') ||
        val.contains('-') ||
        val.contains(' ') ||
        val.toLowerCase().indexOf(RegExp(r'[a-z,-.@_+*^%$#@!&]')) != -1) {
      return ErrorMessages().quantityErrorMessage;
    } else if (val.trim().length > 0 &&
        int.parse(val.trim()) != null &&
        int.parse(val.trim()) == 0) {
      return ErrorMessages().quantityErrorMessage;
    } else if (minimumQuantity != null &&
        val.trim().length > 0 &&
        int.parse(val.trim()) != null &&
        int.parse(val.trim()) < minimumQuantity) {
      return ErrorMessages().minimumQuantityError(minimumQuantity, unit);
    } else if (val.length > 4) {
      return ErrorMessages().quantityLengthErrorMessage;
    } else if (val == "") {
      return ErrorMessages().quantityNotEnteredMessage;
    }
    return null;
  }

  String unitsQuantityValidations(
      String val, int minimumQuantity, String unit) {
    // if(val == ""){
    //   return Error
    // }
    // print(val);
    if ((!onlyNumberRegex.hasMatch(val) && val != '') ||
        val.contains('.') ||
        val.contains('-') ||
        val.contains(' ') ||
        val.toLowerCase().indexOf(RegExp(r'[a-z,-.@_+*^%$#@!&]')) != -1) {
      return ErrorMessages().quantityErrorMessage;
    } else if (val.trim().length > 0 &&
        int.parse(val.trim()) != null &&
        int.parse(val.trim()) == 0) {
      return ErrorMessages().quantityErrorMessage;
    } else if (minimumQuantity != null &&
        val.trim().length > 0 &&
        int.parse(val.trim()) != null &&
        int.parse(val.trim()) < minimumQuantity) {
      return ErrorMessages().minimumQuantityError(minimumQuantity, unit);
    } else if (val.length > 4) {
      return ErrorMessages().quantityLengthErrorMessage;
    } else if (val == "") {
      return ErrorMessages().quantityNotEnteredMessage;
    }
    return null;
  }

  String subscriptionValidations(String val) {
    // if(val == ""){
    //   return Error
    // }
    // print(val);
    if ((!onlyNumberRegex.hasMatch(val) && val != '') ||
        val.contains('.') ||
        val.contains('-') ||
        val.contains(' ') ||
        val.toLowerCase().indexOf(RegExp(r'[a-z,-.@_+*^%$#@!&]')) != -1) {
      return ErrorMessages().subscriptionValidationErrorMessages;
    } else if (val.trim().length > 0 &&
        int.parse(val.trim()) != null &&
        int.parse(val.trim()) == 0) {
      return ErrorMessages().subscriptionValidationErrorMessages;
    } else if (val.length > 4) {
      return ErrorMessages().subscriptionLengthErrorMessages;
    } else if (val == "") {
      return ErrorMessages().subscriptionNotEnteredErrorMessages;
    } else if (val == null) {
      return ErrorMessages().subscriptionNotEnteredErrorMessages;
    }
    return null;
  }

  String advancePaymentValidations(String val) {
    // if(val == ""){
    //   return Error
    // }
    // print(val);
    if ((!onlyNumberRegex.hasMatch(val) && val != '') ||
        val.contains('.') ||
        val.contains('-') ||
        val.contains(' ') ||
        val.toLowerCase().indexOf(RegExp(r'[a-z,-.@_+*^%$#@!&]')) != -1) {
      return ErrorMessages().quantityErrorMessage;
    } else if (int.parse(val.trim()) != null && int.parse(val.trim()) == 0) {
      return ErrorMessages().quantityErrorMessage;
    } else if (val.length > 4) {
      return ErrorMessages().quantityLengthErrorMessage;
    }
    return null;
  }

  // String customerRegistrationMobileValidations(val, alternateMobileNo) {
  //   if (val == "") {
  //     return ErrorMessages().mobileNoNotEnteredError;
  //   } else if (val.length < 10) {
  //     return ErrorMessages().mobileNoValidationError;
  //   }
  //   return null;

  String firstNameValidations(val) {
    if (val == "") {
      return ErrorMessages().firstNameNotEnteredError;
    } else if (!nameRegex.hasMatch(val)) {
      return ErrorMessages().firstNameValidationError;
    } else if (val.trim().length > 75) {
      return ErrorMessages().firstNameValidationError;
    }
    return null;
  }

  String surNameValidations(val) {
    if (val == "") {
      return ErrorMessages().surNameNotEnteredError;
    } else if (!nameRegex.hasMatch(val)) {
      return ErrorMessages().surNameValidationError;
    } else if (val.trim().length > 75) {
      return ErrorMessages().surNameValidationError;
    }
    return null;
  }

  String emailValidations(val) {
    if (val.trim() != '' && !emailRegex.hasMatch(val)) {
      return ErrorMessages().emailError;
    } else if (!alphabetAndNumberAndSpecialCharactersRegex.hasMatch(val)) {
      return ErrorMessages().emailError;
    }
    return null;
  }

  String alternateMobileNoValidations(val, mobileNo) {
    if (val != '' && val.length < 10) {
      return ErrorMessages().alternateMobileNoValidationError;
    } else if (val != '' && mobileNo != '' && val == mobileNo) {
      return ErrorMessages().mobileNosSameValidationError;
    } else if (val != '' && !indianMobileNoRegex.hasMatch(val)) {
      return ErrorMessages().alternateMobileNoValidationError;
    }
    return null;
  }

  String confirmPasswrodValidations(val, passwordValue) {
    // print(val);
    if (passwordValue.length > 1) {
      if (val == '') {
        return ErrorMessages().confirmPasswordNotEnteredError;
      } else if (val != passwordValue) {
        return ErrorMessages().confirmPasswordNotMatchedError;
      } else if (val.toLowerCase().indexOf(RegExp(r'[a-z]')) == -1 ||
          val.indexOf(RegExp(r'[0-9]')) == -1 ||
          val.length < 6) {
        return ErrorMessages().confirmPasswordErrorMessage;
      }
    }
    return null;
  }

  String houseNumberValidations(val, isSameAsDeliveryAddress) {
    if (val == '' && isSameAsDeliveryAddress) {
      return ErrorMessages().houseNoNotEnteredError;
    } else if (val.trim().length > 75) {
      return ErrorMessages().houseNoNotValidError;
    } else if (!alphabetAndNumberAndSpecialCharactersRegex.hasMatch(val)) {
      return ErrorMessages().houseNoNotValidError;
    }
    return null;
  }

  String streetValidations(val, isSameAsDeliveryAddress) {
    if (val == '' && isSameAsDeliveryAddress) {
      return ErrorMessages().streetNotEnteredError;
    } else if (val.trim().length > 75) {
      return ErrorMessages().streetNotValidError;
    } else if (!alphabetAndNumberAndSpecialCharactersRegex.hasMatch(val)) {
      return ErrorMessages().streetNotValidError;
    }
    return null;
  }

  String cityValidations(val) {
    if (val == '') {
      return ErrorMessages().cityNotEnteredError;
    } else if (!onlyAlphabets.hasMatch(val)) {
      return ErrorMessages().cityNotValidError;
    } else if (val.trim().length > 75) {
      return ErrorMessages().cityNotValidError;
    }
    return null;
  }

  String stateValidations(val) {
    if (val == '') {
      return ErrorMessages().stateNotEntereError;
    } else if (!onlyAlphabets.hasMatch(val)) {
      return ErrorMessages().stateNotValidError;
    } else if (val.trim().length > 75) {
      return ErrorMessages().stateNotValidError;
    }
    return null;
  }

  String pincodeValidations(String val) {
    if (val == '') {
      return ErrorMessages().pincodeNotEnteredError;
    } else if (val.trim().length < 6 || val.startsWith("0")) {
      return ErrorMessages().pincodeNotValidError;
    } else if (!pincodeRegex.hasMatch(val)) {
      return ErrorMessages().pincodeNotValidError;
    }
    return null;
  }

  String animalDetailsValidations(List subCategeries) {
    // if (!cowsCheck && !buffaloCheck) {
    List<bool> isSubCategeriesChecked = [];
    List<bool> isFarmDetailsValid = [];
    subCategeries.forEach((val) {
      if (val[val['path'] + 'isChecked'] &&
          val[val['path'] + 'totalNo'] != null) {
        isSubCategeriesChecked.add(true);
      }
      if (val[val['path'] + 'formKey'] != null &&
          val[val['path'] + 'formKey'].currentState != null &&
          !val[val['path'] + 'formKey'].currentState.validate()) {
        isFarmDetailsValid.add(false);
      }
    });
    if (isSubCategeriesChecked.length <= 0) {
      return ErrorMessages().animalDetailsError;
    }

    if (isFarmDetailsValid.length > 0) {
      return ErrorMessages().farmDetailsErrorMessage;
    }

    // }
    return null;
  }

  String otpValidations(val) {
    if (val == '') {
      return ErrorMessages().otpNotEnteredError;
    } else if (val.length < 6) {
      return ErrorMessages().otpValidationError;
    }
    return null;
  }

  String couponCodeValidations(val) {
    if (val.trim() == '') {
      return ErrorMessages().couponCodeNotEnteredmessage;
    }
    return null;
  }

  // On blur validation for a field
  validateCurrentFieldValidOrNot(
      FocusNode focusNode, GlobalKey<FormFieldState> key) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        key.currentState.validate();
        // focusNode.unfocus();
      }
    });
  }

  validateCurrentQuantityField(
      FocusNode focusNode,
      GlobalKey<FormFieldState> key,
      context,
      GlobalKey<ScaffoldState> scaffoldKey) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (!key.currentState.validate()) {
          // closeNotifications();
          clearErrorMessages(scaffoldKey);
          showErrorNotifications(
              key.currentState.errorText, context, scaffoldKey);
        }
        // focusNode.unfocus();
      }
    });
  }

  validateCurrentFarmFieldValidOrNot(
      FocusNode focusNode,
      GlobalKey<FormFieldState> key,
      context,
      GlobalKey<ScaffoldState> scaffoldKey) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (!key.currentState.validate()) {
          // closeNotifications();
          clearErrorMessages(scaffoldKey);
          showErrorNotifications(
              key.currentState.errorText, context, scaffoldKey);
        }
        // focusNode.unfocus();
      }
    });
  }
}
