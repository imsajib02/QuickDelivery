import 'dart:convert';
import 'dart:io';

import 'package:deliveryboy/src/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../repository/order_repository.dart';
import '../repository/user_repository.dart';

class ProfileController extends ControllerMVC {
  User user = new User();
  List<Order> recentOrders = [];
  OverlayEntry loader;
  GlobalKey<ScaffoldState> scaffoldKey;

  ProfileController() {
    loader = Helper.overlayLoader(context);
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForUser();
  }

  void updateProfileImage(File file) async {

    if(file != null) {

      Navigator.pop(context);
      Overlay.of(context).insert(loader);

      updateImage(file).then((response) async {

        if(response != null && json.decode(response)['status']) {

          String avatar = json.decode(response)['avatar'];

          currentUser.value.image.url = avatar;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', json.encode(currentUser.value.toJsonFormat()));

          setState(() {});
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).imageUpdatedSuccessFully),
          ));
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
              content: Text(S.of(context).failedToUpdateImage)
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).failedToUpdateImage),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void listenForUser() {
    getCurrentUser().then((_user) {
      setState(() {
        user = _user;
      });
    });
  }

  void listenForRecentOrders({String message}) async {
    final Stream<Order> stream = await getRecentOrders();
    stream.listen((Order _order) {

      if(_order.statusID == 5) {

        setState(() {
          recentOrders.add(_order);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshProfile() async {
    recentOrders.clear();
    user = new User();
    listenForRecentOrders(message: S.of(context).orders_refreshed_successfuly);
    listenForUser();
  }
}
