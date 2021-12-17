import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:cornext_mobile/constants/appconstants.dart';
import 'package:path_provider/path_provider.dart';

class SqlLiteDataBase {
  String tableName = '';
  List createTableQuerys = [
    "CREATE TABLE users("
        "userid INTEGER PRIMARY KEY AUTOINCREMENT,"
        "firstName TEXT,"
        "lastName TEXT,"
        "email TEXT,"
        "mobileNo TEXT,"
        "countryCode TEXT,"
        "alternateMobileNo TEXT,"
        "userPassword TEXT,"
        "isNotRegistred BOOLEAN"
        ")",
    "CREATE TABLE address("
        "addressid INTEGER PRIMARY KEY AUTOINCREMENT,"
        "doornumber TEXT,"
        "street TEXT,"
        "city TEXT,"
        "state TEXT,"
        "pincode TEXT,"
        "isDeliveryAddress BOOLEAN,"
        "isNotRegistred BOOLEAN"
        ")",
  ];

  // static Data database;
  Database database;

  Future<Database> get db async {
    if (database == null) {
      Directory directory = await getApplicationDocumentsDirectory();
      database = await openDatabase(join(directory.path, dbname),
          version: dbversion, onCreate: (db, version) {
        // return db.execute("CREATE TABLE users("
        //     "userid INTEGER PRIMARY KEY AUTOINCREMENT,"
        //     "firstName TEXT,"
        //     "lastName TEXT,"
        //     "email TEXT,"
        //     "mobileNo TEXT,"
        //     "countryCode TEXT,"
        //     "alternateMobileNo TEXT,"
        //     "userPassword TEXT,"
        //     "isNotRegistred BOOLEAN"
        //     ")");
        createTableQuerys.forEach((query) {
          db.execute(query);
        });
      });
    }
    return database;
  }

  addNewColumnToTable(tableName, columnName, datatype) async {
    Database dbInstance = await db;
    dbInstance
        .rawQuery("ALTER TABLE $tableName ADD COLUMN $columnName $datatype");
  }

  void createTables() async {
    Database dbInstance = await db;
    try {
      createTableQuerys.forEach((query) async {
        return await dbInstance.execute(query);
      });
    } catch (err) {
      // if()
      print(err);
    }
  }

  Future<int> insertDataIntoTable(data, tableName) async {
    Database dbInstance = await db;
    print(db);
    try {
      final result = await dbInstance.insert(tableName, data);
      return result;
    } catch (err) {
      print(err);
      return null;
    }
  }

  updateOneColumnInTable(tableName, columnName) async {
    Database dbInstance = await db;
    // final bool column = false;
    try {
      await dbInstance.rawQuery("UPDATE $tableName set $columnName=0");
      // return result.toList();
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future getDataFromTable(tableName) async {
    Database dbInstance = await db;
    try {
      final result = await dbInstance.rawQuery("SELECT * FROM $tableName");
      return result.toList();
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<List> getDataFromTableUsingCondition(tableName, condition) async {
    Database dbInstance = await db;
    try {
      final result =
          await dbInstance.rawQuery("SELECT * FROM $tableName $condition");
      return result.toList();
    } catch (err) {
      print(err);
      return null;
    }
  }
}
