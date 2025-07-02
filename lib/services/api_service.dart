// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:role_based_auth_app/models/login_response_model.dart';
import 'package:role_based_auth_app/models/user_model.dart';
import 'package:role_based_auth_app/utils/constants.dart';

class ApiService {
  // getEmployees
  Future<List<UserModel>> getEmployees() async {
    try {
      final res = await http.get(
        Uri.parse('${Constants.BASE_URI}/${Constants.USERS}'),
      );
      if (res.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(res.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed To Load Employess");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //getEmployeeById
  Future<UserModel?> getEmployeeById(int id) async {
    final response = await http.get(
      Uri.parse('${Constants.BASE_URI}/${Constants.USERS}/$id'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else if (response.statusCode == 404) {
      return null; // Not found
    } else {
      throw Exception('Failed to fetch employee with ID: $id');
    }
  }

  //Post APi
  Future<bool> addEmployee(UserModel user) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.BASE_URI}/${Constants.USERS}'),
        headers: {"Content-type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //update - PUT api
  /// ✅ PUT: Update an existing user
  Future<bool> updateEmployee(UserModel user) async {
    try {
      if (user.id == null) throw Exception("User ID is required to update");
      final id = user.id;

      // if password is not changed then prevent to re-hashed the password
      final data = user.toJson();
      if (user.password == null || user.password.isEmpty) {
        data.remove('password');
      }
      final res = await http.patch(
        Uri.parse('${Constants.BASE_URI}/${Constants.USERS}/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // delete
  Future<bool> deleteEmployee(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('${Constants.BASE_URI}/${Constants.USERS}/$id'),
      );
      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // login
  Future<LoginResponse> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${Constants.BASE_URI}/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return LoginResponse.fromJson(data);
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
