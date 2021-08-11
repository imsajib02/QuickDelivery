import 'package:deliveryboy/src/models/password.dart';
import 'package:deliveryboy/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';

class ResetPassword extends StatefulWidget {

  final User user;

  const ResetPassword({Key key, this.user}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends StateMVC<ResetPassword> {
  UserController _con;
  TextEditingController _newController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();

  bool _hidden1 = true;
  bool _hidden2 = true;

  _ResetPasswordState() : super(UserController()) {
    _con = controller;
  }
  @override
  void initState() {
    _newController.text = "";
    _confirmController.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.of(context).pushReplacementNamed('/ForgetPassword');
        return Future(() => false);
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(S.of(context).reset + " " + S.of(context).password,
                  style: Theme.of(context).textTheme.headline2.merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                  BoxShadow(
                    blurRadius: 50,
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                  )
                ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _newController,
                        keyboardType: TextInputType.text,
                        validator: (input) => input.length < 6 ? S.of(context).must_be_6_letters : null,
                        obscureText: _hidden1,
                        decoration: InputDecoration(
                          labelText: S.of(context).new_password,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidden1 = !_hidden1;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_hidden1 ? Icons.visibility : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _confirmController,
                        keyboardType: TextInputType.text,
                        validator: (input) => input.length < 6 ? S.of(context).must_be_6_letters : (input != _newController.text ?
                        S.of(context).confirm_password_do_not_match : null),
                        obscureText: _hidden2,
                        decoration: InputDecoration(
                          labelText: S.of(context).confirm_password,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidden2 = !_hidden2;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_hidden2 ? Icons.visibility : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          S.of(context).reset,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if(!_con.passwordResetSuccess) {
                            Password password = Password(newPassword: _newController.text, confirmPassword: _confirmController.text, email: widget.user.email, id: widget.user.id);
                            _con.resetPassword(password);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
