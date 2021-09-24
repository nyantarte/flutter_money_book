import 'package:flutter/material.dart';
import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/main.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_money_book/editTransaction.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class EditTransactionList extends StatefulWidget {
  DateTime m_targetDate;
  List<TransactionData> m_targetData = [];

  EditTransactionList(this.m_targetDate, TransactionData? d) : super() {
    if (null != d) {
      m_targetData.add(d.clone());
    }
  }

  @override
  EditTransactionListState createState() =>
      EditTransactionListState(this.m_targetDate, this.m_targetData);
}

class EditTransactionListState extends State<EditTransactionList> {
  DateTime m_targetDate;
  List<TransactionData> m_targetData = [];
  int m_selectedData = -1;
  int m_totalValue=0;
  EditTransactionListState(this.m_targetDate, this.m_targetData) {
    if (0 < this.m_targetData.length) {
      this.m_targetDate = this.m_targetData[0].m_transDate;
    }

  }

  @override
  Widget build(BuildContext context) {
    _calcTotal();
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Date  ${(DateFormat("y/M/d")).format(this.m_targetDate)}",
                  style: MyApp.globalTextStyle, textAlign: TextAlign.left),
              ElevatedButton(
                child: const Text('Change'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                ),
                onPressed: () async {
                  var pickDate = await showDatePicker(
                      context: context,
                      initialDate: this.m_targetDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (null != pickDate) {
                    _setDate(pickDate);
                  }
                },
              )
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Time  ${(DateFormat.Hm()).format(this.m_targetDate)}",
                  style: MyApp.globalTextStyle, textAlign: TextAlign.left),
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
                  var tod = TimeOfDay(
                      hour: this.m_targetDate.hour,
                      minute: (this.m_targetDate.minute + 1) % 60);
                  _setTimeOfDay(tod);
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
                  var tod = TimeOfDay(
                      hour: this.m_targetDate.hour,
                      minute: (this.m_targetDate.minute + 59) % 60);
                  _setTimeOfDay(tod);
                },
              ),
              ElevatedButton(
                child: const Text('Change'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                ),
                onPressed: () async {
                  var pickTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: this.m_targetDate.hour,
                          minute: this.m_targetDate.minute));
                  if (null != pickTime) {
                    _setTimeOfDay(pickTime);
                  }
                },
              ),
            ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
              child: const Text('Set current date time'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
              ),
              onPressed: () async {
                final curDate=DateTime.now();
                _setDateAndTime(curDate);
              },
            )]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Total ${MyApp.globalPriceFormatter.format(m_totalValue)}",style:MyApp.globalTextStyle, textAlign: TextAlign.left)]),
            Expanded(
                child: ListView.builder(
                    itemCount: this.m_targetData.length,
                    itemBuilder: (context, i) {
                      return new RadioListTile(
                        activeColor: Colors.blue,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text("${this.m_targetData[i].toString()}",
                            style: MyApp.globalTextStyle),
                        value: i,
                        groupValue: m_selectedData,
                        onChanged: _handleDataSelect,
                      );
                    })),
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
                  this.m_selectedData = -1;
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return EditTransaction(TransactionData.create());
                  })).then((value) => setState(() {
                            if (value != null) {
                              value.m_transDate = this.m_targetDate;
                              m_targetData.add(value);
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
                    if ("" != this.m_targetData[this.m_selectedData].m_id) {
                      await DataManagerFactory.getManager()
                          .delete(this.m_targetData[this.m_selectedData]);
                    }
                    this.m_targetData.removeAt(this.m_selectedData);
                    this.m_selectedData = -1;

                    setState(() {


                    });
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
                  if (-1 != this.m_selectedData) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditTransaction(
                          this.m_targetData[this.m_selectedData]);
                    })).then((value) => setState(() {

                    }));
                  }
                },
              )
            ]),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('OK'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    for (var t in m_targetData) {
                      t.m_transDate = this.m_targetDate;
                      if (0 == t.m_id.length) {
                        t.m_id = Uuid().v1();

                        DataManagerFactory.getManager().insert(t);
                      } else {
                        DataManagerFactory.getManager().update(t);
                        print("A");
                      }
                    }
                    Navigator.of(context).pop(this.m_targetDate);
                  },
                ),
                ElevatedButton(
                  child: const Text('CANCEL'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        ));
  }

  void _setTimeOfDay(TimeOfDay tod) {
    setState(() {
      this.m_targetDate = DateTime(this.m_targetDate.year,
          this.m_targetDate.month, this.m_targetDate.day, tod.hour, tod.minute);
    });
  }

  void _setDate(DateTime nDate) {
    setState(() {
      this.m_targetDate = DateTime(nDate.year, nDate.month, nDate.day,
          this.m_targetDate.hour, this.m_targetDate.minute);

    });
  }
  void _setDateAndTime(DateTime tDate){
    setState((){
      this.m_targetDate=tDate;
    });
  }

  void _handleDataSelect(int? d) {
    setState(() {
      this.m_selectedData = d ?? -1;
    });
  }
  void _calcTotal(){
    m_totalValue=0;
    for(var t in m_targetData){
      m_totalValue+=t.m_value;
    }
  }
}
