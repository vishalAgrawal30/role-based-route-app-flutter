import 'package:role_based_auth_app/models/user_model.dart';

abstract class EmpListContractView {
  void onEmployeeListSuccess(List<UserModel> employees);
  void onEmployeeListError(String message);

  void onDeleteSuccess(String message);
  void onDeleteError(String message);
}
