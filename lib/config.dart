import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';
import 'package:flutter_money_book/localDataManager.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info/device_info.dart';
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
              child: const Text('EXPORT TO FILE'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
              ),
              onPressed: () {
                _exportToFile();
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
    if(!Platform.isWindows) {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        developer.log(androidInfo.version.release);
        developer.log(androidInfo.version.previewSdkInt!.toString());
        developer.log(androidInfo.version.sdkInt.toString());

        if(30<=androidInfo.version.previewSdkInt!) {
          await Permission.manageExternalStorage.shouldShowRequestRationale;
          //await Permission.storage.shouldShowRequestRationale;
          if (/*await Permission.storage.isDenied || */await Permission.manageExternalStorage.isDenied) {
            developer.log(
                "Sorry this function needs MANAGE_EXTERNAL_STORAGE permition",
                name: "${this.runtimeType.toString()}._importFromFile");
            return;
          }
        }else if(19 <=androidInfo.version.sdkInt){
            await Permission.storage.shouldShowRequestRationale;
            if(await Permission.storage.isDenied){
              developer.log("Sorry this function needs READ_EXTERNAL_STORAGE permition", name:"${this.runtimeType.toString()}._importFromFile");

            }

        }
      }else if(Platform.isIOS) {
        if(await Permission.storage.isDenied) {

        }
      }
      final pickResult=await FilePicker.platform.pickFiles(
        type:FileType.custom,
        allowedExtensions: ["csv"]

      );
      if(0==pickResult!.count){
        return;
      }
      final filePath=pickResult.paths.elementAt(0)!;
      final lDM = LocalDataManager();
      final sqDM = DataManagerFactory.getManager();
      await lDM.load(filePath);
      var tList=await lDM.getTransactionAll();
      await sqDM.insertAll(tList);
      developer.log("${tList.length} items has imported.",
          name: "${this.runtimeType.toString()}._importFromFile");

      var methods = await lDM.getMethods();
      developer.log("${methods.length}");
      var usages = await lDM.getUsages();
      await sqDM.setMethods(methods);
      await sqDM.setUsages(usages);
    }
  }
  void _exportToFile() async{
    if(Platform.isAndroid){
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;


      if(30<=androidInfo.version.previewSdkInt!) {
        await Permission.manageExternalStorage.shouldShowRequestRationale;
        //await Permission.storage.shouldShowRequestRationale;
        if (/*await Permission.storage.isDenied || */await Permission.manageExternalStorage.isDenied) {
          developer.log(
              "Sorry this function needs MANAGE_EXTERNAL_STORAGE permition",
              name: "${this.runtimeType.toString()}._importFromFile");
          return;
        }
      }else if(19 <=androidInfo.version.sdkInt) {
        await Permission.storage.shouldShowRequestRationale;
        if (await Permission.storage.isDenied) {
          developer.log(
              "Sorry this function needs READ_EXTERNAL_STORAGE permition",
              name: "${this.runtimeType.toString()}._importFromFile");
        }
      }

    }else if(Platform.isIOS) {
      if(await Permission.storage.isDenied) {
        return;
      }
    }
    final lDM = LocalDataManager();
    final sqDM = DataManagerFactory.getManager();
    await sqDM.getTransactionAll().then((value){
      lDM.insertAll(value);
    });

    final outputFile = await FilePicker.platform.getDirectoryPath();

    if(null!=outputFile) {
      await lDM.save(outputFile+"/${DataManagerFactory.moneyBookExportFileName}");
    }
  }
}
