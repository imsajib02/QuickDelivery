import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/user.dart';

class PhoneChangeDialog extends StatefulWidget {
  final User user;
  final void Function(String) onSubmit;

  PhoneChangeDialog({Key key, this.user, this.onSubmit}) : super(key: key);

  @override
  _PhoneChangeDialogState createState() => _PhoneChangeDialogState();
}

class _PhoneChangeDialogState extends State<PhoneChangeDialog> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _controller.text = "";

    return FlatButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {

              return SimpleDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                title: Row(
                  children: <Widget>[
                    Icon(Icons.lock),
                    SizedBox(width: 10),
                    Text(
                      S.of(context).change_phone_number,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
                children: <Widget>[
                  Form(
                    key: _profileSettingsFormKey,
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          controller: _controller,
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Text("+880 ", style: Theme.of(context).textTheme.bodyText2,),
                            ),
                            hintText: S.of(context).new_phone,
                            hintStyle: Theme.of(context).textTheme.bodyText2.merge(
                              TextStyle(color: Theme.of(context).focusColor),
                            ),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
                            contentPadding: EdgeInsets.all(10),
                          ),
                          validator: (input) => input.length < 10 ? S.of(context).not_a_valid_phone : (("0" + input) == widget.user.email ?
                          S.of(context).enter_different_pone : null),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).cancel),
                      ),
                      MaterialButton(
                        onPressed: _submit,
                        child: Text(
                          S.of(context).change,
                          style: TextStyle(color: Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                  SizedBox(height: 10),
                ],
              );
            });
      },
      child: Text(
        S.of(context).change,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  void _submit() {
    if (_profileSettingsFormKey.currentState.validate()) {
      _profileSettingsFormKey.currentState.save();

      widget.onSubmit("0" + _controller.text);
      _controller.text = "";
    }
  }
}
