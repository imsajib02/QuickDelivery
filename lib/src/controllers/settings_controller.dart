import 'dart:convert';

import 'package:deliveryboy/src/helpers/helper.dart';
import 'package:deliveryboy/src/models/password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/credit_card.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class SettingsController extends ControllerMVC {
  CreditCard creditCard = new CreditCard();
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  String phone = "";
  FirebaseAuth _firebaseAuth;
  String verificationID;
  OverlayEntry loader;
  AuthCredential _authCredential;
  bool isCodeSent = false;

  SettingsController() {
    isCodeSent = false;
    loader = Helper.overlayLoader(context);
    _firebaseAuth = FirebaseAuth.instance;
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void sendOTP(SettingsController controller) {

    Overlay.of(context).insert(loader);

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: "+88" + phone,
      timeout: Duration(seconds: 0),
      verificationCompleted: (authCredential) {},
      verificationFailed: (authException) {

        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).otpSendingFailed),
        ));
      },
      codeSent: (verificationId, [token]) {

        //loader.remove();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        loader.remove();
        controller.verificationID = verificationId;
        Navigator.of(context).pushNamed('/ChangePhone', arguments: controller);
      },
    );
  }

  void verifyPhone(String code, BuildContext context) {

    FocusScope.of(context).unfocus();

    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();

      Overlay.of(context).insert(loader);

      _authCredential = PhoneAuthProvider.getCredential(verificationId: this.verificationID, smsCode: code);

      _firebaseAuth.signInWithCredential(_authCredential).then((authResult) async {

        if(authResult.user != null) {

          updatePhone();
        }
        else {

          loader.remove();

          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).failedToVerifyOTP),
          ));
        }
      }).catchError((error) async {

        loader.remove();

        if(error.toString().contains("ERROR_INVALID_VERIFICATION_CODE")) {

          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).invalidOTPCode),
          ));
        }
        else {

          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).failedToVerifyOTP),
          ));
        }
      });
    }
  }

  void update(User user) async {
    Overlay.of(context).insert(loader);
    user.deviceToken = null;
    repository.update(user).then((value) {

      loader.remove();

      if(value != null && value.apiToken != null) {

        setState(() {});
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).profileUpdatedSuccessFully),
        ));
      }
      else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).failedToUpdateProfile),
        ));
      }
    });
  }

  void updatePhone() async {
    User user = repository.currentUser.value;
    user.deviceToken = null;
    user.email = phone;
    repository.update(user).then((value) {

      loader.remove();

      if(value != null && value.apiToken != null) {

        setState(() {});

        try {

          Navigator.of(context).pop();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).phone_change_success),
          ));
        } catch(error) {
          print(error);
        }
      }
      else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).phone_change_failed),
        ));
      }
    });
  }

  void changePassword(Password password) async {

    Overlay.of(context).insert(loader);

    password.apiToken = repository.currentUser.value.apiToken;

    repository.changePassword(password).then((value) {

      loader.remove();

      try {
        if(json.decode(value)['status']) {

          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).password_change_success),
          ));
        }
        else {

          if(json.decode(value)['message'] == "Current password does not match") {

            scaffoldKey?.currentState?.showSnackBar(SnackBar(
              content: Text(S.of(context).old_password_do_not_match),
            ));
          }
        }
      }
      catch(error) {
        print(error);
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).password_change_failed),
        ));
      }
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    repository.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_settings_updated_successfully),
      ));
    });
  }

  void listenForUser() async {
    creditCard = await repository.getCreditCard();
    setState(() {});
  }

  Future<void> refreshSettings() async {
    creditCard = new CreditCard();
  }
}
