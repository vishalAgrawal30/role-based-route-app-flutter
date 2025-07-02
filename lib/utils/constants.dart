// ignore_for_file: constant_identifier_names, unused_import

import 'package:flutter/material.dart';

class Constants {
  // for database
  static const String DB_NAME = "test_db.db";

  static const String TABLE_USERS = "users";
  static const String COLUMN_USER_ID = "userId";
  static const String COLUMN_USER_NAME = "userName";
  static const String COLUMN_EMAIL = "email";
  static const String COLUMN_PASSWORD = "password";
  static const String COLUMN_ADDRESS = "address";
  static const String COLUMN_CITY = "city";
  static const String COLUMN_GENDER = "gender";
  static const String COLUMN_DOB = "dob";
  static const String COLUMN_PROFILE_IMAGE_PATH = "profileImagePath";
  static const String COLUMN_ROLE = "role";

  //URI OF IPV4 OF PC
  static const String BASE_URI = "http://192.168.1.10:5000";
  static const String USERS = "users";

  //shared preference key
  static const String KEY_TOKEN = "token";
  static const String KEY_ROLE = "role";
  static const String KEY_USER_ID = "id";

  //role
  static const String ROLE_ADMIN = "admin";
  static const String ROLE_EMPLOYEE = "employee";
}
