class ErrorMessages {
  final String passwordNotEnteredError = "Please enter Password.";
  final String passwordValidationError =
      "Password must have atleast 6 characters and should have atleast 1 number and 1 alphabet.";
  final String mobileNoNotEnteredError = "Please enter Mobile Number.";
  final String mobileNoValidationError = "Please enter valid mobile number.";

  final String firstNameNotEnteredError = "Please enter First Name.";
  final String firstNameValidationError =
      "First Name should not contain special characters and should contain atleast one alphabet.";
  final String surNameNotEnteredError = "Please enter Surname.";
  final String surNameValidationError =
      "Surname should not contain special characters and should contain atleast one alphabet.";
  final String alternateMobileNoValidationError =
      "Please enter valid Mobile Number.";
  final String emailError = "Please enter valid Email address.";
  final String confirmPasswordNotEnteredError =
      "Please enter confirm Password.";
  final String confirmPasswordNotMatchedError = "Passwords doesn't match.";
  final String confirmPasswordErrorMessage = "Please enter valid Password.";
  final String houseNoNotEnteredError = "Please enter House Number.";
  final String houseNoNotValidError = "Please enter valid House Number.";
  final String streetNotEnteredError = "Please enter Street/Area";
  final String streetNotValidError =
      // "This field allows only alphanumerics and special characters.";
      "Please enter valid Street/Area .";
  final String cityNotEnteredError = "Please enter City/Town/Village.";
  final String cityNotValidError =
      // "City/Town/Village should conatin only alphabets";
      "Please enter valid City/Town/Village.";
  final String stateNotEntereError = "Please enter State.";
  final String stateNotValidError =
      // "State should conatin only alphabets";
      "Please enter valid State.";
  final String pincodeNotEnteredError = "Please enter PIN Code.";
  final String mobileNosSameValidationError =
      "Mobile number and Alternate Mobile Number should not be same.";
  final String pincodeNotValidError =
      // "PIN Code should contain 6 digits and it should not start with 0";
      "Please enter valid Pincode.";
  final String animalDetailsError = "Please select atleast one animal";
  final String otpNotEnteredError = "Please enter OTP.";
  final String otpValidationError =
      // "OTP should contain 6 digits";
      "Please enter valid OTP";
  final String userAlreadyExistsError =
      "The Mobile Number already exists. Please use a different Mobile Number";
  final String internetConnectionError = "Please check internet connection";
  final String serverSideErrors = "Something went wrong. We will fix it soon";
  final String forgotPasswordUserDoesNotExistError =
      "Please enter registered mobile number";
  final String forgotPasswordUserMobileNumberinvalid =
      "Please enter valid mobile number";
  final String forgotPasswordUserOtpExpired = "OTP Expired";
  final String forgotPasswordInvalidOtp = "Please enter valid OTP.";
  final String mobileNoOtpExpiredError = "Entered OTP is expired";
  final String invalidOtpError = "Please enter valid OTP.";
  final String invalidUserDetailsError = "Please enter valid credentials.";
  final String forgotPasswordUserPasswordFailed = "Please enter valid password";
  final String connectionTimedOutError =
      "Server not responding. Please wait for sometime.";
  final String farmDetailsErrorMessage = 'Please enter only numbers';
  final String animalFieldErrorMessage = 'Please enter only numbers';
  final String animalFieldNotEnteredError = "Please enter atleast one number";

  final String quantityErrorMessage = " Please enter valid Quantity";

  final String noResultsFoundMessage = 'No results found';
  final String removedFromFavoritesMessage = "Removed from Favorites";
  final String feedbackTextError = 'Please Enter Your Feedback';
  final String quantityLengthErrorMessage =
      "Quantity must be 4 or less than 4 digits";
  final String quantityNotEnteredMessage = "Please enter Quantity";
  final String couponCodeNotEnteredmessage = "Please enter Coupon code";
  final String stockPointNotAvialableMessage =
      "Stock point is not available. Please contact +91-9876543210";
  final String addressLinkedWithSubscriptionsError =
      "You cannot delete this address as this is linked to subscriptions.";
  final String subscriptionValidationErrorMessages =
      "Please enter valid number";
  final String subscriptionNotEnteredErrorMessages =
      "Please enter subscription details";
  final String subscriptionLengthErrorMessages =
      "Number must be 4 or less than 4 digits";
  final String failedToRegisterErrorMessage =
      "Failed to Register. Please try again";
  final String failedToUpdateProfileErrorMessage =
      "Failed to update your profile. Please try again";

  minimumQuantityError(int minimumQuantity, String unit) {
    if (unit != null && unit != '') {
      return "Quantity should be " +
          minimumQuantity.toString() +
          ' ' +
          unit +
          ' or above for this product';
    } else {
      return "Quantity should be " +
          minimumQuantity.toString() +
          ' or above for this product';
    }
  }
}
