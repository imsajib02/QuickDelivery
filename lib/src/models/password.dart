class Password {

  String oldPassword;
  String newPassword;
  String confirmPassword;
  String apiToken;
  String email;
  String id;

  Password({this.oldPassword, this.newPassword, this.confirmPassword, this.apiToken, this.email, this.id});

  toJson() {

    return {
      "current_password" : oldPassword,
      "password" : newPassword,
      "password_confirmation" : confirmPassword,
      "api_token" : apiToken
    };
  }

  toReset() {

    return {
      "password" : newPassword,
      "password_confirmation" : confirmPassword,
      "email" : email,
      "id" : id,
    };
  }
}