import 'package:flutter_money_book/dataManager.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:path_provider/path_provider.dart";
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';

class LocalDataManager implements DataManager {
  List<TransactionData> m_data = [];
  List<String> m_methods = [];
  List<String> m_usages = [];

  @override
  Future<void> dispose() async {}

  Future<List<TransactionData>> getTransactionByDate(
      DateTime targetDate) async {
    List<TransactionData> res = [];
    DateTime beginDate =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    DateTime endDate = beginDate.add(Duration(days: 1));

    for (var t in m_data) {
      if (0 <= t.m_transDate.compareTo(beginDate) &&
          0 > t.m_transDate.compareTo(endDate)) {
        res.add(t);
      }
    }
    return res;
  }

  @override
  Future<List<String>> getMethods() async {
    return m_methods;
  }

  @override
  Future<List<String>> getUsages() async {
    return m_usages;
  }

  @override
  Future<void> setMethods(List<String> l) async {
    this.m_methods = l;
  }

  List<TransactionData> getTransactionsAll() {
    return m_data;
  }

  @override
  Future<void> setUsages(List<String> l) async {
    m_usages = l;
  }

  @override
  Future<void> insert(TransactionData d) async {
    this.m_data.add(d);
  }

  @override
  Future<void> insertAll(List<TransactionData> d) async {
    for (var t in d) {
      this.m_data.add(t);
      if (-1 == this.m_methods.indexOf(t.m_method)) {
        this.m_methods.add(t.m_method);
      }
      if (-1 == this.m_usages.indexOf(t.m_usage)) {
        this.m_usages.add(t.m_usage);
      }
    }
  }

  @override
  Future<void> update(TransactionData d) async {
    for (var i = 0; i < m_data.length; ++i) {
      var t = this.m_data[i];
      if (t.m_id == d.m_id) {
        this.m_data[i] = d;
      }
    }
  }

  @override
  Future<void> clearTransactiondata() async {
    this.m_data = [];
    this.m_usages = [];
    this.m_methods = [];
  }

  Future<void> load(String fileName) async {
    var dirPath = "";
    if (Platform.isAndroid) {
      await Permission.storage.shouldShowRequestRationale;
      if (await Permission.storage.isDenied) {
        dirPath = (await getExternalStorageDirectory())!.path;
      }
    } else if (Platform.isWindows) {
      dirPath = Directory.current.path;
    }
    developer.log("The application documents directory is ${dirPath}",
        name: "${this.runtimeType.toString()}.load");
    var dir = Directory(dirPath);
    if (!await dir.exists()) {
      dir.create();
    }
    final filePath = "${dir.path}/${fileName}";

    final file = File(filePath);
    if (await file.exists()) {
      developer.log("Import file ${filePath} has found",
          name: "${this.runtimeType.toString()}.load");
      m_data = [];
      m_methods = [];
      m_usages = [];

      final dFormat = DateFormat("yyyy/MM/dd HH:mm");
      final lineList = await file.readAsLines();
      for (var l in lineList) {
        final params = l.toString().split(",");

        m_data.add(TransactionData(Uuid().v1(), dFormat.parse(params[1]),
            params[2], params[3], int.parse(params[4]), params[5]));
        if (-1 == m_methods.indexOf(params[2])) {
          m_methods.add(params[2]);
        }
        if (-1 == m_usages.indexOf(params[3])) {
          m_usages.add(params[3]);
        }
      }
    }
  }

  @override
  Future<void> delete(TransactionData d) async{
    for(var i=0;i < this.m_data.length;++i){
      var t=this.m_data[i];
      if(t.m_id==d.m_id){
        this.m_data.removeAt(i);
        break;
      }
    }

  }

}
