import 'dart:async';

import 'package:KhilafatCola/widgets/messages.dart';
import 'package:flutter/material.dart';

import 'package:panara_dialogs/panara_dialogs.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';


class AppFormFieldValidator {
  AppFormFieldValidator._();

  static String? cnicValidator(String? cnic) {
    if (cnic == null || cnic.isEmpty || cnic.length != 15) {
      return Messages.enterValidCNIC;
    }
    return null;
  }
  static String? pinValidator(String? pin) {
    if (pin == null || pin.isEmpty || pin.length != 6) {
      return Messages.enterValidPIN;
    }
    return null;
  }
  static String? cityValidator(String? city) {
    if (city == null || city.isEmpty || city.length != 15) {
      return Messages.enterValidCity;
    }
    return null;
  }
  static String? ageValidator(String? age) {
    if (age == null || age.isEmpty || age.length != 10) {
      return Messages.enterValidAge;
    }
    return null;
  }
  static String? phoneNumberValidator(String? number) {
    if (number == null || number.isEmpty) {
      return Messages.enterValidNumber;
    }
    return null;
  }

  static String? nameValidator(String? name) {
    if (name == null || name.isEmpty) {
      return Messages.enterName;
    }
    return null;
  }

  static String? registrationNumberValidator(String? number) {
    if (number == null || number.isEmpty) {
      return Messages.enterRegistrationNumber;
    }
    return null;
  }

  static String? addressValidator(String? address) {
    if (address == null || address.isEmpty) {
      return Messages.enterAddress;
    }
    return null;
  }

  static String? pinCode(String? pin) {
    if (pin == null || pin.isEmpty) {
      return Messages.enterPinCode;
    }
    return null;
  }

  static String? emailValidator(String? email) {
    if (email != null &&
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email)) {
      return null;
    }
    return Messages.enterValidEmail;
  }
}
void showModernDialog(BuildContext context, String title, String message,
    String buttonText, Function() onTapDismiss, PanaraDialogType type) {
  PanaraInfoDialog.show(
    context,
    title: title,
    message: message,
    buttonText: buttonText,
    onTapDismiss: () {
      Navigator.pop(context);
    },
    panaraDialogType: type,
  );
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool> connectivityStreamController =
  StreamController<bool>.broadcast();

  // ConnectivityService() {
  //   _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
  //     final isConnected = result != ConnectivityResult.none;
  //     connectivityStreamController.add(isConnected);
  //   });
  // }

  void dispose() {
    connectivityStreamController.close();
  }
}
