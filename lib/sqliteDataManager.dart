import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_money_book/dataManager.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';

class SqliteDataManager implements DataManager {
  late Future<Database> m_db;
  late List<String> m_usages;
  late List<String> m_methods;
  bool m_isInit=false;
  SqliteDataManager() {
    var dbPath = "moneybook.db";
    try {
      if (Platform.isAndroid) {
        getDatabasesPath().then((value) => dbPath = "${value}${dbPath}");
        developer.log("Initialized method for Android is complete.",
            name: this.runtimeType.toString());
      }
    } catch (e) {
      //dbPath="${Directory.current}${dbPath}";
    }
    developer.log("Database path is ${dbPath}.",
        name: this.runtimeType.toString());
    //getApplicationDocumentsDirectory().then((value) => {dbPath="${dbName}"});
    m_db = openDatabase(dbPath, onCreate: _createTable, version: 2);
  }

  @override
  Future<void> init() async{
    if(!m_isInit) {
      m_usages = await _updateUsagesList();
      m_methods = await _updateMethodList();
      m_isInit=true;
    }
  }
  @override
  Future<void> dispose() async {
    final db = await m_db;
    db.close();
  }

  void _createTable(Database db, int version) {
    db.execute(
        "CREATE TABLE moneybook(id TEXT PRIMARY KEY,transactionDate INT, method TEXT, usage TEXT,value INT,note TEXT)");
    developer.log("Table createing moneybook is completed.",
        name: this.runtimeType.toString());
    db.execute("CREATE TABLE usage(usage TEXT)");
    developer.log("Table creating usage is completed.",
        name: this.runtimeType.toString());
    db.execute("CREATE TABLE method(method TEXT)");
    developer.log("Table creating method is completed.",
        name: this.runtimeType.toString());
  }

  @override
  Future<List<TransactionData>> getTransactionAll() async{
    List<TransactionData> res = [];
    final db = await m_db;

    final list = await db.transaction((txn) async {
      return await txn.query("moneybook");
    });
    for (var t in list) {
      res.add(genTransactionData(t));
    }
    return Future.value(res);

  }
  @override
  Future<List<TransactionData>> getTransactionByDate(
      DateTime targetDate) async {
    var beginDate = DateTime(targetDate.year, targetDate.month, targetDate.day);
    developer.log(beginDate.toString());
    var endDate = beginDate.add(Duration(days: 1));
    developer.log(endDate.toString());
    List<TransactionData> res = [];
    final db = await m_db;

    final list = await db.transaction((txn) async {
      return await txn.query("moneybook",
          where: "transactionDate>=? AND transactionDate<?",
          whereArgs: [
            beginDate.millisecondsSinceEpoch,
            endDate.millisecondsSinceEpoch
          ]);
    });

    for (var t in list) {
      res.add(genTransactionData(t));
    }

    developer.log("${res.length} transaction items has found  for ${targetDate.toString()}",
        name: "${this.runtimeType.toString()}.getTransactionByData");
    return Future.value(res);
  }
  Future<List<TransactionData>> getTransactionByDateRange(
      DateTime beginDate,DateTime endDate) async {
    List<TransactionData> res = [];
    final db = await m_db;

    final list = await db.transaction((txn) async {
      return await txn.query("moneybook",
          where: "transactionDate>=? AND transactionDate<?",
          whereArgs: [
            beginDate.millisecondsSinceEpoch,
            endDate.millisecondsSinceEpoch
          ]);
    });

    for (var t in list) {
      res.add(genTransactionData(t));
    }

    developer.log("${res.length} transaction items has found from ${beginDate.toString()} to ${endDate.toString()}",
        name: "${this.runtimeType.toString()}.getTransactionByData");
    return Future.value(res);

  }
  TransactionData genTransactionData(Map<String, dynamic> map) {
    final id = map["id"] ?? "";
    final tDate = map["transactionDate"]!;

    final usage = map["usage"] ?? "";
    final method = map["method"] ?? "";
    final value = map["value"] ?? 0;
    final note = map["note"] ?? "";
    return TransactionData(
        id,
        DateTime.fromMillisecondsSinceEpoch(tDate, isUtc: false),
        method,
        usage,
        value,
        note);
  }

  @override
  List<String> getMethods(){
    return m_methods;
  }
  Future<List<String>> _updateMethodList() async{
    List<String> res = [];
    final db = await m_db;
    await db.transaction((txn) async {
      await txn.query("method").then((value) {
        for (var t in value) {
          if (null != t["method"]) {
            res.add(t["method"].toString());
          }
        }
        developer.log("${res.length} methods has found.",
            name: "${this.runtimeType.toString()}.getMethods");
      });
    });

    return Future<List<String>>.value(res);
  }

  @override
  Future<void> setMethods(List<String> l) async {
    final db = await m_db;
    await db.transaction((txn) async {
      for (var m in l) {
        await txn.insert("method", {"method": m});
      }
      developer.log("${l.length} methods imported");
    });
    m_usages=await _updateUsagesList();
  }

  @override
  List<String> getUsages(){
    return m_usages;
  }

  Future<List<String>> _updateUsagesList() async {
    List<String> res = [];
    final db = await m_db;
    await db.transaction((txn) async {
      await txn.query("usage").then((value) {
        for (var t in value) {
          if (null != t["usage"]) {
            res.add(t["usage"].toString());
          }
        }
        developer.log("${res.length} usages has found.",
            name: "${this.runtimeType.toString()}.getUsages");
      });
    });

    return Future.value(res);
  }

  @override
  Future<void> setUsages(List<String> l) async {
    final db = await m_db;
    await db.transaction((txn) async {
      for (var m in l) {
        await txn.insert("usage", {"usage": m});
      }
    });
    developer.log("${l.length} usages imported");
    m_usages=await _updateUsagesList();
  }

  @override
  Future<void> insert(TransactionData d) async {
    final db = await m_db;
    await db.transaction((txn) async {
      await txn.insert("moneybook", d.toMap());
    });
  }

  @override
  Future<void> insertAll(List<TransactionData> d) async {
    final db = await m_db;
    await db.transaction((txn) async {
      for (var t in d) {
        await txn.insert("moneybook", t.toMap());
      }
    });
  }

  @override
  Future<void> update(TransactionData d) async {
    final db = await m_db;
    await db.transaction((txn) async {
      await txn
          .update("moneybook", d.toMap(), where: "id=?", whereArgs: [d.m_id]);
    });
  }

  @override
  Future<void> clearTransactiondata() async {
    final db = await m_db;
    await db.transaction((txn) async {
      await txn.delete("moneybook");
      await txn.delete("usage");
      await txn.delete("method");
    });
  }

  @override
  Future<void> delete(TransactionData d) async {
    final db = await m_db;
    await db.transaction((txn) async {
      await txn.delete("moneybook", where: "id=?", whereArgs: [d.m_id]);
    });
  }
}
