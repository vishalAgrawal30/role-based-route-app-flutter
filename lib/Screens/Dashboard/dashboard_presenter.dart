import 'package:role_based_auth_app/Screens/Dashboard/dashboard_contract.dart';
import 'package:role_based_auth_app/utils/shared_pref.dart';

class DashboardPresenter {
  final DashboardViewContract? view;

  DashboardPresenter(this.view);

  Future<void> logout() async {
    try {
      await SharedPref.clear();
      view?.onLogoutSuccess();
    } catch (e) {
      view?.onLogoutError("Failed to logout");
    }
  }
}
