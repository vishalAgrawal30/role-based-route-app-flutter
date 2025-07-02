import 'package:role_based_auth_app/Database/employee_dao.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/emp_list_contract.dart';
import 'package:role_based_auth_app/services/api_service.dart';

class EmpListPresenter {
  final EmpListContractView view;

  ApiService apiService = ApiService();

  EmployeeDao empRef = EmployeeDao();

  EmpListPresenter(this.view);

  Future<void> fetchUser() async {
    try {
      final apiUsers = await apiService.getEmployees();
      await empRef.clearAll();
      for (var user in apiUsers) {
        await empRef.insertEmployee(user);
      }
      final localUsers = await empRef.getAllEmployees();
      view.onEmployeeListSuccess(localUsers);
    } catch (e) {
      view.onEmployeeListError("Error to Fetch Employess:$e");
    }
  }

  Future<void> getEmployeesFromLocalDb() async {
    try {
      final users = await empRef.getAllEmployees();
      view.onEmployeeListSuccess(users);
    } catch (e) {
      view.onEmployeeListError("Failed to fetch from local DB: $e");
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await apiService.deleteEmployee(id);
      await empRef.deleteEmployeeById(id);
      view.onDeleteSuccess("Delete Successfully");
      return true;
    } catch (e) {
      view.onDeleteError("Error to Delete the Record");
      return false;
    }
  }
}
