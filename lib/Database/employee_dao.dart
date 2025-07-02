// ignore_for_file: unused_local_variable, unused_import, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:role_based_auth_app/Database/db_helper.dart';
import 'package:role_based_auth_app/models/user_model.dart';
import 'package:role_based_auth_app/utils/constants.dart';
import 'package:sqflite/sqlite_api.dart';

class EmployeeDao {
  DbHelper dbRef = DbHelper.getInstance;

  Future<bool> insertEmployee(UserModel user) async {
    //get Db
    try {
      final db = await dbRef.getDB();

      final existUser = await db.query(
        Constants.TABLE_USERS,
        where: "${Constants.COLUMN_EMAIL} = ?",
        whereArgs: [user.email],
      );

      if (existUser.isNotEmpty) {
        // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        //   SnackBar(
        //     content: Text("User is ALready Exist..!"),
        //     duration: Duration(seconds: 1),
        //   ),
        // );

        debugPrint("User with ID ${user.id} already exists. Skipping insert.");
        return false;
      }

      int rowsEffected = await db.insert(
        Constants.TABLE_USERS,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (rowsEffected > 0) {
        debugPrint("Inserted user: ${user.toMap()}");
      }
      return rowsEffected > 0;
    } catch (e) {
      throw Exception("Error to Insert Employee:${e.toString()}");
    }
  }

  //get all user
  Future<List<UserModel>> getAllEmployees() async {
    try {
      final db = await dbRef.getDB();
      final List<Map<String, dynamic>> maps = await db.query(
        Constants.TABLE_USERS,
      );
      debugPrint("Fetched ${maps.length} users.");
      return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception("Error to Fetch Employee:${e.toString()}");
    }
  }

  //get user by id
  Future<UserModel?> getEmployeeById(int id) async {
    try {
      final db = await dbRef.getDB();
      final List<Map<String, dynamic>> maps = await db.query(
        Constants.TABLE_USERS,
        where: '${Constants.COLUMN_USER_ID} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        debugPrint("Fetched Employee:${maps.first}");
        return UserModel.fromMap(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Error to Fetch Employee by Id:${e.toString()}");
    }
  }

  // update user
  Future<bool> updateEmployee(UserModel user) async {
    try {
      final db = await dbRef.getDB();
      if (user.id == null) {
        throw Exception("Cannot update user with null ID");
      }
      final userMap = user.toMap();
      if (user.password == null || user.password.isEmpty) {
        userMap.remove('password');
      }
      int rowsEffected = await db.update(
        Constants.TABLE_USERS,
        user.toMap(),
        where: '${Constants.COLUMN_USER_ID} = ?',
        whereArgs: [user.id],
      );
      if (rowsEffected > 0) {
        debugPrint("Updated User:${user.toMap()}");
      }
      return rowsEffected > 0;
    } catch (e) {
      throw Exception("Error to Update Employee:${e.toString()}");
    }
  }

  //delete user
  Future<void> deleteEmployeeById(int id) async {
    try {
      final db = await dbRef.getDB();
      await db.delete(
        Constants.TABLE_USERS,
        where: '${Constants.COLUMN_USER_ID} = ?',
        whereArgs: [id],
      );
      debugPrint("Deleted Employee:$id");
    } catch (e) {
      throw Exception("Error to Delete Employee:${e.toString()}");
    }
  }

  // clear all data
  Future<void> clearAll() async {
    try {
      final db = await dbRef.getDB();
      await db.delete(Constants.TABLE_USERS);
    } catch (e) {
      throw Exception("Error to Clean Employee Table:${e.toString()}");
    }
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await dbRef.getDB();
    final result = await db.query(
      Constants.TABLE_USERS,
      where: '${Constants.COLUMN_EMAIL} = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
}
