import 'package:flutter/material.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/main.dart';
import 'dart:developer' as developer;
import 'package:flutter_money_book/transactionListForm.dart';

class ReportData {
  var _curInValue = 0;
  var _curOutValue = 0;
  List<TransactionList> inList = [];
  List<TransactionList> outList = [];
}

class Report extends StatefulWidget {
  DateTime _beginCurMonth = DateTime.now(), _endCurMonth = DateTime.now();
  DateTime _beginPrevMonth = DateTime.now(), _endPrevMonth = DateTime.now();

  Report(DateTime targetDate) : super() {
    _calcDate(targetDate);
  }

  void _calcDate(DateTime d) {
    _beginCurMonth = DateTime(d.year, d.month, 1);
    if (12 == _beginCurMonth.month) {
      _endCurMonth = DateTime(_beginCurMonth.year + 1, 1, 1);
      _beginPrevMonth =
          DateTime(_beginCurMonth.year, _beginCurMonth.month - 1, 1);
      _endPrevMonth = _beginCurMonth;
    } else if (1 == _beginCurMonth.month) {
      _endCurMonth = DateTime(_beginCurMonth.year, _beginCurMonth.month + 1, 1);
      _beginPrevMonth = DateTime(_beginCurMonth.year - 1, 12, 1);
      _endPrevMonth = _beginCurMonth;
    } else {
      _endCurMonth = DateTime(_beginCurMonth.year, _beginCurMonth.month + 1, 1);
      _beginPrevMonth =
          DateTime(_beginCurMonth.year, _beginCurMonth.month - 1, 1);
      _endPrevMonth = _beginCurMonth;
    }
  }

  @override
  ReportState createState() => ReportState();
}

class ReportState extends State<Report> {
  ReportState();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: SingleChildScrollView(
            child:
              Column(children: [
                Row(children: [
                  ElevatedButton(
                    child: const Text('PREV'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      onPrimary: Colors.white,
                      ),
                  onPressed: () {
                    _showPrevMonth();
                  },
                ),
                ElevatedButton(
                  child: const Text('NEXT'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    _showNextMonth();
                  },
                )
                ]),
                FutureBuilder(
                  future: _calcMonthlyData(),
                  builder:
                    (BuildContext context, AsyncSnapshot<ReportData> snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Text(
                              "${MyApp.globalDateFormatter.format(this.widget._beginCurMonth)}-${MyApp.globalDateFormatter.format(this.widget._endCurMonth.add(Duration(days: -1)))}",
                              style: MyApp.globalTextStyle,
                            ),
                            Text(
                              "Income ${snapshot.data!._curInValue}",
                              style: MyApp.globalTextStyle,
                            ),
                            Text("Spends ${snapshot.data!._curOutValue}",
                              style: MyApp.globalTextStyle
                            ),
                            Text(
                              "Delta ${snapshot.data!._curInValue - snapshot.data!._curOutValue}",
                              style: MyApp.globalTextStyle,
                            ),
                            Text("Income items", style: MyApp.globalTextStyle),
                            ListView.builder(
                              itemCount: snapshot.data!.inList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                final tl = snapshot.data!.inList[i];
                                return ListTile(
                                    onTap:(){
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) {
                                    return TransactionListForm(
                                        tl);
                                  }));
                                },
                                title: Text("${tl.usage} ${tl.total.toString()}(${tl.substanceToPrevMonth})",
                                  style: MyApp.globalTextStyle));
                              }
                              ),
                            Text("Spend items", style: MyApp.globalTextStyle),
                            ListView.builder(
                              itemCount: snapshot.data!.outList.length,
                              shrinkWrap: true,

                                itemBuilder: (context, i) {
                                final tl = snapshot.data!.outList[i];
                                return ListTile(
                                    onTap:(){
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (context) {
                                        return TransactionListForm(
                                            tl);
                                      }));
                                    },
                                  title: Text("${tl.usage} ${tl.total.toString()}(${tl.substanceToPrevMonth})",
                                    style: MyApp.globalTextStyle));
                              }
                              ),
                        ],
                      );
                    } else {
                      return Text("");
                    }
                  })
        ])));
  }

  Future<ReportData> _calcMonthlyData() async {
    final dm = DataManagerFactory.getManager();
    var l = await dm.getTransactionByDateRange(
        this.widget._beginCurMonth, this.widget._endCurMonth);
    ReportData rd = ReportData();
    var inList = Map<String, TransactionList>();
    var outList = Map<String, TransactionList>();
    for (var t in l) {
      if (0 < t.m_value) {
        rd._curInValue += t.m_value;
        if (inList.containsKey(t.m_usage)) {
          inList[t.m_usage]!.total += t.m_value;
          inList[t.m_usage]!.list.add(t);
        } else {
          final tl = TransactionList();
          tl.usage = t.m_usage;
          tl.total = t.m_value;
          inList[t.m_usage] = tl;
          inList[t.m_usage]!.list.add(t);
        }
      } else {
        rd._curOutValue += -t.m_value;
        if (outList.containsKey(t.m_usage)) {
          outList[t.m_usage]!.total += t.m_value;
          outList[t.m_usage]!.list.add(t);
        } else {
          final tl = TransactionList();
          tl.usage = t.m_usage;

          tl.total = t.m_value;
          outList[t.m_usage] = tl;
          outList[t.m_usage]!.list.add(t);
        }
      }
    }

    var prevInList = Map<String, TransactionList>();
    var prevOutList = Map<String, TransactionList>();
    l = await dm.getTransactionByDateRange(
        this.widget._beginPrevMonth, this.widget._endPrevMonth);

    for (var t in l) {
      if (0 < t.m_value) {
        rd._curInValue += t.m_value;
        if (prevInList.containsKey(t.m_usage)) {
          prevInList[t.m_usage]!.total += t.m_value;
          prevInList[t.m_usage]!.list.add(t);
        } else {
          final tl = TransactionList();
          tl.usage = t.m_usage;
          tl.total = t.m_value;
          prevInList[t.m_usage] = tl;
          prevInList[t.m_usage]!.list.add(t);
        }
      } else {
        rd._curOutValue += -t.m_value;
        if (prevOutList.containsKey(t.m_usage)) {
          prevOutList[t.m_usage]!.total += t.m_value;
          prevOutList[t.m_usage]!.list.add(t);
        } else {
          final tl = TransactionList();
          tl.usage = t.m_usage;

          tl.total = t.m_value;
          prevOutList[t.m_usage] = tl;
          prevOutList[t.m_usage]!.list.add(t);
        }
      }
    }
    for(var k in inList.keys){
      if(prevInList.containsKey(k)){
        final curList=inList[k]!;
        final prevList=prevInList[k]!;
        curList.substanceToPrevMonth=prevList.total-curList.total;
      }
    }
    for(var k in outList.keys){
      if(prevOutList.containsKey(k)){
        final curList=outList[k]!;
        final prevList=prevOutList[k]!;
        curList.substanceToPrevMonth=prevList.total-curList.total;
      }
    }

    for (var v in inList.values) {
      v.list.sort((a,b)=>a.m_transDate.compareTo(b.m_transDate));
      rd.inList.add(v);
    }
    rd.inList.sort((a, b) => a.total - b.total);
    for (var v in outList.values) {
      v.list.sort((a,b)=>a.m_transDate.compareTo(b.m_transDate));
      rd.outList.add(v);
    }
    rd.outList.sort((a, b) => a.total - b.total);
    return rd;
  }

  void _showPrevMonth() {
    setState(() {
      var dt = this.widget._beginCurMonth;
      if (1 == dt.month) {
        dt = DateTime(dt.year - 1, 12, 1);
      } else {
        dt = DateTime(dt.year, dt.month - 1, 1);
      }
      this.widget._calcDate(dt);
    });
  }

  void _showNextMonth() {
    setState(() {
      var dt = this.widget._beginCurMonth;
      if (12 == dt.month) {
        dt = DateTime(dt.year + 1, 1, 1);
      } else {
        dt = DateTime(dt.year, dt.month + 1, 1);
      }
      this.widget._calcDate(dt);
    });
  }
}
