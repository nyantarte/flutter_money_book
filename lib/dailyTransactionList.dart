import 'package:flutter/material.dart';
import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/editTransactionList.dart';
import 'package:flutter_money_book/main.dart';
import 'package:flutter_money_book/notionDataManager.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter_money_book/editTransactionList.dart';
import 'package:flutter_money_book/config.dart';
import "package:flutter/services.dart";
import 'dart:developer' as developer;

class DailyTransactionList extends StatefulWidget {
  DateTime m_targetDate;

  DailyTransactionList(this.m_targetDate) : super();

  @override
  DailyTransactionState createState() =>
      DailyTransactionState(this.m_targetDate);
}

class DailyTransactionState extends State<DailyTransactionList> {
  DateTime m_targetDate;
  List<TransactionData> m_dailyData = [];
  int m_dailyIn = 0;
  int m_dailyOut = 0;
  int m_monthlyIn = 0;
  int m_monthlyOut = 0;
  int m_selectedData = -1;

  DailyTransactionState(this.m_targetDate);

  final TextStyle m_menuStyle = TextStyle(
      fontSize: MyApp.globalTextStyle.fontSize, backgroundColor: Colors.white);

  @override
  Widget build(BuildContext context) {
/*
    var dm=new NotionDataManager("v5gE6CAO6uLX0JsF9cvH7m8FcZtf72B4tj5qU33eC6A","dc23545cd7c74dd5a431f5f5cb8b7585");
     dm.getDBData().then((value) => print(value));
*/

    var size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
        appBar: AppBar(
          title: Text(
              "${m_targetDate.year}/${m_targetDate.month}/${m_targetDate.day}"),
        ),
        backgroundColor: Colors.white,
        drawer: Container(
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text("DAILY", style: MyApp.globalTextStyle),
                  onTap: () async {
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                ),
                ListTile(
                  title: Text("Set Date", style: MyApp.globalTextStyle),
                  onTap: () async {
                    final reqDate = await showDatePicker(
                        context: context,
                        initialDate: this.m_targetDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (null != reqDate) {
                      this.m_targetDate = DateTime(
                          reqDate.year,
                          reqDate.month,
                          reqDate.day,
                          this.m_targetDate.hour,
                          this.m_targetDate.minute);
                    }
                    setState(() {
                      Navigator.of(context).pop();
                      updateDailyList();
                    });
                  },
                ),
                ListTile(
                  title: Text("CONFIG", style: m_menuStyle),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return Config();
                    }));
                  },
                ),
                ListTile(
                  title: Text("END APP", style: m_menuStyle),
                  onTap: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    await SystemNavigator.pop();
                  },
                )
              ],
            ),
            color: Colors.white),
        body: Column(children: [
          FutureBuilder(
              future: updateDailyList(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TransactionData>> snapshot) {
                return Expanded(
                    child:

                    ListView.builder(
                        itemCount: this.m_dailyData.length + 2,
                        itemBuilder: (context, i) {
                          if (0 == i) {
                            return Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                    "Monthly spends IN:${MyApp.globalPriceFormatter.format(m_monthlyIn)} OUT:${MyApp.globalPriceFormatter.format(m_monthlyOut)}",
                                    style: MyApp.globalTextStyle));
                          } else if (1 == i) {
                            return Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                    "Daily spends IN:${MyApp.globalPriceFormatter.format(m_dailyIn)} OUT:${MyApp.globalPriceFormatter.format(m_dailyOut)}",
                                    style: MyApp.globalTextStyle));
                          } else {
                            return new RadioListTile(
                              activeColor: Colors.blue,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(this.m_dailyData[i - 2].toString(),
                                  style: MyApp.globalTextStyle),
                              value: i-2,
                              groupValue: this.m_selectedData,
                              onChanged: _handleDataSelect,
                            );
                          }
                        })
                );

              }),
          Row(children: [
            ElevatedButton(
              child: const Text('+'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.black,
                shape: const CircleBorder(
                  side: BorderSide(
                    color: Colors.black,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return EditTransactionList(this.m_targetDate, null);
                })).then((value) =>
                    setState(() {
                      if (null != value) {
                        this.m_targetDate = value;
                        developer.log("return date ${value.toString()}");
                      }
                    }));
              },
            ),
            ElevatedButton(
              child: const Text('-'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.black,
                shape: const CircleBorder(
                  side: BorderSide(
                    color: Colors.black,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              onPressed: () async {
                if (-1 != this.m_selectedData) {
                  final t = this.m_dailyData[this.m_selectedData];
                  await (await DataManagerFactory.getManager()).delete(t);
                  setState(() {});
                }
              },
            ),
            ElevatedButton(
              child: Icon(Icons.brush),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.black,
                shape: const CircleBorder(
                  side: BorderSide(
                    color: Colors.black,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              onPressed: () {
                if (-1 != m_selectedData) {
                  developer.log("Request index ${m_selectedData} data to edit");
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return EditTransactionList(this.m_targetDate,
                        this.m_dailyData[this.m_selectedData]);
                  })).then((value) =>
                      setState(() {
                        if (null != value) {
                          this.m_targetDate = value;
                          developer.log("return date ${value.toString()}");
                        }
                      }));
                }
              },
            )
          ])
        ]));
  }

  Future<List<TransactionData>> updateDailyList() async {
    await DataManagerFactory.getManager().init();
    var dManager = DataManagerFactory.getManager();
    final mBeginDate =
    DateTime(this.m_targetDate.year, this.m_targetDate.month, 1);
    var mEndDate = mBeginDate;
    if (12 == mEndDate.month) {
      mEndDate = DateTime(mEndDate.year + 1, 1, 1);
    } else {
      mEndDate = DateTime(mEndDate.year, mEndDate.month + 1, 1);
    }
    await dManager
        .getTransactionByDateRange(mBeginDate, mEndDate)
        .then((value) {
      m_monthlyIn = 0;
      m_monthlyOut = 0;
      for (var t in value) {
        if (0 < t.m_value) {
          m_monthlyIn += t.m_value;
        } else {
          m_monthlyOut += -t.m_value;
        }
      }
    });
    await dManager.getTransactionByDate(this.m_targetDate).then((value) {
      m_dailyIn = 0;
      m_dailyOut = 0;
      m_dailyData = value;
      for (var t in m_dailyData) {
        if (0 < t.m_value) {
          m_dailyIn += t.m_value;
        } else {
          m_dailyOut += -t.m_value;
        }
      }
    });

    m_dailyData.sort((a,b)=>a.m_transDate.compareTo(b.m_transDate));
    return this.m_dailyData;
  }

  void _handleDataSelect(int? d) {
    setState(() {
      m_selectedData = d ?? -1;
    });
  }

  @override
  void dispose() {
    DataManagerFactory.getManager().dispose();
    super.dispose();
  }
}
