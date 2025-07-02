// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, unused_field, prefer_final_fields

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:role_based_auth_app/Screens/Admin/employeeList/addEmployee/emp_AddEdit_contract.dart';
import 'package:role_based_auth_app/Screens/Admin/employeeList/addEmployee/emp_AddEdit_presenter.dart';
import 'package:role_based_auth_app/models/user_model.dart';

class EmpAddEditView extends StatefulWidget {
  final UserModel? user;
  final bool isSelfEdit;
  const EmpAddEditView({super.key, this.user, this.isSelfEdit = false});

  @override
  State<EmpAddEditView> createState() => _EmpAddEditViewState();
}

class _EmpAddEditViewState extends State<EmpAddEditView>
    implements EmpAddContractView {
  final _formKey = GlobalKey<FormState>();
  late EmpAddPresenter presenter;
  bool isUpdate = false;
  UserModel? exisUser;

  File? _profileImage;
  bool _isCompressing = false;

  @override
  void initState() {
    super.initState();
    presenter = EmpAddPresenter(this);
    fetcDataForEditUser();
  }

  fetcDataForEditUser() {
    if (widget.user != null) {
      _userNameController.text = widget.user!.userName;
      _emailController.text = widget.user!.email;
      _passwordController.text = "";
      _addressController.text = widget.user!.address;
      _selectedCity = widget.user!.city;
      _gender = widget.user!.gender;
      _selectedDob = widget.user!.dob;
      _role = widget.user!.role;
      isUpdate = true;
      exisUser = widget.user;
      if (!_cities.contains(_selectedCity)) {
        _cities.add(_selectedCity!);
      }
      if (widget.user!.profileImagePath != null) {
        _profileImage = File(widget.user!.profileImagePath!);
      }
    }
  }

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedCity;
  String? _gender;
  String _role = 'employee';
  DateTime? _selectedDob;

  final List<String> _cities = ['New York', 'London', 'Mumbai', 'Tokyo'];
  final List<String> _roles = ['admin', 'employee'];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_gender == null) {
        _showSimpleAlert(context, "Please fill gender");
        return;
      }
      if (_selectedCity == null) {
        _showSimpleAlert(context, "Please fill city");
        return;
      }
      if (_selectedDob == null) {
        _showSimpleAlert(context, "Please fill DOB.");
        return;
      }

      if (!isUpdate) {
        final emailExist = await presenter.isEmailExists(
          _emailController.text.toString(),
        );
        if (emailExist) {
          _showSimpleAlert(context, "Email Address is Already Exist");
          return;
        }
      }

      final String newPassword = _passwordController.text.trim();
      final bool isPasswordChanged = newPassword.isNotEmpty;

      final user = UserModel(
        id: isUpdate ? exisUser?.id : null,
        userName:
            _userNameController.text.trim().isEmpty
                ? exisUser?.userName ?? ''
                : _userNameController.text.trim(),
        email:
            _emailController.text.trim().isEmpty
                ? exisUser?.email ?? ''
                : _emailController.text.trim(),
        password: isPasswordChanged ? newPassword : "",
        address:
            _addressController.text.trim().isEmpty
                ? exisUser?.address ?? ''
                : _addressController.text.trim(),
        city: _selectedCity ?? exisUser?.city,
        gender: _gender ?? exisUser?.gender,
        dob: _selectedDob ?? exisUser?.dob,
        profileImagePath: _profileImage?.path ?? exisUser?.profileImagePath,
        role: _role,
      );

      if (!isUpdate) {
        presenter.addUser(user);
      } else {
        presenter.updateUser(user);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final dateAllowed = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: dateAllowed,
      firstDate: DateTime(1950),
      lastDate: dateAllowed,
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final fileImage = File(picked.path);
      _showLoader(context, "Compressing image...");
      final File compressed = await _compressImage(fileImage);
      Navigator.of(context).pop(); // hide loader
      if (compressed.path == fileImage.path) {
        _showAlert(context, "Image compression failed. Using original image.");
      }
      setState(() {
        _profileImage = compressed;
      });
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) return file;

      final resized = img.copyResize(image, width: 800);
      final compressedBytes = img.encodeJpg(resized, quality: 60);

      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        "compressed_${p.basename(file.path)}",
      );
      final compressedFile = File(targetPath)
        ..writeAsBytesSync(compressedBytes);

      return compressedFile;
    } catch (e) {
      debugPrint("Image compression failed: $e");
      return file;
    }
  }

  void _showAlert(BuildContext context, String message) {
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
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Navigator.of(context).pop("refresh"); // Go back and return
                  });
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSimpleAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Info"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(context).pop(), // just close alert
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showLoader(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (_) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(child: Text(message)),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(!isUpdate ? "Add User" : "Update User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage("assets/images/default_user.png")
                              as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text("Tap to change profile photo")),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter username' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  if (!isUpdate)
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Please enter password' : null,
                    ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter address' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text("Gender"),
                  Row(
                    children: [
                      Radio<String>(
                        value: "Male",
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      const Text("Male"),
                      Radio<String>(
                        value: "Female",
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      const Text("Female"),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(labelText: "City"),
                    items:
                        _cities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _selectedCity = value),
                    validator:
                        (value) =>
                            value == null ? 'Please select a city' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDob == null
                              ? "No date selected"
                              : "DOB: ${_selectedDob!.toLocal().toIso8601String().split("T").first}",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: const Text("Select DOB"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!widget.isSelfEdit)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Role"),
                      value: _role,
                      items:
                          _roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => setState(() => _role = value!),
                    ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(!isUpdate ? "Add User" : "Update User"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onAddError(String message) {
    _showAlert(context, "Error: $message");
  }

  @override
  void onAddSuccess() async {
    if (isUpdate && exisUser?.id != null) {
      final updatedUser = await presenter.getUserById(exisUser!.id!);
      setState(() {
        exisUser = updatedUser;
        _userNameController.text = updatedUser!.userName;
        _emailController.text = updatedUser.email;
        _addressController.text = updatedUser.address;
        _selectedCity = updatedUser.city;
        _gender = updatedUser.gender;
        _selectedDob = updatedUser.dob;
        _role = updatedUser.role;
        if (updatedUser.profileImagePath != null) {
          _profileImage = File(updatedUser.profileImagePath!);
        }
      });
    }
    _showAlert(
      context,
      isUpdate ? "User updated successfully." : "User added successfully.",
    );
  }
}
