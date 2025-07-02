// ignore_for_file: file_names

import 'package:role_based_auth_app/Database/employee_dao.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/addEmployee/emp_AddEdit_contract.dart';
import 'package:role_based_auth_app/models/user_model.dart';
import 'package:role_based_auth_app/services/api_service.dart';

class EmpAddPresenter {
  final EmpAddContractView view;
  final ApiService api = ApiService();
  final EmployeeDao dao = EmployeeDao();

  EmpAddPresenter(this.view);

  Future<void> addUser(UserModel user) async {
    try {
      await api.addEmployee(user); // POST to API
      await dao.insertEmployee(user); // Save to SQLite
      view.onAddSuccess(); // Notify UI
    } catch (e) {
      view.onAddError(e.toString());
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await api.updateEmployee(user); // POST to API
      await dao.updateEmployee(user); // Save to SQLite
      view.onAddSuccess(); // Notify UI
    } catch (e) {
      view.onAddError(e.toString());
    }
  }

  Future<UserModel?> getUserById(int id) async {
    return await dao.getEmployeeById(id); // implement this in your DAO
  }

  Future<bool> isEmailExists(String email) async {
    return await dao.checkEmailExists(email);
  }
}
