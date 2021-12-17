final RegExp passwordRegex =
    RegExp(r"^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{6,}$");
final RegExp nameRegex = RegExp(r"^(?=.*[a-zA-Z])[a-zA-Z0-9 ]{0,75}$");
// final RegExp nameRegex = RegExp(r"^(?=.*[a-zA-Z])[^-\s][a-zA-Z0-9\s-]{0,75}$");

final RegExp emailRegex = RegExp(
    r"^(([^<>()\[\]\\.,;:\s@']+(\.[^<>()\[\]\\.,;:\s@']+)*)|('.+'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$");
final RegExp alphabetAndNumberRegex = RegExp(r"/^[a-zA-Z0-9]*$/");
final RegExp indianMobileNoRegex = RegExp(r"^((?!(0))[0-9]{10})$");
final RegExp pincodeRegex = RegExp(r"[0-9]{6}$");
final RegExp onlyAlphabets = RegExp(r"^[a-zA-Z ]*$");
final RegExp alphabetAndNumberAndSpecialCharactersRegex =
    RegExp(r"^[a-zA-Z0-9-+()/\., _@&]*$");
final RegExp onlyNumberRegex = RegExp(r"[0-9]*$");
final RegExp otherThanNumbersRegex = RegExp(r"^[a-zA-Z-+()/\., _@&]*$");
