import 'package:deliveryboy/src/controllers/user_controller.dart';
import 'package:deliveryboy/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart' as userRepo;
import '../repository/settings_repository.dart' as settingRepo;

class PasswordResetOtpVerify extends StatefulWidget {

  final String verificationID;
  final User user;

  PasswordResetOtpVerify(this.verificationID, this.user);

  @override
  _PasswordResetOtpVerifyState createState() => _PasswordResetOtpVerifyState();
}

class _PasswordResetOtpVerifyState extends StateMVC<PasswordResetOtpVerify> {

  UserController _con;
  TextEditingController _codeController = TextEditingController();

  _PasswordResetOtpVerifyState() : super(UserController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {

    final _ac = config.App(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.of(context).pushReplacementNamed('/ForgetPassword');
        return Future(() => false);
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        //resizeToAvoidBottomPadding: false,
        body: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: _ac.appWidth(100),
                child: Column(
                  children: <Widget>[
                    Text(S.of(context).verify_number,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(S.of(context).otp_code_sent + "+88-" + widget.user.email,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Form(
                key: _con.loginFormKey,
                child: TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  validator: (input) => input.isEmpty ? S.of(context).enterSentCode : input.length < 6 ? S.of(context).codeShort : null,
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                    ),
                    focusedBorder: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.5),
                      ),
                    ),
                    hintText: '000-000',
                  ),
                ),
              ),
              SizedBox(height: 80),
              new BlockButtonWidget(
                onPressed: () {
                  _con.verifyPasswordResetCode(_codeController.text, widget.verificationID, widget.user);
                },
                color: Theme.of(context).accentColor,
                text: Text(S.of(context).verify.toUpperCase(),
                    style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Theme.of(context).primaryColor))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
