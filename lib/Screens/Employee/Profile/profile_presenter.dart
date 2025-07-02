import 'package:role_based_auth_app/Database/employee_dao.dart';
import 'package:role_based_auth_app/Screens/Employee/Profile/profile_contract.dart';
import 'package:role_based_auth_app/models/user_model.dart';
import 'package:role_based_auth_app/services/api_service.dart';
import 'package:role_based_auth_app/utils/shared_pref.dart';

class ProfilePresenter {
  final ProfileContractView? view;
  ApiService apiService = ApiService();
  EmployeeDao empDB = EmployeeDao();

  ProfilePresenter(this.view);

  Future<void> loadUser() async {
    try {
      int? id = await SharedPref.getUserId();
      if (id == null) {
        view?.onError("User is not Logged-In");
        return;
      }

      //First Fetch from the API
      UserModel? user = await apiService.getEmployeeById(id);
      if (user != null) {
        await empDB.updateEmployee(user);
        view?.onProfileLoaded(user);
        return;
      }

      //else Fallback with The DB
      user = await empDB.getEmployeeById(id);
      if (user != null) {
        view?.onProfileLoaded(user);
      } else {
        view?.onError("User Data Not Found");
      }
    } catch (e) {
      view?.onError("Error to find the User id");
    }
  }
}
