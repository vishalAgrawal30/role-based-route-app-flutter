// ignore_for_file: avoid_print, unused_local_variable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:role_based_auth_app/Database/employee_dao.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/addEmployee/emp_AddEdit_view.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/emp_list_view.dart';
import 'package:role_based_auth_app/Screens/Employee/Profile/profile_view.dart';
import 'package:role_based_auth_app/Screens/Login/login_view.dart';
import 'package:role_based_auth_app/Screens/Dashboard/dashboard_contract.dart';
import 'package:role_based_auth_app/Screens/Dashboard/dashboard_presenter.dart';
import 'package:role_based_auth_app/models/user_model.dart';
import 'package:role_based_auth_app/providers/user_provider.dart';
import 'package:role_based_auth_app/utils/shared_pref.dart';
import 'package:role_based_auth_app/utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    implements DashboardViewContract {
  late DashboardPresenter _presenter;
  String _role = '';
  UserModel? _currentUser;
  EmployeeDao db = EmployeeDao();

  @override
  void initState() {
    super.initState();
    _presenter = DashboardPresenter(this);
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SharedPref.getRole();
    final userId = await SharedPref.getUserId();
    if (userId == null) {
      debugPrint("User Not Found");
      return;
    }
    setState(() {
      _role = role ?? '';
    });
    final userFetch = await db.getEmployeeById(userId);

    setState(() {
      _currentUser = userFetch;

      debugPrint("User Id:$userId");
    });
    debugPrint("Fetching User:${userFetch?.toMap()}");
    debugPrint("User name:${_currentUser?.userName.toString()}");
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalUser = Provider.of<UserProvider>(context, listen: true).user;
    print("From Dashboard User Name:${_currentUser?.userName}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _presenter.logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_currentUser != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      _currentUser!.profileImagePath != null
                          ? FileImage(File(_currentUser!.profileImagePath!))
                          : AssetImage("assets/images/default_user.png")
                              as ImageProvider,
                ),
                // SizedBox(width: 5),
                Text(
                  "Welcome, ${_currentUser?.userName.toUpperCase()} 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],

          if (_role == Constants.ROLE_ADMIN || _role == Constants.ROLE_EMPLOYEE)
            _buildTile(
              "My Profile",
              Icons.person,
              () => _navigateTo(ProfileView()),
            ),

          if (_role == Constants.ROLE_ADMIN)
            _buildTile(
              "Employee List",
              Icons.people,
              () => _navigateTo(const EmpListScreen()),
            ),

          if (_role == Constants.ROLE_ADMIN)
            _buildTile(
              "Add New Employee",
              Icons.person_add,
              () => _navigateTo(const EmpAddEditView()),
            ),
        ],
      ),
    );
  }

  @override
  void onLogoutError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void onLogoutSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
