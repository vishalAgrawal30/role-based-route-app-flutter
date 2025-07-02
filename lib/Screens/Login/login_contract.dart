abstract class LoginContractView {
  void onLoginSuccess(String token, String role, int userId);
  void onLoginError(String message);
}
