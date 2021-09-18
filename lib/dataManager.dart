
import 'package:flutter_money_book/transactionData.dart';
class DataManager{

  Future<void> init() async{}
  Future<void> dispose() async{}
  Future<List<TransactionData>> getTransactionAll() async{
    return Future<List<TransactionData>>.value([]);
  }
  Future<List<TransactionData>> getTransactionByDate(DateTime targetDate) async{

    return Future<List<TransactionData>>.value([]);
  }
  Future<List<TransactionData>> getTransactionByDateRange(
      DateTime beginDate,DateTime endDate) async {
    return Future<List<TransactionData>>.value([]);

  }
    List<String> getMethods() {
    return [];
  }
  Future<void> setMethods(List<String> l) async{}
  List<String> getUsages() {
    return [];
  }
  Future<void> setUsages(List<String> l) async{}
  Future<void> insert(TransactionData d) async{}
  Future<void> insertAll(List<TransactionData> d) async{}
  Future<void> update(TransactionData d) async{}
  Future<void> clearTransactiondata() async{}
  Future<void> delete(TransactionData d) async{}
  }