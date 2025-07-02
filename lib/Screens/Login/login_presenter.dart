// ignore_for_file: avoid_print, unused_local_variable, use_build_context_synchronously, unused_import, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:role_based_auth_app/Database/employee_dao.dart';
import 'package:role_based_auth_app/Screens/Login/login_contract.dart';
import 'package:role_based_auth_app/models/login_response_model.dart';
import 'package:role_based_auth_app/models/user_model.dart';
import 'package:role_based_auth_app/providers/user_provider.dart';
import 'package:role_based_auth_app/services/api_service.dart';

class LoginPresenter {
  final LoginContractView? view;
  final BuildContext context;
  ApiService apiService = ApiService();
  EmployeeDao empRef = EmployeeDao();
  LoginPresenter(this.view, this.context);

  Future<void> login(String email, String password) async {
    try {
      final LoginResponse result = await apiService.login(email, password);
      final api = await apiService.getEmployees();
      final sqlData = await empRef.getAllEmployees();
      //global state data store
      // final userProvider = Provider.of<UserProvider>(context, listen: false);
      // final UserModel? loggedIN_User = await empRef.getEmployeeById(
      //   result.userId,
      // );
      // if (loggedIN_User != null) {
      //   userProvider.setUser(loggedIN_User);
      // } else {
      //   print("Error to fetching the User Data");
      // }
      // debugPrint("LoginResponse: $result");
      // debugPrint("Logged-in User from DB: $loggedIN_User");
      // debugPrint(
      //   "Logged in as: ${context.watch<UserProvider>().user?.email ?? 'none'}",
      // );

      debugPrint("Api User:${api.length}\nDatabase User:${sqlData.length}");
      debugPrint("Email is :$email \nPassword:$password");

      view?.onLoginSuccess(result.token, result.role, result.userId);
    } catch (e) {
      print("Email is :$email \nPassword:$password");
      String errorMessage = "Login failed. Please try again.";

      if (e.toString().contains('401')) {
        errorMessage =
            "The password you entered is incorrect. Please try again.";
      } else if (e.toString().contains('404')) {
        errorMessage =
            "No account exists with this email address. Please check and try again.";
      } else if (e.toString().contains('SocketException')) {
        errorMessage = "No internet connection. Please check your network.";
      }

      view?.onLoginError(errorMessage);
    }
  }

  Future<UserModel?> getUserById(int id) async {
    return await empRef.getEmployeeById(id); // implement this in your DAO
  }
}
