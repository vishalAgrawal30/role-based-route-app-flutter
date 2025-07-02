import 'dart:io';

import 'package:flutter/material.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/addEmployee/emp_AddEdit_view.dart';
import 'package:role_based_auth_app/Screens/Employee/Profile/profile_contract.dart';
import 'package:role_based_auth_app/Screens/Employee/Profile/profile_presenter.dart';
import 'package:role_based_auth_app/models/user_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    implements ProfileContractView {
  late ProfilePresenter _presenter;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenter(this);
    _presenter.loadUser();
  }

  @override
  void onProfileLoaded(UserModel user) {
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),
      body:
          _user == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _user!.profileImagePath != null &&
                                  File(_user!.profileImagePath!).existsSync()
                              ? FileImage(File(_user!.profileImagePath!))
                              : const AssetImage(
                                    "assets/images/default_user.png",
                                  )
                                  as ImageProvider,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user!.userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_user!.email, style: TextStyle(color: Colors.grey)),
                    Divider(),
                    _infoTile("Role", _user!.role),
                    _infoTile("City", _user!.city),
                    _infoTile("Address", _user!.address),
                    _infoTile("Gender", _user!.gender),
                    _infoTile(
                      "DOB",
                      _user!.dob?.toIso8601String().split('T').first ?? "",
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EmpAddEditView(
                                isSelfEdit: true,
                                user: _user,
                              );
                            },
                          ),
                        );
                        if (result == 'refresh') {
                          _presenter.loadUser();
                        }
                      },
                      child: const Text("Edit Profile"),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return ListTile(title: Text(label), subtitle: Text(value ?? "Not set"));
  }

  @override
  void onError(String message) {
    debugPrint("Error is:$message");
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
