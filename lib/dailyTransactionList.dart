import 'package:flutter/material.dart';
import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/editTransactionList.dart';
import 'package:flutter_money_book/main.dart';
import 'package:flutter_money_book/notionDataManager.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter_money_book/editTransactionList.dart';
import 'package:flutter_money_book/config.dart';

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
  int m_selectedData = -1;

  DailyTransactionState(this.m_targetDate);

  @override
  Widget build(BuildContext context) {
/*
    var dm=new NotionDataManager("v5gE6CAO6uLX0JsF9cvH7m8FcZtf72B4tj5qU33eC6A","dc23545cd7c74dd5a431f5f5cb8b7585");
     dm.getDBData().then((value) => print(value));
*/

    var size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text("${m_targetDate.year}/${m_targetDate.month}/${m_targetDate.day}"),
        ),
        drawer: ListView(
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
              title: Text("Set Date"),
              onTap: () async {
                final reqDate = await showDatePicker(
                    context: context,
                    initialDate: this.m_targetDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100));
                if (null != reqDate) {
                  this.m_targetDate = reqDate;
                }
                setState(() {
                  Navigator.of(context).pop();
                  updateDailyList();
                });
              },
            ),
            ListTile(
              title: Text("CONFIG"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Config();
                }));
              },
            )
          ],
        ),
        body: Column(children: [
          Align(
              alignment: Alignment.topLeft,
              child: Text("Daily spends IN:${m_dailyIn} OUT:${m_dailyOut}",style: MyApp.globalTextStyle)),
          FutureBuilder(
              future: updateDailyList(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TransactionData>> snapshot) {
                return Expanded(
                    child: ListView.builder(
                        itemCount: this.m_dailyData.length,
                        itemBuilder: (context, i) {
                          return new RadioListTile(
                            activeColor: Colors.blue,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(this.m_dailyData[i].toString(),style: MyApp.globalTextStyle),
                            value: i,
                            groupValue: this.m_selectedData,
                            onChanged: _handleDataSelect,
                          );
                        }));
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
                  return EditTransactionList(this.m_targetDate,null);
                })).then((value) => setState(() {
                  if(null!=value) {
                    this.m_targetDate = value;
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
              onPressed: () async{
                if(-1!=this.m_selectedData) {
                  final t = this.m_dailyData[this.m_selectedData];
                  await DataManagerFactory.getManager().delete(t);
                  setState(() {

                  });
                }
              },
            ),
            ElevatedButton(
              child:  Icon(Icons.brush),
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
                if(-1!=m_selectedData) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return EditTransactionList(this.m_targetDate,
                        this.m_dailyData[this.m_selectedData]);
                  })).then((value) =>
                      setState(() {
                        this.m_targetDate = value;
                      }));
                }
              },
            )
          ])
        ]));
  }

  Future<List<TransactionData>> updateDailyList() async {
    var dManager = DataManagerFactory.getManager();

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

    return this.m_dailyData;
  }

  void _handleDataSelect(int? d) {
    setState(() {
      m_selectedData = d ?? -1;
    });
  }
  @override
  void dispose() {
    super.dispose();
    //SqliteDataManager.s_self.dispose();
    DataManagerFactory.getManager().dispose();
  }
}
