import 'package:flutter/material.dart';
import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/main.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_money_book/editTransaction.dart';
import 'package:uuid/uuid.dart';
class EditTransactionList extends StatefulWidget {
  DateTime m_targetDate;
  List<TransactionData> m_targetData=[];
  EditTransactionList(this.m_targetDate,TransactionData? d) : super(){
    if(null!=d){
      m_targetData.add(d);
    }
  }

  @override
  EditTransactionListState createState() =>
      EditTransactionListState(this.m_targetDate,this.m_targetData);
}

class EditTransactionListState extends State<EditTransactionList> {
  DateTime m_targetDate;
  List<TransactionData> m_targetData = [];
  int m_selectedData=-1;

  EditTransactionListState(this.m_targetDate,this.m_targetData){
    if(0<this.m_targetData.length){
      this.m_targetDate=this.m_targetData[0].m_transDate;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Date  ${(DateFormat("y/M/d")).format(this.m_targetDate)}",
                  style:  MyApp.globalTextStyle,
                  textAlign: TextAlign.left),
              ElevatedButton(
                child: const Text('Change'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                ),
                onPressed: () {
                  showDatePicker(
                          context: context,
                          initialDate: this.m_targetDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100))
                      .then((value) => _setDate(value ?? DateTime.now()));
                },
              )
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Time  ${(DateFormat.Hm()).format(this.m_targetDate)}",
                  style:MyApp.globalTextStyle,
                  textAlign: TextAlign.left),
              ElevatedButton(
                child: const Text('Change'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                ),
                onPressed: () {
                  showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: this.m_targetDate.hour,
                              minute: this.m_targetDate.minute))
                      .then((value) => _setTimeOfDay(value ?? TimeOfDay.now()));
                },
              ),
            ]),
            Expanded(
                child: ListView.builder(
                    itemCount: this.m_targetData.length,
                    itemBuilder: (context, i) {
                      return new RadioListTile(
                        activeColor: Colors.blue,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text("${this.m_targetData[i].toString()}",style:MyApp.globalTextStyle),
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
                  this.m_selectedData=-1;
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return EditTransaction(TransactionData.create());
                  })).then((value) => setState(() {
                    if(value!=null) {
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
                onPressed: () async{
                  if(-1!=this.m_selectedData ){
                    if(""!=this.m_targetData[this.m_selectedData].m_id) {
                      await
                      DataManagerFactory.getManager().delete(this
                          .m_targetData[this.m_selectedData]);
                    }
                    this.m_targetData.removeAt(this.m_selectedData);
                    this.m_selectedData=-1;

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
                  if(-1!=this.m_selectedData){
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditTransaction(this.m_targetData[this.m_selectedData]);
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
                      if (0 == t.m_id.length) {
                        t.m_id=Uuid().v1();
                        t.m_transDate=this.m_targetDate;
                        DataManagerFactory.getManager().insert(t);
                      }else{
                        DataManagerFactory.getManager().update(t);
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

  void _setDate(DateTime date) {
    setState(() {
      this.m_targetDate = DateTime(date.year, date.minute, date.day,
          this.m_targetDate.hour, this.m_targetDate.minute);
    });
  }

  void _handleDataSelect(int? d) {
    setState(() {
      this.m_selectedData=d??-1;
    });
  }
}
