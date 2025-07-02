// ignore_for_file: use_build_context_synchronously, avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/addEmployee/emp_AddEdit_view.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/emp_list_contract.dart';
import 'package:role_based_auth_app/models/user_model.dart';
import 'package:role_based_auth_app/screens/Admin/employeeList/emp_list_presenter.dart';
import 'package:role_based_auth_app/utils/shared_pref.dart';

class EmpListScreen extends StatefulWidget {
  const EmpListScreen({super.key});
  @override
  State<EmpListScreen> createState() => _EmpListScreenState();
}

class _EmpListScreenState extends State<EmpListScreen>
    implements EmpListContractView {
  late final EmpListPresenter _presenter;
  List<UserModel> _employees = [];
  bool _loading = true;
  int? _currentUserId;
  @override
  void initState() {
    super.initState();
    _presenter = EmpListPresenter(this);
    _presenter.fetchUser(); // Fetch API + store in SQLite
    fetchUserId();
  }

  fetchUserId() async {
    _currentUserId = await SharedPref.getUserId();
    _presenter.fetchUser();
  }

  @override
  void onEmployeeListError(String message) {
    if (!mounted) return; // ✅ Prevents setState after dispose
    setState(() {
      _loading = false;
    });
    debugPrint("Error is: $message");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void onEmployeeListSuccess(List<UserModel> employees) {
    final filterUser =
        employees.where((emp) => emp.id != _currentUserId).toList();
    setState(() {
      _loading = false;
      _employees = filterUser;
    });
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Confirm Delete"),
                content: const Text(
                  "Are you sure you want to delete this employee?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false; // default to false if null
  }

  void _showAlert(String message) {
    bool shouldDelete = false;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Info"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee List")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async => _presenter.fetchUser(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 500,
                      child: ListView.builder(
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final emp = _employees[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(emp.userName),
                              subtitle: Text("${emp.email} • ${emp.role}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  EmpAddEditView(user: emp),
                                        ),
                                      );
                                      if (result == "refresh") {
                                        _presenter
                                            .fetchUser(); // Refresh your list
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      bool check = await _confirmDeleteDialog();
                                      if (check) {
                                        _presenter.deleteUser(emp.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: SizedBox(
        width: 100,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmpAddEditView()),
            ).then((result) {
              _loadUsers();
            });
          },
          backgroundColor: Colors.blueAccent,
          tooltip: "Add New Employee",
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text("Add", style: TextStyle(color: Colors.white))],
          ),
        ),
      ),
    );
  }

  void _loadUsers() {
    _presenter.getEmployeesFromLocalDb();
  }

  deleteEmp(int id) async {}

  @override
  void onDeleteError(String message) {
    _showAlert(message);
  }

  @override
  void onDeleteSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(backgroundColor: Colors.red)),
        duration: Duration(seconds: 1),
      ),
    );
    _presenter.fetchUser(); // 🔁 Refresh after delete
  }
}
