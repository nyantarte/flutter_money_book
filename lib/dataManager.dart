
import 'package:flutter_money_book/transactionData.dart';
class DataManager{

  Future<void> dispose() async{}
  Future<List<TransactionData>> getTransactionByDate(DateTime targetDate) async{

    return Future<List<TransactionData>>.value([]);
  }
  Future<List<String>> getMethods() async{
    return Future<List<String>>.value([]);
  }
  Future<void> setMethods(List<String> l) async{}
  Future<List<String>> getUsages() async{
    return Future<List<String>>.value([]);
  }
  Future<void> setUsages(List<String> l) async{}
  Future<void> insert(TransactionData d) async{}
  Future<void> insertAll(List<TransactionData> d) async{}
  Future<void> update(TransactionData d) async{}
  Future<void> clearTransactiondata() async{}
  Future<void> delete(TransactionData d) async{}
  }