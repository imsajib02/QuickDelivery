import 'dart:async';
import 'dart:convert';

import 'package:deliveryboy/src/models/otp_verify.dart';
import 'package:deliveryboy/src/models/password.dart';
import 'package:deliveryboy/src/pages/password_reset_otp_verify.dart';
import 'package:deliveryboy/src/pages/reset_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  FirebaseAuth _firebaseAuth;
  bool passwordResetSuccess = false;
  AuthCredential _authCredential;
  OverlayEntry loader;
  int resendingToken;
  String verificationID;
  Timer _timer;
  int timeOut;

  UserController() {
    passwordResetSuccess = false;
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseAuth = FirebaseAuth.instance;
    _firebaseMessaging.getToken().then((String _deviceToken) {
      print("Firebase Device Token: " + _deviceToken);
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(S.of(context).thisAccountNotExist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void sendOTP() {

    FocusScope.of(context).unfocus();

    if(loginFormKey.currentState.validate()) {

      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);

      String phoneNumber = "+88" + user.email;

      _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 0),
        verificationCompleted: (authCredential) {},
        verificationFailed: (authException) {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).otpSendingFailed),
          ));
        },
        codeSent: (verificationId, [token]) {
          resendingToken = token;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          loader.remove();
          OtpVerify otpVerify = OtpVerify(verificationID: verificationId, resendingToken: resendingToken, user: user);
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/MobileVerification2', arguments: otpVerify);
        },
      );
    }
  }

  void startCountDown() {

    repository.timeOut.value = 60;
    //timeOut = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {

      if(repository.timeOut.value == 0) {

        timer.cancel();
      }
      else if(repository.timeOut.value > 0) {

        repository.timeOut.value = repository.timeOut.value - 1;
      }
    });
  }

  void resendOTP(String phone) {

    FocusScope.of(context).unfocus();

    if(resendingToken != null) {

      Overlay.of(context).insert(loader);

      String phoneNumber = "+88" + phone;

      _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 0),
        forceResendingToken: resendingToken,
        verificationCompleted: (authCredential) {},
        verificationFailed: (authException) {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).otpSendingFailed),
          ));
        },
        codeSent: (verificationId, [token]) {
          this.resendingToken = token;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          this.verificationID = verificationId;
          loader.remove();
          startCountDown();
        },
      );
    }
  }

  void verifyCode(String code, OtpVerify otpVerify) {

    FocusScope.of(context).unfocus();

    if(loginFormKey.currentState.validate()) {

      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);

      _authCredential = PhoneAuthProvider.getCredential(verificationId: this.verificationID, smsCode: code);

      _firebaseAuth.signInWithCredential(_authCredential).then((authResult) async {

        if(authResult.user != null) {
          register(otpVerify.user);
        }
        else {

          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).failedToVerifyOTP),
          ));
        }
      }).catchError((error) async {

        loader.remove();

        if(error.toString().contains("ERROR_INVALID_VERIFICATION_CODE")) {

          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).invalidOTPCode),
          ));
        }
        else {

          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).failedToVerifyOTP),
          ));
        }
      });
    }
  }

  void register(User user) async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      //Overlay.of(context).insert(loader);
      repository.register(user).then((value) {

        try {
          loader.remove();
        }
        catch(e) {
          print(e);
        }

        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {

        try {
          loader.remove();
        }
        catch(e) {
          print(e);
        }

        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(S.of(context).thisAccountNotExist),
        ));
      }).whenComplete(() {
        try {
          loader.remove();
        }
        catch(e) {
          print(e);
        }
        Helper.hideLoader(loader);
      });
    }
  }

  void validateUser(String phone) {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      //loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.validateUser(phone).then((response) {

        try {
          if(json.decode(response)['success']) {

            User user = User.fromJSON(json.decode(response)['data']);
            sendPasswordResetOTP(user);
          }
          else {

            if(json.decode(response)['message'] == "No Data Found") {

              loader.remove();
              scaffoldKey?.currentState?.showSnackBar(SnackBar(
                content: Text(S.of(context).account_not_exist),
              ));
            }
          }
        }
        catch(error) {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).password_reset_failed),
          ));
          print(error);
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void sendPasswordResetOTP(User user) {

    String phoneNumber = "+88" + user.email;

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 0),
      verificationCompleted: (authCredential) {},
      verificationFailed: (authException) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).otpSendingFailed),
        ));
      },
      codeSent: (verificationId, [token]) {
        loader.remove();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PasswordResetOtpVerify(verificationId, user)));
      },
      codeAutoRetrievalTimeout: (verificationId) {
      },
    );
  }

  void verifyPasswordResetCode(String code, String verificationID, User user) {

    FocusScope.of(context).unfocus();

    if(loginFormKey.currentState.validate()) {

      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);

      _authCredential = PhoneAuthProvider.getCredential(verificationId: verificationID, smsCode: code);

      _firebaseAuth.signInWithCredential(_authCredential).then((authResult) async {

        loader.remove();

        if(authResult.user != null) {

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResetPassword(user: user)));
        }
        else {

          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).failedToVerifyOTP),
          ));
        }
      }).catchError((error) async {

        loader.remove();

        if(error.toString().contains("ERROR_INVALID_VERIFICATION_CODE")) {

          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).invalidOTPCode),
          ));
        }
        else {

          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).failedToVerifyOTP),
          ));
        }
      });
    }
  }

  void resetPassword(Password password) {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.reset();
      Overlay.of(context).insert(loader);
      repository.resetPassword(password).then((value) {

        if (value != null && value == true) {
          passwordResetSuccess = true;
          loginFormKey?.currentState?.reset();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).password_reset_success),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(days: 365),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).password_reset_failed),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
