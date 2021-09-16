import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';
import 'package:flutter_money_book/localDataManager.dart';
import 'dart:developer' as developer;

class Config extends StatefulWidget {
  Config() : super();

  @override
  ConfigState createState() => ConfigState();
}

class ConfigState extends State<Config> {
  ConfigState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Text("Mode"),
                DropdownButton(items: [DropdownMenuItem(child: Text("Sqlite"))])
              ],
            ),
            ElevatedButton(
              child: const Text('IMPORT FROM FILE'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
              ),
              onPressed: () {
                _importFromFile();
              },
            ),
            ElevatedButton(
              child: const Text('CLEAR DATA'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
              ),
              onPressed: () {
                final dm = SqliteDataManager();
                dm.clearTransactiondata();
              },
            ),
          ],
        ));
  }

  void _importFromFile() async {
    final lDM = LocalDataManager();
    final sqDM = DataManagerFactory.getManager();
    await lDM.load("backup.csv");
    sqDM.insertAll(lDM.getTransactionsAll());
    developer.log("${lDM.getTransactionsAll().length} items has imported.",
        name: "${this.runtimeType.toString()}._importFromFile");

    var methods = await lDM.getMethods();
    var usages = await lDM.getUsages();
    await sqDM.setMethods(methods);
    await sqDM.setUsages(usages);
  }
}
