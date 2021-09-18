import 'dart:io';

import 'package:flutter_money_book/dataManager.dart';
import 'package:flutter_money_book/localDataManager.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';

class DataManagerFactory{
  static String moneyBookFileName="backup.csv";
  static String moneyBookExportFileName="export.csv";
  static DataManager? s_manager;
  static DataManager getManager() {
    if(null==s_manager) {
      if (Platform.isAndroid || Platform.isIOS) {
        s_manager=SqliteDataManager();
      }else if(Platform.isWindows){
        var lm=LocalDataManager();
        s_manager=lm;




      }
    }
    return s_manager!;
  }
}