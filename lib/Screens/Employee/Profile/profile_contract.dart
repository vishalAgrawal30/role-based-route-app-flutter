import 'package:role_based_auth_app/models/user_model.dart';

abstract class ProfileContractView {
  void onProfileLoaded(UserModel user);
  void onError(String message);
}
