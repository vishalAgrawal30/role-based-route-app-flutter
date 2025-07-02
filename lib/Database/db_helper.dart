// ignore_for_file: unused_local_variable, constant_identifier_names, unnecessary_string_interpolations, non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/constants.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper getInstance = DbHelper._();
  Database? mydb;

  Future<Database> getDB() async {
    mydb ??= await openDB();
    return mydb!;
  }

  Future<Database> openDB() async {
    Directory getDir = await getApplicationDocumentsDirectory();
    String dbPath = join(getDir.path, Constants.DB_NAME);
    debugPrint("Database Path:$dbPath");
    return openDatabase(
      dbPath,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE ${Constants.TABLE_USERS} (
          ${Constants.COLUMN_USER_ID}  INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Constants.COLUMN_USER_NAME}  TEXT NOT NULL,
          ${Constants.COLUMN_EMAIL} TEXT NOT NULL,
          ${Constants.COLUMN_PASSWORD}  TEXT NOT NULL,
          ${Constants.COLUMN_ADDRESS} TEXT NOT NULL,
          ${Constants.COLUMN_CITY} TEXT,
          ${Constants.COLUMN_GENDER} TEXT,
          ${Constants.COLUMN_DOB} TEXT,
          ${Constants.COLUMN_PROFILE_IMAGE_PATH} TEXT,
          ${Constants.COLUMN_ROLE} TEXT NOT NULL  
        )
      ''');
      },
      version: 1,
    );
  }
}
