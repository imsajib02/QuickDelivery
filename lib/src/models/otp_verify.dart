import 'user.dart';

class OtpVerify {

  String verificationID;
  int resendingToken;
  User user;

  OtpVerify({this.verificationID, this.resendingToken, this.user});
}