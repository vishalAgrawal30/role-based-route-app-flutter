// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:role_based_auth_app/Screens/Dashboard/dashboard_view.dart';
import 'package:role_based_auth_app/providers/user_provider.dart';
import 'package:role_based_auth_app/utils/constants.dart';
import 'package:role_based_auth_app/utils/shared_pref.dart';
import 'login_presenter.dart';
import 'login_contract.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginContractView {
  late final LoginPresenter _presenter;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _presenter = LoginPresenter(this, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () {
                    setState(() => _loading = true);
                    _presenter.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                  },
                  child: const Text("Login"),
                ),
          ],
        ),
      ),
    );
  }

  @override
  void onLoginSuccess(String token, String role, int id) async {
    // store in the local storage
    await SharedPref.saveToken(token);
    await SharedPref.saveRole(role);
    await SharedPref.saveUserId(id);

    setState(() => _loading = false);
    // ✅ 1. Fetch the logged-in user from SQLite using ID
    final user = await _presenter.getUserById(id);
    debugPrint("Tested Id is fetc or not\nUSerId:$id");
    debugPrint('$user');
    // ✅ 2. Set the user globally using Provider
    if (user != null && mounted) {
      Provider.of<UserProvider>(context, listen: false).setUser(user);
    }

    if (role == Constants.ROLE_ADMIN) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()), // To be created
      );
    }
  }

  @override
  void onLoginError(String message) {
    setState(() => _loading = false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
